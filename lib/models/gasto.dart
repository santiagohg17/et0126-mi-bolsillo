// Modelo que representa un gasto que registra el estudiante.
class Gasto {
  final String id;
  final String descripcion;
  final double valor;
  final String categoria;
  final DateTime fecha;
  // La nota es opcional, por eso es el unico dato que puede ser null
  final String? nota;

  Gasto({
    required this.id,
    required this.descripcion,
    required this.valor,
    required this.categoria,
    required this.fecha,
    this.nota,
  });

  // Devuelve el valor con el signo de pesos y puntos de miles, ej: $12.500
  String valorEnPesos() {
    return formatearPesos(valor);
  }

  // Un gasto es "grande" si pasa de 50.000 pesos
  bool esGastoGrande() {
    return valor > 50000;
  }

  // Devuelve la fecha en formato dia/mes/año
  String fechaCorta() {
    return '${fecha.day}/${fecha.month}/${fecha.year}';
  }

  // Convierte el gasto a un Map para poder guardarlo como JSON
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'descripcion': descripcion,
      'valor': valor,
      'categoria': categoria,
      'fecha': fecha.toIso8601String(),
      'nota': nota,
    };
  }

  // Crea un gasto a partir de un Map (cuando lo leo de la memoria)
  factory Gasto.fromMap(Map<String, dynamic> mapa) {
    return Gasto(
      id: mapa['id'],
      descripcion: mapa['descripcion'],
      valor: (mapa['valor'] as num).toDouble(),
      categoria: mapa['categoria'],
      fecha: DateTime.parse(mapa['fecha']),
      nota: mapa['nota'],
    );
  }
}

// Funcion para mostrar cualquier valor como pesos colombianos
String formatearPesos(double valor) {
  String numero = valor.round().toString();
  String resultado = '';
  int contador = 0;

  // Recorro el numero de atras para adelante poniendo un punto cada 3 cifras
  for (int i = numero.length - 1; i >= 0; i--) {
    resultado = numero[i] + resultado;
    contador++;
    if (contador == 3 && i > 0 && numero[i - 1] != '-') {
      resultado = '.$resultado';
      contador = 0;
    }
  }
  return '\$$resultado';
}
