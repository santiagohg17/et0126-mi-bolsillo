import 'package:flutter/material.dart';

import '../models/gasto.dart';

// Icono que le corresponde a cada categoria
const Map<String, IconData> iconosCategoria = {
  'Comida': Icons.restaurant,
  'Transporte': Icons.directions_bus,
  'Estudio': Icons.menu_book,
  'Ocio': Icons.sports_esports,
  'Otros': Icons.shopping_bag,
};

// Tarjeta que muestra un gasto de la lista
class GastoCard extends StatelessWidget {
  final Gasto gasto;
  final VoidCallback alBorrar;

  const GastoCard({super.key, required this.gasto, required this.alBorrar});

  @override
  Widget build(BuildContext context) {
    // Si el gasto es grande lo muestro en rojo para que llame la atencion
    final Color colorValor = gasto.esGastoGrande() ? Colors.red : Colors.teal;

    String subtitulo = '${gasto.categoria} · ${gasto.fechaCorta()}';
    if (gasto.nota != null && gasto.nota!.isNotEmpty) {
      subtitulo = '$subtitulo\n${gasto.nota}';
    }

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.teal.shade50,
          child: Icon(
            iconosCategoria[gasto.categoria] ?? Icons.attach_money,
            color: Colors.teal,
          ),
        ),
        title: Text(gasto.descripcion),
        subtitle: Text(subtitulo),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              gasto.valorEnPesos(),
              style: TextStyle(fontWeight: FontWeight.bold, color: colorValor),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Borrar gasto',
              onPressed: alBorrar,
            ),
          ],
        ),
      ),
    );
  }
}
