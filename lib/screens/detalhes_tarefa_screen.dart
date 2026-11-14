import 'package:flutter/material.dart';

import '../models/tarefa.dart';
import '../services/auth_service.dart';
import '../services/firebase_service.dart';
import '../utils/helpers.dart';
import '../widgets/prioridade_badge.dart';
import 'cadastro_tarefa_screen.dart';

/// Mostra os detalhes de uma tarefa (consulta em tempo real).
class DetalhesTarefaScreen extends StatefulWidget {
  final String tarefaId;

  const DetalhesTarefaScreen({super.key, required this.tarefaId});

  @override
  State<DetalhesTarefaScreen> createState() => _DetalhesTarefaScreenState();
}

class _DetalhesTarefaScreenState extends State<DetalhesTarefaScreen> {
  final _auth = AuthService();
  final _db = FirebaseService();

  Stream<Tarefa?>? _stream;

  @override
  void initState() {
    super.initState();
    final uid = _auth.uid;
    if (uid != null) {
      _stream = _db.tarefaStream(uid, widget.tarefaId);
    }
  }

  Future<void> _excluir(Tarefa tarefa) async {
    final confirmou = await confirmarAcao(
      context,
      titulo: 'Excluir tarefa',
      mensagem: 'Deseja excluir "${tarefa.titulo}"?',
      confirmar: 'Excluir',
    );
    if (!confirmou || !mounted) return;

    final uid = _auth.uid;
    if (uid == null) return;

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    navigator.pop(); // volta para a lista antes de apagar
    await _db.excluirTarefa(uid, tarefa.id);
    messenger.showSnackBar(const SnackBar(content: Text('Tarefa excluída.')));
  }

  Future<void> _alternarSituacao(Tarefa tarefa) async {
    final uid = _auth.uid;
    if (uid == null) return;
    await _db.alterarSituacao(uid, tarefa.id, !tarefa.concluida);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Tarefa?>(
      stream: _stream,
      builder: (context, snapshot) {
        final tarefa = snapshot.data;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Detalhes da tarefa'),
            actions: [
              if (tarefa != null) ...[
                IconButton(
                  tooltip: 'Editar',
                  icon: const Icon(Icons.edit),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CadastroTarefaScreen(tarefa: tarefa),
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Excluir',
                  icon: const Icon(Icons.delete),
                  onPressed: () => _excluir(tarefa),
                ),
              ],
            ],
          ),
          body: _corpo(context, snapshot, tarefa),
        );
      },
    );
  }

  Widget _corpo(
    BuildContext context,
    AsyncSnapshot<Tarefa?> snapshot,
    Tarefa? tarefa,
  ) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }
    if (tarefa == null) {
      return const Center(child: Text('Tarefa não encontrada.'));
    }

    final atrasada = tarefa.atrasada;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          tarefa.titulo,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                decoration:
                    tarefa.concluida ? TextDecoration.lineThrough : null,
              ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            PrioridadeBadge(prioridade: tarefa.prioridade),
            SituacaoBadge(concluida: tarefa.concluida),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            leading: Icon(Icons.event, color: atrasada ? Colors.red : null),
            title: const Text('Vencimento'),
            subtitle: Text(
              atrasada
                  ? '${formatarData(tarefa.dataVencimento)} (atrasada)'
                  : formatarData(tarefa.dataVencimento),
              style: TextStyle(color: atrasada ? Colors.red : null),
            ),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.notes),
            title: const Text('Descrição'),
            subtitle: Text(
              tarefa.descricao.isEmpty ? 'Sem descrição.' : tarefa.descricao,
            ),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: () => _alternarSituacao(tarefa),
          icon: Icon(tarefa.concluida ? Icons.undo : Icons.check),
          label: Text(
            tarefa.concluida ? 'Reabrir (marcar como pendente)' : 'Marcar como concluída',
          ),
        ),
      ],
    );
  }
}
