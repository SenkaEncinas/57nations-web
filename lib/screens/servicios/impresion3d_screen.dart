import 'package:flutter/material.dart';
import '../../widgets/widgets.dart';

class Impresion3dScreen extends StatelessWidget {
  const Impresion3dScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            NavBar(),
            Center(
              child: Padding(
                padding: EdgeInsets.all(60),
                child: Text('Pantalla Impresión 3D - EN CONSTRUCCIÓN'),
              ),
            ),
            Footer(),
          ],
        ),
      ),
    );
  }
}
