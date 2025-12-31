import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

class Environment {
  // 🌍 Environment Configuration
  // Change this to switch between development and production
  static const bool isDevelopment = kDebugMode; // Auto-detect based on debug mode
  
  // 🔧 Manual Override (set to true to force production URL even in debug mode)
  static const bool forceProduction = false;
  
  // 🖥️ Your Mac's Local IP Address
  // Auto-detected: 192.168.31.123
  // This works for: iPhone (USB/WiFi), Android devices, iPad, etc.
  static const String macIpAddress = '192.168.31.123';
  
  // 📡 API URLs
  static const String productionUrl = 'http://148.135.136.17:3002';
  
  // 🎯 Smart Development URL (auto-selects based on platform)
  static String get developmentUrl {
    if (kIsWeb) {
      // Web browser - use localhost
      return 'http://localhost:3000';
    }
    
    try {
      if (Platform.isIOS || Platform.isAndroid) {
        // Physical devices (iPhone, iPad, Android phones)
        // Use Mac's IP address so device can reach the server
        return 'http://$macIpAddress:3000';
      } else if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
        // Desktop apps - use localhost
        return 'http://localhost:3000';
      }
    } catch (e) {
      // Fallback if Platform is not available
      return 'http://localhost:3000';
    }
    
    return 'http://localhost:3000';
  }
  
  // 🎯 Get Active Base URL
  static String get baseUrl {
    if (forceProduction) {
      return productionUrl;
    }
    return isDevelopment ? developmentUrl : productionUrl;
  }
  
  // 📝 Environment Info
  static String get environmentName {
    if (forceProduction) return 'Production (Forced)';
    return isDevelopment ? 'Development' : 'Production';
  }
  
  // 🔍 Debug Info
  static void printEnvironmentInfo() {
    if (kDebugMode) {
      String platform = 'Unknown';
      try {
        if (kIsWeb) {
          platform = 'Web Browser';
        } else if (Platform.isIOS) {
          platform = 'iOS (iPhone/iPad)';
        } else if (Platform.isAndroid) {
          platform = 'Android';
        } else if (Platform.isMacOS) {
          platform = 'macOS Desktop';
        } else if (Platform.isWindows) {
          platform = 'Windows Desktop';
        } else if (Platform.isLinux) {
          platform = 'Linux Desktop';
        }
      } catch (e) {
        platform = 'Web';
      }
      
      print('═══════════════════════════════════════════════');
      print('🌍 Environment: ${environmentName}');
      print('📱 Platform: $platform');
      print('📡 Base URL: ${baseUrl}');
      print('🔧 Debug Mode: ${kDebugMode}');
      print('🎯 Force Production: ${forceProduction}');
      print('═══════════════════════════════════════════════');
    }
  }
  
  // 💡 Platform-specific URLs for different scenarios:
  // 
  // 🖥️ DEVELOPMENT (Flutter Desktop/Web):
  // - macOS/Windows/Linux: http://localhost:3000
  // - Chrome Web: http://localhost:3000
  //
  // 📱 MOBILE DEVELOPMENT:
  // - Android Emulator: http://10.0.2.2:3000 (Special IP for emulator to access host)
  // - iOS Simulator: http://localhost:3000 (Can access host's localhost)
  // - Physical Device (Same WiFi): http://YOUR_MAC_IP:3000 (e.g., 192.168.1.100:3000)
  //
  // 🚀 PRODUCTION (APK/IPA):
  // - Production Server: http://148.135.136.17:3002
  //
  // 🎯 To test on Android Emulator:
  // Change developmentUrl to: 'http://10.0.2.2:3000'
  //
  // 🎯 To test on Physical Device:
  // Find your Mac's IP: System Preferences > Network
  // Change developmentUrl to: 'http://YOUR_IP:3000'
  // Example: 'http://192.168.1.100:3000'
  
  // 🔄 Get platform-appropriate development URL
  static String get platformDevelopmentUrl {
    // You can add platform-specific logic here if needed
    // For now, we use localhost which works for most scenarios
    return developmentUrl;
  }
}
