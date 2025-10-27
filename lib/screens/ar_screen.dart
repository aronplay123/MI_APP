import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:flutter/material.dart' hide Colors;
import 'package:vector_math/vector_math_64.dart';

class ArScreen extends StatefulWidget {
  const ArScreen({super.key});

  @override
  _ArScreenState createState() => _ArScreenState();
}

class _ArScreenState extends State<ArScreen> {
  ArCoreController? arCoreController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AR Scanner'),
      ),
      body: ArCoreView(
        onArCoreViewCreated: _onArCoreViewCreated,
        enableTapRecognizer: true,
      ),
    );
  }

  void _onArCoreViewCreated(ArCoreController controller) {
    arCoreController = controller;
    controller.onNodeTap = (name) => _onTapHandler(name);
    controller.onPlaneTap = _handleOnPlaneTap;
  }

  void _onTapHandler(String name) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        content: Text('Tapped $name'),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  void _handleOnPlaneTap(List<ArCoreHitTestResult> hits) {
    final hit = hits.first;
    _addCube(hit);
  }

  void _addCube(ArCoreHitTestResult hit) {
    final material = ArCoreMaterial(
      color: Color.fromARGB(255, 33, 150, 243),
      metallic: 1.0,
    );
    final cube = ArCoreCube(
      materials: [material],
      size: Vector3(0.5, 0.5, 0.5),
    );
    final node = ArCoreNode(
      shape: cube,
      position: hit.pose.translation,
      rotation: hit.pose.rotation,
    );
    arCoreController?.addArCoreNode(node);
  }

  @override
  void dispose() {
    arCoreController?.dispose();
    super.dispose();
  }
}