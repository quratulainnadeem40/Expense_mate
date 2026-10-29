package com.innovexa.expensemate

import io.flutter.embedding.android.FlutterFragmentActivity

// local_auth needs a FragmentActivity to show the system biometric
// sheet. FlutterActivity is not one, and the prompt fails silently
// without this change.
class MainActivity : FlutterFragmentActivity()
