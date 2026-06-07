# BookShelf

Mobile library app built with **Flutter** and a **Node.js/Express** backend backed by **MongoDB**.

## Project structure

```
backend/          Node.js REST API (port 3000)
flutter/          BookShelf Flutter app
scrapebooks/      CSV dataset + optional Python scraper
```

## Prerequisites

- Node.js 18+
- MongoDB (local or Atlas)
- Flutter SDK 3.11+

## Backend setup

```bash
cd backend
cp .env.example .env   # edit MONGODB_URI and JWT secrets
npm install
npm run seed             # imports scrapebooks/books.csv → bookshelf_db
npm run dev              # http://localhost:3000
```

### API highlights

| Route | Description |
|-------|-------------|
| `POST /api/auth/register` | Create account |
| `POST /api/auth/login` | Login → JWT |
| `GET /api/books` | Paginated book list |
| `GET /api/books/search?q=` | Search |
| `GET /api/users/me` | Profile (auth required) |

## Flutter app

```bash
cd flutter
flutter pub get
flutter run
```

Set the API base URL in `flutter/lib/core/constants/api_constants.dart`:

- **Android emulator:** `http://10.0.2.2:3000/api` (default)
- **iOS simulator / desktop:** `http://localhost:3000/api`
- **Physical device:** `http://<your-pc-ip>:3000/api`

## Features

- JWT auth with secure token storage
- Home feed with featured books, categories, infinite scroll
- Book detail, reviews, favorites & reading list
- Search, settings (theme/language), pull-to-refresh
- Shimmer loading, empty states, offline banner

## Data refresh (optional)

```bash
cd scrapebooks
pip install -r requirements.txt
python scrape.py
# Then re-run: cd ../backend && npm run seed
```
