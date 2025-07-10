import 'package:firebase_core/firebase_core.dart'
    show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) throw UnsupportedError('Web non supportato');
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError('Platform non supportata');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDd8LIxPtI3_X-G3vjG3NBj3ysgXLSVIys',
    appId: '1:920510440937:android:880e5574e2d71a67f1d778',
    messagingSenderId: '920510440937',
    projectId: 'snowfinder-22',
    storageBucket: 'snowfinder-22.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDd8LIxPtI3_X-G3vjG3NBj3ysgXLSVIys',
    appId: '1:920510440937:ios:880e5574e2d71a67f1d778',
    messagingSenderId: '920510440937',
    projectId: 'snowfinder-22',
    storageBucket: 'snowfinder-22.firebasestorage.app',
    iosBundleId: 'com.example.snowfinder_flutter',
  );
}
