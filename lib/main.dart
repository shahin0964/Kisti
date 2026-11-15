import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/kisti_storage.dart';
import 'theme/liquid_glass_theme.dart';
import 'screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Dark immersive status bar and navigation bar styling
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: LiquidGlassTheme.bgDarkVoid,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  final storage = KistiStorage();

  runApp(KistiApp(storage: storage));
}

class KistiApp extends StatelessWidget {
  final KistiStorage storage;

  const KistiApp({super.key, required this.storage});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: storage,
      builder: (context, _) {
        return MaterialApp(
          title: 'Kisti - কিস্তি সেবা',
          debugShowCheckedModeBanner: false,
          theme: LiquidGlassTheme.darkTheme,
          builder: (context, child) {
            final mediaQuery = MediaQuery.of(context);
            // Global compact DPI scaling for edge-to-edge perfect fit on mobile displays
            return MediaQuery(
              data: mediaQuery.copyWith(
                textScaler: const TextScaler.linear(0.90),
              ),
              child: child!,
            );
          },
          home: storage.isLoaded
              ? MainScreen(storage: storage)
              : const Scaffold(
                  backgroundColor: LiquidGlassTheme.bgDarkVoid,
                  body: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        LiquidGlassTheme.neonEmerald,
                      ),
                    ),
                  ),
                ),
        );
      },
    );
  }
}
