# NexBloom - Ultimate Student Companion

NexBloom is a modern, feature-rich Flutter application designed to be the ultimate companion for students. It helps manage academics, track progress, and stay organized throughout the semester with a sleek, intuitive, and high-performance user interface.

![NexBloom Logo](app logo/NexBloom transparent.png)

## Key Features

- **Smart Timetable**: Organize and track your daily class schedule with ease.
- **Advanced Notes**: Full-featured note-taking system with Markdown support.
- **Assignment Manager**: Track deadlines and prioritize your academic tasks.
- **Study Planner**: Designate specific study sessions and manage your learning goals.
- **Attendance Tracker**: Keep a real-time record of your presence in every subject.
- **Progress Visuals**: Built-in charts to visualize your academic performance and consistency.
- **Smart Notifications**: Stay on top of classes and assignments with local push notifications.

## Technology Stack

NexBloom is built using state-of-the-art Flutter and Dart tools:

- **Framework**: [Flutter](https://flutter.dev) (Dart-based)
- **State Management**: [Riverpod](https://riverpod.dev) (for scalable and reactive states)
- **Navigation**: [GoRouter](https://pub.dev/packages/go_router)
- **Local Persistence**: [Hive](https://hivedb.dev) (NoSQL storage for offline data)
- **Charts**: [fl_chart](https://pub.dev/packages/fl_chart)
- **Animations**: [flutter_animate](https://pub.dev/packages/flutter_animate)
- **Theming**: Custom dynamic dark/light mode with Google Fonts integration.

## Project Structure

The project follows a modular, clean-architecture-inspired organization:

```text
lib/
├── core/         # Shared utilities and configurations
├── data/         # Repositories and local/remote data sources
├── domain/       # Core business logic and models
├── features/     # Feature-specific modules (attendance, notes, study planner)
├── presentation/ # UI components and screens
└── main.dart     # App entry point
```

## Getting Started

### Prerequisites

- Flutter SDK (latest version recommended)
- Android Studio or VS Code with Flutter extensions
- A mobile device or emulator

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/Aryyl/NexBloom.git
   cd NexBloom
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure Environment:**
   Ensure you have a `.env` file for any environment-specific configurations.

4. **Run the app:**
   ```bash
   flutter run
   ```

## Contributing

Contributions are welcome! If you have suggestions or find bugs, feel free to open an issue or submit a pull request.

## License

This project is for academic and personal use. Please refer to specify a license if intended for redistribution.

---
*Created by [Aryyl](https://github.com/Aryyl)*
