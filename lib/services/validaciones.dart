// Funciones para validar lo que escribe el usuario en los formularios.
// Si todo esta bien devuelven null, si no devuelven el mensaje de error.

String? validarDescripcion(String? texto) {
  if (texto == null || texto.trim().isEmpty) {
    return 'Escribe en que gastaste';
  }
  if (texto.trim().length < 3) {
    return 'La descripción debe tener minimo 3 letras';
  }
  return null;
}

String? validarValor(String? texto) {
  if (texto == null || texto.trim().isEmpty) {
    return 'Escribe el valor del gasto';
  }
  // Quito los puntos por si el usuario escribe 12.500
  final double? valor = double.tryParse(texto.replaceAll('.', '').trim());
  if (valor == null) {
    return 'Solo se permiten números';
  }
  if (valor <= 0) {
    return 'El valor debe ser mayor a 0';
  }
  if (valor > 10000000) {
    return 'Ese valor es muy alto, revisalo';
  }
  return null;
}

// Convierte el texto del campo valor a número (ya validado)
double convertirValor(String texto) {
  return double.parse(texto.replaceAll('.', '').trim());
}
