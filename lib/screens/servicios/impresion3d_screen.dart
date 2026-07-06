import 'package:flutter/material.dart';
import '../../widgets/widgets.dart';

class Impresion3dScreen extends StatelessWidget {
  const Impresion3dScreen({Key? key}) : super(key: key);

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
                child: Text('Pantalla Impresión 3D - EN CONSTRUCCIÓN'),
              ),
            ),
            const Footer(),
          ],
        ),
      ),
    );
  }
}
