import 'package:flutter/material.dart';

import '../models/tarefa.dart';
import '../models/usuario.dart';
import '../services/auth_service.dart';
import '../services/firebase_service.dart';
import '../themes/app_theme.dart';
import '../utils/helpers.dart';
import '../widgets/drawer_menu.dart';
import '../widgets/prioridade_badge.dart';
import 'cadastro_tarefa_screen.dart';
import 'detalhes_tarefa_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _auth = AuthService();
  final _db = FirebaseService();

  Stream<Usuario?>? _usuarioStream;
  Stream<List<Tarefa>>? _tarefasStream;

  @override
  void initState() {
    super.initState();
    final uid = _auth.uid;
    if (uid != null) {
      _usuarioStream = _db.usuarioStream(uid);
      _tarefasStream = _db.tarefasStream(uid);
    }
  }

  DateTime get _hoje {
    final agora = DateTime.now();
    return DateTime(agora.year, agora.month, agora.day);
  }

  bool _mesmoDia(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Future<void> _alterarSituacao(Tarefa tarefa) async {
    final uid = _auth.uid;
    if (uid == null) return;
    try {
      await _db.alterarSituacao(uid, tarefa.id, !tarefa.concluida);
    } catch (_) {
      if (mounted) mostrarMensagem(context, 'Não foi possível atualizar a tarefa.');
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
    try {
      await _db.excluirTarefa(uid, tarefa.id);
      if (mounted) mostrarMensagem(context, 'Tarefa excluída.');
    } catch (_) {
      if (mounted) mostrarMensagem(context, 'Não foi possível excluir a tarefa.');
    }
  }

  void _editar(Tarefa tarefa) {
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

  void _navegar(int indice) {
    switch (indice) {
      case 1:
        Navigator.pushNamed(context, '/tarefas');
        break;
      case 2:
        Navigator.pushNamed(context, '/configuracoes');
        break;
      case 3:
        Navigator.pushNamed(context, '/sobre');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            tooltip: 'Abrir menu',
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(''),
        actions: [
          IconButton(
            tooltip: 'Configurações',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.pushNamed(context, '/configuracoes'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: const DrawerMenu(rotaAtual: '/'),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: _navegar,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Início'),
          NavigationDestination(icon: Icon(Icons.checklist), label: 'Tarefas'),
          NavigationDestination(
            icon: Icon(Icons.tune_outlined),
            label: 'Ajustes',
          ),
          NavigationDestination(icon: Icon(Icons.info_outline), label: 'Sobre'),
        ],
      ),
      body: StreamBuilder<Usuario?>(
        stream: _usuarioStream,
        builder: (context, usuarioSnap) {
          final nome = usuarioSnap.data?.nome ??
              _auth.usuarioAtual?.displayName ??
              'usuário';

          return StreamBuilder<List<Tarefa>>(
            stream: _tarefasStream,
            builder: (context, tarefasSnap) {
              if (tarefasSnap.hasError) {
                return const Center(child: Text('Não foi possível carregar as tarefas.'));
              }
              if (!tarefasSnap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              return _conteudo(nome, tarefasSnap.data!);
            },
          );
        },
      ),
    );
  }

  Widget _conteudo(String nome, List<Tarefa> tarefas) {
    final hoje = _hoje;
    final tarefasHoje = tarefas
        .where((t) => _mesmoDia(t.dataVencimento, hoje))
        .toList();
    final atrasadas = tarefas
        .where((t) => !t.concluida && t.dataVencimento.isBefore(hoje))
        .toList();
    final proximas = tarefas
        .where((t) => !t.concluida && t.dataVencimento.isAfter(hoje))
        .toList();
    final pendentes = tarefas.where((t) => !t.concluida).length;
    final concluidas = tarefas.length - pendentes;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Olá, $nome!', style: _tituloAcolhedor(context)),
            const SizedBox(height: 4),
            Text(
              'Você consegue!',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontFamily: 'serif',
                  ),
            ),
            const SizedBox(height: 10),
            Container(
              width: 82,
              height: 3,
              decoration: BoxDecoration(
                color: AppTheme.sage,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _ResumoTarefas(
          cadastradas: tarefas.length,
          pendentes: pendentes,
          concluidas: concluidas,
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 58,
          child: FilledButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CadastroTarefaScreen()),
            ),
            icon: const Icon(Icons.add, size: 24),
            label: const Text('Adicionar tarefa'),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.coffee,
              foregroundColor: AppTheme.cream,
              textStyle: const TextStyle(
                fontFamily: 'serif',
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              shape: const StadiumBorder(),
            ),
          ),
        ),
        const SizedBox(height: 24),
        if (atrasadas.isNotEmpty) ...[
          const _TituloSecao(icone: Icons.warning_amber_rounded, texto: 'Atrasadas'),
          const SizedBox(height: 8),
          for (final tarefa in atrasadas)
            _TarefaCard(
              tarefa: tarefa,
              aoTocar: () => _abrirDetalhes(tarefa),
              aoConcluir: () => _alterarSituacao(tarefa),
              aoEditar: () => _editar(tarefa),
              aoExcluir: () => _excluir(tarefa),
            ),
          const SizedBox(height: 10),
        ],
        _TituloSecao(
          icone: Icons.calendar_today_outlined,
          texto: 'Hoje, ${_dataCurta(hoje)}',
        ),
        const SizedBox(height: 8),
        if (tarefasHoje.isEmpty)
          const _MensagemVazia(texto: 'Nenhuma tarefa para hoje. Aproveite o dia!'),
        for (final tarefa in tarefasHoje)
          _TarefaCard(
            tarefa: tarefa,
            aoTocar: () => _abrirDetalhes(tarefa),
            aoConcluir: () => _alterarSituacao(tarefa),
            aoEditar: () => _editar(tarefa),
            aoExcluir: () => _excluir(tarefa),
          ),
        if (proximas.isNotEmpty) ...[
          const SizedBox(height: 18),
          const _TituloSecao(icone: Icons.flag_outlined, texto: 'Próximas tarefas'),
          const SizedBox(height: 8),
          for (final tarefa in proximas.take(3))
            _TarefaCard(
              tarefa: tarefa,
              aoTocar: () => _abrirDetalhes(tarefa),
              aoConcluir: () => _alterarSituacao(tarefa),
              aoEditar: () => _editar(tarefa),
              aoExcluir: () => _excluir(tarefa),
            ),
        ],
      ],
    );
  }

  TextStyle? _tituloAcolhedor(BuildContext context) =>
      Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontFamily: 'cursive',
            fontSize: 31,
            color: Theme.of(context).colorScheme.onSurface,
          );

  String _dataCurta(DateTime data) {
    const meses = [
      'jan', 'fev', 'mar', 'abr', 'mai', 'jun',
      'jul', 'ago', 'set', 'out', 'nov', 'dez',
    ];
    return '${data.day} de ${meses[data.month - 1]}';
  }
}

