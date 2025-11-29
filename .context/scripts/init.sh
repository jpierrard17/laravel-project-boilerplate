#!/bin/bash

# Exit on error
set -e

echo "🚀 Starting Dynamic Boilerplate Initialization..."

# 1. Install Latest Laravel
# CHANGED: Check for composer.json instead of just the directory
if [ -f "src/composer.json" ]; then
    echo "⚠️  Laravel is already installed in 'src'. Skipping download."
else
    echo "📦 Downloading latest Laravel into 'src'..."
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
cp .context/stubs/bootstrap.php.stub src/bootstrap/app.php

# 4. Install Tech Stack (Jetstream + Inertia)
# REMOVED: --teams flag
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