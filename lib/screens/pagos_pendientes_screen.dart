import 'package:flutter/material.dart';

import '../models/pago_pendiente.dart';
import '../services/gastos_service.dart';
import '../services/pagos_service.dart';
import '../services/validaciones.dart';
import '../widgets/lista_vacia.dart';
import '../widgets/pago_card.dart';

// Pantalla para registrar y ver los pagos pendientes.
// Es StatefulWidget porque el formulario, la lista y la carga cambian.
class PagosPendientesScreen extends StatefulWidget {
  const PagosPendientesScreen({super.key});

  @override
  State<PagosPendientesScreen> createState() => _PagosPendientesScreenState();
}

class _PagosPendientesScreenState extends State<PagosPendientesScreen> {
  final PagosService _servicio = PagosService();

  // La llave del formulario va aqui en el State, no dentro de build()
  final _formKey = GlobalKey<FormState>();
  final _descripcionController = TextEditingController();
  final _valorController = TextEditingController();
  final _fechaController = TextEditingController();
  final _focoDescripcion = FocusNode();

  String? _categoria;
  DateTime? _fechaLimite;

  List<PagoPendiente> _pagos = [];
  bool _cargandoLista = true;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _cargarPagos(); // pido la lista al entrar, no en build()
  }

  @override
  void dispose() {
    _descripcionController.dispose();
    _valorController.dispose();
    _fechaController.dispose();
    _focoDescripcion.dispose();
    super.dispose();
  }

  Future<void> _cargarPagos() async {
    final pagos = await _servicio.listar();
    if (!mounted) return;
    setState(() {
      _pagos = pagos;
      _cargandoLista = false;
    });
  }

  Future<void> _escogerFecha() async {
    final hoy = DateTime.now();
    final fecha = await showDatePicker(
      context: context,
      initialDate: hoy,
      // dejo escoger fechas pasadas para que la validacion muestre el error
      firstDate: DateTime(hoy.year - 1),
      lastDate: DateTime(hoy.year + 2),
    );
    if (fecha == null) return;
    setState(() {
      _fechaLimite = fecha;
      _fechaController.text = '${fecha.day}/${fecha.month}/${fecha.year}';
    });
  }

  Future<void> _guardar() async {
    // 1 y 2. Si el formulario tiene errores no llamo al servicio
    if (!_formKey.currentState!.validate()) return;

    // 3. Bloqueo el boton para que no se guarde dos veces
    setState(() {
      _guardando = true;
    });

    final nuevo = PagoPendiente(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      descripcion: _descripcionController.text.trim(),
      valor: convertirValor(_valorController.text),
      categoria: _categoria!,
      fechaLimite: _fechaLimite!,
    );

    try {
      // 4. Espero la respuesta del servicio
      await _servicio.crear(nuevo);
      final pagos = await _servicio.listar();
      if (!mounted) return;

      // 5. Salio bien: actualizo la lista, aviso y limpio el formulario
      setState(() {
        _pagos = pagos;
        _descripcionController.clear();
        _valorController.clear();
        _fechaController.clear();
        _fechaLimite = null;
        _categoria = null;
      });
      _mostrarMensaje('Pago "${nuevo.descripcion}" registrado ✔', Colors.green);
    } on StateError catch (error) {
      // 6. Salio mal: muestro el error y NO borro lo que escribio
      if (!mounted) return;
      _mostrarMensaje(error.message, Colors.red);
    } finally {
      // 7. En cualquier caso termino la carga
      if (mounted) {
        setState(() {
          _guardando = false;
        });
      }
    }
  }

  void _mostrarMensaje(String texto, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pagos pendientes')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Anota los pagos que vas a tener que hacer (matricula, copias, '
            'salidas) para que no te cojan de sorpresa. Estos datos son de '
            'prueba y se borran al cerrar la app.',
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 16),
          _formulario(),
          const SizedBox(height: 20),
          const Text(
            'Mis pagos pendientes',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _lista(),
        ],
      ),
    );
  }

  Widget _formulario() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _descripcionController,
            focusNode: _focoDescripcion,
            decoration: const InputDecoration(
              labelText: '¿Qué tienes que pagar?',
              border: OutlineInputBorder(),
            ),
            validator: descripcionPagoValidator.call,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _valorController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Valor',
              border: OutlineInputBorder(),
            ),
            validator: validarValorPago,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _categoria,
            decoration: const InputDecoration(
              labelText: 'Categoria',
              border: OutlineInputBorder(),
            ),
            items: GastosService.categorias.map((cat) {
              return DropdownMenuItem(value: cat, child: Text(cat));
            }).toList(),
            onChanged: (valor) {
              setState(() {
                _categoria = valor;
              });
            },
            validator: validarCategoriaPago,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _fechaController,
            readOnly: true,
            onTap: _escogerFecha,
            decoration: const InputDecoration(
              labelText: 'Fecha limite',
              hintText: 'Toca para escoger',
              border: OutlineInputBorder(),
            ),
            validator: (_) => validarFechaLimite(_fechaLimite),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            // si esta guardando el boton queda desactivado (null)
            onPressed: _guardando ? null : _guardar,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(14),
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: Text(_guardando ? 'Guardando...' : 'Guardar pago'),
          ),
          if (_guardando) const LinearProgressIndicator(),
        ],
      ),
    );
  }

  Widget _lista() {
    if (_cargandoLista) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_pagos.isEmpty) {
      return Column(
        children: [
          const ListaVacia(mensaje: 'No tienes pagos pendientes.'),
          TextButton(
            onPressed: () => _focoDescripcion.requestFocus(),
            child: const Text('Registrar mi primer pago'),
          ),
        ],
      );
    }

    final List<Widget> tarjetas = [];
    for (var pago in _pagos) {
      tarjetas.add(PagoCard(pago: pago));
    }
    return Column(children: tarjetas);
  }
}