class _ResumoTarefas extends StatelessWidget {
  final int cadastradas;
  final int pendentes;
  final int concluidas;

  const _ResumoTarefas({
    required this.cadastradas,
    required this.pendentes,
    required this.concluidas,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.sage,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ResumoNumero(
              rotulo: 'Cadastradas',
              valor: cadastradas,
              icone: Icons.list_alt,
            ),
          ),
          _separador(),
          Expanded(
            child: _ResumoNumero(
              rotulo: 'Pendentes',
              valor: pendentes,
              icone: Icons.schedule,
            ),
          ),
          _separador(),
          Expanded(
            child: _ResumoNumero(
              rotulo: 'Concluídas',
              valor: concluidas,
              icone: Icons.check_circle_outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _separador() => Container(
        width: 1,
        height: 60,
        color: AppTheme.cream.withValues(alpha: .7),
      );
}

class _ResumoNumero extends StatelessWidget {
  final String rotulo;
  final int valor;
  final IconData icone;

  const _ResumoNumero({
    required this.rotulo,
    required this.valor,
    required this.icone,
  });

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icone, color: AppTheme.cream, size: 22),
          Text(
            '$valor',
            style: TextStyle(
              color: AppTheme.cream,
              fontSize: 28,
              height: 1.1,
              fontFamily: 'serif',
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            rotulo,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.cream, fontSize: 11),
          ),
        ],
      );
}

class _TituloSecao extends StatelessWidget {
  final IconData icone;
  final String texto;

  const _TituloSecao({required this.icone, required this.texto});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icone, color: AppTheme.terracotta),
          const SizedBox(width: 10),
          Text(
            texto,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontFamily: 'serif',
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Divider(color: AppTheme.terracotta.withValues(alpha: .5)),),
        ],
      );
}

class _TarefaCard extends StatelessWidget {
  final Tarefa tarefa;
  final VoidCallback aoTocar;
  final VoidCallback aoConcluir;
  final VoidCallback aoEditar;
  final VoidCallback aoExcluir;

  const _TarefaCard({
    required this.tarefa,
    required this.aoTocar,
    required this.aoConcluir,
    required this.aoEditar,
    required this.aoExcluir,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 9),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: AppTheme.beige.withValues(alpha: .9)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        child: ListTile(
          onTap: aoTocar,
          leading: Checkbox(
            value: tarefa.concluida,
            onChanged: (_) => aoConcluir(),
            activeColor: AppTheme.sage,
            shape: const CircleBorder(),
          ),
          title: Text(
            tarefa.titulo,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontFamily: 'serif',
                  decoration: tarefa.concluida ? TextDecoration.lineThrough : null,
                  color: tarefa.concluida ? colors.outline : null,
                ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Icon(Icons.event_outlined, size: 14, color: AppTheme.terracotta),
                Text(formatarData(tarefa.dataVencimento)),
                PrioridadeBadge(prioridade: tarefa.prioridade),
              ],
            ),
          ),
          trailing: PopupMenuButton<String>(
            onSelected: (acao) {
              if (acao == 'editar') aoEditar();
              if (acao == 'excluir') aoExcluir();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'editar', child: Text('Editar')),
              PopupMenuItem(value: 'excluir', child: Text('Excluir')),
            ],
          ),
        ),
      ),
    );
  }
}

class _MensagemVazia extends StatelessWidget {
  final String texto;
  const _MensagemVazia({required this.texto});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppTheme.beige.withValues(alpha: .65),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(texto, style: Theme.of(context).textTheme.bodyMedium),
      );
}

