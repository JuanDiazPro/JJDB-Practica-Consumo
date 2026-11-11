import 'package:dio/dio.dart';

import 'bitacora_interceptor.dart';

const urlDummyJson = 'https://dummyjson.com';

Dio crearDioRecetas({List<Interceptor> interceptores = const []}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: urlDummyJson,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );
  dio.interceptors.add(BitacoraInterceptor());
  dio.interceptors.addAll(interceptores);
  return dio;
}
