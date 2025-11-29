# Technology Stack & Versions

## Core Frameworks
- **Backend Framework**: Laravel 11.x
- **Language**: PHP 8.2+
- **Frontend Framework**: Vue.js 3 (Composition API)
- **App Stack**: Laravel Jetstream + Inertia.js (SSR disabled by default)
- **Language**: TypeScript 5.x (Strict Mode)

## Database & Storage
- **Primary Database**: MySQL 8.0+ (via Docker/Sail)
- **Cache/Queue**: Redis (via Docker/Sail)
- **Migrations**: Standard Laravel Migrations (Anonymous classes)

## Frontend Libraries
- **Build Tool**: Vite
- **Styling**: Tailwind CSS 3.x
- **Component Library**: PrimeVue (Unstyled or Tailwind Presets preferred)
- **Icons**: Heroicons (via Vue wrapper) or PrimeIcons

## Testing & Quality
- **Test Runner**: Pest PHP (Preferred over PHPUnit)
- **Static Analysis**: PHPStan (Level 5+)
- **Formatting**: Laravel Pint (PSR-12)

## Infrastructure (Local)
- **Environment**: Laravel Sail (Docker Compose)
- **Node**: LTS Version