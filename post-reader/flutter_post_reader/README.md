# Post Reader & Favorites (Flutter Laboratory Examination)

A complete Flutter mobile application built with Dart and Material Design 3 for reading posts from JSONPlaceholder, submitting new posts via REST API, and persisting favorites and personal study notes locally using Hive.

---

## 🛠️ Technologies Used
- **Flutter & Dart** (Null-safe, Material Design 3)
- **`http`** package for REST API communication
- **`hive` & `hive_flutter`** for lightweight key-value persistent storage
- **JSONPlaceholder API**: `https://jsonplaceholder.typicode.com/posts`

---

## 📁 Project Structure

```text
flutter_post_reader/
├── pubspec.yaml                 # Dependencies and assets configuration
└── lib/
    ├── main.dart                # App entry point, Hive init & named routes
    ├── theme/
    │   └── app_theme.dart       # Material 3 Blue and White theme with favorite accent
    └── screens/
        ├── posts_screen.dart    # Feed, API GET, FAB create post, API POST (201 check)
        ├── details_screen.dart  # Full post details, Save to Hive (prevents duplicates)
        └── favorites_screen.dart# Read Hive values, edit notes with put(), delete()
```

---

## 🚀 Setup & Execution Guide

### 1. Install Dependencies
In the terminal, navigate to the project directory and run:
```bash
flutter pub get
```

### 2. Run the Application
Launch an emulator or connect a physical device, then run:
```bash
flutter run
```

---

## 🧪 Testing Checklist (Laboratory Exam Requirements)

1. **Screen 1 (Posts)**:
   - On app launch, a circular progress indicator appears while fetching from JSONPlaceholder.
   - When HTTP status 200 is received, 100 posts load in the `ListView.builder` cards.
   - Tap the Floating Action Button `+` to open the Create Post dialog.
   - Both fields are validated as required.
   - When submitted, `http.post()` sends JSON with `Content-Type: application/json; charset=UTF-8`.
   - On status `201`, a green success SnackBar is displayed and the new post is added at the top.
   - Tapping the heart icon in the AppBar navigates to the Favorites screen using `Navigator.pushNamed(context, 'favorites')`.

2. **Screen 2 (Post Details)**:
   - Tapping any post opens the details screen using named route `'details'` with arguments map `{'id': ..., 'title': ..., 'body': ...}`.
   - Full post details display in a clean, readable card layout.
   - Tap **"Save to Favorites"**: saves the post map in Hive with post ID as key.
   - Tapping again warns that the post is already in favorites.
   - Tap the back arrow: pops the screen via `Navigator.pop(context)`.

3. **Screen 3 (Favorites)**:
   - Reads all saved items from the Hive box using `box.values`.
   - Displays empty state if no favorites are saved.
   - Each card has an **Edit** button to add/modify personal study notes using Hive `box.put()`.
   - Each card has a **Delete** button to remove the item using Hive `box.delete()`.
   - Close the app and reopen it: all saved favorites and personal notes remain persisted.
