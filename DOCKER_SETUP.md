# HRMS Docker Deployment Guide

This document outlines the custom Docker setup implemented for local development and deployment of the HRMS project.

## Architecture Overview
The setup uses a multi-container architecture via `docker-compose`:
- **frappe-app**: The main container running Frappe Bench, ERPNext, and HRMS.
- **mariadb**: Database server for Frappe.
- **redis-cache/queue/socketio**: Performance and messaging layers.

## Key Components

### 1. `docker-compose.yml`
Located in the root, it defines the services.
- **Image**: `frappe/bench:latest`
- **Volumes**: Maps the local project folder to `/workspace` inside the container.
- **Ports**: Exposes port `8000` for the web UI.

### 2. `docker/init.sh`
A robust bootstrap script that:
- Waits for MariaDB to be healthy.
- Initializes the Frappe Bench environment.
- Installs **ERPNext** (required dependency).
- Links/Copies the local **HRMS** app into the bench.
- Creates the default site `hrms.localhost`.
- Configures Redis and Database hosts automatically.

## How to Run

### First Time Setup
1. Ensure Docker is installed.
2. Run the start command:
   ```bash
   ./docker-compose-bin up -d
   ```
3. Wait for the initialization (check logs: `./docker-compose-bin logs -f frappe`).
4. Once you see "Starting Bench...", the system is ready.

### Building Assets
If you face "NoneType" or "CSS/JS missing" errors, run the build command:
```bash
docker exec -it frappe-app bench build
```

## Accessing the System
- **URL**: [http://localhost:8000](http://localhost:8000)
- **Administrator Username**: `Administrator`
- **Administrator Password**: `admin`

## Maintenance
- **Restart Services**: `./docker-compose-bin restart`
- **Stop Services**: `./docker-compose-bin stop`
- **View Logs**: `./docker-compose-bin logs -f`
- **Enter Container**: `docker exec -it frappe-app bash`

## Troubleshooting
- **Port 8000 404 Error**: Ensure the site `hrms.localhost` is set as default (`bench use hrms.localhost`).
- **ModuleNotFoundError**: Ensure the app is installed in the bench venv (`pip install -e apps/hrms`).
