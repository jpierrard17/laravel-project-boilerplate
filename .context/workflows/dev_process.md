# Development Workflows

> **AI INSTRUCTION:** Identify the SCENARIO that matches the user's request. Follow the steps exactly.

---

## SCENARIO 0: First Time Setup
**Trigger:** User asks to "start", "setup", or "init" the project, or the `src` directory is empty/missing.

1.  **Check:** Does `src/composer.json` exist?
2.  **Action:** If not, run `./.context/scripts/init.sh`.
3.  **Wait:** Wait for the script to complete installation.
4.  **Verify:** Ensure `src/app/Modules` exists.

---

## SCENARIO 1: New Feature / Module
**Trigger:** User asks to "build", "create", or "add" a new domain/module (e.g., "Add a Blog").

1.  **Scaffold:**
    * Run: `cd src && php artisan module:make {ModuleName}`.
    * *Note:* This command automatically generates the Model, Controller, Service Provider, and Routes.

2.  **Cleanup (Optional):**
    * The package generates a `composer.json` and `module.json` inside `app/Modules/{Name}/`.
    * If this is an internal module, these can be ignored.

3.  **Verify Structure:**
    * Routes: `src/app/Modules/{Name}/Routes/web.php` (Auto-registered).
    * Config: `src/app/Modules/{Name}/Config/config.php`.

4.  **Database:**
    * Create Migration: `cd src && php artisan module:make-migration create_xxx_table {ModuleName}`.
    * Update Model: Located in `src/app/Modules/{Name}/Models/`. Set `$guarded = []`.

5.  **Test (Red):**
    * Create a Feature test: `src/tests/Feature/{Module}/xxxTest.php`.
    * *Tip:* You can use `php artisan module:make-test {Name} {ModuleName}`.

6.  **Implement (Green):**
    * Write the Service logic.
    * Connect the Controller (`Http/Controllers`).
    * Create the API Resource (`Http/Resources`).

7.  **UI (Inertia):**
    * Create Vue Page: `src/resources/js/Pages/{Module}/Index.vue`.

---

## SCENARIO 2: Bug Fix
**Trigger:** User reports an error, exception, or "fix".

1.  **Replication:**
    * Ask user for reproduction steps.
    * Write a failing test case.

2.  **Fix:**
    * Modify code in `src/app/Modules/{Module}`.
    * Run tests until Green.

---

## SCENARIO 3: Database Modification
**Trigger:** User wants to add columns or change schema.

1.  **Migration:**
    * `cd src && php artisan module:make-migration add_xxx_to_yyy_table {ModuleName}`.
2.  **Model Update:**
    * Update `src/app/Modules/{Module}/Models/{Model}.php`.