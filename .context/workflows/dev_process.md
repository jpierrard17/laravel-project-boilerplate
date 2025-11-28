# Development Workflows

> **AI INSTRUCTION:** Identify the SCENARIO that matches the user's request. Follow the steps exactly.

---

## SCENARIO 1: New Feature / Domain Logic
**Trigger:** User asks to "build", "create", or "add" a new capability (e.g., "Add a Gym Tracker").

1.  **Analyze Domain:**
    * Does this belong to an existing Module (e.g., `Hevy`)?
    * Or is this a *new* Domain?

2.  **Scaffold:**
    * **If New Module:**
        * Run the helper script: `./.context/scripts/make-module.sh {ModuleName}`.
        * *Action:* Register the new Module's routes or ServiceProvider in `bootstrap/providers.php` (or `app.php`) if required.
    * **If Existing Module:**
        * Manually create the Service/Controller in `app/Modules/{Module}/...`.
        * *Constraint:* Ensure Namespace matches `App\Modules\{Module}\...`.

3.  **Database:**
    * Create Migration: `php artisan make:migration create_xxx_table`.
    * Update Model: Located in `app/Modules/{Module}/Models/`. Set `$guarded = []`.

4.  **Test (Red):**
    * Create a Feature test: `tests/Feature/{Module}/xxxTest.php`.
    * Ensure it fails first.

5.  **Implement (Green):**
    * Write the Service logic.
    * Connect the Controller.
    * Create the API Resource.

6.  **UI (Inertia):**
    * Create Vue Page: `resources/js/Pages/{Module}/Index.vue`.
    * Ensure props are typed with TypeScript interfaces.

---

## SCENARIO 2: Bug Fix
**Trigger:** User reports an error, exception, or "fix".

1.  **Replication:**
    * Ask user for reproduction steps.
    * Write a failing test case that reproduces the bug.

2.  **Fix:**
    * Modify the code in the specific `app/Modules/{Module}`.
    * Run tests until Green.

3.  **Refactor:**
    * Check for regression.
    * Ensure no "quick hacks" were left (e.g., `dd()`, commented code).

---

## SCENARIO 3: Refactoring & Cleanup
**Trigger:** User asks to "clean up", "optimize", or "review" code.

1.  **Safety Check:** Run `php artisan test` to ensure baseline is passing.
2.  **Analyze:**
    * Check `.context/rules/coding_style.md`.
    * Look for fat Controllers (move logic to Services).
    * Look for direct DB queries in Controllers (move to Services).
3.  **Apply:** Make changes incrementally.
4.  **Verify:** Run tests after every major change.

---

## SCENARIO 4: Database Modification
**Trigger:** User wants to add columns or change schema.

1.  **Migration:** Create a *new* migration. DO NOT edit old migration files.
2.  **Model Update:**
    * Update `app/Modules/{Module}/Models/{Model}.php`.
    * Update `casts` (e.g., `=> 'datetime'`).
    * Update relationships if foreign keys changed.