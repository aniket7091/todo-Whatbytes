import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      default:
        return android;
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDH__EEFEHnhm7cQMoqhpSsqPr-4uLFMwg',
    appId: '1:760875832530:android:70f7628736dd6cbc3fc90b',
    messagingSenderId: '760875832530',
    projectId: 'solo2duo-fddeb',
    storageBucket: 'solo2duo-fddeb.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA5jHhuEpXdifd3eA9KX1TRwP9eYjYG358',
    appId: '1:760875832530:ios:6b42a580059f14143fc90b',
    messagingSenderId: '760875832530',
    projectId: 'solo2duo-fddeb',
    storageBucket: 'solo2duo-fddeb.firebasestorage.app',
    iosBundleId: 'com.example.todo',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyA5jHhuEpXdifd3eA9KX1TRwP9eYjYG358',
    appId: '1:760875832530:ios:6b42a580059f14143fc90b',
    messagingSenderId: '760875832530',
    projectId: 'solo2duo-fddeb',
    storageBucket: 'solo2duo-fddeb.firebasestorage.app',
    iosBundleId: 'com.example.todo',
  );
}
