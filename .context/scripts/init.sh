#!/bin/bash

# Exit on error
set -e

echo "🚀 Starting Dynamic Boilerplate Initialization..."

# 1. Install Latest Laravel
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
echo "🏗️  Creating app/Modules directory..."
mkdir -p src/app/Modules

# 3. Install & Configure nwidart/laravel-modules
echo "📦 Installing Modular Architecture Package..."
cd src

# Require the package
../vendor/bin/sail composer require nwidart/laravel-modules

# Publish the config file (We will overwrite it, but good to have the base)
../vendor/bin/sail artisan vendor:publish --provider="Nwidart\Modules\LaravelModulesServiceProvider"

# 4. Inject Custom Configuration (The Magic Step)
# We copy our pre-configured stub that maps 'Modules' -> 'app/Modules' and 'Entities' -> 'Models'
echo "⚙️  Applying Custom Module Configuration..."
if [ -f "../.context/stubs/modules.php.stub" ]; then
    cp ../.context/stubs/modules.php.stub config/modules.php
else
    echo "❌ Error: .context/stubs/modules.php.stub not found!"
    exit 1
fi

# 5. Update Composer Autoload for PSR-4
# This tells Composer that "App\Modules\" lives in "app/Modules/"
echo "🎼 Updating Composer Autoload..."
# Note: Using python for safer JSON editing than sed
python3 -c "import sys, json; data=json.load(open('composer.json')); data['autoload']['psr-4']['App\\\\Modules\\\\'] = 'app/Modules/'; json.dump(data, open('composer.json', 'w'), indent=4)"

# Regenerate autoload files
../vendor/bin/sail composer dump-autoload

# 6. Install Tech Stack (Jetstream + Inertia)
echo "🎨 Installing Jetstream & Inertia (Vue)..."
../vendor/bin/sail composer require laravel/jetstream
../vendor/bin/sail artisan jetstream:install inertia --dark

# 7. Finalize
echo "🧹 Cleaning up..."
../vendor/bin/sail npm install
../vendor/bin/sail npm run build
../vendor/bin/sail artisan migrate

echo "✅ Project Initialized!"
echo "👉 You can now create a module: cd src && php artisan module:make Blog"