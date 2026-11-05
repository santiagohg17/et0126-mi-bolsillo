import 'package:form_field_validator/form_field_validator.dart';

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

// ---------- Validadores para el formulario de pagos pendientes ----------
// Aqui uso la libreria form_field_validator

final descripcionPagoValidator = MultiValidator([
  RequiredValidator(errorText: 'Escribe que tienes que pagar.'),
  MinLengthValidator(3, errorText: 'Usa al menos 3 letras.'),
  MaxLengthValidator(40, errorText: 'Maximo 40 letras.'),
]);

final valorPagoValidator = MultiValidator([
  RequiredValidator(errorText: 'Escribe el valor del pago.'),
  PatternValidator(r'^[0-9.]+$', errorText: 'Solo números, sin letras ni signos.'),
]);

final categoriaPagoValidator = RequiredValidator(errorText: 'Escoge una categoria.');

// Regla propia del dominio: el valor tiene que ser mayor a 0
// y no mas de 5 millones (un estudiante no deberia tener pagos tan altos)
String? validarValorPago(String? texto) {
  final String? error = valorPagoValidator(texto);
  if (error != null) {
    return error;
  }
  // tryParse por si el usuario escribe solo puntos, ej: "..."
  final double? valor = double.tryParse(texto!.replaceAll('.', ''));
  if (valor == null || valor <= 0) {
    return 'El valor debe ser mayor a 0.';
  }
  if (valor > 5000000) {
    return 'El valor no puede pasar de \$5.000.000.';
  }
  return null;
}

// Regla propia del dominio: la fecha limite no puede ser antes de hoy
String? validarFechaLimite(DateTime? fecha) {
  if (fecha == null) {
    return 'Escoge la fecha limite del pago.';
  }
  final DateTime ahora = DateTime.now();
  final DateTime hoy = DateTime(ahora.year, ahora.month, ahora.day);
  if (fecha.isBefore(hoy)) {
    return 'La fecha no puede ser anterior a hoy.';
  }
  return null;
}

// Convierte el texto del campo valor a número (ya validado)
double convertirValor(String texto) {
  return double.parse(texto.replaceAll('.', '').trim());
}
