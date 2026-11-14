import 'package:firebase_auth/firebase_auth.dart';

import '../models/usuario.dart';
import 'firebase_service.dart';

/// Erro de autenticacao com mensagem pronta para mostrar ao usuario.
class AuthException implements Exception {
  final String mensagem;
  const AuthException(this.mensagem);

  @override
  String toString() => mensagem;
}

/// Cadastro, login e logout com Firebase Authentication (e-mail e senha).
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseService _db = FirebaseService();

  /// Emite o usuario logado (ou null). O Firebase guarda a sessao no
  /// aparelho, entao ao reabrir o app o usuario continua logado.
  Stream<User?> get estadoAutenticacao => _auth.authStateChanges();

  User? get usuarioAtual => _auth.currentUser;
  String? get uid => _auth.currentUser?.uid;

  Future<void> cadastrar({
    required String nome,
    required String email,
    required String senha,
  }) async {
    try {
      final credencial = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );
      final user = credencial.user!;
      await user.updateDisplayName(nome);
      await _db.salvarUsuario(Usuario(uid: user.uid, nome: nome, email: email));
    } on FirebaseAuthException catch (e) {
      throw AuthException(_traduzirErro(e.code));
    }
  }

  Future<void> login({required String email, required String senha}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: senha);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_traduzirErro(e.code));
    }
  }

  Future<void> logout() => _auth.signOut();

  String _traduzirErro(String codigo) {
    switch (codigo) {
      case 'invalid-email':
        return 'E-mail inválido.';
      case 'user-disabled':
        return 'Esta conta foi desativada.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'E-mail ou senha incorretos.';
      case 'email-already-in-use':
        return 'Já existe uma conta com este e-mail.';
      case 'weak-password':
        return 'A senha é muito fraca. Use pelo menos 6 caracteres.';
      case 'network-request-failed':
        return 'Sem conexão com a internet.';
      case 'too-many-requests':
        return 'Muitas tentativas. Aguarde um pouco e tente de novo.';
      case 'operation-not-allowed':
        return 'Login por e-mail/senha não está ativado no Firebase.';
      default:
        return 'Erro de autenticação ($codigo).';
    }
  }
}
