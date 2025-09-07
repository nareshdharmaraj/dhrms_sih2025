import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/auth/role_selection_screen.dart';
import 'presentation/providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyHealthApp());
}

class MyHealthApp extends StatelessWidget {
  const MyHealthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            final authProvider = AuthProvider();
            authProvider.initializeAuth(); // Initialize auth state
            return authProvider;
          },
        ),
      ],
      child: MaterialApp(
        title: 'MyHealth - DHRMS',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const RoleSelectionScreen(),
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: MediaQuery.of(
                context,
              ).textScaler.clamp(minScaleFactor: 0.8, maxScaleFactor: 2.0),
            ),
            child: child!,
          );
        },
      ),
    );
  }
}
