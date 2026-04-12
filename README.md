# NexBloom

NexBloom is a comprehensive, high-performance Flutter application engineered to serve as an advanced companion for academic management. Developed with a focus on productivity and organizational efficiency, NexBloom provides an intuitive interface and robust functionality to manage schedules, track attendance, and optimize study sessions.

<img src="app%20logo/NexBloom%20transparent1.png" alt="NexBloom Logo" width="250" />

## Overview

NexBloom consolidates essential academic tools into a single, cohesive platform. It is designed to assist students in maintaining a structured approach to their coursework, deadlines, and overall performance tracking. The application leverages modern software architecture principles to ensure scalability, maintainability, and exceptional performance across devices.

## Core Features

- **Intelligent Timetable Management**: Facilitates the organization and tracking of daily class schedules with a streamlined interface.
- **Advanced Markdown Notes**: Provides a fully-featured note-taking environment supporting Markdown syntax for structured and readable academic documentation.
- **Assignment and Deadline Tracking**: Enables users to monitor pending tasks, establish priorities, and meet academic deadlines effectively.
- **Comprehensive Study Planner**: Includes a dedicated module for planning study sessions and managing learning objectives.
- **Integrated Pomodoro Focus Timer**: Features a built-in focus timer to enhance productivity during study sessions, complete with automated logging upon completion.
- **Real-Time Attendance Monitoring**: Maintains an accurate, up-to-date record of attendance metrics across all enrolled subjects.
- **Performance Analytics**: Utilizes data visualization techniques to present academic progress and consistency tracking over time.

## Architecture and Technical Implementation

The application adheres to a feature-first architecture, heavily inspired by Clean Architecture principles. This modular design isolates concerns, enhances testability, and streamlines future feature integrations.

### Technology Stack

- **Framework**: [Flutter](https://flutter.dev)
- **Language**: Dart
- **State Management**: [Riverpod](https://riverpod.dev) for reactive and scalable state handling.
- **Routing**: [GoRouter](https://pub.dev/packages/go_router) for declarative routing.
- **Local Storage**: [Hive](https://hivedb.dev) optimized for secure, offline NoSQL data persistence.
- **Data Visualization**: [fl_chart](https://pub.dev/packages/fl_chart) for rendering complex performance metrics.
- **Animations**: [flutter_animate](https://pub.dev/packages/flutter_animate) for performant UI transitions.
- **Theming**: Dynamic dark and light modes with custom typography integration.

### Directory Structure

```text
lib/
├── core/         # Shared utilities, services, and base configurations
├── data/         # Data providers, repositories, and DTOs
├── domain/       # Core business logic, entities, and use cases
├── features/     # Isolated feature modules (e.g., study_planner, attendance, notes)
├── presentation/ # Reusable UI components and visual representations
└── main.dart     # Application entry point
```

## Getting Started

### Prerequisites

Ensure the following dependencies are installed to evaluate or build the application:

- Flutter SDK (stable channel, latest version recommended)
- Android Studio or Visual Studio Code with corresponding Flutter extensions
- A connected physical device or active emulator
- Git

### Installation and Environment Initialization

1. **Clone the Repository**
   ```bash
   git clone https://github.com/Aryyl/NexBloom.git
   cd NexBloom
   ```

2. **Acquire Dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure the Environment**
   Ensure an appropriate `.env` file is present in the project root if specific environment variables are required.

4. **Execute the Application**
   ```bash
   flutter run
   ```

### Generating a Release Build

To generate an optimized, compressed release build for Android:

```bash
flutter build apk --release
```

## Contributing

We welcome professional contributions to NexBloom. When preparing a contribution, please ensure adherence to the existing feature-first architectural patterns and comprehensive testing standards. Open an issue to discuss proposed changes prior to submitting a corresponding pull request.

## License

This project is intended for academic and personal use. Please refer to the designated licensing documentation for terms regarding redistribution or commercial application.

---
*Developed and maintained by [Aryyl](https://github.com/Aryyl)*
