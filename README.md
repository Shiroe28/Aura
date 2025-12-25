# Aura: Year in Focus 🎯

A beautiful, minimalist New Year resolution and goal-tracking mobile application built with Flutter and Supabase.

## ✨ Features

### Core Features
- **Daily Todo List**: Manage your daily tasks with an intuitive, clean interface
- **Goal Tracker**: Set and track yearly goals with progress bars and categories
- **Resolution Pillars**: Categorize goals (Health, Career, Personal) with visual progress rings
- **Streaks & Momentum**: Track daily consistency with streak indicators
- **Morning Intention & Evening Reflection**: Start and end your day with mindful prompts
- **Calendar Integration**: Plan and view events with an interactive monthly calendar
- **History & Achievements**: View completed tasks and celebrate your progress

### Design
- **Minimalist Zen Aesthetic**: Clean, distraction-free interface
- **Dark Theme**: Easy on the eyes with Deep Indigo (#3F51B5) and Soft Mint (#00BFA5) accents
- **Smooth Animations**: Delightful user experience with fluid transitions

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.2.0 or higher)
- Dart SDK (3.2.0 or higher)
- A Supabase account (free tier works great!)
- Android Studio / VS Code with Flutter extensions
- iOS Simulator (Mac) or Android Emulator

### 1. Clone the Repository

```bash
git clone <your-repo-url>
cd Aura
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Set Up Supabase

#### Create a Supabase Project

1. Go to [https://supabase.com](https://supabase.com) and create a new project
2. Wait for your project to be provisioned (usually takes 2-3 minutes)
3. Once ready, navigate to **Settings** → **API**
4. Copy your **Project URL** and **anon public** key

#### Run the Database Schema

1. In your Supabase dashboard, go to **SQL Editor**
2. Open the file `supabase/schema.sql` from this project
3. Copy and paste the entire SQL content into the SQL Editor
4. Click **Run** to create all the tables, policies, and functions

### 4. Configure the App

Open `lib/main.dart` and replace the placeholder values with your Supabase credentials:

```dart
await Supabase.initialize(
  url: 'YOUR_SUPABASE_URL',        // Replace with your Supabase URL
  anonKey: 'YOUR_SUPABASE_ANON_KEY', // Replace with your anon key
);
```

### 5. Add Fonts (Optional)

If you want to use custom Inter fonts:

1. Download Inter font from [Google Fonts](https://fonts.google.com/specimen/Inter)
2. Create a folder: `assets/fonts/`
3. Add the font files:
   - `Inter-Regular.ttf`
   - `Inter-Medium.ttf`
   - `Inter-SemiBold.ttf`
   - `Inter-Bold.ttf`

If you skip this step, the app will use the system default font.

### 6. Run the App

```bash
# For Android
flutter run

# For iOS (Mac only)
flutter run -d ios

# For Web
flutter run -d chrome
```

## 📁 Project Structure

```
lib/
├── models/              # Data models (Goal, Todo, CalendarEvent, etc.)
├── providers/           # State management with Provider
├── services/            # Supabase service for API calls
├── utils/              # Utilities (theme, date formatter)
├── views/              # Screen widgets
│   ├── auth/           # Login and signup screens
│   ├── today/          # Daily todo screen
│   ├── goals/          # Goals tracker screen
│   ├── calendar/       # Calendar view screen
│   └── history/        # Achievements and history
├── widgets/            # Reusable custom widgets
└── main.dart           # App entry point

supabase/
└── schema.sql          # Database schema with RLS policies
```

## 🎨 Theme & Design

### Color Palette
- **Deep Indigo**: `#3F51B5` - Primary color
- **Soft Mint**: `#00BFA5` - Success/accent color
- **Slate Grey**: `#37474F` - Secondary elements
- **Dark Background**: `#1A1A2E` - Main background
- **Card Background**: `#16213E` - Card surfaces

### Typography
- Font Family: Inter (with fallback to system default)
- Carefully designed hierarchy for readability

## 📱 App Screens

### 1. Today Screen
- View and manage daily tasks
- Set morning intentions
- Write evening reflections
- Track daily completion percentage

### 2. Goals Screen
- Create goals with categories
- Track progress with visual indicators
- Maintain streaks for consistency
- View Resolution Pillars (category progress rings)

### 3. Calendar Screen
- Interactive monthly calendar
- Add and manage events
- View events by date
- Mark events as completed

### 4. History Screen
- View achievements and statistics
- See completed goals
- Browse completed tasks
- Track your best streaks

## 🔐 Security

All data is protected with Row Level Security (RLS) policies in Supabase:
- Users can only access their own data
- All CRUD operations are authenticated
- Profile creation is automatic on signup

## 🛠️ Technologies Used

- **Flutter**: Cross-platform mobile framework
- **Supabase**: Backend-as-a-Service (PostgreSQL database, Auth, RLS)
- **Provider**: State management
- **table_calendar**: Calendar widget
- **intl**: Date formatting

