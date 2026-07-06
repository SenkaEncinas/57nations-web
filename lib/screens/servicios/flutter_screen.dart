import 'package:flutter/material.dart';
import '../../widgets/widgets.dart';

class FlutterScreen extends StatelessWidget {
  const FlutterScreen({Key? key}) : super(key: key);

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
                child: Text('Pantalla Apps Flutter - EN CONSTRUCCIÓN'),
              ),
            ),
            const Footer(),
          ],
        ),
      ),
    );
  }
}
