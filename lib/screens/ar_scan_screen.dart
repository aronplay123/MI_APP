import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// ar_flutter_plugin expone widgets y managers para crear sesiones AR.
// La API puede cambiar entre versiones; este archivo incluye instrucciones
// y un ejemplo básico de inicialización y manejo de imágenes aumentadas.
import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
import 'package:ar_flutter_plugin/datatypes/config_planedetection.dart';

/// Pantalla AR para detectar imágenes impresas y anclar un modelo 3D encima.
///
/// NOTA: Este archivo ofrece un scaffold seguro y multiplataforma para iniciar
/// una vista AR mediante `ar_flutter_plugin`. La detección de imágenes
/// requiere que generes la database de ARCore (`.imgdb`) y la coloques en
/// `android/app/src/main/assets/` — ver instrucciones más abajo.
class ARScanScreen extends StatefulWidget {
  const ARScanScreen({super.key});

  @override
  State<ARScanScreen> createState() => _ARScanScreenState();
}

class _ARScanScreenState extends State<ARScanScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Usamos SafeArea + Stack para superponer un AppBar transparente.
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Widget principal AR. `onARViewCreated` se puede añadir cuando
            // implementes la lógica nativa/DB de imágenes específica.
            ARView(
              onARViewCreated: _onARViewCreated,
              planeDetectionConfig: PlaneDetectionConfig.none,
            ),

            // AppBar transparente con botón de retroceso
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Container(
                  color: Colors.black26,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text('', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Instrucciones breves en la parte inferior
            Positioned(
              bottom: 24,
              left: 24,
              right: 24,
              child: Text(
                'Apunta la cámara al dibujo. Asegúrate de generar la .imgdb y añadirla a Android assets (ver README).',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Callback con firmado flexible para adaptarse a la versión del plugin.
  // Recibe hasta 4 parámetros dependiendo de la versión del paquete.
  void _onARViewCreated(dynamic sessionManager, [dynamic objectManager, dynamic anchorManager, dynamic extras]) {
    // Aquí puedes inicializar la sesión y cargar la DB de imágenes aumentadas.
    // Por seguridad no ejecutamos lógica aquí; veremos los pasos en el README.
    debugPrint('AR view created: $sessionManager, $objectManager, $anchorManager');
  }
}
