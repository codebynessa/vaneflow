import 'package:flutter/material.dart';

import '../widgets/drawer_menu.dart';
import '../widgets/brand_mark.dart';

class SobreScreen extends StatelessWidget {
  const SobreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sobre o aplicativo')),
      drawer: const DrawerMenu(rotaAtual: '/sobre'),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const BrandMark(size: 116),
          const SizedBox(height: 12),
          const Text('Versão 1.0.0', textAlign: TextAlign.center),
          const SizedBox(height: 24),
          const Text(
            'VaneFlow é um aplicativo de gerenciamento de tarefas pessoais, '
            'desenvolvido '
            'como atividade prática (P2) da disciplina de Programação Mobile.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          const Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.flutter_dash),
                  title: Text('Flutter / Dart'),
                ),
                ListTile(
                  leading: Icon(Icons.lock_outline),
                  title: Text('Firebase Authentication'),
                  subtitle: Text('Cadastro e login por e-mail e senha'),
                ),
                ListTile(
                  leading: Icon(Icons.cloud_outlined),
                  title: Text('Firebase Realtime Database'),
                  subtitle: Text('Tarefas na nuvem, em tempo real'),
                ),
                ListTile(
                  leading: Icon(Icons.save_outlined),
                  title: Text('SharedPreferences'),
                  subtitle: Text('Tema claro/escuro salvo no aparelho'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Desenvolvido por Vanessa — UNIGRAN',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
