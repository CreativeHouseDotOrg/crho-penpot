# crho-penpot

Fork of Penpot 2.19.1 with multi-file MCP support (backported from `develop`):
global plugins, `penpotMgmt` (list projects/files, `openFile`), and per-tab MCP sessions
(`sessionId` on every tool). Branch: `crho-2.19.1`.

## What differs from upstream 2.19.1
13 cherry-picked upstream commits (PR #12169 series + "Allow MCP to work with multiple files in
parallel", #11927), plus two repair commits for merge damage (`VersionCompatibility` imports in
`mcp/packages/plugin/src/plugin.ts`, `:as errors` in `frontend/src/app/main.cljs`), plus
`docker/images/Dockerfile.crho-*` which build on public nginx/node images (the official ones need a
`dhi.io` login). Backend, exporter and admin console are the official 2.19.1 images.

## Run / rebuild
1. `cp deploy/crho-penpot/.env.example ~/repos/crho-penpot/.env` and fill in the secrets.
2. `deploy/crho-penpot/rebuild.sh` (first run builds the 7 GB devenv pull + bundles; later runs are faster).
3. UI at http://localhost:9101, Mailpit at http://localhost:8125.

The data lives in the Docker volumes `crho-penpot_crho_postgres_v15` and `crho-penpot_crho_assets`
(not in this repo). Back them up before upgrading.

## Known risk
The official 2.19.1 backend does not know the new plugin permissions (`allow:global`,
`manage:*`) or the `scope` field. If saving plugin settings fails, build the backend from this
branch too (`./manage.sh build-backend-bundle`).
