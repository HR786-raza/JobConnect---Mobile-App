import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;

// Config
import 'config/routes.dart';
import 'config/app_config.dart';
// import 'config/firebase_config.dart';

// Firebase Options
import 'firebase_options.dart';

// Providers
import 'providers/auth_provider.dart' as app;
import 'providers/theme_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/job_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/notification_provider.dart';

// Services
import 'services/notification_service.dart';
import 'services/firebase_service.dart';

// Screens
import 'screens/splash/splash_screen.dart';

// Extensions
// import 'utils/extensions.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize Firebase with platform-specific options
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Initialize Firebase Service
    await FirebaseService.initialize();
    
    // Initialize Notifications (skip on web if not supported)
    if (!kIsWeb || (kIsWeb && await _isWebNotificationSupported())) {
      await NotificationService.initialize();
      
      // Request notification permissions
      await _requestNotificationPermissions();
      
      // Setup Firebase Messaging Handlers
      _setupFirebaseMessaging();
    } else {
      debugPrint('Web notifications not supported');
    }
    
  } catch (e) {
    debugPrint('Error initializing app: $e');
  }
  
  runApp(const MyApp());
}

// Check if web notifications are supported
Future<bool> _isWebNotificationSupported() async {
  try {
    return await FirebaseMessaging.instance.isSupported();
  } catch (e) {
    return false;
  }
}

Future<void> _requestNotificationPermissions() async {
  try {
    final messaging = FirebaseMessaging.instance;
    
    NotificationSettings settings;
    
    if (kIsWeb) {
      settings = await messaging.requestPermission();
    } else {
      settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
    }
    
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('Notification permissions granted');
      
      String? token = await messaging.getToken();
      debugPrint('FCM Token: $token');
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fcm_token', token ?? '');
      
      await _updateFCMToken(token);
    } else {
      debugPrint('Notification permissions denied');
    }
  } catch (e) {
    debugPrint('Error requesting notification permissions: $e');
  }
}

// In your main.dart, modify the _setupFirebaseMessaging method:

void _setupFirebaseMessaging() {
  try {
    final messaging = FirebaseMessaging.instance;
    
    // Check if web notifications are supported before setting up
    if (kIsWeb) {
      // For web, we need to check if service worker is supported
      try {
        // This will trigger service worker registration
        messaging.getToken().then((token) {
          if (token != null) {
            debugPrint('FCM Token for web: $token');
          }
        }).catchError((error) {
          debugPrint('Web FCM initialization failed (non-critical): $error');
          // Don't throw - this is non-critical for web
        });
      } catch (e) {
        debugPrint('Web FCM not fully supported: $e');
        // Continue app initialization - notifications are optional on web
      }
    }
    
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Foreground message received: ${message.messageId}');
      NotificationService.handleForegroundMessage(message);
    });

    // Handle background messages - only on mobile platforms
    if (!kIsWeb) {
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    }

    // Handle when app is opened from terminated state
    messaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        debugPrint('App opened from terminated state: ${message.messageId}');
        _handleNotificationNavigation(message);
      }
    });

    // Handle when app is in background and opened
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('App opened from background: ${message.messageId}');
      _handleNotificationNavigation(message);
    });

    // Handle token refresh
    messaging.onTokenRefresh.listen((String newToken) {
      debugPrint('FCM Token refreshed: $newToken');
      _updateFCMToken(newToken);
    });
    
  } catch (e) {
    debugPrint('Error setting up Firebase Messaging (non-critical): $e');
    // Don't rethrow - allow app to continue without notifications
  }
}

void _handleNotificationNavigation(RemoteMessage message) {
  debugPrint('Navigate with data: ${message.data}');
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Handling background message: ${message.messageId}');
  await NotificationService.handleBackgroundMessage(message);
}

Future<void> _updateFCMToken(String? token) async {
  if (token == null) return;
  
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fcm_token', token);
  } catch (e) {
    debugPrint('Error updating FCM token: $e');
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    themeProvider.onPlatformBrightnessChanged();
    super.didChangePlatformBrightness();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => app.AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => JobProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: Consumer3<ThemeProvider, LocaleProvider, app.AuthProvider>(
        builder: (context, themeProvider, localeProvider, authProvider, child) {
          return MaterialApp(
            title: AppConfig.appName,
            debugShowCheckedModeBanner: false,
            
            theme: _buildLightTheme(),
            darkTheme: _buildDarkTheme(),
            themeMode: themeProvider.themeMode,
            
            locale: localeProvider.locale,
            supportedLocales: const [
              Locale('en', 'US'),
              Locale('es', 'ES'),
              Locale('fr', 'FR'),
              Locale('de', 'DE'),
              Locale('zh', 'CN'),
              Locale('ja', 'JP'),
              Locale('ar', 'SA'),
              Locale('hi', 'IN'),
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            
            initialRoute: AppRoutes.splash,
            onGenerateRoute: AppRoutes.generateRoute,
            home: const SplashScreen(),
            navigatorObservers: const [],
            
            builder: (context, child) {
              return Directionality(
                textDirection: localeProvider.textDirection,
                child: child!,
              );
            },
          );
        },
      ),
    );
  }

  // Light Theme
  ThemeData _buildLightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.blue,
      fontFamily: 'Poppins',
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.black),
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      // cardTheme: const CardTheme(
      //   elevation: 2,
      //   shape: RoundedRectangleBorder(
      //     borderRadius: BorderRadius.all(Radius.circular(12)),
      //   ),
      //   clipBehavior: Clip.antiAlias,
      //   color: Colors.white,
      // ),
    );
  }

  // Dark Theme
  ThemeData _buildDarkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      primarySwatch: Colors.blue,
      fontFamily: 'Poppins',
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.blue.shade700,
          foregroundColor: Colors.white,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey.shade800,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      // cardTheme: CardTheme(
      //   elevation: 2,
      //   shape: const RoundedRectangleBorder(
      //     borderRadius: BorderRadius.all(Radius.circular(12)),
      //   ),
      //   clipBehavior: Clip.antiAlias,
      //   color: Colors.grey.shade900,
      // ),
    );
  }
}