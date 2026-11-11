import 'package:dio/dio.dart';

import '../dominio/falla_red.dart';
import '../dominio/receta.dart';
import 'recetas_json.dart';
import 'recetas_repositorio.dart';
import 'traducir_error.dart';

const recetasPorPagina = 10;

class DummyJsonRepositorio implements RecetasRepositorio {
  DummyJsonRepositorio(Dio dio) : _dio = dio;

  final Dio _dio;

  @override
  Future<PaginaRecetas> buscar({String texto = ''}) async {
    final limpio = texto.trim();
    try {
      final respuesta = limpio.isEmpty
          ? await _dio.get<Object?>(
              '/recipes',
              queryParameters: {'limit': recetasPorPagina},
            )
          : await _dio.get<Object?>(
              '/recipes/search',
              queryParameters: {'q': limpio, 'limit': recetasPorPagina},
            );
      final datos = respuesta.data;
      if (datos is! Map<String, dynamic>) {
        throw const RespuestaInvalida();
      }
      return paginaDesdeJson(datos);
    } on DioException catch (e) {
      throw traducirError(e);
    } on FormatException {
      throw const RespuestaInvalida();
    }
  }
}
