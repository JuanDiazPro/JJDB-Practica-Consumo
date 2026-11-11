import '../dominio/receta.dart';

abstract class RecetasRepositorio {
  Future<PaginaRecetas> buscar({String texto = ''});
}
