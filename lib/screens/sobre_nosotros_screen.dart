import 'package:flutter/material.dart';
import '../widgets/widgets.dart';

class SobreNosotrosScreen extends StatelessWidget {
  const SobreNosotrosScreen({Key? key}) : super(key: key);

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
                child: Text('Pantalla Sobre Nosotros - EN CONSTRUCCIÓN'),
              ),
            ),
            const Footer(),
          ],
        ),
      ),
    );
  }
}
