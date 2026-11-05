import 'gasto.dart';

// Un pago que el estudiante tiene que hacer mas adelante,
// por ejemplo la matricula o las copias para un parcial.
class PagoPendiente {
  final String id;
  final String descripcion;
  final double valor;
  final String categoria;
  final DateTime fechaLimite;

  PagoPendiente({
    required this.id,
    required this.descripcion,
    required this.valor,
    required this.categoria,
    required this.fechaLimite,
  });

  // Cuantos dias faltan para la fecha limite (0 = es hoy)
  int diasQueFaltan() {
    final DateTime hoy = DateTime.now();
    final DateTime soloHoy = DateTime(hoy.year, hoy.month, hoy.day);
    return fechaLimite.difference(soloHoy).inDays;
  }

  // Dos pagos son "el mismo" si tienen la misma descripcion y la misma fecha.
  // Esto lo usa el servicio para no dejar guardar duplicados.
  bool esIgualA(PagoPendiente otro) {
    return descripcion.toLowerCase() == otro.descripcion.toLowerCase() &&
        fechaLimite == otro.fechaLimite;
  }

  String valorEnPesos() {
    return formatearPesos(valor);
  }

  String fechaCorta() {
    return '${fechaLimite.day}/${fechaLimite.month}/${fechaLimite.year}';
  }
}
