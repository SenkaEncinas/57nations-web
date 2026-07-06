import 'package:flutter/material.dart';
import '../../widgets/widgets.dart';

class FlutterScreen extends StatelessWidget {
  const FlutterScreen({super.key});

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
                child: Text('Pantalla Apps Flutter - EN CONSTRUCCIÓN'),
              ),
            ),
            Footer(),
          ],
        ),
      ),
    );
  }
}
