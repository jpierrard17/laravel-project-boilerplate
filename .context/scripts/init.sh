#!/bin/bash

# Exit on error
set -e

echo "🚀 Starting Dynamic Boilerplate Initialization..."

# 1. Install Latest Laravel
if [ -f "src/composer.json" ]; then
    echo "⚠️  Laravel detected in 'src'. Skipping download."
else
    echo "📦 Downloading latest Laravel into 'src'..."
    
    # Remove src to ensure clean install
    rm -rf src

    # Use /tmp for cache to avoid permission warnings
    docker run --rm \
        -u "$(id -u):$(id -g)" \
        -v $(pwd):/var/www/html \
        -w /var/www/html \
        -e COMPOSER_CACHE_DIR=/tmp/composer_cache \
        laravelsail/php83-composer:latest \
        composer create-project laravel/laravel src
fi

# 2. Generate docker-compose.yml (CRITICAL MISSING STEP)
if [ ! -f "src/docker-compose.yml" ]; then
    echo "⛵ Generating Laravel Sail configuration..."
    docker run --rm \
        -u "$(id -u):$(id -g)" \
        -v $(pwd)/src:/var/www/html \
        -w /var/www/html \
        laravelsail/php83-composer:latest \
        php artisan sail:install --with=mysql,redis,mailpit --no-interaction
fi

# 3. Configure Ports
echo "🔌 Configuring Ports to avoid conflicts..."
if [ -f ".context/scripts/setup-ports.sh" ]; then
    ./.context/scripts/setup-ports.sh
else
    echo "❌ Error: Port setup script not found!"
    exit 1
fi

# 4. Setup Directory Structure
echo "🏗️  Creating app/Modules directory..."
mkdir -p src/app/Modules

# 5. Start Sail
echo "🐳 Starting Docker Environment..."
cd src

if [ ! -f "docker-compose.yml" ]; then
    echo "❌ Error: docker-compose.yml still not found. Sail installation failed."
    exit 1
fi

./vendor/bin/sail up -d

# 6. Install & Configure nwidart/laravel-modules
echo "📦 Installing Modular Architecture Package..."
./vendor/bin/sail composer require nwidart/laravel-modules
./vendor/bin/sail artisan vendor:publish --provider="Nwidart\Modules\LaravelModulesServiceProvider"

# 7. Inject Custom Configuration
echo "⚙️  Applying Custom Module Configuration..."
# Go up one level (..) to find .context
if [ -f "../.context/stubs/modules.php.stub" ]; then
    cp ../.context/stubs/modules.php.stub config/modules.php
else
    echo "❌ Error: .context/stubs/modules.php.stub not found!"
    exit 1
fi

# 8. Update Composer Autoload for PSR-4
echo "🎼 Updating Composer Autoload..."
# Use python for safe JSON editing
python3 -c "import sys, json; data=json.load(open('composer.json')); data['autoload']['psr-4']['App\\\\Modules\\\\'] = 'app/Modules/'; json.dump(data, open('composer.json', 'w'), indent=4)"

# Regenerate autoload files
./vendor/bin/sail composer dump-autoload

# 9. Install Tech Stack (Jetstream + Inertia)
echo "🎨 Installing Jetstream & Inertia (Vue)..."
./vendor/bin/sail composer require laravel/jetstream
./vendor/bin/sail artisan jetstream:install inertia --dark

# 10. Finalize
echo "🧹 Cleaning up..."
./vendor/bin/sail npm install
./vendor/bin/sail npm run build
./vendor/bin/sail artisan migrate

echo "✅ Project Initialized!"
echo "👉 You can now create a module: cd src && ./vendor/bin/sail artisan module:make Blog"