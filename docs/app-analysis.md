# Application analysis: MERN Store

What the platform has to build, run and watch, based on upstream commit
`7f73dfb` and a local run on 2026-10-26.

## Overview

| Part | Technology |
|---|---|
| Front end | React 16 and Redux, bundled by webpack 4 (`client/`) |
| Back end | Node.js and Express 4 REST API, plus Socket.IO (`server/`) |
| Database | MongoDB, through Mongoose 5.9 |
| Run here | Node 24 LTS on WSL2, MongoDB 7.0 in Docker |

## How the pieces talk

```text
Browser --> :8080  client (webpack dev server now, Nginx from M2)
               |  REST calls to API_URL, plus a Socket.IO connection
               v
            :3000  server (Express, every route under /api) --> :27017 MongoDB
```

## Configuration

The server reads `server/.env` and the client reads `client/.env`. Both files
are git-ignored; the committed `.env.example` files are the templates.

| Variable | Needed | Purpose |
|---|---|---|
| `MONGO_URI` | yes | MongoDB connection string |
| `JWT_SECRET` | yes | signs login tokens (64 random hex characters) |
| `BASE_API_URL` | yes | API path prefix, `api` |
| `PORT` | default 3000 | API port |
| `API_URL` (client) | yes | where the browser sends API calls |
| `CLIENT_URL` | OAuth only | redirect target after Google or Facebook login |
| `MAILGUN_*`, `MAILCHIMP_*` | no | email and newsletter, off when empty |
| `GOOGLE_*`, `FACEBOOK_*` | no | social login, off when empty |
| `AWS_*` | no | product image upload to S3, off when empty |

## API

73 route handlers in 13 groups under `/api` (`server/routes/api/`). Logged-in
calls send a JWT as `Authorization: Bearer <token>`; management routes also
check the role (`Admin`, `Merchant` or `Member`).

| Group | What it does | Login |
|---|---|---|
| `/auth` | login, register, password reset, social login | mostly no |
| `/product` | list, search, item by slug; add, edit, delete | browse no, manage yes |
| `/category`, `/brand` | list; add, edit | browse no, manage yes |
| `/cart`, `/order`, `/wishlist`, `/address`, `/user` | shopping and account | yes |
| `/review` | read, post, approve | post yes |
| `/merchant` | merchant sign-up and approval | mostly yes |
| `/contact`, `/newsletter` | forms | no |

Unknown `/api/*` paths return `404 "No API route found"`. There is no health
endpoint.

## Data

Database `mern_ecommerce` with 11 Mongoose models (`server/models/`): address,
brand, cart, category, contact, merchant, order, product, review, user,
wishlist. `npm run seed:db -- <email> <password>` creates 1 admin,
10 categories, 10 brands and 100 Faker products, and skips whatever already
exists, so it is safe to run again.

## Findings for the platform

| Finding | Risk | Handled in |
|---|---|---|
| No health endpoint | probes can't tell when the API is ready | M2 adds `/api/health`; M4 probes use it |
| No automated tests | a broken build can ship | M2 smoke test, M3 test stage |
| Upstream Dockerfiles: Node 16 (end of life), root user, `npm install` | outdated, over-privileged, unrepeatable images | M2 multi-stage, non-root images with `npm ci` |
| Upstream Compose: `mongo:latest`, port 27017 on all interfaces, placeholder JWT secret | drift, exposed database, weak secret | M2 Compose rewrite |
| 227 known vulnerabilities in dependencies | exploitable packages | M3 npm audit and Trivy stages |
| Support chat keeps online users in server memory (`socket/support.js`) | a second API replica would not see them | one replica for now; noted for scaling |
| Product images upload to S3 only when AWS keys are set | uploaded images are dropped without an error | out of scope; seed products have no images |
