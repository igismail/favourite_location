# favourite_location

A Flutter Google Maps app with three saved places in Khulna. Tap a marker for
its details, use **My Location** to center the map on your current position, or
choose a saved place from the phone bottom sheet or the large-screen side panel.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Google Maps API key

Enable the Maps SDK for Android and Maps SDK for iOS for a Google Cloud project,
then provide a restricted API key before running the app.

- Android: pass `-PGOOGLE_MAPS_API_KEY=YOUR_KEY` to the Gradle build, or add
	`GOOGLE_MAPS_API_KEY=YOUR_KEY` to `android/gradle.properties`.
- iOS: set `GOOGLE_MAPS_API_KEY` in the Runner target's build settings or its
	local `.xcconfig` file.

Location permissions are requested when **My Location** is pressed. The app
declares the required Android permissions and iOS usage description.
