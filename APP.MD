# 📚 Flutter Library App — Agent Build Specification

> **Purpose:** This document is the complete specification for an AI coding agent to build a Flutter mobile library app backed by MongoDB. Follow every section precisely.

---

## 1. Project Overview

| Field | Value |
|---|---|
| App Name | **BookShelf** |
| Framework | Flutter (Dart) |
| Backend | Node.js + Express REST API |
| Database | MongoDB (Atlas or local) |
| Auth | JWT (JSON Web Tokens) |
| State Management | Provider or Riverpod |
| Target Platforms | Android & iOS |

---

## 2. MongoDB Database Structure

### 2.1 Database Name
```
bookshelf_db
```

### 2.2 Collections

---

#### Collection: `users`
Stores registered users and their authentication data.

```json
{
  "_id": "ObjectId",
  "name": "string",
  "email": "string (unique, indexed)",
  "password_hash": "string (bcrypt)",
  "avatar_url": "string | null",
  "role": "string (enum: 'user' | 'admin')",
  "favorites": ["ObjectId (ref: books._id)"],
  "reading_list": ["ObjectId (ref: books._id)"],
  "settings": {
    "theme": "string (enum: 'light' | 'dark' | 'system')",
    "language": "string (default: 'en')",
    "notifications_enabled": "boolean"
  },
  "created_at": "ISODate",
  "updated_at": "ISODate"
}
```

**Indexes:**
- `email` — unique
- `created_at` — descending

---

#### Collection: `books`
Stores the full book catalog imported from the CSV dataset.

```json
{
  "_id": "ObjectId",
  "book_id": "number (original CSV id, unique, indexed)",
  "title": "string (indexed, text)",
  "price": "number",
  "price_excl_tax": "number",
  "price_incl_tax": "number",
  "tax": "number",
  "rating": "number (1–5)",
  "availability": "string",
  "in_stock": "boolean",
  "stock_count": "number",
  "category": "string (indexed)",
  "subcategory": "string",
  "upc": "string (unique)",
  "product_type": "string",
  "number_of_reviews": "number",
  "url": "string",
  "image_url": "string",
  "description": "string",
  "created_at": "ISODate",
  "updated_at": "ISODate"
}
```

**Indexes:**
- `book_id` — unique
- `upc` — unique
- `title` — text index (for search)
- `category` — ascending
- `rating` — descending
- `in_stock` — ascending

---

#### Collection: `reviews`
User reviews and ratings for books.

```json
{
  "_id": "ObjectId",
  "book_id": "ObjectId (ref: books._id, indexed)",
  "user_id": "ObjectId (ref: users._id, indexed)",
  "rating": "number (1–5)",
  "comment": "string",
  "created_at": "ISODate"
}
```

**Indexes:**
- `book_id` + `user_id` — compound unique (one review per user per book)

---

#### Collection: `sessions` *(optional — if using refresh tokens)*
```json
{
  "_id": "ObjectId",
  "user_id": "ObjectId (ref: users._id)",
  "refresh_token": "string (hashed)",
  "expires_at": "ISODate",
  "created_at": "ISODate"
}
```

---

### 2.3 Sample Book Document (from CSV row)

```json
{
  "_id": "ObjectId('...')",
  "book_id": 1000,
  "title": "A Light in the Attic",
  "price": 51.77,
  "price_excl_tax": 51.77,
  "price_incl_tax": 51.77,
  "tax": 0.0,
  "rating": 3,
  "availability": "In stock (22 available)",
  "in_stock": true,
  "stock_count": 22,
  "category": "Poetry",
  "subcategory": "Books",
  "upc": "a897fe39b1053632",
  "product_type": "Books",
  "number_of_reviews": 0,
  "url": "http://books.toscrape.com/catalogue/a-light-in-the-attic_1000/index.html",
  "image_url": "http://books.toscrape.com/media/cache/fe/72/fe72f0532301ec28892ae79a629a293c.jpg",
  "description": "It's hard to imagine a world without A Light in the Attic...",
  "created_at": "ISODate('2024-01-01T00:00:00Z')",
  "updated_at": "ISODate('2024-01-01T00:00:00Z')"
}
```

