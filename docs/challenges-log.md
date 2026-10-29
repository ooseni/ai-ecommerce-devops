# Challenges log

Problems met while building the platform, how each was diagnosed and fixed, and the lesson kept. Screenshots live in [evidence/](evidence/).

| # | Date | Milestone | Challenge |
|---|------------|----|------------------------------------------------|
| 1 | 2026-10-23 | M0 | Trivy package not found |
| 2 | 2026-10-25 | M0 | Banner images blocked by the large-file guard |
| 3 | 2026-10-25 | M1 | 227 known vulnerabilities in upstream packages |
| 4 | 2026-10-26 | M1 | MongoDB down after a WSL restart |
| 5 | 2026-10-27 | M1 | Health check reported MongoDB down while it was up |
| 6 | 2026-10-27 | M1 | VS Code split two .gitignore patterns on save |
| 7 | 2026-10-28 | M2 | API image crashed: Cannot find module 'chalk' |
| 8 | 2026-10-28 | M2 | Containerised API could not reach MongoDB on 127.0.0.1 |
| 9 | 2026-10-29 | M2 | Compose rejected compose.yaml |
| 10 | 2026-10-29 | M2 | Support chat cannot connect at localhost:8080 |

## 1. Trivy package not found (M0)

- **Symptom:** `sudo apt install trivy` failed with `Unable to locate package trivy`.
- **Cause:** the line that registers Trivy's apt repository in `/etc/apt/sources.list.d/trivy.list` had been skipped, so apt never knew the package existed.
- **Fix:** added the repository line (signed by the key in `/etc/apt/keyrings/trivy.gpg`), ran `sudo apt update`, then installed Trivy 0.76.1.
- **Lesson:** "Unable to locate package" means apt's package list lacks it. Check the sources list first.

## 2. Banner images blocked by the large-file guard (M0)

- **Symptom:** the `check-added-large-files` pre-commit hook (1 MB limit) rejected the import.
- **Cause:** four upstream homepage banners totalled 11.5 MB.
- **Fix:** resized them to 1920 px wide with ImageMagick (`magick -resize '1920x>' -strip -quality 82`), from 11.5 MB down to 1.1 MB, about 90% smaller.
- **Lesson:** guards set up on day one catch problems before they enter git history.

## 3. 227 known vulnerabilities in upstream packages (M1)

- **Symptom:** `npm ci` reported 77 vulnerabilities in `server/` (11 critical, 43 high) and 150 in `client/` (18 critical, 59 high).
- **Cause:** the shop's dependencies were pinned years ago and never upgraded.
- **Decision:** did not run `npm audit fix --force`, which jumps major versions and can break the app. Scanning and triage move into the M3 pipeline (npm audit and Trivy stages).
- **Lesson:** record the baseline first, so later scans show whether the numbers go down.

## 4. MongoDB down after a WSL restart (M1)

- **Symptom:** the seed script failed with `MongooseServerSelectionError: connect ECONNREFUSED 127.0.0.1:27017`.
- **Diagnosis:** `docker exec` answered `container … is not running`. `docker ps -a` showed `mongo-dev` as `Exited (255)`: WSL had restarted overnight, and the container had no restart policy.
- **Fix:** `docker start mongo-dev`. The data was safe in the `mongo-dev-data` volume.
- **Lesson:** ECONNREFUSED means nothing is listening on that port. Follow-up, done: `scripts/setup.sh` now starts the container, or creates it, when it is down.

## 5. Health check reported MongoDB down while it was up (M1)

- **Symptom:** `scripts/health-check.sh` printed `FAIL  MongoDB` although the API was connected to the database and serving products.
- **Diagnosis:** the check ran `docker exec mongo-dev mongo --eval ...` with `2>/dev/null`, which hid the real error. Run without the redirect, it printed `exec: "mongo": executable file not found in $PATH`: the legacy `mongo` shell was removed in MongoDB 6.0, and the `mongo:7.0` image ships only `mongosh`.
- **Fix:** `docker exec mongo-dev mongosh --quiet --eval 'db.runCommand({ ping: 1 }).ok'`, which prints `1` when the server answers.
- **Lesson:** a check that can never pass is as useless as one that never fails. Prove both outcomes, and when a check fails, run its command without `2>/dev/null` to see why.

