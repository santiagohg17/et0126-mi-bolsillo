import '../models/pago_pendiente.dart';

// Servicio que simula una API para los pagos pendientes.
// OJO: la lista vive en memoria, si se cierra la app se pierde.
// (Los gastos normales si se guardan con SharedPreferences en gastos_service.dart)
class PagosService {
  // Lista privada: solo el servicio la puede cambiar
  static final List<PagoPendiente> _pagos = [];

  // Listar: espera medio segundo como si fuera una API
  Future<List<PagoPendiente>> listar() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List<PagoPendiente>.unmodifiable(_pagos);
  }

  // Crear: espera un poco y revisa la regla antes de guardar
  Future<PagoPendiente> crear(PagoPendiente pago) async {
    await Future.delayed(const Duration(milliseconds: 1200));

    // Regla de negocio: no se puede repetir el mismo pago con la misma fecha
    for (var actual in _pagos) {
      if (actual.esIgualA(pago)) {
        throw StateError('Ya tienes "${pago.descripcion}" para esa fecha.');
      }
    }

    _pagos.insert(0, pago);
    return pago;
  }
}