---

## 3. REST API Endpoints (Backend — Node.js/Express)

### Auth Routes `/api/auth`
| Method | Path | Description |
|---|---|---|
| POST | `/api/auth/register` | Create new user account |
| POST | `/api/auth/login` | Login, returns JWT |
| POST | `/api/auth/logout` | Invalidate token |
| POST | `/api/auth/refresh` | Refresh JWT token |

### Books Routes `/api/books`
| Method | Path | Description |
|---|---|---|
| GET | `/api/books` | List all books (paginated, filterable) |
| GET | `/api/books/:id` | Get single book details |
| GET | `/api/books/search?q=` | Full-text search |
| GET | `/api/books/categories` | List all categories |
| GET | `/api/books/category/:name` | Books by category |

### User Routes `/api/users`
| Method | Path | Description |
|---|---|---|
| GET | `/api/users/me` | Get current user profile |
| PUT | `/api/users/me` | Update profile |
| PUT | `/api/users/me/settings` | Update app settings |
| POST | `/api/users/me/favorites/:bookId` | Add to favorites |
| DELETE | `/api/users/me/favorites/:bookId` | Remove from favorites |
| POST | `/api/users/me/reading-list/:bookId` | Add to reading list |
| DELETE | `/api/users/me/reading-list/:bookId` | Remove from reading list |

### Reviews Routes `/api/reviews`
| Method | Path | Description |
|---|---|---|
| GET | `/api/reviews/book/:bookId` | Get reviews for a book |
| POST | `/api/reviews` | Post a review |
| DELETE | `/api/reviews/:id` | Delete own review |

---

## 4. Flutter Project Structure

```
lib/
├── main.dart
├── app.dart                        # MaterialApp, theme, routes
│
├── core/
│   ├── constants/
│   │   ├── app_colors.dart
│   │   ├── app_strings.dart
│   │   └── api_constants.dart      # Base URL, endpoints
│   ├── theme/
│   │   ├── app_theme.dart          # Light & dark theme
│   │   └── text_styles.dart
│   ├── utils/
│   │   ├── validators.dart
│   │   ├── token_storage.dart      # Secure storage for JWT
│   │   └── helpers.dart
│   └── network/
│       ├── api_client.dart         # Dio/http client
│       └── interceptors.dart       # Auth header injection
│
├── models/
│   ├── user_model.dart
│   ├── book_model.dart
│   └── review_model.dart
│
├── services/
│   ├── auth_service.dart
│   ├── book_service.dart
│   └── user_service.dart
│
├── providers/                      # State management
│   ├── auth_provider.dart
│   ├── books_provider.dart
│   └── settings_provider.dart
│
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── home/
│   │   ├── home_screen.dart
│   │   └── widgets/
│   │       ├── book_card.dart
│   │       ├── category_chips.dart
│   │       └── featured_banner.dart
│   ├── book_detail/
│   │   ├── book_detail_screen.dart
│   │   └── widgets/
│   │       ├── rating_bar.dart
│   │       └── review_tile.dart
│   ├── search/
│   │   └── search_screen.dart
│   ├── favorites/
│   │   └── favorites_screen.dart
│   └── settings/
│       └── settings_screen.dart
│
└── widgets/                        # Shared/common widgets
    ├── custom_button.dart
    ├── custom_text_field.dart
    ├── book_grid_view.dart
    ├── loading_indicator.dart
    └── error_widget.dart
```

---

## 5. Screen Specifications

---

### Screen 1: Login Screen (`login_screen.dart`)

**Route:** `/login`

