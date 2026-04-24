import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';
import 'config/theme.dart';
import 'config/routes.dart';
import 'config/app_localizations.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/chat_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CronosApp());
}

class CronosApp extends StatelessWidget {
  const CronosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => AppLocalizations()),
      ],
      child: ToastificationWrapper(
        child: Builder(
          builder: (context) {
            final auth = context.watch<AuthProvider>();
            // Watch locale so the whole app rebuilds on language change
            context.watch<AppLocalizations>();
            final router = createRouter(auth);
            return MaterialApp.router(
              title: 'CRONOS - Crustacean Origin Network Oversight System',
              debugShowCheckedModeBanner: false,
              theme: CronosTheme.lightTheme,
              routerConfig: router,
            );
          },
        ),
      ),
    );
  }
}
