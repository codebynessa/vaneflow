import 'package:flutter/material.dart';

import '../models/tarefa.dart';
import '../services/auth_service.dart';
import '../services/firebase_service.dart';
import '../utils/helpers.dart';
import '../widgets/prioridade_badge.dart';

/// Tela usada para CADASTRAR (tarefa == null) e para EDITAR uma tarefa.
class CadastroTarefaScreen extends StatefulWidget {
  final Tarefa? tarefa;

  const CadastroTarefaScreen({super.key, this.tarefa});

  @override
  State<CadastroTarefaScreen> createState() => _CadastroTarefaScreenState();
}

class _CadastroTarefaScreenState extends State<CadastroTarefaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloCtrl = TextEditingController();
  final _descricaoCtrl = TextEditingController();
  final _auth = AuthService();
  final _db = FirebaseService();

  late DateTime _data;
  Prioridade _prioridade = Prioridade.media;
  bool _concluida = false;
  bool _salvando = false;

  bool get _editando => widget.tarefa != null;

  @override
  void initState() {
    super.initState();
    final t = widget.tarefa;
    if (t != null) {
      _tituloCtrl.text = t.titulo;
      _descricaoCtrl.text = t.descricao;
      _data = t.dataVencimento;
      _prioridade = t.prioridade;
      _concluida = t.concluida;
    } else {
      final agora = DateTime.now();
      _data = DateTime(agora.year, agora.month, agora.day);
    }
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descricaoCtrl.dispose();
    super.dispose();
  }

  Future<void> _escolherData() async {
    final escolhida = await showDatePicker(
      context: context,
      initialDate: _data,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (escolhida != null) {
      setState(() => _data = escolhida);
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    final uid = _auth.uid;
    if (uid == null) return;

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final tarefa = Tarefa(
      id: widget.tarefa?.id ?? '',
      titulo: _tituloCtrl.text.trim(),
      descricao: _descricaoCtrl.text.trim(),
      dataVencimento: _data,
      prioridade: _prioridade,
      concluida: _concluida,
    );

    setState(() => _salvando = true);
    try {
      if (_editando) {
        await _db.atualizarTarefa(uid, tarefa);
      } else {
        await _db.criarTarefa(uid, tarefa);
      }
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            _editando ? 'Tarefa atualizada.' : 'Tarefa cadastrada.',
          ),
        ),
      );
      navigator.pop();
    } catch (_) {
      if (mounted) {
        setState(() => _salvando = false);
        mostrarMensagem(context, 'Não foi possível salvar a tarefa.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editando ? 'Editar tarefa' : 'Nova tarefa'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _tituloCtrl,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.next,
                  decoration: decoracaoCampo('Título', icone: Icons.title),
                  validator: (v) => validarObrigatorio(v, 'o título'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descricaoCtrl,
                  textCapitalization: TextCapitalization.sentences,
                  minLines: 3,
                  maxLines: 6,
                  decoration: decoracaoCampo('Descrição', icone: Icons.notes),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: _escolherData,
                  child: InputDecorator(
                    decoration: decoracaoCampo(
                      'Data de vencimento',
                      icone: Icons.event,
                    ),
                    child: Text(formatarData(_data)),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Prioridade',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                SegmentedButton<Prioridade>(
                  segments: Prioridade.values
                      .map(
                        (p) => ButtonSegment<Prioridade>(
                          value: p,
                          label: Text(p.rotulo),
                          icon: Icon(
                            PrioridadeBadge.iconeDe(p),
                            color: PrioridadeBadge.corDe(p),
                          ),
                        ),
                      )
                      .toList(),
                  selected: {_prioridade},
                  onSelectionChanged: (selecao) =>
                      setState(() => _prioridade = selecao.first),
                ),
                const SizedBox(height: 24),
                Text(
                  'Situação',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment<bool>(
                      value: false,
                      label: Text('Pendente'),
                      icon: Icon(Icons.schedule),
                    ),
                    ButtonSegment<bool>(
                      value: true,
                      label: Text('Concluída'),
                      icon: Icon(Icons.check_circle_outline),
                    ),
                  ],
                  selected: {_concluida},
                  onSelectionChanged: (selecao) =>
                      setState(() => _concluida = selecao.first),
                ),
                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: _salvando ? null : _salvar,
                  icon: _salvando
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: Text(_editando ? 'Salvar alterações' : 'Cadastrar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
