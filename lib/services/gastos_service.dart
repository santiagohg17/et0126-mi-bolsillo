import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/gasto.dart';

// Aqui esta todo lo de guardar y leer datos, y los calculos del resumen.
class GastosService {
  static const String _llaveGastos = 'gastos';
  static const String _llavePresupuesto = 'presupuesto';
  static const double presupuestoPorDefecto = 300000;

  // Categorias que puede escoger el usuario
  static const List<String> categorias = [
    'Comida',
    'Transporte',
    'Estudio',
    'Ocio',
    'Otros',
  ];

  // ---------- Guardar y leer (SharedPreferences) ----------

  Future<List<Gasto>> cargarGastos() async {
    final prefs = await SharedPreferences.getInstance();
    final String? texto = prefs.getString(_llaveGastos);
    if (texto == null) {
      return []; // la primera vez no hay nada guardado
    }
    final List<dynamic> listaJson = jsonDecode(texto);
    final List<Gasto> gastos = [];
    for (var item in listaJson) {
      gastos.add(Gasto.fromMap(item));
    }
    return gastos;
  }

  Future<void> guardarGastos(List<Gasto> gastos) async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> listaMapas = [];
    for (var gasto in gastos) {
      listaMapas.add(gasto.toMap());
    }
    await prefs.setString(_llaveGastos, jsonEncode(listaMapas));
  }

  Future<double> cargarPresupuesto() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_llavePresupuesto) ?? presupuestoPorDefecto;
  }

  Future<void> guardarPresupuesto(double valor) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_llavePresupuesto, valor);
  }

  // ---------- Calculos ----------

  // Suma todos los gastos de la lista
  double calcularTotal(List<Gasto> gastos) {
    double total = 0;
    for (var gasto in gastos) {
      total += gasto.valor;
    }
    return total;
  }

  // Map: cuanto se ha gastado en cada categoria. Ej: {'Comida': 25000}
  Map<String, double> resumenPorCategoria(List<Gasto> gastos) {
    final Map<String, double> resumen = {};
    for (var gasto in gastos) {
      if (resumen.containsKey(gasto.categoria)) {
        resumen[gasto.categoria] = resumen[gasto.categoria]! + gasto.valor;
      } else {
        resumen[gasto.categoria] = gasto.valor;
      }
    }
    return resumen;
  }

  // Set: las categorias en las que ya hay gastos (sin repetir)
  Set<String> categoriasUsadas(List<Gasto> gastos) {
    final Set<String> usadas = {};
    for (var gasto in gastos) {
      usadas.add(gasto.categoria); // si ya estaba, el Set no la repite
    }
    return usadas;
  }

  // while: cuantos dias me alcanza la plata que me queda si sigo
  // gastando lo mismo que gasto en promedio por dia.
  // Es una repeticion finita: como maximo cuenta 31 dias (un mes).
  int diasQueAlcanza(double restante, double promedioDiario) {
    if (promedioDiario <= 0) {
      return 31; // si no he gastado nada, me alcanza todo el mes
    }
    int dias = 0;
    double plata = restante;
    while (plata >= promedioDiario && dias < 31) {
      plata = plata - promedioDiario;
      dias++;
    }
    return dias;
  }

  // Promedio de gasto por dia en lo que va del mes
  double promedioDiario(List<Gasto> gastos) {
    final int diaDeHoy = DateTime.now().day;
    return calcularTotal(gastos) / diaDeHoy;
  }
}
