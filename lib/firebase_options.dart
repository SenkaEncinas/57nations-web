import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCo8ka4daUkfXkqefgeRAENZxnSjy_okIw',
    appId: '1:362244352362:web:a811525bfd3ee5fcc9dd13',
    messagingSenderId: '362244352362',
    projectId: 'nations-2b049',
    authDomain: 'nations-2b049.firebaseapp.com',
    storageBucket: 'nations-2b049.firebasestorage.app',
    measurementId: 'G-BJNPNFWSV6',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBj3YFbtCtULu8LrzzT7wrU-QNSkNDq71I',
    appId: '1:362244352362:android:29c9b457c4fb8fe5c9dd13',
    messagingSenderId: '362244352362',
    projectId: 'nations-2b049',
    storageBucket: 'nations-2b049.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDEXVfQ1s5T7YzK9lFq1aRxWxN8pQjKmL0',
    appId: '1:123456789012:ios:abc123def456',
    messagingSenderId: '123456789012',
    projectId: 'your-project-id',
    storageBucket: 'your-project.appspot.com',
    iosBundleId: 'com.example.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDEXVfQ1s5T7YzK9lFq1aRxWxN8pQjKmL0',
    appId: '1:123456789012:ios:abc123def456',
    messagingSenderId: '123456789012',
    projectId: 'your-project-id',
    storageBucket: 'your-project.appspot.com',
    iosBundleId: 'com.example.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCo8ka4daUkfXkqefgeRAENZxnSjy_okIw',
    appId: '1:362244352362:web:48ce39621fda0d3fc9dd13',
    messagingSenderId: '362244352362',
    projectId: 'nations-2b049',
    authDomain: 'nations-2b049.firebaseapp.com',
    storageBucket: 'nations-2b049.firebasestorage.app',
    measurementId: 'G-Q1GMMTP99E',
  );
}