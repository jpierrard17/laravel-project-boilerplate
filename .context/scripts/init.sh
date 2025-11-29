#!/bin/bash

# Exit on error
set -e

echo "🚀 Starting Dynamic Boilerplate Initialization..."

# 1. Install Latest Laravel
if [ -f "src/composer.json" ]; then
    echo "⚠️  Laravel is already installed in 'src'. Skipping download."
else
    echo "📦 Downloading latest Laravel into 'src'..."
    # No need to rm -rf src; Composer will create it automatically.
    
    docker run --rm \
        -u "$(id -u):$(id -g)" \
        -v $(pwd):/var/www/html \
        -w /var/www/html \
        laravelsail/php83-composer:latest \
        composer create-project laravel/laravel src
fi

# 2. Setup Directory Structure
echo "🏗️  Setting up Modular Architecture..."
mkdir -p src/app/Modules

# 3. Patch Bootstrap for Module Routing
echo "💉 Injecting Module Loader into bootstrap/app.php..."
if [ -f "src/bootstrap/app.php" ]; then
    cp .context/stubs/bootstrap.php.stub src/bootstrap/app.php
else 
    echo "❌ Error: src/bootstrap/app.php not found. Laravel install may have failed."
    exit 1
fi

# 4. Install Tech Stack (Jetstream + Inertia)
echo "🎨 Installing Jetstream & Inertia (Vue)..."
cd src

# Use Sail to ensure environment compatibility
../vendor/bin/sail up -d
../vendor/bin/sail composer require laravel/jetstream
../vendor/bin/sail artisan jetstream:install inertia --dark

# 5. Finalize
echo "🧹 Cleaning up..."
../vendor/bin/sail npm install
../vendor/bin/sail npm run build
../vendor/bin/sail artisan migrate

echo "✅ Project Initialized! Run 'cd src && ./vendor/bin/sail up' to start."