import 'package:flutter/material.dart';
import 'screens/scan_screen.dart';

void main() {
  runApp(const MyApp());
}

/// Aplicación principal con tema minimalista (negro + azul eléctrico)
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const electricBlue = Color(0xFF00B0FF);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Escanear dibujo',
      theme: ThemeData(
        // Base oscuro
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        primaryColor: electricBlue,
        colorScheme: ColorScheme.dark(
          primary: electricBlue,
          secondary: electricBlue,
        ),
        // Botones grandes y minimalistas
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: electricBlue,
            foregroundColor: Colors.black,
            shape: const CircleBorder(),
            elevation: 6,
          ),
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          bodySmall: TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

/// Pantalla principal limpia y centrada.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Escanear dibujo',
                style: theme.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Botón grande con icono de cámara
              SizedBox(
                width: 140,
                height: 140,
                child: ElevatedButton(
                  onPressed: () {
                    // Navegar a la pantalla de escaneo
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ScanScreen()),
                    );
                  },
                  child: const Icon(
                    Icons.camera_alt,
                    size: 56,
                  ),
                ),
              ),

              const SizedBox(height: 16),
              const Text(
                'Apunta al dibujo para detectar la figura',
                style: TextStyle(fontSize: 13, color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

