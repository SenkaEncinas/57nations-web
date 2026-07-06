import 'package:flutter/material.dart';
import '../../widgets/widgets.dart';

class PortfolioScreen extends StatelessWidget {
  const PortfolioScreen({Key? key}) : super(key: key);

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
                child: Text('Pantalla Portfolio - EN CONSTRUCCIÓN'),
              ),
            ),
            const Footer(),
          ],
        ),
      ),
    );
  }
}
