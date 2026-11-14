import 'package:flutter/material.dart';

import '../services/preferences_service.dart';
import '../themes/app_theme.dart';
import '../widgets/drawer_menu.dart';

class ConfiguracoesScreen extends StatelessWidget {
  const ConfiguracoesScreen({super.key});

  Future<void> _alternarTema(bool escuro) async {
    final modo = escuro ? ThemeMode.dark : ThemeMode.light;
    temaNotifier.value = modo; // muda o tema do app inteiro na hora
    await PreferencesService().salvarTema(modo); // salva no aparelho
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      drawer: const DrawerMenu(rotaAtual: '/configuracoes'),
      body: ListView(
        children: [
          ValueListenableBuilder<ThemeMode>(
            valueListenable: temaNotifier,
            builder: (context, modo, child) {
              final escuro = modo == ThemeMode.dark;
              return SwitchListTile(
                secondary: Icon(escuro ? Icons.dark_mode : Icons.light_mode),
                title: const Text('Tema escuro'),
                subtitle: Text(
                  escuro ? 'Tema escuro ativado' : 'Tema claro ativado',
                ),
                value: escuro,
                onChanged: _alternarTema,
              );
            },
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.save_outlined),
            title: Text('Preferência salva neste aparelho'),
            subtitle: Text(
              'O tema escolhido fica guardado e é aplicado '
              'quando você abrir o aplicativo novamente.',
            ),
          ),
        ],
      ),
    );
  }
}
