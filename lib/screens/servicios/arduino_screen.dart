import 'package:flutter/material.dart';
import '../../widgets/widgets.dart';

class ArduinoScreen extends StatelessWidget {
  const ArduinoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const NavBar(),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(60),
                child: Text('Pantalla Arduino & ESP32 - EN CONSTRUCCIÓN'),
              ),
            ),
            const Footer(),
          ],
        ),
      ),
    );
  }
}