**UI Elements:**
- App logo + "BookShelf" title at top
- Email text field (keyboard: emailAddress, validator: not empty + valid email format)
- Password text field (obscured, toggle visibility icon)
- "Forgot Password?" text button (right-aligned)
- "Sign In" primary button (full width, calls `POST /api/auth/login`)
- Divider with "OR"
- "Create an Account" outlined button → navigates to `/register`
- Loading overlay while API call is in progress

**Behavior:**
- On success: store JWT in `flutter_secure_storage`, navigate to `/home` (replace route)
- On failure: show SnackBar with error message from API
- Redirect to `/home` if token already exists and is valid on app launch

**Form Validation:**
- Email: required, valid email format
- Password: required, min 6 characters

---

### Screen 2: Register Screen (`register_screen.dart`)

**Route:** `/register`

**UI Elements:**
- Back arrow to return to Login
- "Create Account" headline
- Full Name text field
- Email text field
- Password text field (obscured)
- Confirm Password text field (obscured)
- "Sign Up" primary button (calls `POST /api/auth/register`)
- "Already have an account? Sign In" text button → `/login`

**Behavior:**
- On success: auto-login (store JWT), navigate to `/home`
- On failure: show inline field errors or SnackBar

**Form Validation:**
- Name: required, min 2 chars
- Email: required, valid format, unique (server-side)
- Password: required, min 8 chars, at least 1 number
- Confirm Password: must match Password

---

### Screen 3: Home Screen (`home_screen.dart`)

**Route:** `/home`

**Layout:** `Scaffold` with `BottomNavigationBar` (4 tabs):
1. 🏠 Home
2. 🔍 Search
3. ❤️ Favorites
4. 👤 Profile/Settings

**Home Tab Content:**

**App Bar:**
- "Good Morning, [Name]" greeting (left)
- Notification bell icon (right)
- Search bar tap → navigates to Search screen

**Sections (vertical scroll):**

1. **Featured Banner** — horizontal `PageView` showing top-rated books (rating = 5), auto-scrolls every 3 seconds, dot indicator

2. **Categories Row** — horizontal scrollable `Chip` list of all categories from `/api/books/categories`; tapping a chip filters the grid below

3. **"All Books" Grid** — `GridView` (2 columns), paginated (20 items/page), infinite scroll with load-more trigger at bottom

**Book Card Widget (`book_card.dart`):**
- Book cover image (`CachedNetworkImage`)
- Title (max 2 lines, ellipsis)
- Category badge
- Star rating display (1–5)
- Price with currency symbol
- Heart icon (toggle favorite, filled/outlined)

**Pull-to-refresh** supported on the book grid.

---

### Screen 4: Book Detail Screen (`book_detail_screen.dart`)

**Route:** `/book/:id`

**Layout:** `CustomScrollView` with `SliverAppBar`

**SliverAppBar (collapsed/expanded):**
- Book cover image as background (expanded, `expandedHeight: 280`)
- Back button
- Share icon button
- Heart/Favorite icon button (top-right)

**Content sections (below AppBar):**

1. **Book Header**
   - Title (large, bold)
   - Author/Category chip
   - Star rating (visual bar) + "X reviews" count
   - Price (large, primary color)
   - Availability badge: green "In Stock (22)" or red "Out of Stock"

2. **Action Buttons Row**
   - "Add to Reading List" button
   - "Add to Favorites" button

3. **Description**
   - Collapsible text: show first 3 lines, "Read more" tap expands

4. **Book Details (small info grid)**
   - UPC, Product Type, Tax, Price excl. tax, Price incl. tax

5. **Reviews Section**
   - "Write a Review" button (opens bottom sheet with rating + comment field)
   - List of `ReviewTile` widgets (avatar, name, star rating, comment, date)
   - "Load more reviews" button

---

### Screen 5: Settings Screen (`settings_screen.dart`)

**Route:** `/settings`

**Layout:** `Scaffold` with `ListView`

**Sections:**

