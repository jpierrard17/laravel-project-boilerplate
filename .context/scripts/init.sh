#!/bin/bash

# Exit on error
set -e

echo "🚀 Starting Dynamic Boilerplate Initialization..."

# 1. Install Latest Laravel
if [ -f "src/composer.json" ]; then
    echo "⚠️  Laravel is already installed in 'src'. Skipping download."
else
    echo "📦 Downloading latest Laravel into 'src'..."
    
    # Pre-cleanup to appease Composer
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

# 2. Configure Ports (CRITICAL FIX)
# We must update .env ports BEFORE starting Sail, otherwise it conflicts with your other apps
echo "🔌 Configuring Ports to avoid conflicts..."
if [ -f ".context/scripts/setup-ports.sh" ]; then
    ./.context/scripts/setup-ports.sh
else
    echo "❌ Error: Port setup script not found!"
    exit 1
fi

# 3. Setup Directory Structure
echo "🏗️  Creating app/Modules directory..."
mkdir -p src/app/Modules

# 4. Install & Configure nwidart/laravel-modules
echo "📦 Installing Modular Architecture Package..."

cd src

# Safety Check: Ensure docker-compose.yml exists
if [ ! -f "docker-compose.yml" ]; then
    echo "❌ Error: docker-compose.yml not found. The Laravel download failed."
    exit 1
fi

# Start Sail (Now using the custom ports from Step 2)
./vendor/bin/sail up -d

# Install the package
./vendor/bin/sail composer require nwidart/laravel-modules

# Publish config
./vendor/bin/sail artisan vendor:publish --provider="Nwidart\Modules\LaravelModulesServiceProvider"

# 5. Inject Custom Configuration
echo "⚙️  Applying Custom Module Configuration..."
if [ -f "../.context/stubs/modules.php.stub" ]; then
    cp ../.context/stubs/modules.php.stub config/modules.php
else
    echo "❌ Error: .context/stubs/modules.php.stub not found!"
    exit 1
fi

# 6. Update Composer Autoload for PSR-4
echo "🎼 Updating Composer Autoload..."
python3 -c "import sys, json; data=json.load(open('composer.json')); data['autoload']['psr-4']['App\\\\Modules\\\\'] = 'app/Modules/'; json.dump(data, open('composer.json', 'w'), indent=4)"

# Regenerate autoload files
./vendor/bin/sail composer dump-autoload

# 7. Install Tech Stack (Jetstream + Inertia)
echo "🎨 Installing Jetstream & Inertia (Vue)..."
./vendor/bin/sail composer require laravel/jetstream
./vendor/bin/sail artisan jetstream:install inertia --dark

# 8. Finalize
echo "🧹 Cleaning up..."
./vendor/bin/sail npm install
./vendor/bin/sail npm run build
./vendor/bin/sail artisan migrate

echo "✅ Project Initialized!"
echo "👉 You can now create a module: cd src && ./vendor/bin/sail artisan module:make Blog"