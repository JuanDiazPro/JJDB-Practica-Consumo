import 'package:flutter/material.dart';

import '../dominio/receta.dart';

class TarjetaReceta extends StatelessWidget {
  const TarjetaReceta({super.key, required this.receta});

  final Receta receta;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(receta.nombre, style: textos.titleMedium),
            const SizedBox(height: 4),
            Text('${receta.cocina} · ${receta.dificultad.etiqueta}'),
            const SizedBox(height: 4),
            Text(
              'Tiempo: ${receta.tiempoTotal} min · '
              'Porciones: ${receta.porciones}',
            ),
            const SizedBox(height: 4),
            Text('Calificación: ${receta.calificacion.toStringAsFixed(1)}'),
            if (receta.esRapida) ...[
              const SizedBox(height: 8),
              const Chip(label: Text('Rápida')),
            ],
          ],
        ),
      ),
    );
  }
}
