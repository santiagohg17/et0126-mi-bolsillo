import '../models/pago_pendiente.dart';

// Servicio que simula una API para los pagos pendientes.
// OJO: la lista vive en memoria, entonces si se cierra la app se pierde.
// (Los gastos normales si se guardan con SharedPreferences en gastos_service.dart)
class PagosService {
  // Lista privada: solo el servicio la puede modificar
  static final List<PagoPendiente> _pagos = [];

  // Regla de negocio: maximo 10 pagos pendientes a la vez
  static const int maximoPagos = 10;

  // Listar: espera medio segundo como si fuera una API
  Future<List<PagoPendiente>> listar() async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Devuelvo una copia que no se puede modificar desde la pantalla
    return List<PagoPendiente>.unmodifiable(_pagos);
  }

  // Crear: espera un poco y revisa las reglas antes de guardar
  Future<PagoPendiente> crear(PagoPendiente pago) async {
    await Future.delayed(const Duration(milliseconds: 1200));

    // Regla 1: no se puede repetir el mismo pago con la misma fecha
    for (var actual in _pagos) {
      if (actual.esIgualA(pago)) {
        throw StateError(
          'Ya tienes "${pago.descripcion}" para el ${pago.fechaCorta()}.',
        );
      }
    }

    // Regla 2: no mas de 10 pagos pendientes
    if (_pagos.length >= maximoPagos) {
      throw StateError('Solo puedes tener $maximoPagos pagos pendientes.');
    }

    _pagos.insert(0, pago);
    return pago;
  }

  // Extra: eliminar un pago (cuando ya lo pague o me equivoque)
  Future<void> eliminar(String id) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _pagos.removeWhere((pago) => pago.id == id);
  }
}
