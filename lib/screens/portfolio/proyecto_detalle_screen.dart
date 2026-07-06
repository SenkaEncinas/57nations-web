import 'package:flutter/material.dart';
import '../../widgets/widgets.dart';

class ProyectoDetalleScreen extends StatelessWidget {
  final String proyectoId;

  const ProyectoDetalleScreen({
    super.key,
    required this.proyectoId,
  });

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
                child: Text('Pantalla Detalle de Proyecto - EN CONSTRUCCIÓN'),
              ),
            ),
            Footer(),
          ],
        ),
      ),
    );
  }
}
