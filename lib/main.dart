import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/supabase_service.dart';
import 'providers/todo_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/setup/setup_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print('Error loading .env file: $e');
  }

  // Initialize Supabase with environment variables
  try {
    final supabaseUrl = dotenv.env['SUPABASE_URL'];
    final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];
    
    // Check if credentials are properly configured
    if (supabaseUrl == null || supabaseUrl.isEmpty || supabaseUrl.contains('your-project-ref')) {
      print('❌ SUPABASE_URL not configured properly in .env file');
      print('Please update .env with your actual Supabase URL from https://supabase.com/dashboard');
    } else if (supabaseAnonKey == null || supabaseAnonKey.isEmpty || supabaseAnonKey.contains('your-anon-key')) {
      print('❌ SUPABASE_ANON_KEY not configured properly in .env file');
      print('Please update .env with your actual Supabase anon key from https://supabase.com/dashboard');
    } else {
      await SupabaseService.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
      );
      print('✅ Supabase initialized successfully');
    }
  } catch (e) {
    print('❌ Error initializing Supabase: $e');
    print('Please check your Supabase credentials in the .env file');
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    
    return MaterialApp(
      title: 'FocusFlow',
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: themeMode,
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isConfigured = ref.watch(isSupabaseConfiguredProvider);
    
    if (!isConfigured) {
      return const SetupScreen();
    }
    
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    return isAuthenticated ? const HomeScreen() : const LoginScreen();
  }
}


