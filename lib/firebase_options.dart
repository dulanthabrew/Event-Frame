// THIS FILE IS GENERATED — Replace with your actual Firebase config
// Run: flutterfire configure
// See: https://firebase.flutter.dev/docs/cli/

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // ⚠️ REPLACE with your actual Firebase project values from:
  // Firebase Console → Project Settings → Your Apps

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBDONH3PoAAsjyePWzU6xxeLwsiA919wCg',
    appId: '1:21331862028:web:eacb9d7edc146532d18429',
    messagingSenderId: '21331862028',
    projectId: 'event-frame-project',
    authDomain: 'event-frame-project.firebaseapp.com',
    storageBucket: 'event-frame-project.firebasestorage.app',
    measurementId: 'G-B3V6QS2V4V',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD-yxQQaY_2VWA_9raBCD-GxbrWI8Mc6yU',
    appId: '1:21331862028:android:96033f0f5e357697d18429',
    messagingSenderId: '21331862028',
    projectId: 'event-frame-project',
    storageBucket: 'event-frame-project.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: 'YOUR_IOS_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_PROJECT_ID.appspot.com',
    iosBundleId: 'com.eventframe.app',
  );
}