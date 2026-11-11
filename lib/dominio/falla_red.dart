sealed class FallaRed implements Exception {
  const FallaRed();
}

final class SinConexion extends FallaRed {
  const SinConexion();
}

final class TiempoAgotado extends FallaRed {
  const TiempoAgotado();
}

final class ErrorDelServidor extends FallaRed {
  const ErrorDelServidor(this.codigo);
  final int codigo;
}

final class PeticionRechazada extends FallaRed {
  const PeticionRechazada(this.codigo);
  final int codigo;
}

final class RespuestaInvalida extends FallaRed {
  const RespuestaInvalida();
}
