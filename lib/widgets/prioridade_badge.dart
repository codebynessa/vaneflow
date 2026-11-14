import 'package:flutter/material.dart';

import '../models/tarefa.dart';

/// Etiqueta colorida com icone que identifica a prioridade da tarefa.
class PrioridadeBadge extends StatelessWidget {
  final Prioridade prioridade;

  const PrioridadeBadge({super.key, required this.prioridade});

  static Color corDe(Prioridade p) {
    switch (p) {
      case Prioridade.baixa:
        return Colors.green;
      case Prioridade.media:
        return Colors.orange;
      case Prioridade.alta:
        return Colors.red;
    }
  }

  static IconData iconeDe(Prioridade p) {
    switch (p) {
      case Prioridade.baixa:
        return Icons.arrow_downward;
      case Prioridade.media:
        return Icons.remove;
      case Prioridade.alta:
        return Icons.priority_high;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cor = corDe(prioridade);
    return _Etiqueta(
      cor: cor,
      icone: iconeDe(prioridade),
      texto: prioridade.rotulo,
    );
  }
}

/// Etiqueta que mostra se a tarefa esta Pendente ou Concluida.
class SituacaoBadge extends StatelessWidget {
  final bool concluida;

  const SituacaoBadge({super.key, required this.concluida});

  @override
  Widget build(BuildContext context) {
    return _Etiqueta(
      cor: concluida ? Colors.teal : Colors.blueGrey,
      icone: concluida ? Icons.check_circle_outline : Icons.schedule,
      texto: concluida ? 'Concluída' : 'Pendente',
    );
  }
}

class _Etiqueta extends StatelessWidget {
  final Color cor;
  final IconData icone;
  final String texto;

  const _Etiqueta({
    required this.cor,
    required this.icone,
    required this.texto,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icone, size: 14, color: cor),
          const SizedBox(width: 4),
          Text(
            texto,
            style: TextStyle(
              color: cor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
