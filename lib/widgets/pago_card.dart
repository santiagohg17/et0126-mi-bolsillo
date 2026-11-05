import 'package:flutter/material.dart';

import '../models/pago_pendiente.dart';

// Tarjeta para mostrar un pago pendiente. Solo recibe datos, por eso es StatelessWidget.
class PagoCard extends StatelessWidget {
  final PagoPendiente pago;

  const PagoCard({super.key, required this.pago});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.event, color: Colors.orange),
        title: Text(pago.descripcion),
        subtitle: Text(
          '${pago.categoria} · hasta ${pago.fechaCorta()} · faltan ${pago.diasQueFaltan()} días',
        ),
        trailing: Text(
          pago.valorEnPesos(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
