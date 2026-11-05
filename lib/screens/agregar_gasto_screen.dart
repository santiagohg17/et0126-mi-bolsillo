import 'package:flutter/material.dart';

import '../models/gasto.dart';
import '../services/gastos_service.dart';
import '../services/validaciones.dart';

// Pantalla con el formulario para registrar un gasto nuevo
class AgregarGastoScreen extends StatefulWidget {
  const AgregarGastoScreen({super.key});

  @override
  State<AgregarGastoScreen> createState() => _AgregarGastoScreenState();
}

class _AgregarGastoScreenState extends State<AgregarGastoScreen> {
  // Llave para poder validar todo el formulario
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _valorController = TextEditingController();
  final TextEditingController _notaController = TextEditingController();

  String _categoria = GastosService.categorias[0];

  void _guardar() {
    // Si algun campo no es valido no sigo
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final String nota = _notaController.text.trim();

    final Gasto nuevo = Gasto(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      descripcion: _descripcionController.text.trim(),
      valor: convertirValor(_valorController.text),
      categoria: _categoria,
      fecha: DateTime.now(),
      nota: nota.isEmpty ? null : nota,
    );

    // Devuelvo el gasto a la pantalla anterior
    Navigator.pop(context, nuevo);
  }

  @override
  void dispose() {
    _descripcionController.dispose();
    _valorController.dispose();
    _notaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agregar gasto')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _descripcionController,
                decoration: const InputDecoration(
                  labelText: '¿En qué gastaste?',
                  hintText: 'Ej: almuerzo, pasaje, fotocopias',
                  prefixIcon: Icon(Icons.edit),
                  border: OutlineInputBorder(),
                ),
                validator: validarDescripcion,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _valorController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Valor',
                  hintText: 'Ej: 12500',
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(),
                ),
                validator: validarValor,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _categoria,
                decoration: const InputDecoration(
                  labelText: 'Categoria',
                  prefixIcon: Icon(Icons.category),
                  border: OutlineInputBorder(),
                ),
                items: GastosService.categorias.map((cat) {
                  return DropdownMenuItem(value: cat, child: Text(cat));
                }).toList(),
                onChanged: (valor) {
                  setState(() {
                    _categoria = valor!;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notaController,
                decoration: const InputDecoration(
                  labelText: 'Nota (opcional)',
                  prefixIcon: Icon(Icons.notes),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _guardar,
                icon: const Icon(Icons.save),
                label: const Text('Guardar'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
