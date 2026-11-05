import 'package:flutter/material.dart';

// Se muestra cuando no hay gastos para ver
class ListaVacia extends StatelessWidget {
  final String mensaje;

  const ListaVacia({super.key, required this.mensaje});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Opacity(
            opacity: 0.5,
            child: Image.asset('assets/images/billetera.png', width: 80),
          ),
          const SizedBox(height: 12),
          Text(
            mensaje,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
