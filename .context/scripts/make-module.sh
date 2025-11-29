#!/bin/bash

# Usage: ./make-module.sh ModuleName
MODULE_NAME=$1

if [ -z "$MODULE_NAME" ]; then
  echo "Error: Module name is required."
  echo "Usage: ./make-module.sh <ModuleName>"
  exit 1
fi

# 1. Dynamic Path Detection
# Checks if we are in the Repo Root (src exists) or inside the App (app exists)
if [ -d "src/app" ]; then
    PROJECT_ROOT="src"
elif [ -d "app" ]; then
    PROJECT_ROOT="."
else
    echo "❌ Error: Could not find Laravel 'app' directory."
    exit 1
fi

BASE_PATH="$PROJECT_ROOT/app/Modules/$MODULE_NAME"

# 2. Create Directories
echo "📂 Creating Module: $MODULE_NAME in $BASE_PATH..."
mkdir -p "$BASE_PATH/Http/Controllers"
mkdir -p "$BASE_PATH/Http/Requests"
mkdir -p "$BASE_PATH/Http/Resources"
mkdir -p "$BASE_PATH/Models"
mkdir -p "$BASE_PATH/Services"
mkdir -p "$BASE_PATH/Data"
mkdir -p "$BASE_PATH/Tests"
mkdir -p "$BASE_PATH/routes"  # <-- Critical: Added routes folder

# 3. Create Service Class
cat <<EOT > "$BASE_PATH/Services/${MODULE_NAME}Service.php"
<?php

declare(strict_types=1);

namespace App\Modules\\$MODULE_NAME\Services;

class ${MODULE_NAME}Service
{
    // Define business logic here
}
EOT

# 4. Create Model
cat <<EOT > "$BASE_PATH/Models/${MODULE_NAME}.php"
<?php

declare(strict_types=1);

namespace App\Modules\\$MODULE_NAME\Models;

use Illuminate\Database\Eloquent\Model;

class $MODULE_NAME extends Model
{
    protected \$guarded = [];
}
EOT

# 5. Create Controller
cat <<EOT > "$BASE_PATH/Http/Controllers/${MODULE_NAME}Controller.php"
<?php

declare(strict_types=1);

namespace App\Modules\\$MODULE_NAME\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Modules\\$MODULE_NAME\Services\\${MODULE_NAME}Service;
use Inertia\Inertia;

class ${MODULE_NAME}Controller extends Controller
{
    public function __construct(
        protected ${MODULE_NAME}Service \$service
    ) {}

    public function index()
    {
        return Inertia::render('${MODULE_NAME}/Index');
    }
}
EOT

# 6. Create Routes File (Critical for Auto-Discovery)
cat <<EOT > "$BASE_PATH/routes/web.php"
<?php

use Illuminate\Support\Facades\Route;
use App\Modules\\$MODULE_NAME\Http\Controllers\\${MODULE_NAME}Controller;

Route::middleware(['web', 'auth:sanctum', 'verified'])->group(function () {
    Route::get('/${MODULE_NAME,,}', [${MODULE_NAME}Controller::class, 'index'])->name('${MODULE_NAME,,}.index');
});
EOT

echo "✅ Module $MODULE_NAME scaffolded successfully!"
echo "👉 Routes auto-registered at: $BASE_PATH/routes/web.php"