## 6. VS Code split two .gitignore patterns on save (M1)

- **Symptom:** `git diff .gitignore` showed changes on lines nobody had edited: `Icon[\r]` and `.HFS+ Private Directory Data[\r]` were each split over two lines.
- **Cause:** GitHub's macOS template puts a literal carriage return inside the brackets, because macOS stores custom folder icons in a file named `Icon` plus a carriage return. VS Code treats a lone carriage return as a line break and saved it as a newline, so both patterns stopped matching.
- **Fix:** `git restore .gitignore`, then added the new lines with `sed -i '/^anchor$/a ...'`, which leaves the other bytes alone. `grep -c $'\r' .gitignore` must print `2`.
- **Lesson:** read `git diff` before every `git add`: it shows what the tools changed, not only what you typed. Edit `.gitignore` with `sed`, not VS Code.

## 7. API image crashed: Cannot find module 'chalk' (M2)

- **Symptom:** the first run of the API image exited at once with `Error: Cannot find module 'chalk'` at `index.js:3`.
- **Cause:** upstream lists `chalk` under `devDependencies`, but `index.js`, `utils/db.js` and `utils/seed.js` load it at runtime. The image installs with `npm ci --omit=dev`, which rightly leaves dev packages out. It never showed natively because `setup.sh` runs a full `npm ci`.
- **Fix:** `npm install --save-prod chalk@2.4.2` in `application/server`, which moves it to `dependencies`; the lockfile only loses its `"dev": true` flags. `--omit=dev` stays, so nodemon and other dev tools stay out of production.
- **Lesson:** read the error literally. A missing module is a packaging fault, not a database or network one.

## 8. Containerised API could not reach MongoDB on 127.0.0.1 (M2)

- **Symptom:** the API container, started with the local `.env`, served requests but readiness stayed `503`, with `ECONNREFUSED 127.0.0.1:27017` after 30 seconds.
- **Cause:** the local `.env` points `MONGO_URI` at `127.0.0.1`. Inside a container, `127.0.0.1` is the container itself, not the WSL host, and nothing listens on 27017 there.
- **Fix:** Compose puts the three services on one private network, where each service name is a DNS name, and sets `MONGO_URI` to `mongodb://mongo:27017/mern_ecommerce` under `environment:`, which wins over the same key in `env_file:`. Readiness through Nginx then reported `db: connected`.
- **Lesson:** `localhost` in a container means that container. Containers find each other by service name.

## 9. Compose rejected compose.yaml (M2)

- **Symptom:** `docker compose config --quiet` failed with `additional properties 'client', 'server' not allowed`.
- **Cause:** the `server:` and `client:` blocks were typed at column 0, which made them top-level keys beside `services:` instead of services inside it.
- **Fix:** indented both blocks two spaces under `services:`. The file validated and the stack started.
- **Lesson:** in YAML, indentation is the structure. Validate with `docker compose config --quiet` before starting anything; without `--quiet` it prints the resolved file, `.env` secrets included.

## 10. Support chat cannot connect at localhost:8080 (M2)

- **Symptom:** opened at `http://localhost:8080`, the shop sends its socket.io connection to `127.0.0.1:3000`, which refuses it (`curl` exit 7). Through Nginx at `http://127.0.0.1:8080/socket.io/` the handshake succeeds and offers the WebSocket upgrade.
- **Cause:** `application/client/app/constants/index.js` sends the socket to `http://127.0.0.1:3000` whenever the host name contains `localhost`, a shortcut for the native setup. The container stack publishes only Nginx, so port 3000 is unreachable. The socket opens only for a signed-in user.
- **Fix (for now):** browse the container stack at `http://127.0.0.1:8080`. The lasting fix, always using the page's own address, is planned with the other upstream changes.
- **Lesson:** front-end code runs in the user's browser, outside the Docker network, so every address it uses must be one the browser can reach.
