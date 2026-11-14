import 'package:flutter/material.dart';

import '../models/tarefa.dart';
import '../services/auth_service.dart';
import '../services/firebase_service.dart';
import '../utils/helpers.dart';
import '../widgets/drawer_menu.dart';
import '../widgets/prioridade_badge.dart';
import 'cadastro_tarefa_screen.dart';
import 'detalhes_tarefa_screen.dart';

enum FiltroTarefas { todas, pendentes, concluidas }

class TarefasScreen extends StatefulWidget {
  const TarefasScreen({super.key});

  @override
  State<TarefasScreen> createState() => _TarefasScreenState();
}

class _TarefasScreenState extends State<TarefasScreen> {
  final _auth = AuthService();
  final _db = FirebaseService();

  Stream<List<Tarefa>>? _stream;
  FiltroTarefas _filtro = FiltroTarefas.todas;

  @override
  void initState() {
    super.initState();
    final uid = _auth.uid;
    if (uid != null) {
      _stream = _db.tarefasStream(uid);
    }
  }

  List<Tarefa> _filtrar(List<Tarefa> tarefas) {
    switch (_filtro) {
      case FiltroTarefas.todas:
        return tarefas;
      case FiltroTarefas.pendentes:
        return tarefas.where((t) => !t.concluida).toList();
      case FiltroTarefas.concluidas:
        return tarefas.where((t) => t.concluida).toList();
    }
  }

  void _abrirCadastro([Tarefa? tarefa]) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CadastroTarefaScreen(tarefa: tarefa)),
    );
  }

  void _abrirDetalhes(Tarefa tarefa) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetalhesTarefaScreen(tarefaId: tarefa.id),
      ),
    );
  }

  Future<void> _alterarSituacao(Tarefa tarefa, bool concluida) async {
    final uid = _auth.uid;
    if (uid == null) return;
    await _db.alterarSituacao(uid, tarefa.id, concluida);
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
    await _db.excluirTarefa(uid, tarefa.id);
    if (mounted) mostrarMensagem(context, 'Tarefa excluída.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Minhas tarefas')),
      drawer: const DrawerMenu(rotaAtual: '/tarefas'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirCadastro(),
        icon: const Icon(Icons.add),
        label: const Text('Nova tarefa'),
      ),
      body: StreamBuilder<List<Tarefa>>(
        stream: _stream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final tarefas = _filtrar(snapshot.data!);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                child: SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<FiltroTarefas>(
                    segments: const [
                      ButtonSegment(
                        value: FiltroTarefas.todas,
                        label: Text('Todas'),
                      ),
                      ButtonSegment(
                        value: FiltroTarefas.pendentes,
                        label: Text('Pendentes'),
                      ),
                      ButtonSegment(
                        value: FiltroTarefas.concluidas,
                        label: Text('Concluídas'),
                      ),
                    ],
                    selected: {_filtro},
                    onSelectionChanged: (selecao) =>
                        setState(() => _filtro = selecao.first),
                  ),
                ),
              ),
              Expanded(
                child: tarefas.isEmpty
                    ? _estadoVazio()
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 88),
                        itemCount: tarefas.length,
                        itemBuilder: (context, i) => _itemTarefa(tarefas[i]),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _estadoVazio() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.inbox_outlined, size: 64),
            const SizedBox(height: 12),
            Text(
              'Nenhuma tarefa por aqui.',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            const Text('Toque em "Nova tarefa" para cadastrar.'),
          ],
        ),
      ),
    );
  }

  Widget _itemTarefa(Tarefa tarefa) {
    final atrasada = tarefa.atrasada;
    final corData = atrasada ? Colors.red : null;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        onTap: () => _abrirDetalhes(tarefa),
        leading: Checkbox(
          value: tarefa.concluida,
          onChanged: (valor) => _alterarSituacao(tarefa, valor ?? false),
        ),
        title: Text(
          tarefa.titulo,
          style: TextStyle(
            decoration: tarefa.concluida ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Wrap(
            spacing: 8,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.event, size: 14, color: corData),
                  const SizedBox(width: 4),
                  Text(
                    formatarData(tarefa.dataVencimento),
                    style: TextStyle(color: corData),
                  ),
                ],
              ),
              PrioridadeBadge(prioridade: tarefa.prioridade),
              SituacaoBadge(concluida: tarefa.concluida),
            ],
          ),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (acao) {
            if (acao == 'editar') {
              _abrirCadastro(tarefa);
            } else if (acao == 'excluir') {
              _excluir(tarefa);
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'editar', child: Text('Editar')),
            PopupMenuItem(value: 'excluir', child: Text('Excluir')),
          ],
        ),
      ),
    );
  }
}
