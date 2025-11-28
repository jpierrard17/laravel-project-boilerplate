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
# Resolve .env path relative to the script location (.context/scripts/setup-ports.sh -> ../src/.env)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$SCRIPT_DIR/../src/.env"

if [ -f "$ENV_FILE" ]; then
    # Function to update or append env var
    update_env() {
        local key=$1
        local value=$2
        if grep -q "^$key=" .env; then
            sed -i '' "s/^$key=.*/$key=$value/" .env
        else
            echo "$key=$value" >> .env
        fi
    }

    update_env "APP_PORT" "$APP_PORT"
    update_env "VITE_PORT" "$VITE_PORT"
    update_env "FORWARD_DB_PORT" "$FORWARD_DB_PORT"
    update_env "FORWARD_REDIS_PORT" "$FORWARD_REDIS_PORT"
    update_env "FORWARD_MAILPIT_PORT" "$FORWARD_MAILPIT_PORT"
    update_env "FORWARD_MAILPIT_DASHBOARD_PORT" "$FORWARD_MAILPIT_DASHBOARD_PORT"

    echo "Ports updated in .env"
else
    echo ".env file not found! Please copy .env.example to .env first."
fi