**Account Section:**
- User avatar (circle, tappable to change)
- Display name (tappable → edit dialog)
- Email (display only)
- "Change Password" list tile

**Preferences Section:**
- "Theme" list tile → bottom sheet picker (Light / Dark / System)
- "Language" list tile → bottom sheet picker
- "Notifications" switch tile

**Library Section:**
- "My Favorites" → navigates to favorites screen
- "Reading List" → navigates to reading list screen

**About Section:**
- "App Version" (read from `package_info_plus`)
- "Privacy Policy" (opens WebView or browser)
- "Terms of Service"
- "Rate the App" (opens store listing)

**Danger Zone:**
- "Log Out" button (red, shows confirmation dialog → clears JWT → navigates to `/login`)
- "Delete Account" button (red outline, double-confirm dialog)

---

## 6. Key Flutter Packages

Add these to `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter

  # HTTP & Networking
  dio: ^5.4.0
  
  # State Management
  provider: ^6.1.1
  # OR: flutter_riverpod: ^2.4.9

  # Secure Storage (JWT)
  flutter_secure_storage: ^9.0.0

  # Image Caching
  cached_network_image: ^3.3.1

  # UI
  flutter_rating_bar: ^4.0.1
  shimmer: ^3.0.0              # Loading skeletons
  lottie: ^3.0.0               # Animated illustrations

  # Navigation
  go_router: ^13.0.0

  # Local Storage (settings)
  shared_preferences: ^2.2.2

  # Package Info
  package_info_plus: ^5.0.1

  # URL Launcher
  url_launcher: ^6.2.4

  # Connectivity
  connectivity_plus: ^5.0.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
```

---

## 7. Authentication Flow

```
App Launch
    │
    ▼
Check flutter_secure_storage for JWT
    │
    ├─ JWT found → Validate with server (GET /api/users/me)
    │       ├─ Valid   → Navigate to /home
    │       └─ Invalid → Clear token → Navigate to /login
    │
    └─ No JWT → Navigate to /login
                    │
                    ├─ Login success   → Store JWT → /home
                    └─ Register success → Store JWT → /home
```

All authenticated API calls must include:
```
Authorization: Bearer <JWT_TOKEN>
```

Use a Dio interceptor (`interceptors.dart`) to automatically inject this header.

---

## 8. Theme Configuration

### Colors
```dart
// Light Theme
primary:        Color(0xFF4A90D9)   // Blue
secondary:      Color(0xFFF5A623)   // Amber/Gold
background:     Color(0xFFF8F9FA)
surface:        Color(0xFFFFFFFF)
error:          Color(0xFFE53935)
onPrimary:      Color(0xFFFFFFFF)
text:           Color(0xFF1A1A2E)
textSecondary:  Color(0xFF6B7280)

// Dark Theme
primary:        Color(0xFF5BA3E8)
background:     Color(0xFF0F0F1A)
surface:        Color(0xFF1E1E2E)
text:           Color(0xFFF1F5F9)
```

### Typography
- Font Family: `Inter` (Google Fonts)
- Headline Large: 28px, bold
- Headline Medium: 22px, semi-bold
- Body Large: 16px, regular
- Body Medium: 14px, regular
- Label: 12px, medium

---

## 9. Error Handling & Edge Cases

| Scenario | Behavior |
|---|---|
| No internet | Show banner "No internet connection", disable API calls |
| API timeout | Show retry button with error message |
| 401 Unauthorized | Clear JWT, redirect to `/login` |
| 404 Book not found | Show "Book not found" illustration |
| Empty search results | Show "No books found" illustration + clear search button |
| Empty favorites | Show "No favorites yet" + browse books button |
| Image load failure | Show placeholder book cover icon |

---

## 10. Folder Conventions & Code Style

