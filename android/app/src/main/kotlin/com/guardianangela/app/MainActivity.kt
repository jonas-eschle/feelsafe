package com.guardianangela.app

import io.flutter.embedding.android.FlutterFragmentActivity

// FlutterFragmentActivity (not FlutterActivity) is required by `local_auth`:
// its BiometricPrompt is hosted by a FragmentActivity. The base class does not
// affect platform-channel registration (channels attach in
// configureFlutterEngine regardless of the host activity type).
class MainActivity : FlutterFragmentActivity()
