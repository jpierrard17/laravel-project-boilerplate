# Coding Standards & Style Guide

## 1. General PHP Rules
* **Strict Types:** ALL PHP files (Classes, Interfaces, Traits, Tests) MUST begin with:
  `declare(strict_types=1);`
* **PSR-12:** Follow PSR-12 coding standards.
* **Return Types:** Explicitly declare return types for all methods.
  * *Bad:* `public function index() { ... }`
  * *Good:* `public function index(): InertiaResponse { ... }`
* **Named Arguments:** Preferred for boolean flags or functions with 3+ arguments.

## 2. Laravel Architecture Rules
* **Controllers:**
  * MUST be "Skinny". No business logic.
  * MUST return `Inertia::render` or a JSON Resource.
  * MUST NOT validate data (use FormRequests).
* **Models:**
  * Use `$guarded = []` (Unguarded) instead of `$fillable`.
  * Relationships must have return types (`: BelongsTo`).
* **Services (Business Logic):**
  * All complex logic belongs in `app/Modules/{Module}/Services`.
  * Services should be injected via the constructor.
* **Data Transfer:**
  * Use **Readonly DTOs** (PHP 8.2 classes) to pass data between Controllers and Services.
  * Avoid passing raw associative arrays (`$data['key']`).

## 3. Modular Specifics
* **Namespacing:**
  * Code in modules MUST follow: `App\Modules\{ModuleName}\{Layer}`.
  * *Example:* `App\Modules\Billing\Services\InvoiceService`.
* **Dependency Injection:**
  * Reference other modules via their Service classes, never direct DB queries.

## 4. Frontend (Vue + TypeScript)
* **Syntax:** Use `<script setup lang="ts">`.
* **Props:** Must be defined using TypeScript interfaces.
  ```typescript
  interface Props {
      user: UserResource;
      active: boolean;
  }
  const props = defineProps<Props>();
  ```
* **Naming:**
  * Components: PascalCase (`UserProfileCard.vue`).
  * Files: PascalCase.
* **Composables:** Use standard Vue composables (`useForm` from Inertia) for form handling.

## 5. Testing (Pest PHP)
* **Location:** Tests typically live in `tests/Feature` or `app/Modules/{Module}/Tests`.
* **Syntax:** Use the `it()` syntax.
  ```php
  it('creates a new order', function () {
      // Arrange... Act... Assert
  });
  ```
* **Coverage:** Every public facing feature requires a Happy Path test and a Validation Failure test.