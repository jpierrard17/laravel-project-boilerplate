#!/bin/bash

# Usage: ./make-module.sh ModuleName
MODULE_NAME=$1

if [ -z "$MODULE_NAME" ]; then
  echo "Error: Module name is required."
  echo "Usage: ./make-module.sh <ModuleName>"
  exit 1
fi

BASE_PATH="app/Modules/$MODULE_NAME"

# 1. Create Directories
echo "📂 Creating Module: $MODULE_NAME..."
mkdir -p "$BASE_PATH/Http/Controllers"
mkdir -p "$BASE_PATH/Http/Requests"
mkdir -p "$BASE_PATH/Http/Resources"
mkdir -p "$BASE_PATH/Models"
mkdir -p "$BASE_PATH/Services"
mkdir -p "$BASE_PATH/Data"
mkdir -p "$BASE_PATH/Tests"

# 2. Create Service Class (The "Brain")
cat <<EOT > "$BASE_PATH/Services/${MODULE_NAME}Service.php"
<?php

declare(strict_types=1);

namespace App\Modules\\$MODULE_NAME\Services;

class ${MODULE_NAME}Service
{
    // Define business logic here
}
EOT

# 3. Create Model
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

# 4. Create Controller
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

echo "✅ Module $MODULE_NAME scaffolded successfully at $BASE_PATH"