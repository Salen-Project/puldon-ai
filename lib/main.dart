import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart' as provider;
import 'core/theme/app_theme.dart';
import 'core/constants/app_config.dart';
import 'providers/financial_data_provider.dart';
import 'providers/api_integrated_financial_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/currency_provider.dart';
import 'data/repositories/chat_repository.dart';
import 'data/repositories/dashboard_repository.dart';
import 'data/repositories/goal_repository.dart';
import 'data/repositories/expense_repository.dart';
import 'data/repositories/debt_repository.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/home/home_screen.dart';
import 'presentation/screens/auth/signin_screen.dart';
import 'presentation/providers/auth_state_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for local storage and caching (in background)
  Hive.initFlutter().catchError((e) {
    print('Hive init error (non-critical): $e');
  });

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Lock orientation to portrait
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Wrap app with ProviderScope for Riverpod
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Check if we're in API mode and user is authenticated
    final authState = ref.watch(authStateProvider);
    final useRealData = !AppConfig.useMockData && authState.isAuthenticated;

    return provider.MultiProvider(
      // Use key to force recreation when auth state changes
      key: ValueKey('multiProvider_auth_${authState.isAuthenticated}'),
      providers: [
        // Financial Data Provider - use real API if authenticated
        provider.ChangeNotifierProxyProvider<Object?, FinancialDataProvider>(
          create: (_) {
            if (useRealData) {
              // Use API-integrated provider when authenticated
              print('🔄 Creating API-integrated financial provider');
              final apiProvider = ApiIntegratedFinancialProvider(
                dashboardRepo: ref.read(dashboardRepositoryProvider),
                goalRepo: ref.read(goalRepositoryProvider),
                expenseRepo: ref.read(expenseRepositoryProvider),
                debtRepo: ref.read(debtRepositoryProvider),
              );
              WidgetsBinding.instance.addPostFrameCallback((_) {
                apiProvider.initialize();
              });
              return apiProvider as FinancialDataProvider;
            } else {
              // Use mock provider when not authenticated
              print('🔄 Creating mock financial provider');
              final financialProvider = FinancialDataProvider();
              WidgetsBinding.instance.addPostFrameCallback((_) {
                financialProvider.initialize();
              });
              return financialProvider;
            }
          },
          update: (context, _, previous) {
            // Recreate provider when auth state changes
            if (useRealData) {
              final apiProvider = ApiIntegratedFinancialProvider(
                dashboardRepo: ref.read(dashboardRepositoryProvider),
                goalRepo: ref.read(goalRepositoryProvider),
                expenseRepo: ref.read(expenseRepositoryProvider),
                debtRepo: ref.read(debtRepositoryProvider),
              );
              apiProvider.initialize();
              return apiProvider as FinancialDataProvider;
            } else {
              return previous ?? FinancialDataProvider()..initialize();
            }
          },
        ),
        // Chat Provider - update repository when auth changes
        provider.ChangeNotifierProvider<ChatProvider>(
          create: (_) => ChatProvider(
            chatRepository: useRealData ? ref.read(chatRepositoryProvider) : null,
          ),
          lazy: false, // Create immediately to ensure auth state is applied
        ),
        provider.ChangeNotifierProvider(create: (_) => CurrencyProvider()),
      ],
      child: MaterialApp(
        title: 'Puldon',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const AppInitializer(),
      ),
    );
  }
}

class AppInitializer extends ConsumerStatefulWidget {
  const AppInitializer({super.key});

  @override
  ConsumerState<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends ConsumerState<AppInitializer> {
  bool _showSplash = true;

  @override
  Widget build(BuildContext context) {
    // Always show splash screen first
    if (_showSplash) {
      return SplashScreen(
        onComplete: () {
          if (mounted) {
            setState(() {
              _showSplash = false;
            });
          }
        },
      );
    }

    // After splash, watch auth state (non-blocking)
    final authState = ref.watch(authStateProvider);

    // Show sign-in screen by default while auth is being checked
    // This prevents blank screens or freezing
    return authState.isAuthenticated && authState.user != null
        ? const HomeScreen()
        : const SignInScreen();
  }
}
