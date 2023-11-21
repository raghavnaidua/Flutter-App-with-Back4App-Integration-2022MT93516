# project

A new Flutter project.

## Getting Started

# Flutter Task Management App

This Flutter app demonstrates a basic task management system using the Parse Server SDK for backend integration.

## Features

- View a list of tasks
- Add tasks with descriptions
- View task details
- Delete tasks
- Update task names and descriptions

## Setup

1. Clone the repository:

    ```bash
    git clone https://github.com/your-username/your-repository.git
    ```

2. Install dependencies:

    ```bash
    flutter pub get
    ```

3. Run the app:

    ```bash
    flutter run
    ```

## Configuration

Make sure to replace the Parse Server credentials in the `main.dart` file with your own:

```dart
await Parse().initialize(
  'your-app-id',
  'your-server-url',
  clientKey: 'your-client-key',
  autoSendSessionId: true,
  debug: true,
);
