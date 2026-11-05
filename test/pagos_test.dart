import 'package:flutter_test/flutter_test.dart';

import 'package:mi_bolsillo/models/pago_pendiente.dart';
import 'package:mi_bolsillo/services/pagos_service.dart';
import 'package:mi_bolsillo/services/validaciones.dart';

void main() {
  test('la descripcion del pago necesita minimo 3 letras', () {
    expect(descripcionPagoValidator(''), isNotNull);
    expect(descripcionPagoValidator('ab'), isNotNull);
    expect(descripcionPagoValidator('Matricula'), isNull);
  });

  test('el valor del pago debe ser un numero mayor a 0', () {
    expect(validarValorPago('abc'), isNotNull);
    expect(validarValorPago('0'), isNotNull);
    expect(validarValorPago('25000'), isNull);
  });

  test('la categoria es obligatoria (aunque llegue null)', () {
    expect(validarCategoriaPago(null), isNotNull);
    expect(validarCategoriaPago('Estudio'), isNull);
  });

  test('la fecha limite no puede ser antes de hoy', () {
    final ayer = DateTime.now().subtract(const Duration(days: 1));
    expect(validarFechaLimite(null), isNotNull);
    expect(validarFechaLimite(ayer), isNotNull);
    expect(validarFechaLimite(DateTime.now()), isNull);
  });

  test('el servicio no deja guardar el mismo pago dos veces', () async {
    final servicio = PagosService();
    final fecha = DateTime(2030, 1, 15);
    final pago = PagoPendiente(id: '1', descripcion: 'Matricula', valor: 500000, categoria: 'Estudio', fechaLimite: fecha);
    final repetido = PagoPendiente(id: '2', descripcion: 'matricula', valor: 500000, categoria: 'Estudio', fechaLimite: fecha);

    await servicio.crear(pago);
    expect(() => servicio.crear(repetido), throwsStateError);
    expect((await servicio.listar()).length, 1);
  });
}
