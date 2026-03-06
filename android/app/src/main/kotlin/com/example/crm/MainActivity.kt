package com.example.crm

import android.os.Bundle
import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        // Install and immediately dismiss native splash screen
        installSplashScreen()
        super.onCreate(savedInstanceState)
    }
}
