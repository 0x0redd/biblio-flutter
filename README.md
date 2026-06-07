# BookShelf

A full-stack mobile library app for browsing, searching, and managing a book catalog. Built with **Flutter**, **Node.js/Express**, and **MongoDB**.

Data is sourced from [books.toscrape.com](http://books.toscrape.com/) (1000 books) via an optional Python scraper and imported into MongoDB through a seed script.

## Tech stack

| Layer | Stack |
|-------|--------|
| Mobile / Web | Flutter, Provider, GoRouter, Dio |
| Backend | Node.js, Express, Mongoose, JWT |
| Database | MongoDB (`bookshelf_db`) |
| Auth | JWT + refresh tokens (`flutter_secure_storage`) |

## Project structure

```
biblio-flutter/
├── backend/           REST API (port 3000)
│   ├── src/           Models, routes, controllers, middleware
│   └── scripts/       CSV seed script
├── flutter/           BookShelf Flutter app
│   └── lib/           Screens, providers, services, widgets
└── scrapebooks/       Python scraper + books.csv dataset
```

## Prerequisites

- [Node.js](https://nodejs.org/) 18+
- [MongoDB](https://www.mongodb.com/) (local or Atlas)
- [Flutter SDK](https://flutter.dev/) 3.11+
- Python 3 (optional, for re-scraping data)

## Quick start

### 1. Backend

```bash
cd backend
cp .env.example .env
```

Edit `.env` — set at minimum `MONGODB_URI` and `JWT_SECRET`:

```env
PORT=3000
MONGODB_URI=mongodb://localhost:27017/bookshelf_db
JWT_SECRET=change_me_to_a_long_random_string
REFRESH_TOKEN_SECRET=change_me_too
```

Install, seed, and run:

```bash
npm install
npm run seed
npm run dev
```

API available at `http://127.0.0.1:3000`  
Health check: `GET /health`

### 2. Flutter app

In a second terminal:

```bash
cd flutter
flutter pub get
flutter run
```

Choose your target (Windows, Edge, Android emulator, etc.).

### 3. Register & use

1. Open the app → **Create an Account**
2. Sign in and browse books on the home screen
3. Tap a book for details, favorites, reviews, and reading list

## API base URL (Flutter)

Configured in `flutter/lib/core/constants/api_constants.dart`:

| Platform | URL |
|----------|-----|
| Web / Windows / iOS simulator | `http://127.0.0.1:3000/api` |
| Android emulator | `http://10.0.2.2:3000/api` |
| Physical device | `http://<your-pc-lan-ip>:3000/api` |

The app picks the correct host automatically. Override in code only if you deploy to a remote server.

## Main API routes

### Auth — `/api/auth`

| Method | Path | Description |
|--------|------|-------------|
| POST | `/register` | Create account |
| POST | `/login` | Login → access + refresh tokens |
| POST | `/logout` | Invalidate refresh token |
| POST | `/refresh` | Refresh JWT |

### Books — `/api/books` (public)

| Method | Path | Description |
|--------|------|-------------|
| GET | `/` | Paginated list (`?page=1&limit=20&category=Poetry`) |
| GET | `/search?q=` | Full-text search |
| GET | `/categories` | All categories |
| GET | `/category/:name` | Books by category |
| GET | `/:id` | Single book |

### Users — `/api/users` (auth required)

| Method | Path | Description |
|--------|------|-------------|
| GET | `/me` | Current profile |
| PUT | `/me` | Update name / avatar |
| PUT | `/me/settings` | Theme, language, notifications |
| GET/POST/DELETE | `/me/favorites/:bookId` | Favorites |
| GET/POST/DELETE | `/me/reading-list/:bookId` | Reading list |

### Reviews — `/api/reviews`

| Method | Path | Description |
|--------|------|-------------|
| GET | `/book/:bookId` | Reviews for a book |
| POST | `/` | Post review (auth) |
| DELETE | `/:id` | Delete own review |

## App features

- Login / register with JWT
- Home: featured banner, category filters, infinite scroll
- Book detail: description, reviews, favorites, reading list
- Search with debounce
- Favorites & reading list screens
- Settings: light / dark / system theme, language, logout
- Shimmer loading, empty states, pull-to-refresh, offline banner
- Web-safe book cover images (CORS workaround)

## Refresh book data (optional)

```bash
cd scrapebooks
pip install -r requirements.txt
python scrape.py              # writes books.csv + books.json

cd ../backend
npm run seed                  # re-import CSV into MongoDB
```

## Troubleshooting

**`EADDRINUSE` on port 3000** — another Node process is already running:

```powershell
netstat -ano | findstr :3000
taskkill /PID <PID> /F
npm run dev
```

**Flutter cannot reach API** — confirm backend is up (`curl http://127.0.0.1:3000/health`) and use `127.0.0.1` on web/desktop, not `10.0.2.2`.

**Book images blocked on web (CORS)** — the app uses `BookCoverImage` with a web-specific loader. Hot restart the Flutter app after pulling latest code.

**MongoDB connection failed** — start MongoDB locally or update `MONGODB_URI` in `backend/.env` for Atlas.

## Environment files (do not commit secrets)

| File | Purpose |
|------|---------|
| `backend/.env.example` | Template — copy to `.env` |
| `backend/.env` | Local secrets (gitignored) |

## License

Academic / personal project — MSDIA S8.
