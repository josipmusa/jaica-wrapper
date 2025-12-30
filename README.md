# JAICA Wrapper

This repo is a thin “wrapper” around the **JAICA backend** and **JAICA frontend** projects.
It uses **git submodules** plus a single **Docker Compose** file so you can spin up the full stack (frontend + backend + dependencies) with a couple of commands.

If you want to contribute to the backend/frontend code, work inside the `backend/` and `frontend/` submodules.

## What you get

When you start the stack, Docker Compose runs:

- `jaica-frontend` (built from `./frontend` submodule)
- `jaica-backend` (built from `./backend` submodule)
- `jaica-neo4j` (Neo4j 5)
- `jaica-chromadb` (ChromaDB)

### Default URLs / ports

- Frontend: http://localhost:3000
- Backend API: http://localhost:8000
  - Health/status: `GET http://localhost:8000/api/status`
- Neo4j Browser: http://localhost:7474
  - Bolt: `bolt://localhost:7687`
- ChromaDB: http://localhost:8001 (host port → container port `8000`)

## Prerequisites

- **Docker** + **Docker Compose v2**
- **git** (for submodules)
- Free ports: `3000`, `8000`, `7474`, `7687`, `8001`

## Quickstart (recommended)

```bash
./scripts/setup.sh
./scripts/start.sh
```

Then open the frontend at http://localhost:3000.

## Helper scripts

- `./scripts/setup.sh`
  - Checks prerequisites
  - Initializes git submodules
  - Creates a `.env` file from `.env.example` if present (optional)

- `./scripts/start.sh`
  - Runs `docker compose up -d --build`
  - Waits for the backend health endpoint (`/api/status`) to respond

- `./scripts/stop.sh`
  - Runs `docker compose down`
  - Add `--volumes` to wipe persistent data

- `./scripts/logs.sh`
  - Tails logs (all services by default, or a single service)

## Manual usage (no scripts)

Initialize submodules (first run only):

```bash
git submodule update --init --recursive
```

Start:

```bash
docker compose up -d --build
```

Stop:

```bash
docker compose down
```

## Configuration

This wrapper currently wires configuration directly in `docker-compose.yml`.
If you want to change any of these, edit `docker-compose.yml` (simple + explicit), or extend it with a `.env` file and variable substitution.

### Backend environment

- `NEO4J_URI=bolt://jaica-neo4j:7687`
- `NEO4J_USERNAME=neo4j`
- `NEO4J_PASSWORD=qwerty`
- `CHROMA_HOST=jaica-chromadb`
- `CHROMA_PORT=8000`
- `OLLAMA_HOST=http://host.docker.internal:11434`

### Frontend build arg

- `VITE_API_URL=http://localhost:8000`

## Optional: Ollama

The backend is configured to talk to an Ollama instance at:

- `http://host.docker.internal:11434`

If you don’t have Ollama running, features that require it may fail.


## Data persistence / reset

Neo4j and ChromaDB use Docker named volumes, so your data survives container restarts.

To reset everything:

```bash
./scripts/stop.sh --volumes
```

This removes named volumes:

- `chroma_data`
- `neo4j_data`, `neo4j_logs`, `neo4j_import`, `neo4j_plugins`

## Troubleshooting

### Submodule content missing

If `./backend` or `./frontend` is empty:

```bash
git submodule update --init --recursive
```

### Backend unhealthy (compose waits forever)

The backend container is considered healthy only when:

- `http://localhost:8000/api/status` responds successfully **inside the container** (Compose healthcheck).

Common reasons:

- The backend code in the `backend` submodule changed its status endpoint
- Neo4j password mismatch (wrapper defaults to `qwerty`)
- Neo4j is still starting (wait a bit; it has its own healthcheck)

To inspect logs:

```bash
./scripts/logs.sh jaica-backend
```

### Port already in use

If `docker compose up` fails with “port is already allocated”, either stop the service using that port or change the port mapping in `docker-compose.yml`.
