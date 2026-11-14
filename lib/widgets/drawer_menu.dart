import 'package:flutter/material.dart';

import '../models/usuario.dart';
import '../services/auth_service.dart';
import '../services/firebase_service.dart';

/// Menu lateral (Drawer) usado em todas as telas principais.
/// [rotaAtual] serve para destacar a opcao da tela em que o usuario esta.
class DrawerMenu extends StatefulWidget {
  final String rotaAtual;

  const DrawerMenu({super.key, required this.rotaAtual});

  @override
  State<DrawerMenu> createState() => _DrawerMenuState();
}

class _DrawerMenuState extends State<DrawerMenu> {
  final AuthService _auth = AuthService();
  Stream<Usuario?>? _usuarioStream;

  @override
  void initState() {
    super.initState();
    final uid = _auth.uid;
    if (uid != null) {
      _usuarioStream = FirebaseService().usuarioStream(uid);
    }
  }

  /// Fecha o menu e navega para a rota escolhida.
  void _ir(String rota) {
    Navigator.pop(context); // fecha o Drawer
    if (rota == widget.rotaAtual) return;

    if (rota == '/') {
      Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
    } else if (widget.rotaAtual == '/') {
      Navigator.pushNamed(context, rota);
    } else {
      Navigator.pushReplacementNamed(context, rota);
    }
  }

  Future<void> _sair() async {
    final navigator = Navigator.of(context);
    navigator.pop(); // fecha o Drawer
    await _auth.logout();
    navigator.pushNamedAndRemoveUntil('/', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          StreamBuilder<Usuario?>(
            stream: _usuarioStream,
            builder: (context, snapshot) {
              final nome = snapshot.data?.nome ??
                  _auth.usuarioAtual?.displayName ??
                  'Usuário';
              final email =
                  snapshot.data?.email ?? _auth.usuarioAtual?.email ?? '';
              return UserAccountsDrawerHeader(
                accountName: Text(nome),
                accountEmail: Text(email),
                currentAccountPicture: CircleAvatar(
                  child: Text(
                    nome.isNotEmpty ? nome[0].toUpperCase() : '?',
                    style: const TextStyle(fontSize: 26),
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Início'),
            selected: widget.rotaAtual == '/',
            onTap: () => _ir('/'),
          ),
          ListTile(
            leading: const Icon(Icons.checklist),
            title: const Text('Minhas tarefas'),
            selected: widget.rotaAtual == '/tarefas',
            onTap: () => _ir('/tarefas'),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Configurações'),
            selected: widget.rotaAtual == '/configuracoes',
            onTap: () => _ir('/configuracoes'),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Sobre o aplicativo'),
            selected: widget.rotaAtual == '/sobre',
            onTap: () => _ir('/sobre'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sair'),
            onTap: _sair,
          ),
        ],
      ),
    );
  }
}
