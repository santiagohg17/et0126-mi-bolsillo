import 'package:flutter/material.dart';

// Encabezado con la imagen, el nombre y la descripcion de la app.
// Es StatelessWidget porque este contenido nunca cambia.
class EncabezadoApp extends StatelessWidget {
  const EncabezadoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset('assets/images/billetera.png', width: 60, height: 60),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mi Bolsillo',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                'Anota tus gastos y no te quedes sin plata antes de fin de mes.',
                style: TextStyle(color: Colors.black54),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
