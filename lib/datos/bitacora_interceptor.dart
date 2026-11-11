import 'dart:developer' as developer;

import 'package:dio/dio.dart';

class BitacoraInterceptor extends Interceptor {
  BitacoraInterceptor({void Function(String linea)? escribir})
    : _escribir = escribir ?? _escribirEnLog;

  static const _llaveCronometro = 'bitacora_cronometro';

  final void Function(String linea) _escribir;

  static void _escribirEnLog(String linea) {
    developer.log(linea, name: 'recetario');
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_llaveCronometro] = Stopwatch()..start();
    _escribir('→ ${options.method} ${options.path}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final options = response.requestOptions;
    _escribir(
      '← ${response.statusCode} ${options.method} ${options.path} '
      '(${_milisegundos(options)} ms)',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final options = err.requestOptions;
    final codigo = err.response?.statusCode;
    final partes = [
      '✗',
      err.type.name,
      if (codigo != null) '$codigo',
      options.method,
      options.path,
      '(${_milisegundos(options)} ms)',
    ];
    _escribir(partes.join(' '));
    handler.next(err);
  }

  int _milisegundos(RequestOptions options) {
    final cronometro = options.extra[_llaveCronometro];
    if (cronometro is Stopwatch) {
      cronometro.stop();
      return cronometro.elapsedMilliseconds;
    }
    return 0;
  }
}
