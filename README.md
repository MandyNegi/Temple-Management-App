# Temple Management App

Temple Management App is a Flutter-based mobile application for GFSC Township Charitable Trust Temple in Jamnagar. It provides a modern digital experience for temple visitors and administrators with features such as browsing temple events, managing donations, booking pooja slots, and handling temple-related services.

## What’s included

- Home dashboard with animated slider, featured tiles, and live darshan sections
- Books management module with inventory, sales, and reports
- Sewa management module with Firestore-backed programs and details
- Donation flow with Razorpay integration
- Slot booking for pooja services
- Contact, circulars, gallery, and about us screens
- Firebase-backed data for temple events, slider images, and sewa programs

## Tech stack

- Flutter / Dart
- Firebase Firestore, Firebase Auth, Firebase Storage
- GetX for navigation and state management
- Razorpay for payments
- Google Maps and location services
- Custom UI components and reusable widgets

## Getting started

1. Clone the repository
   ```bash
   git clone https://github.com/MandyNegi/Temple-Management-App.git
   cd Temple-Management-App-master
   ```

2. Install dependencies
   ```bash
   flutter pub get
   ```

3. Configure Firebase
   - Create a Firebase project
   - Enable Firestore, Authentication, and Storage if required
   - Add your Firebase configuration files such as google-services.json and firebase_options.dart

4. Configure payment and location services
   - Create a Razorpay account and add your API keys
   - Configure any required Google Maps / location permissions for the device platform

5. Run the app
   ```bash
   flutter run
   ```

## Project structure

- lib/main.dart - app entry point
- lib/screens - all main screens and pages
- lib/services - Firebase and backend service logic
- lib/models - data models
- lib/routes - route definitions
- lib/widget - reusable UI widgets
- lib/utils - colors, constants, dimensions, and helpers

## Notes

- Some features depend on Firebase data being present in your Firestore database.
- Local secrets, signing files, and build artifacts should be kept out of version control using the repository ignore rules.

## Support

If you have any questions or run into issues, please contact the project maintainer at mandeepnegi010@gmail.com.
