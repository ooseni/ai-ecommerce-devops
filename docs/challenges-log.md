# Challenges log

Problems met while building the platform, how each was diagnosed and fixed, and the lesson kept. Screenshots live in [evidence/](evidence/).

| # | Date | Milestone | Challenge |
|---|------------|----|------------------------------------------------|
| 1 | 2026-10-23 | M0 | Trivy package not found |
| 2 | 2026-10-25 | M0 | Banner images blocked by the large-file guard |
| 3 | 2026-10-25 | M1 | 227 known vulnerabilities in upstream packages |
| 4 | 2026-10-26 | M1 | MongoDB down after a WSL restart |

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
- **Lesson:** ECONNREFUSED means nothing is listening on that port. Follow-up: make `scripts/setup.sh` start the container when it is down.