- Use `snake_case` for file names
- Use `PascalCase` for class names
- Use `camelCase` for variables and methods
- All screens extend `StatelessWidget` unless local state needed (then `StatefulWidget` or hooks)
- Use `const` constructors wherever possible
- Separate business logic from UI — no API calls inside widget `build()` methods
- All API calls must be wrapped in try/catch with typed error handling
- Use `freezed` or simple `copyWith` patterns for immutable models

---

## 11. Data Seeding Script (Node.js)

Create `scripts/seed_books.js` to import the CSV into MongoDB:

```javascript
const { MongoClient } = require('mongodb');
const csv = require('csv-parser');
const fs = require('fs');

const uri = process.env.MONGODB_URI || 'mongodb://localhost:27017';
const client = new MongoClient(uri);

async function seedBooks() {
  await client.connect();
  const db = client.db('bookshelf_db');
  const collection = db.collection('books');

  const books = [];

  fs.createReadStream('books.csv')
    .pipe(csv())
    .on('data', (row) => {
      books.push({
        book_id: parseInt(row.id),
        title: row.title,
        price: parseFloat(row.price),
        price_excl_tax: parseFloat(row.price_excl_tax),
        price_incl_tax: parseFloat(row.price_incl_tax),
        tax: parseFloat(row.tax),
        rating: parseInt(row.rating),
        availability: row.availability,
        in_stock: row.in_stock === 'True',
        stock_count: parseInt(row.stock_count) || 0,
        category: row.category,
        subcategory: row.subcategory,
        upc: row.upc,
        product_type: row.product_type,
        number_of_reviews: parseInt(row.number_of_reviews) || 0,
        url: row.url,
        image_url: row.image_url,
        description: row.description,
        created_at: new Date(),
        updated_at: new Date()
      });
    })
    .on('end', async () => {
      await collection.createIndex({ book_id: 1 }, { unique: true });
      await collection.createIndex({ title: 'text' });
      await collection.createIndex({ category: 1 });
      await collection.insertMany(books, { ordered: false });
      console.log(`Inserted ${books.length} books`);
      await client.close();
    });
}

seedBooks().catch(console.error);
```

Run with: `node scripts/seed_books.js`

---

## 12. Environment Variables

Create `.env` file in the backend root:

```
PORT=3000
MONGODB_URI=mongodb+srv://<user>:<password>@cluster.mongodb.net/bookshelf_db
JWT_SECRET=your_super_secret_key_here
JWT_EXPIRES_IN=7d
REFRESH_TOKEN_SECRET=your_refresh_secret
REFRESH_TOKEN_EXPIRES_IN=30d
```

In Flutter, set the base URL in `lib/core/constants/api_constants.dart`:
```dart
class ApiConstants {
  static const String baseUrl = 'http://10.0.2.2:3000/api'; // Android emulator
  // static const String baseUrl = 'http://localhost:3000/api'; // iOS simulator
  // static const String baseUrl = 'https://your-production-api.com/api'; // Production
}
```

---

## 13. Agent Implementation Order

The agent should build in this order:

1. **Backend first:**
   - Setup Express + MongoDB connection
   - Create Mongoose models (User, Book, Review)
   - Implement auth routes (register, login, JWT middleware)
   - Implement book routes (list, detail, search, categories)
   - Implement user routes (profile, favorites, reading list)
   - Seed the database with the CSV data

2. **Flutter project setup:**
   - Create Flutter project: `flutter create bookshelf`
   - Add all packages to `pubspec.yaml`
   - Configure theme, routes (GoRouter), and providers

3. **Flutter screens in order:**
   - Login Screen
   - Register Screen
   - Home Screen (with book grid)
   - Book Detail Screen
   - Settings Screen
   - Search Screen
   - Favorites Screen

4. **Polish:**
   - Add loading skeletons (shimmer)
   - Add empty state illustrations
   - Add pull-to-refresh
   - Add infinite scroll pagination
   - Test on both Android and iOS

---

*End of Specification — Agent should follow this document top to bottom.*