import 'package:flutter_test/flutter_test.dart';

import 'package:mi_bolsillo/models/gasto.dart';
import 'package:mi_bolsillo/services/gastos_service.dart';
import 'package:mi_bolsillo/services/validaciones.dart';

void main() {
  test('formatearPesos pone los puntos de miles', () {
    expect(formatearPesos(12500), '\$12.500');
    expect(formatearPesos(300000), '\$300.000');
    expect(formatearPesos(800), '\$800');
  });

  test('validarValor rechaza valores vacios, negativos o con letras', () {
    expect(validarValor(''), isNotNull);
    expect(validarValor('abc'), isNotNull);
    expect(validarValor('-5'), isNotNull);
    expect(validarValor('12.500'), isNull);
  });

  test('el resumen por categoria suma bien y el Set no repite', () {
    final servicio = GastosService();
    final gastos = [
      Gasto(id: '1', descripcion: 'Almuerzo', valor: 12000, categoria: 'Comida', fecha: DateTime.now()),
      Gasto(id: '2', descripcion: 'Tinto', valor: 2000, categoria: 'Comida', fecha: DateTime.now()),
      Gasto(id: '3', descripcion: 'Pasaje', valor: 3200, categoria: 'Transporte', fecha: DateTime.now()),
    ];
    expect(servicio.resumenPorCategoria(gastos)['Comida'], 14000);
    expect(servicio.categoriasUsadas(gastos).length, 2);
    expect(servicio.diasQueAlcanza(10000, 3000), 3);
  });
}
