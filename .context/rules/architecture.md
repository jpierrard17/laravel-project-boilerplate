# Application Architecture: Modular Monolith

## 1. High-Level Pattern
This application follows a **Modular Monolith** architecture.
Code is organized by **Domain Context** (Modules) rather than technical layer.

* **Default Location:** All core business logic lives in `app/Modules/`.
* **The `app/` Root:** Standard Laravel folders (`app/Http`, `app/Models`) should remain empty or minimal. They are reserved only for "Glue" code, global middleware, or generic app concerns (e.g., Auth) that do not fit into a specific domain.

## 2. Directory Structure
Each logical domain (e.g., `Hevy`, `Strava`, `Billing`) must follow this strict structure:

```text
app/Modules/{DomainName}/
├── Http/
│   ├── Controllers/   # Entry points (Inertia responses)
│   ├── Requests/      # Form Requests (Validation)
│   └── Resources/     # API/Inertia Resources (Data Transformation)
├── Models/            # Database Models & Relationships
├── Services/          # Business Logic & Integrations
├── Data/              # DTOs (Data Transfer Objects)
├── routes/            # Module-specific routes (web.php / api.php)
└── Tests/             # Unit/Feature tests specific to this module
```

## 3. Namespacing & File Placement
* **Namespace:** All classes within a module must use the namespace:
  `App\Modules\{DomainName}\{Layer}`
* **Example:**
    * Controller: `App\Modules\Strava\Http\Controllers\ActivityController`
    * Service: `App\Modules\Strava\Services\ActivitySyncService`
    * Model: `App\Modules\Strava\Models\Activity`

## 4. Layer Responsibilities

### A. Http Layer (The Interface)
* **Controllers:** Strictly for handling HTTP input and returning responses.
    * *Do not* write business logic here.
    * *Do* call a Service.
    * *Do* return `Inertia::render()` or a JSON response.
* **Requests:** Use `FormRequest` classes for all validation. Never validate inside the Controller.
* **Resources:** All data sent to the frontend (Inertia props) must be transformed via an **API Resource**. This prevents exposing raw DB columns (security).

### B. Domain Layer (The Logic)
* **Services:** The "Brain" of the module.
    * Contains all calculations, external API calls, and complex mutations.
    * Should return DTOs or Models, not HTTP responses.
* **Models:** Strictly for database configuration (relationships, scopes, casts).
    * Use `$guarded = []`.
* **Data (DTOs):** Use **readonly PHP 8.2 classes** to pass data between Controllers and Services.
    * *Avoid* passing associative arrays (`$data['email']`).
    * *Prefer* `new CreateUserData(email: '...')`.

## 5. Cross-Module Communication
* **Strict Boundaries:** Modules should be loosely coupled.
* **No Direct DB Access:** Module A (e.g., `Hevy`) should generally not query Module B's tables (`Strava`) directly.
* **Service Interfaces:** If Module A needs data from Module B, it should call a public method on Module B's Service.
    * *Bad:* `HevyService` queries `StravaActivity::where(...)`.
    * *Good:* `HevyService` calls `app(StravaService::class)->getActivities()`.

## 6. Frontend Architecture (Inertia + Vue)
* **Pages:** (`resources/js/Pages`)
    * Map 1:1 to Laravel Routes.
    * Receive data via Props (transformed by Resources).
* **Components:** (`resources/js/Components`)
    * Reusable UI elements (Buttons, Cards).
    * Must use TypeScript interfaces for props.
* **State:**
    * Use **Inertia** for server state (DB data).
    * Use **Pinia** only for global UI state (Sidebar toggle, Dark mode).