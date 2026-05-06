import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBYrhugVRRszhqPOxgpUe9LsJsve6JepF0',
    appId: '1:1090764921089:web:7a66f225b7f71d11c2e300',
    messagingSenderId: '1090764921089',
    projectId: 'final-year-project-88064',
    authDomain: 'final-year-project-88064.firebaseapp.com',
    storageBucket: 'final-year-project-88064.firebasestorage.app',
    measurementId: 'G-BWF55T94VH',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBYrhugVRRszhqPOxgpUe9LsJsve6JepF0',
    appId: '1:1090764921089:web:7a66f225b7f71d11c2e300',
    messagingSenderId: '1090764921089',
    projectId: 'final-year-project-88064',
    storageBucket: 'final-year-project-88064.firebasestorage.app',
  );
}
