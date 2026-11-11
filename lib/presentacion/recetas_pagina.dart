import 'package:flutter/material.dart';

import 'recetas_view_model.dart';
import 'tarjeta_receta.dart';

class RecetasPagina extends StatefulWidget {
  const RecetasPagina({super.key, required this.vm});

  final RecetasViewModel vm;

  @override
  State<RecetasPagina> createState() => _RecetasPaginaState();
}

class _RecetasPaginaState extends State<RecetasPagina> {
  final _controlador = TextEditingController();

  RecetasViewModel get _vm => widget.vm;

  void _buscar() {
    _vm.buscar(_controlador.text);
  }

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recetario UTEZ')),
      body: ListenableBuilder(
        listenable: _vm,
        builder: (context, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        key: const Key('busqueda'),
                        controller: _controlador,
                        textInputAction: TextInputAction.search,
                        onSubmitted: (_) => _buscar(),
                        decoration: const InputDecoration(
                          labelText: 'Receta',
                          hintText: 'pasta, chicken, pizza…',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton(
                      key: const Key('buscar'),
                      onPressed: _vm.cargando ? null : _buscar,
                      child: const Text('Buscar recetas'),
                    ),
                  ],
                ),
              ),
              Expanded(child: _contenido(context)),
            ],
          );
        },
      ),
    );
  }

  Widget _contenido(BuildContext context) {
    return switch (_vm.estado) {
      RecetasInicial() => const _Aviso(
        texto: 'Escribe una receta o déjalo vacío y toca Buscar recetas.',
      ),
      RecetasCargando() => const Center(child: CircularProgressIndicator()),
      RecetasVacias(:final busqueda) => _Aviso(
        texto: busqueda.isEmpty
            ? 'No hay recetas disponibles.'
            : 'No encontramos recetas para "$busqueda".',
      ),
      RecetasFallidas(:final mensaje) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(mensaje, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: _vm.reintentar,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
      RecetasListas(:final recetas, :final total) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Mostrando ${recetas.length} de $total recetas · '
              'Rápidas: ${_vm.rapidas}',
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: recetas.length,
              itemBuilder: (context, indice) =>
                  TarjetaReceta(receta: recetas[indice]),
            ),
          ),
        ],
      ),
    };
  }
}

class _Aviso extends StatelessWidget {
  const _Aviso({required this.texto});

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(texto, textAlign: TextAlign.center),
      ),
    );
  }
}
