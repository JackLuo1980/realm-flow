# RealmFlow

RealmFlow is a from-scratch rebuild of the FLVX-style control panel.

Current focus:
- Recreate the FLVX feature set and UI structure
- Use a Go backend with GORM
- Use a React + TypeScript frontend
- Keep development notes synchronized in Obsidian

Repository layout:
- `go-backend/` Go API and domain model
- `vite-frontend/` React UI shell
- `01-项目概述/`, `02-架构设计/`, `03-功能模块/`, `04-开发日志/`, `05-部署运维/` project notes
- `docker-compose.yml` Docker deployment for separated backend/frontend containers

Development notes:
- The project is being rebuilt from scratch.
- Local testing is intentionally deferred to the target test server workflow described in Obsidian.

## Backend

```bash
cd go-backend
go test ./...
go run ./cmd/paneld
```

## Frontend

```bash
cd vite-frontend
npm install
npm run dev
```

## Docker deployment

```bash
docker compose -f docker-compose.yml -f docker-compose.test.yml up -d --build
```

The base compose file defines the backend and frontend services. The test override publishes them on `16365` and `16366`.
