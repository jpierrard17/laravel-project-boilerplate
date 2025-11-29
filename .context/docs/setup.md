# Project Setup & Environment

This is a **Generator Repository**. The actual application code is not checked into git by default; it resides in the `src/` directory which you must hydrate.

## 1. Installation (First Time)
To download the latest Laravel, install Jetstream/Inertia, and apply the Modular Monolith patches, run:

```bash
# Run from repository root
./.context/scripts/init.sh
```

* **What this does:**
    * Downloads Laravel 11 into `src/`.
    * Configures `bootstrap/app.php` for Module routing.
    * Installs Vue 3, Tailwind, and Inertia.js.

---

## 2. Docker Environment (Laravel Sail)
This project uses **Laravel Sail** (Docker Compose).

### Starting the App
Once initialized, the application lives in `src`.

```bash
cd src
./vendor/bin/sail up -d
```

### Stopping the App
```bash
./vendor/bin/sail down
```

### Common Commands
Always run these from inside the `src/` directory:

* **Artisan:** `./vendor/bin/sail artisan migrate`
* **Composer:** `./vendor/bin/sail composer require ...`
* **NPM:** `./vendor/bin/sail npm run build`
* **Shell:** `./vendor/bin/sail shell`

---

## 3. Port Management
To run this project alongside other Laravel apps without port conflicts (e.g., "Address already in use" errors), use the included port manager.

**Run this from the project root:**

```bash
./.context/scripts/setup-ports.sh
```

**What this does:**
1.  Scans for available ports on your host machine.
2.  Updates `src/.env` automatically:
    * `APP_PORT` (Default: 8000 -> 8001...)
    * `VITE_PORT` (Default: 5173 -> 5174...)
    * `FORWARD_DB_PORT` (Default: 3306 -> 3307...)

> **Note:** If you change ports, you must restart Sail:
> `cd src && ./vendor/bin/sail down && ./vendor/bin/sail up -d`

---

## 4. Troubleshooting

### Database Connection
When connecting via a GUI (TablePlus/Sequel Ace):
* **Host:** `127.0.0.1` (localhost)
* **Port:** Check `FORWARD_DB_PORT` in `src/.env`.
* **User/Pass:** `sail` / `password`

### "Missing src directory"
If the AI complains that `src` is missing, ensure you have run the initialization script in Step 1.