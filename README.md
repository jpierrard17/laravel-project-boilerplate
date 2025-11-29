# Laravel Modular Monolith (AI-Native Boilerplate)

This is a **Generator Repository** designed to spin up a production-ready Laravel 11 application with a Modular Monolith architecture. It comes pre-packaged with a strict AI Context for Gemini/Claude.

## 🚀 Quick Start

### 1. Initialize Project
This repo does not contain the Laravel source code. You must hydrate it first.

```bash
# Downloads latest Laravel, installs Jetstream/Inertia, and configures modules
./.context/scripts/init.sh

## 📂 Project Structure

* **`.context/`**: The "Brain" of the project (AI Rules, Scripts, Workflows).
* **`src/`**: The Application Code.
    * *Note:* This directory is empty by default in this repo.
    * It is populated automatically when you run `./.context/scripts/init.sh`.