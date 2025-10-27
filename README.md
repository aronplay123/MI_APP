
# mi_app

Aplicación Flutter orientada a pruebas de cámara y detección (MVP).

## Descripción

Este repositorio contiene una app Flutter que actualmente integra funcionalidades
básicas de cámara: preview en tiempo real, captura de fotos, cambio de cámara y
control de flash. Fue el resultado de simplificar una idea inicial de AR/ML a
una implementación de cámara para poder iterar rápidamente en dispositivos
reales (por ejemplo, un Samsung A50).

## Características actuales

- Preview de cámara en tiempo real
- Captura de imágenes y guardado en caché de la app
- Cambio entre cámara frontal y trasera
- Control básico del flash

## Requisitos

- Flutter (estable) instalado
- Android SDK / dispositivos con USB debugging activado (o emulador)
- En Windows, la shell por defecto es PowerShell (pwsh)

## Cómo ejecutar (Android)

Abra una terminal en la carpeta del proyecto y ejecute:

```powershell
# Obtener dependencias
flutter pub get

# Limpiar build y ejecutar en dispositivo conectado (ej: Samsung A50)
flutter clean
flutter run -d <device_id>

# Para generar un APK de debug
flutter build apk --debug
```

Sustituya `<device_id>` por el id mostrado en `flutter devices` o por el id
de su dispositivo conectado. En los logs se muestra cuando la app toma
fotos y la ruta donde se guardan (ej: `/data/user/0/com.example.mi_app/cache/`).

## Permisos importantes

- Android: asegúrese de que `android/app/src/main/AndroidManifest.xml`
	contiene permisos de cámara y almacenamiento si los necesita:

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
```

- iOS: agregue descripciones en `ios/Runner/Info.plist` para `NSCameraUsageDescription`
	y `NSMicrophoneUsageDescription` si aplica.

## Problemas conocidos y soluciones rápidas

- "Unable to establish connection on channel: dev.flutter.pigeon.camera_android.CameraApi.takePicture"
	- Suele ocurrir cuando `ImageReader` no fue inicializado o la sesión de cámara
		fue cerrada abruptamente. En muchos casos volver a inicializar la cámara o
		evitar múltiples llamadas concurrentes a `takePicture` reduce la incidencia.
	- Asegúrese de usar una única instancia del controlador de la cámara y de
		esperar a que la inicialización termine antes de capturar.

- Logs sobre `androidx.window.sidecar.SidecarInterface$SidecarCallback` (NoClassDefFound)
	- No suele bloquear la app pero aparece en algunos dispositivos OEM. Si causa
		problemas persistentes, actualizar la dependencia `androidx.window:window` o
		revisar versiones de los plugins que usan `androidx.window` puede ayudar.

- RejectedExecutionException en finalizers de Camera2
	- Son avisos de recursos que intentan liberarse al cerrar la cámara. En la
		práctica, si la app funciona (preview + capturas) pueden no requerir acción
		inmediata; sin embargo, revisar que `dispose()` del controlador de cámara se
		llame correctamente al salir de la pantalla mejora la estabilidad.

## Desarrollo y próximas mejoras

- Preparar dataset de imágenes para detección (3–10 ejemplos por dibujo).
- Volver a intentar AR image-tracking (ARCore/ARKit) o entrenar un modelo TFLite
	para detectar dibujos en la escena.
- Añadir tests automáticos y un pequeño script que verifique la cámara en CI

## Contribuir

1. Haga fork y abra un PR.
2. Describa el dispositivo y pasos para reproducir cualquier bug.

## Contacto

Si quieres que integre la detección de dibujos (AR o ML) o que añada ejemplos
para procesar las imágenes capturadas, dime qué preferes y lo implemento.

---
Pequeña nota: este README se añadió/actualizó automáticamente para dar
instrucciones claras sobre ejecución y depuración de la funcionalidad de
cámara que ya está implementada en el proyecto.
