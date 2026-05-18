// lib/main.dart
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'providers/auth_provider.dart';
import 'providers/item_provider.dart';
import 'providers/message_provider.dart';
import 'providers/team_provider.dart';

import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/team_screen.dart';
import 'utils/constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TeamProvider()),
        ChangeNotifierProvider(create: (_) => ItemProvider()),
        ChangeNotifierProvider(create: (_) => MessageProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoading = true;
  Widget _initialScreen = const LoginScreen();

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final authProvider = context.read<AuthProvider>();
    final teamProvider = context.read<TeamProvider>();
    
    // Cek session Supabase saat app start
    final session = Supabase.instance.client.auth.currentSession;
    
    if (session != null) {
      await authProvider.loadCurrentUser();
      await teamProvider.loadUserTeams();
      
      if (teamProvider.teams.isNotEmpty) {
        teamProvider.setActiveTeam(teamProvider.teams.first);
        _initialScreen = const HomeScreen();
      } else {
        _initialScreen = const TeamScreen();
      }
    } else {
      _initialScreen = const LoginScreen();
    }
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'CRUD App W13L',
      debugShowCheckedModeBanner: false,
      theme: const CupertinoThemeData(
        primaryColor: CupertinoColors.systemBlue,
        brightness: Brightness.light,
        textTheme: CupertinoTextThemeData(
          primaryColor: CupertinoColors.systemBlue,
        ),
      ),
      home: _isLoading
          ? const CupertinoPageScaffold(
              child: Center(
                child: CupertinoActivityIndicator(),
              ),
            )
          : _initialScreen,
    );
  }
}
