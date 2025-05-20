# final_project

A new Flutter project.

# Campus Pulse Challenge

## Concept

Campus Pulse Challenge (Gladness) is a real-time campus engagement application designed to foster inter-faculty competition and enhance campus spirit. Students align with their respective faculties and earn points by responding quickly and correctly to randomized, time-limited "quests" or "directives" delivered via push notifications throughout the day. A dynamic, live leaderboard fuels the rivalry, showcasing faculty performance in near real-time.

## Innovation

The core innovation of Campus Pulse lies in its ability to weave a dynamic and unpredictable game directly into the daily campus life of students. By leveraging randomized, time-sensitive quests delivered through push notifications, it creates an exciting and engaging experience that promotes real-time interaction. This directly enhances inter-faculty rivalry and identity, transforming routine into a competitive adventure.

## Key Features

<!--
Lists the main functionalities of the application, categorized for readability.
Provides brief descriptions for each feature.
-->

* **Faculty Registration & Profiles:**
    * Secure sign-up and login for all users.
    * Mandatory faculty selection during registration.
    * Basic user profiles displaying accumulated points and earned badges.
    * Supports 7 distinct faculties: Faculty of Arts & Humanities, Faculty of Business Administration, Faculty of Education, Faculty of Information Technology, Faculty of Nursing, Faculty of Religious Studies, and Faculty of Science.

* **Real-Time Faculty Leaderboard:**
    * A prominently displayed leaderboard showcasing faculty rankings.
    * Designed for near real-time updates to reflect ongoing quest participation and scoring.
    * Potential for daily/weekly winners to further incentivize competition.

* **Randomized Quest/Directive System:**
    * **Push Notifications:** Quests are delivered directly to users' devices via push notifications.
    * **Random Timing Engine (Backend):** Quests are dispatched at unpredictable intervals, keeping users engaged and on their toes.
    * **Time Sensitivity:** Each quest has a strict time limit, rewarding quick responses.
    * **Diverse Quest Types:**
        * **Campus Trivia:** Quick questions about campus facts.
        * **Location Check-in:** Requires users to be at specific campus locations.
        * **Live Photo Challenge:** Users submit photos based on a given directive.
        * **Quick Polls:** Simple opinion-based questions.
        * **Mini-Puzzles:** Small, solvable challenges.
        * **(Advanced) AR Hunt:** Future potential for Augmented Reality-based scavenger hunts.

* **Response Handling & Scoring:**
    * Instant validation of quest answers.
    * Points are awarded based on correctness, speed of response, and participation.
    * Points are immediately credited to the user's total and, consequently, their faculty's overall score.

* **Admin/Control Panel (Backend):**
    * **Quest Content Management:** Admins can create, edit, and manage all types of quest content.
    * **Random Notification Configuration:** Control the parameters for the randomized quest delivery system.
    * **Leaderboard Monitoring:** Real-time oversight of faculty and individual user performance.
    * **User Activity Tracking:** Monitor how users engage with the app and quests.
    * **Manual Announcements:** Send immediate push notifications for important campus updates or special events.
    * **Faculty List Management:** Maintain the list of available faculties.

## Potential Impact

<!--
Discusses the broader benefits and value proposition of the application within a university context.
Addresses how it serves students, teachers, faculties, and departments.
-->

Campus Pulse aims to create a vibrant and engaged campus community. It introduces unpredictability and excitement into the daily routine, fostering a sense of adventure. By leveraging inter-faculty competition, it significantly enhances faculty spirit and identity. The scalable design allows for the introduction of increasingly complex and interactive quests, ensuring long-term engagement.

**For Students:**
* **Enhanced Engagement:** Breaks the monotony of daily campus life with unexpected, fun challenges.
* **Community Building:** Fosters a sense of belonging and camaraderie within their faculty.
* **Active Participation:** Encourages physical movement (location quests) and cognitive engagement (trivia, puzzles).
* **Recognition:** Provides a tangible way to earn points and badges, and contribute to their faculty's standing.

**For Teachers/Faculty (as a collective):**
* **Faculty Identity & Pride:** Strengthens the sense of identity and pride among students for their respective faculties.
* **Informal Learning:** Quests can be designed to subtly educate students about campus history, resources, or current events.
* **Student Well-being:** Promotes active breaks and social interaction.

