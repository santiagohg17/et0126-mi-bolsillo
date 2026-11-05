import 'dart:math';

import 'package:flutter/material.dart';

// Widget que muestra el anillo dibujado con Canvas y el porcentaje en el centro
class AnilloPresupuesto extends StatelessWidget {
  final double gastado;
  final double presupuesto;

  const AnilloPresupuesto({
    super.key,
    required this.gastado,
    required this.presupuesto,
  });

  @override
  Widget build(BuildContext context) {
    final double porcentaje = presupuesto > 0 ? gastado / presupuesto : 0;

    return SizedBox(
      width: 140,
      height: 140,
      child: CustomPaint(
        painter: AnilloPainter(porcentaje: porcentaje),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${(porcentaje * 100).round()}%',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text('gastado', style: TextStyle(color: Colors.black54)),
            ],
          ),
        ),
      ),
    );
  }
}

// Aqui se dibuja el anillo con Canvas
class AnilloPainter extends CustomPainter {
  final double porcentaje; // 0.5 = 50%

  AnilloPainter({required this.porcentaje});

  // Escoge el color segun como va el presupuesto
  Color colorSegunAvance() {
    if (porcentaje >= 1) {
      return Colors.red; // ya se paso
    } else if (porcentaje >= 0.7) {
      return Colors.orange; // cuidado
    } else {
      return Colors.green; // va bien
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final Offset centro = Offset(size.width / 2, size.height / 2);
    final double radio = size.width / 2 - 10;
    const double grosor = 16;

    // 1. Circulo gris de fondo (el 100% del presupuesto)
    final Paint pincelFondo = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = grosor;
    canvas.drawCircle(centro, radio, pincelFondo);

    // 2. Arco de color con lo que ya se gasto
    final Paint pincelAvance = Paint()
      ..color = colorSegunAvance()
      ..style = PaintingStyle.stroke
      ..strokeWidth = grosor
      ..strokeCap = StrokeCap.round;

    // El arco no puede pasar de una vuelta completa
    final double avance = porcentaje > 1 ? 1 : porcentaje;
    final double angulo = 2 * pi * avance;

    canvas.drawArc(
      Rect.fromCircle(center: centro, radius: radio),
      -pi / 2, // empieza arriba, como las 12 del reloj
      angulo,
      false,
      pincelAvance,
    );
  }

  // Solo se vuelve a dibujar si cambio el porcentaje
  @override
  bool shouldRepaint(AnilloPainter oldDelegate) {
    return oldDelegate.porcentaje != porcentaje;
  }
}
