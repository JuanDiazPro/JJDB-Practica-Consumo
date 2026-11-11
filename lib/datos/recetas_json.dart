import '../dominio/receta.dart';

Dificultad dificultadDesdeTexto(Object? valor) {
  return switch (valor) {
    'Easy' => Dificultad.facil,
    'Medium' => Dificultad.media,
    'Hard' => Dificultad.dificil,
    _ => Dificultad.desconocida,
  };
}

Receta recetaDesdeJson(Map<String, dynamic> json) {
  return switch (json) {
    {
      'id': int id,
      'name': String nombre,
      'cuisine': String cocina,
      'prepTimeMinutes': int minutosPreparacion,
      'cookTimeMinutes': int minutosCoccion,
      'servings': int porciones,
      'rating': num calificacion,
    } =>
      Receta(
        id: id,
        nombre: nombre,
        cocina: cocina,
        dificultad: dificultadDesdeTexto(json['difficulty']),
        minutosPreparacion: minutosPreparacion,
        minutosCoccion: minutosCoccion,
        porciones: porciones,
        calificacion: calificacion.toDouble(),
        etiquetas: _textosOpcionales(json, 'tags'),
        ingredientes: _textosOpcionales(json, 'ingredients'),
      ),
    _ => throw const FormatException('Receta con campos faltantes o inválidos'),
  };
}

PaginaRecetas paginaDesdeJson(Map<String, dynamic> json) {
  return switch (json) {
    {'recipes': List<dynamic> elementos, 'total': int total} => PaginaRecetas(
      recetas: [
        for (final elemento in elementos)
          if (elemento is Map<String, dynamic>)
            recetaDesdeJson(elemento)
          else
            throw const FormatException('Elemento de recipes no es un objeto'),
      ],
      total: total,
    ),
    _ => throw const FormatException('Página sin recipes o sin total'),
  };
}

List<String> _textosOpcionales(Map<String, dynamic> json, String llave) {
  if (!json.containsKey(llave) || json[llave] == null) return const [];
  final valor = json[llave];
  if (valor is! List) {
    throw FormatException('$llave no es una lista');
  }
  final textos = <String>[];
  for (final elemento in valor) {
    if (elemento is! String) {
      throw FormatException('$llave contiene un elemento que no es texto');
    }
    textos.add(elemento);
  }
  return textos;
}