**For University Departments/Administration:**
* **Campus Vitality:** Increases overall student engagement and activity on campus.
* **Data Insights:** Provides valuable data on student participation, popular locations, and engagement patterns (via the Admin Panel).
* **Communication Channel:** Offers a dynamic new channel for announcements and engaging students with campus initiatives.
* **Recruitment/Retention:** A vibrant campus life can be a draw for prospective students and a factor in retention.

## Technologies Used

<!--
Lists all major technologies and libraries used in the project.
Provides a brief description of each's role.
-->

* **Flutter:** Cross-platform UI toolkit for building natively compiled applications for mobile, web, and desktop from a single codebase.
* **Dart:** The client-optimized language for fast apps on any platform.
* **Riverpod:** A robust and flexible reactive caching and data-binding framework for Flutter, used for efficient state management and dependency injection.
* **GoRouter:** A declarative URL-based routing package for Flutter, simplifying navigation flow and deep linking.
* **Firebase:** A comprehensive mobile and web application development platform by Google.
    * **Firebase Authentication:** Provides backend services for user sign-up, sign-in, and session management, supporting various authentication methods.
    * **Cloud Firestore:** A flexible, scalable NoSQL cloud database for storing and syncing data in real-time, used for user profiles, quest data, and leaderboard information.
    * **Firebase Cloud Messaging (FCM):** A cross-platform messaging solution that lets you reliably send messages at no cost, used for delivering push notifications (quests, announcements).
    * **Firebase Crashlytics:** A lightweight, real-time crash reporting tool that helps you track, prioritize, and fix stability issues.
* **SQLite (via `sqflite`):** A lightweight, embedded relational database management system, used for local caching of user profiles, quest data, and leaderboard information to improve offline experience and performance.
* **`flutter_background_service`:** A Flutter plugin enabling the execution of long-running, continuous background tasks on Android (as a foreground service) and iOS, crucial for continuous location tracking and maintaining real-time connections.
* **`geolocator`:** A Flutter plugin providing easy access to platform-specific location services, used for retrieving device location for check-in quests.
* **`image_picker`:** A Flutter plugin for picking images from the image gallery or taking new pictures with the camera, essential for photo challenges.
* **`web_socket_channel`:** A Dart package for WebSocket client and server, used for establishing real-time WebSocket connections (e.g., for live leaderboard updates).
* **`flutter_local_notifications`:** A Flutter plugin for displaying local notifications, used for showing foreground FCM messages and potentially background service status.
* **`dartz`:** A functional programming library for Dart, providing utilities like `Either` for robust error handling and explicit representation of success/failure states.
* **`equatable`:** A Dart package that helps to implement value equality in classes without boilerplate code, simplifying comparison of entities and models.
* **`intl`:** A Dart package for internationalization and localization, used for formatting dates and other locale-specific data.
* **`rxdart`:** A reactive programming library for Dart, providing powerful stream transformations and combinations, used for advanced stream manipulation (e.g., in `LeaderboardProvider`).

## Setup and Usage

### Prerequisites

* **Flutter SDK:** Version 3.0.0 or higher is recommended.
* **Dart SDK:** Version 3.0.0 or higher is recommended.
* **Firebase Project:** A Google Firebase project must be set up with the following services enabled:
    * **Firebase Authentication:** Enable "Email/Password" sign-in method.
    * **Cloud Firestore:** Create a Firestore database.
    * **Cloud Messaging:** Enable Cloud Messaging.
    * **Crashlytics:** Enable Crashlytics.
* **Firebase Configuration Files:**
    * For Android: `google-services.json` (placed in `android/app/`).
    * For iOS: `GoogleService-Info.plist` (placed in `ios/Runner/`).
    * Ensure your Android and iOS project files (`build.gradle`, `AppDelegate.swift`/`.m`) are correctly configured as per the official Firebase Flutter setup guide.

### Installation

1.  **Clone the repository:**
    ```bash
    git clone <repository_url_here>
    cd final_project
    ```

2.  **Install Flutter dependencies:**
    ```bash
    flutter pub get
    ```

### Platform-Specific Configuration

#### Android

1.  **Firebase `google-services.json`:**
    * Download your `google-services.json` file from your Firebase project settings.
    * Place it in the `android/app/` directory of your Flutter project.

