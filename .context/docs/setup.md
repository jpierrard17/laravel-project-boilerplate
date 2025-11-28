# Docker Setup & Port Management

This project uses **Laravel Sail** for a Dockerized development environment. To run multiple projects simultaneously without port conflicts, we use dynamic port assignment in the `.env` file.

## Dynamic Port Assignment

Instead of hardcoding ports, use the following script to find available ports and update your `.env` file automatically before starting Sail.

### Setup Script (`.agent/setup-ports.sh`)

The project includes a `setup-ports.sh` script in the `.agent` directory. This script automatically finds available ports and updates your `.env` file.

**Script Logic:**

```bash
#!/bin/bash

# Function to find a free port starting from a base port
find_free_port() {
    local port=$1
    while lsof -i:$port >/dev/null; do
        ((port++))
    done
    echo $port
}

# Base ports
BASE_APP_PORT=8000
BASE_VITE_PORT=5173
BASE_DB_PORT=3306
BASE_REDIS_PORT=6379
BASE_MAILPIT_PORT=1025
BASE_MAILPIT_DASH_PORT=8025

# Find free ports
APP_PORT=$(find_free_port $BASE_APP_PORT)
VITE_PORT=$(find_free_port $BASE_VITE_PORT)
FORWARD_DB_PORT=$(find_free_port $BASE_DB_PORT)
FORWARD_REDIS_PORT=$(find_free_port $BASE_REDIS_PORT)
FORWARD_MAILPIT_PORT=$(find_free_port $BASE_MAILPIT_PORT)
FORWARD_MAILPIT_DASHBOARD_PORT=$(find_free_port $BASE_MAILPIT_DASH_PORT)

echo "Configuring ports..."
echo "APP_PORT: $APP_PORT"
echo "VITE_PORT: $VITE_PORT"
echo "FORWARD_DB_PORT: $FORWARD_DB_PORT"
echo "FORWARD_REDIS_PORT: $FORWARD_REDIS_PORT"
echo "FORWARD_MAILPIT_PORT: $FORWARD_MAILPIT_PORT"
echo "FORWARD_MAILPIT_DASHBOARD_PORT: $FORWARD_MAILPIT_DASHBOARD_PORT"

# Update .env file
# Ensure these keys exist in your .env or append them
sed -i '' "s/^APP_PORT=.*/APP_PORT=$APP_PORT/" .env || echo "APP_PORT=$APP_PORT" >> .env
sed -i '' "s/^VITE_PORT=.*/VITE_PORT=$VITE_PORT/" .env || echo "VITE_PORT=$VITE_PORT" >> .env
sed -i '' "s/^FORWARD_DB_PORT=.*/FORWARD_DB_PORT=$FORWARD_DB_PORT/" .env || echo "FORWARD_DB_PORT=$FORWARD_DB_PORT" >> .env
sed -i '' "s/^FORWARD_REDIS_PORT=.*/FORWARD_REDIS_PORT=$FORWARD_REDIS_PORT/" .env || echo "FORWARD_REDIS_PORT=$FORWARD_REDIS_PORT" >> .env
sed -i '' "s/^FORWARD_MAILPIT_PORT=.*/FORWARD_MAILPIT_PORT=$FORWARD_MAILPIT_PORT/" .env || echo "FORWARD_MAILPIT_PORT=$FORWARD_MAILPIT_PORT" >> .env
sed -i '' "s/^FORWARD_MAILPIT_DASHBOARD_PORT=.*/FORWARD_MAILPIT_DASHBOARD_PORT=$FORWARD_MAILPIT_DASHBOARD_PORT/" .env || echo "FORWARD_MAILPIT_DASHBOARD_PORT=$FORWARD_MAILPIT_DASHBOARD_PORT" >> .env

echo "Ports updated in .env"
```

# Project Setup

This is a **Generator Repository**. It does not contain the application code by default. You must hydrate the project using the initialization script.

## 1. Initialize Project
This command will fetch the **latest** version of Laravel and configure the Modular Monolith architecture.

```bash
./.context/scripts/init.sh

### Usage

1.  **Make executable**: `chmod +x .context/scripts/setup-ports.sh`
2.  **Run before starting Sail** (from project root):
    ```bash
    ./.context/scripts/setup-ports.sh
    cd src && ./vendor/bin/sail up -d
    ```

## Standard Sail Commands

- **Start**: `./vendor/bin/sail up -d`
- **Stop**: `./vendor/bin/sail down`
- **Restart**: `./vendor/bin/sail restart`
- **Shell**: `./vendor/bin/sail shell`
- **Artisan**: `./vendor/bin/sail artisan ...`
- **Composer**: `./vendor/bin/sail composer ...`
- **NPM**: `./vendor/bin/sail npm ...`

## Troubleshooting

- **Port Conflicts**: If Sail fails to start due to "address already in use", run `./setup-ports.sh` again to find new free ports.
- **Database Connection**: Ensure your GUI client (TablePlus, Sequel Ace) uses the `FORWARD_DB_PORT` assigned in `.env`.
