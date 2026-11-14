import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart'; // gerado pelo comando: flutterfire configure
import 'screens/cadastro_usuario_screen.dart';
import 'screens/configuracoes_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/sobre_screen.dart';
import 'screens/tarefas_screen.dart';
import 'services/auth_service.dart';
import 'services/preferences_service.dart';
import 'themes/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Le o tema salvo ANTES de abrir o app, para nao piscar o tema errado.
  temaNotifier.value = await PreferencesService().carregarTema();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Sempre que temaNotifier mudar, o app inteiro e reconstruido com o novo tema.
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: temaNotifier,
      builder: (context, modo, child) {
        return MaterialApp(
          title: 'VaneFlow',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: modo,
          // A rota '/' e o proprio AuthGate (home).
          home: const AuthGate(),
          routes: {
            '/cadastro': (context) => const CadastroUsuarioScreen(),
            '/tarefas': (context) => const TarefasScreen(),
            '/configuracoes': (context) => const ConfiguracoesScreen(),
            '/sobre': (context) => const SobreScreen(),
          },
        );
      },
    );
  }
}

/// Decide qual tela mostrar: logado -> Home, deslogado -> Login.
/// Como o Firebase guarda a sessao, ao reabrir o app o usuario segue logado.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final Stream<User?> _estado = AuthService().estadoAutenticacao;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _estado,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          return const HomeScreen();
        }
        return const LoginScreen();
      },
    );
  }
}
