import 'package:flutter/material.dart';

import '../models/gasto.dart';
import '../services/gastos_service.dart';
import '../services/validaciones.dart';
import '../widgets/anillo_presupuesto.dart';
import '../widgets/encabezado_app.dart';
import '../widgets/gasto_card.dart';
import '../widgets/lista_vacia.dart';
import 'agregar_gasto_screen.dart';

// Pantalla principal. Es StatefulWidget porque la lista, el filtro
// y el presupuesto cambian mientras se usa la app.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GastosService _servicio = GastosService();

  List<Gasto> _gastos = [];
  double _presupuesto = GastosService.presupuestoPorDefecto;
  String _filtro = 'Todos';
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  // Lee los datos guardados cuando se abre la app
  Future<void> _cargarDatos() async {
    final gastos = await _servicio.cargarGastos();
    final presupuesto = await _servicio.cargarPresupuesto();
    setState(() {
      _gastos = gastos;
      _presupuesto = presupuesto;
      _cargando = false;
    });
  }

  Future<void> _irAAgregarGasto() async {
    // Espero a que la otra pantalla me devuelva el gasto
    final Gasto? nuevo = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AgregarGastoScreen()),
    );

    if (nuevo == null) return; // el usuario se devolvio sin guardar

    setState(() {
      _gastos.insert(0, nuevo); // lo pongo de primero en la lista
    });
    await _servicio.guardarGastos(_gastos);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Gasto "${nuevo.descripcion}" guardado ✔'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _borrarGasto(Gasto gasto) async {
    setState(() {
      _gastos.remove(gasto);
    });
    await _servicio.guardarGastos(_gastos);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Se borró "${gasto.descripcion}"')),
    );
  }

  // Ventana para cambiar el presupuesto del mes
  Future<void> _cambiarPresupuesto() async {
    final controller = TextEditingController(
      text: _presupuesto.round().toString(),
    );
    final formKey = GlobalKey<FormState>();

    final double? nuevo = await showDialog<double>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Presupuesto del mes'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(prefixText: '\$ '),
              validator: validarValor,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(context, convertirValor(controller.text));
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );

    if (nuevo == null) return;
    setState(() {
      _presupuesto = nuevo;
    });
    await _servicio.guardarPresupuesto(nuevo);
  }

  // Devuelve solo los gastos de la categoria escogida en el filtro
  List<Gasto> _gastosFiltrados() {
    if (_filtro == 'Todos') {
      return _gastos;
    }
    final List<Gasto> resultado = [];
    for (var gasto in _gastos) {
      if (gasto.categoria == _filtro) {
        resultado.add(gasto);
      }
    }
    return resultado;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Bolsillo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Cambiar presupuesto',
            onPressed: _cambiarPresupuesto,
          ),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const EncabezadoApp(),
                const SizedBox(height: 16),
                _tarjetaPresupuesto(),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _irAAgregarGasto,
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar gasto'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(14),
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                _resumenCategorias(),
                const SizedBox(height: 8),
                _filtros(),
                const SizedBox(height: 8),
                ..._listaDeGastos(),
              ],
            ),
    );
  }

  // Tarjeta con el anillo (Canvas) y los numeros del presupuesto
  Widget _tarjetaPresupuesto() {
    final double total = _servicio.calcularTotal(_gastos);
    final double restante = _presupuesto - total;
    final int dias = _servicio.diasQueAlcanza(
      restante,
      _servicio.promedioDiario(_gastos),
    );

    String mensaje;
    if (restante < 0) {
      mensaje = '¡Te pasaste del presupuesto!';
    } else if (_gastos.isEmpty) {
      mensaje = 'Aún no tienes gastos este mes';
    } else {
      mensaje = 'A este ritmo te alcanza para $dias días';
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            AnilloPresupuesto(gastado: total, presupuesto: _presupuesto),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Presupuesto', style: TextStyle(color: Colors.black54)),
                  Text(
                    formatearPesos(_presupuesto),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  const Text('Gastado', style: TextStyle(color: Colors.black54)),
                  Text(formatearPesos(total), style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 6),
                  const Text('Te queda', style: TextStyle(color: Colors.black54)),
                  Text(
                    formatearPesos(restante),
                    style: TextStyle(
                      fontSize: 16,
                      color: restante < 0 ? Colors.red : Colors.green,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(mensaje, style: const TextStyle(fontStyle: FontStyle.italic)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Muestra cuanto se ha gastado por categoria (usa el Map del servicio)
  Widget _resumenCategorias() {
    final Map<String, double> resumen = _servicio.resumenPorCategoria(_gastos);
    if (resumen.isEmpty) {
      return const SizedBox();
    }

    final List<Widget> filas = [];
    resumen.forEach((categoria, valor) {
      filas.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              Icon(iconosCategoria[categoria], size: 18, color: Colors.teal),
              const SizedBox(width: 8),
              Expanded(child: Text(categoria)),
              Text(formatearPesos(valor)),
            ],
          ),
        ),
      );
    });

    return Card(
      color: Colors.teal.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumen por categoria',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            ...filas,
          ],
        ),
      ),
    );
  }

  // Chips para filtrar. Solo salen las categorias que se han usado (Set)
  Widget _filtros() {
    final Set<String> usadas = _servicio.categoriasUsadas(_gastos);
    final List<String> opciones = ['Todos', ...usadas];

    return Wrap(
      spacing: 8,
      children: opciones.map((opcion) {
        return ChoiceChip(
          label: Text(opcion),
          selected: _filtro == opcion,
          onSelected: (_) {
            setState(() {
              _filtro = opcion;
            });
          },
        );
      }).toList(),
    );
  }

  List<Widget> _listaDeGastos() {
    final List<Gasto> lista = _gastosFiltrados();

    if (_gastos.isEmpty) {
      return [
        const ListaVacia(
          mensaje: 'No tienes gastos registrados.\nToca "Agregar gasto" para empezar.',
        ),
      ];
    }
    if (lista.isEmpty) {
      return [const ListaVacia(mensaje: 'No hay gastos en esta categoria.')];
    }

    final List<Widget> tarjetas = [];
    for (var gasto in lista) {
      tarjetas.add(GastoCard(gasto: gasto, alBorrar: () => _borrarGasto(gasto)));
    }
    return tarjetas;
  }
}
