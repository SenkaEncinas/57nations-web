import 'package:flutter/material.dart';
import '../../widgets/widgets.dart';

class BotsScreen extends StatelessWidget {
  const BotsScreen({super.key});

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
                child: Text('Pantalla Bots & Sistemas - EN CONSTRUCCIÓN'),
              ),
            ),
            Footer(),
          ],
        ),
      ),
    );
  }
}
