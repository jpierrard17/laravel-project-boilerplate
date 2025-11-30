#!/bin/bash

# Exit on error
set -e

echo "🚀 Starting Dynamic Boilerplate Initialization..."

# 1. Install Latest Laravel
if [ -f "src/composer.json" ]; then
    echo "⚠️  Laravel detected in 'src'. Skipping download."
else
    echo "📦 Downloading latest Laravel into 'src'..."
    
    # CRITICAL FIX: Destroy old volumes (-v) if a previous install exists
    # This prevents 'Unknown database' errors caused by stale MySQL data
    if [ -d "src" ]; then
        if [ -f "src/vendor/bin/sail" ]; then
            echo "🧹 Destroying old Docker volumes..."
            (cd src && ./vendor/bin/sail down -v) || true
        fi
        rm -rf src
    fi

    # Use /tmp for cache to avoid permission warnings
    docker run --rm \
        -u "$(id -u):$(id -g)" \
        -v $(pwd):/var/www/html \
        -w /var/www/html \
        -e COMPOSER_CACHE_DIR=/tmp/composer_cache \
        laravelsail/php83-composer:latest \
        composer create-project laravel/laravel src
fi

# 2. Generate docker-compose.yml (Manually)
if [ ! -f "src/docker-compose.yml" ]; then
    echo "⛵ Writing docker-compose.yml..."
cat <<EOF > src/docker-compose.yml
services:
    laravel.test:
        build:
            context: ./vendor/laravel/sail/runtimes/8.4
            dockerfile: Dockerfile
            args:
                WWWGROUP: '\${WWWGROUP}'
        image: sail-8.4/app
        extra_hosts:
            - 'host.docker.internal:host-gateway'
        ports:
            - '\${APP_PORT:-80}:80'
            - '\${VITE_PORT:-5173}:\${VITE_PORT:-5173}'
        environment:
            WWWUSER: '\${WWWUSER}'
            LARAVEL_SAIL: 1
            XDEBUG_MODE: '\${SAIL_XDEBUG_MODE:-off}'
            XDEBUG_CONFIG: '\${SAIL_XDEBUG_CONFIG:-client_host=host.docker.internal}'
            IGNITION_LOCAL_SITES_PATH: '\${PWD}'
        volumes:
            - '.:/var/www/html'
        networks:
            - sail
        depends_on:
            - mysql
            - redis
            - mailpit
    mysql:
        image: 'mysql/mysql-server:8.0'
        ports:
            - '\${FORWARD_DB_PORT:-3306}:3306'
        environment:
            MYSQL_ROOT_PASSWORD: '\${DB_PASSWORD}'
            MYSQL_ROOT_HOST: '%'
            MYSQL_DATABASE: '\${DB_DATABASE}'
            MYSQL_USER: '\${DB_USERNAME}'
            MYSQL_PASSWORD: '\${DB_PASSWORD}'
            MYSQL_ALLOW_EMPTY_PASSWORD: 1
        volumes:
            - 'sail-mysql:/var/lib/mysql'
            - './vendor/laravel/sail/database/mysql/create-testing-database.sh:/docker-entrypoint-initdb.d/10-create-testing-database.sh'
        networks:
            - sail
        healthcheck:
            test: ["CMD", "mysqladmin", "ping", "-p\${DB_PASSWORD}"]
            retries: 3
            timeout: 5s
    redis:
        image: 'redis:alpine'
        ports:
            - '\${FORWARD_REDIS_PORT:-6379}:6379'
        volumes:
            - 'sail-redis:/data'
        networks:
            - sail
        healthcheck:
            test: ["CMD", "redis-cli", "ping"]
            retries: 3
            timeout: 5s
    mailpit:
        image: 'axllent/mailpit:latest'
        ports:
            - '\${FORWARD_MAILPIT_PORT:-1025}:1025'
            - '\${FORWARD_MAILPIT_DASHBOARD_PORT:-8025}:8025'
        networks:
            - sail
networks:
    sail:
        driver: bridge
volumes:
    sail-mysql:
        driver: local
    sail-redis:
        driver: local
EOF
fi

# 3. Configure Ports
echo "🔌 Configuring Ports..."
if [ -f ".context/scripts/setup-ports.sh" ]; then
    ./.context/scripts/setup-ports.sh
else
    echo "❌ Error: Port setup script not found!"
    exit 1
fi

# 4. Patch .env for MySQL (Moved Up for Safety)
echo "🔧 Configuring Environment for MySQL..."
if [ -f "src/.env" ]; then
    # Switch connection
    sed -i '' 's/DB_CONNECTION=sqlite/DB_CONNECTION=mysql/' src/.env
    # Uncomment and set defaults
    sed -i '' 's/# DB_HOST=127.0.0.1/DB_HOST=mysql/' src/.env
    sed -i '' 's/# DB_PORT=3306/DB_PORT=3306/' src/.env
    sed -i '' 's/# DB_DATABASE=laravel/DB_DATABASE=laravel/' src/.env
    sed -i '' 's/# DB_USERNAME=root/DB_USERNAME=sail/' src/.env
    sed -i '' 's/# DB_PASSWORD=/DB_PASSWORD=password/' src/.env
fi

# 5. Setup Directory Structure
echo "🏗️  Creating app/Modules directory..."
mkdir -p src/app/Modules

# 6. Start Sail
echo "🐳 Starting Docker Environment..."
cd src

if [ ! -f "docker-compose.yml" ]; then
    echo "❌ Error: docker-compose.yml failed to generate."
    exit 1
fi

# Load .env variables to suppress Docker warnings
set -a
[ -f .env ] && . .env
set +a

./vendor/bin/sail up -d

# 7. Install & Configure nwidart/laravel-modules
echo "📦 Installing Modular Architecture Package..."

# FIX: Pre-authorize the merge plugin to prevent interactive prompt
./vendor/bin/sail composer config allow-plugins.wikimedia/composer-merge-plugin true

./vendor/bin/sail composer require nwidart/laravel-modules
./vendor/bin/sail artisan vendor:publish --provider="Nwidart\Modules\LaravelModulesServiceProvider"

# 8. Inject Custom Configuration
echo "⚙️  Applying Custom Module Configuration..."
if [ -f "../.context/stubs/modules.php.stub" ]; then
    cp ../.context/stubs/modules.php.stub config/modules.php
else
    echo "❌ Error: .context/stubs/modules.php.stub not found!"
    exit 1
fi

# 9. Update Composer Autoload for PSR-4
echo "🎼 Updating Composer Autoload..."
python3 -c "import sys, json; data=json.load(open('composer.json')); data['autoload']['psr-4']['App\\\\Modules\\\\'] = 'app/Modules/'; json.dump(data, open('composer.json', 'w'), indent=4)"

# Regenerate autoload files
./vendor/bin/sail composer dump-autoload

# 10. Install Tech Stack (Jetstream + Inertia)
echo "🎨 Installing Jetstream & Inertia (Vue)..."
./vendor/bin/sail composer require laravel/jetstream

# Note: We add '|| true' because Jetstream tries to run 'npm install' which might fail due to Vite 7 conflicts.
./vendor/bin/sail artisan jetstream:install inertia --dark --no-interaction || true

# 11. Finalize
echo "🧹 Cleaning up and Installing Frontend..."

# Use --legacy-peer-deps to resolve Vite 7 vs Plugin conflicts
./vendor/bin/sail npm install --legacy-peer-deps
./vendor/bin/sail npm run build
./vendor/bin/sail artisan migrate

echo "✅ Project Initialized!"
echo "👉 You can now create a module: cd src && ./vendor/bin/sail artisan module:make Blog"