2.  **`AndroidManifest.xml` Permissions and Service Declaration:**
    * Open `android/app/src/main/AndroidManifest.xml`.
    * Ensure the following permissions are present within the `<manifest>` tag (outside `<application>`):
        ```xml
        <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
        <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
        <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
        <uses-permission android:name="android.permission.INTERNET" />
        <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/> <uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION"/> ```
    * Inside the `<application>` tag, declare the `BackgroundService`:
        ```xml
        <service
            android:name="dev.flutter.plugins.flutter_background_service.BackgroundService"
            android:foregroundServiceType="location|dataSync"
            android:enabled="true"
            android:exported="false" />
        ```

3.  **ProGuard Rules (Optional but Recommended for Release Builds):**
    * If you encounter issues with release builds, you might need to add ProGuard rules. Refer to Firebase and other plugin documentation for specific rules.

#### iOS

1.  **Firebase `GoogleService-Info.plist`:**
    * Download your `GoogleService-Info.plist` file from your Firebase project settings.
    * Place it in the `ios/Runner/` directory of your Flutter project.

2.  **Xcode Project Settings:**
    * Open your Flutter project in Xcode (`open ios/Runner.xcworkspace`).
    * Select your `Runner` target in the project navigator.
    * Go to the `Signing & Capabilities` tab.
    * Add the following capabilities (by clicking `+ Capability`):
        * **Background Modes:** Enable "Location updates", "Background fetch", and potentially "Remote notifications" (if not already enabled by Firebase).
        * **Push Notifications:** Add this capability.

3.  **`Info.plist` Privacy Descriptions and Background Modes:**
    * Open `ios/Runner/Info.plist`.
    * Add the following keys and their corresponding string values (replace the example strings with your specific reasons):
        ```xml
        <key>NSLocationWhenInUseUsageDescription</key>
        <string>This app needs access to your location when in use for quest check-ins and challenges.</string>
        <key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
        <string>This app needs continuous access to your location to track progress for background quests and challenges, even when the app is not actively in use.</string>
        <key>UIBackgroundModes</key>
        <array>
            <string>fetch</string>
            <string>location</string>
            <string>remote-notification</string> </array>
        ```

### Running the Application

1.  **Connect a physical device or start an emulator/simulator.**
2.  **Run the app from your terminal:**
    ```bash
    flutter run
    ```
    Alternatively, run from your IDE (VS Code, Android Studio).

### Backend Integration

This client-side application is designed to interact with a robust backend for core functionalities like quest management, response validation, scoring, and real-time leaderboard updates. **You will need to implement the backend services separately.**

* **API Endpoints:**
    * Review `lib/data/datasources/remote/api_client.dart` (if you introduce a custom HTTP client for other API calls) and `lib/data/datasources/remote/quest_remote_datasource_impl.dart`. You will need to update any placeholder URLs (e.g., `YOUR_API_BASE_URL`) with your actual backend API base URLs.
* **WebSocket URL:**
    * In `lib/main.dart`, locate the `onStart` background service function. The `wsUrl` variable currently has a placeholder: `ws://your-backend-websocket-url/leaderboard`. **Replace this with the actual WebSocket URL of your live leaderboard service.**
* **FCM Token Management:**
    * The `main.dart` file retrieves the FCM device token. You must implement logic on your backend to receive this token from the client and store it, allowing your backend to send targeted push notifications for quests and announcements.

## Future Enhancements

<!--
Outlines potential areas for future development and expansion.
This shows the scalability and long-term vision for the project.
-->
* **AR Hunt Quest Type:** Implement the Augmented Reality-based scavenger hunt using AR Foundation or similar.
* **Admin Panel UI:** Develop a dedicated Flutter web or mobile UI for the admin panel functionalities, allowing quest creation, user management, and real-time monitoring.
* **Advanced Leaderboard Features:** Implement historical leaderboards, faculty-specific breakdowns, individual user statistics, and more detailed performance metrics.
* **Quest Creation UI for Admins:** Provide a user-friendly interface for administrators to create, edit, schedule, and publish quests directly from the app or a dedicated web portal.
* **User Profile Customization:** Allow users to upload profile pictures, customize their bio, and manage privacy settings.
* **Offline Quest Play:** Enhance local caching and synchronization to allow limited quest participation and progress tracking even without immediate internet connectivity.
* **Expanded Gamification Elements:** Introduce more diverse badges, achievements, in-app currency, and a virtual store for rewards.
* **Social Features:** Enable users to connect with friends, share quest results on social media, form temporary quest teams, or challenge other users.
* **Internationalization:** Implement multi-language support to cater to a diverse campus population.
* **Analytics Dashboard:** Integrate with analytics tools to gain deeper insights into user engagement, quest popularity, and faculty performance trends.


## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
