import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return android;
  }

  // static const FirebaseOptions android = FirebaseOptions(
  //   apiKey: 'placeholder-api-key',
  //   appId: '1:1234567890:android:1234567890',
  //   messagingSenderId: '1234567890',
  //   projectId: 'placeholder-project-id',
  //   storageBucket: '://appspot.com',
  // );

  static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'AIzaSyD4QGCEEkXSnDrzdnWEY6lnpJct54Bq_xc',
  appId: '1:792513014274:android:64e58bcc09b7147757551b',
  messagingSenderId: '792513014274',
  projectId: 'temple-management-app-master',
  storageBucket: 'temple-management-app-master.firebasestorage.app',
);

}