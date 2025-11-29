# Laravel Modular Monolith (AI-Native Boilerplate)

This is a **Generator Repository** designed to spin up a production-ready Laravel 11 application with a Modular Monolith architecture. It comes pre-packaged with a strict AI Context for Gemini/Claude.

## 🚀 Quick Start

### 1. Initialize Project
This repo does not contain the Laravel source code. You must hydrate it first.

```bash
# Downloads latest Laravel, installs Jetstream/Inertia, and configures modules
./.context/scripts/init.sh
```

### 2. Start Environment
Once initialized, the application lives in the `src/` directory.

```bash
cd src
./vendor/bin/sail up -d
```

### 3. Setup Ports
To avoid conflicts with other running projects, configure dynamic ports:

```bash
# Run from project root
./.context/scripts/setup-ports.sh
```

---

## 📂 Project Structure

* **`.context/`**: The "Brain" of the project (AI Rules, Scripts, Workflows).
* **`src/`**: The Application Code.
    * *Note:* This directory is empty by default in this repo.
    * It is populated automatically when you run `./.context/scripts/init.sh`.

---

## 🤖 AI Development Workflow

This project is optimized for AI-assisted development (Gemini CLI / Claude Code).

**1. Initialize Session**
Start your AI session by loading the system context:
> "Read `.context/SYSTEM_CONTEXT.md` and resume as the Architect."

**2. Generate Features**
The AI is trained to follow the **Modular Monolith** structure.
> "Create a new 'Billing' module."
> *The AI will trigger `./.context/scripts/make-module.sh Billing`*

---

## 📂 Architecture Rules

* **Modules:** `app/Modules/{Name}` (Services, Models, Controllers)
* **Routing:** Automatically discovered in `app/Modules/{Name}/routes/web.php`
* **Frontend:** Vue 3 + TypeScript + Inertia.js
* **Testing:** Pest PHP