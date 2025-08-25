# FocusFlow Mobile - Flutter Todo App

A beautiful and feature-rich mobile todo application built with Flutter and Supabase, designed to match your React web app functionality.

## Features

- ✅ **Authentication** - Sign up/Sign in with Supabase Auth
- ✅ **Todo Management** - Create, edit, delete, and complete todos
- ✅ **Sub-todos** - Break down tasks into smaller subtasks
- ✅ **Priority Levels** - Low, Medium, High, Urgent priorities
- ✅ **Due Dates & Times** - Set deadlines for your tasks
- ✅ **Tags** - Organize todos with custom tags
- ✅ **Search & Filter** - Find todos by title, priority, status, or tags
- ✅ **Real-time Sync** - Changes sync across devices instantly
- ✅ **Progress Tracking** - Visual progress indicators for subtasks
- ✅ **Swipe Actions** - Swipe to delete todos
- ✅ **Material Design** - Beautiful, modern UI following Material 3 guidelines

## Setup Instructions

### 1. Prerequisites
- Flutter SDK (>=3.10.0)
- Dart SDK (>=3.0.0)
- Android Studio or VS Code with Flutter extensions
- Supabase account

### 2. Supabase Setup
1. Create a new project on [Supabase](https://supabase.com)
2. Run the SQL script from `PERFECT-ERRORLESS-SETUP.sql` in your Supabase SQL editor
3. Get your project URL and anon key from Settings > API

### 3. Flutter Setup
1. Clone or download this project
2. Navigate to the project directory:
   ```bash
   cd flutter_todo_app
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Update `lib/main.dart` with your Supabase credentials:
   ```dart
   await SupabaseService.initialize(
     url: 'YOUR_SUPABASE_URL',
     anonKey: 'YOUR_SUPABASE_ANON_KEY',
   );
   ```

### 4. Run the App
```bash
flutter run
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/
│   └── todo.dart            # Todo and SubTodo data models
├── providers/
│   └── todo_provider.dart   # State management with Riverpod
├── screens/
│   ├── auth/
│   │   └── login_screen.dart    # Authentication screen
│   ├── home/
│   │   └── home_screen.dart     # Main todo list screen
│   └── todo/
│       ├── add_todo_screen.dart     # Add/Edit todo screen
│       └── todo_detail_screen.dart  # Todo details screen
├── services/
│   └── supabase_service.dart    # Supabase integration
└── widgets/
    ├── todo_card.dart           # Todo list item widget
    └── filter_bottom_sheet.dart # Filter options widget
```

## Key Technologies

- **Flutter** - Cross-platform mobile framework
- **Riverpod** - State management solution
- **Supabase** - Backend-as-a-Service (Auth, Database, Real-time)
- **Material 3** - Modern Material Design components

## Database Schema

The app uses the same database schema as your React web app:

- **todos** table - Main todo items with user association
- **sub_todos** table - Subtasks linked to main todos
- Row Level Security (RLS) enabled for data protection
- Real-time subscriptions for live updates

## Features in Detail

### Authentication
- Email/password authentication via Supabase Auth
- Automatic session management
- Secure user data isolation

### Todo Management
- Create todos with title, description, priority, and due dates
- Edit existing todos with full data preservation
- Mark todos as complete/incomplete
- Delete todos with confirmation dialog

### Sub-todos
- Add unlimited subtasks to any todo
- Track completion progress with visual indicators
- Individual due dates and times for subtasks

### Filtering & Search
- Search todos by title or description
- Filter by priority level (Low, Medium, High, Urgent)
- Filter by completion status
- Filter by tags
- Clear all filters option

### Real-time Updates
- Changes sync instantly across all devices
- Live updates when todos are modified
- Optimistic UI updates for smooth experience

## Customization

### Themes
Modify the theme in `lib/main.dart` to match your brand colors:

```dart
theme: ThemeData(
  primarySwatch: Colors.blue, // Change primary color
  // Add custom theme properties
),
```

### Priority Colors
Update priority colors in `lib/widgets/todo_card.dart`:

```dart
Color _getPriorityColor(Priority priority) {
  switch (priority) {
    case Priority.urgent: return Colors.red;
    // Customize colors here
  }
}
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License.
