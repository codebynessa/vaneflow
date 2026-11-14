/// Model que representa o usuario autenticado.
/// Guardado no Realtime Database em: usuarios/{uid}
class Usuario {
  final String uid;
  final String nome;
  final String email;

  const Usuario({
    required this.uid,
    required this.nome,
    required this.email,
  });

  /// Converte o objeto em Map para salvar no Firebase.
  /// O uid nao vai no Map porque ele ja e a chave do registro.
  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'email': email,
    };
  }

  /// Cria um Usuario a partir do Map lido do Firebase.
  factory Usuario.fromMap(String uid, Map<dynamic, dynamic> map) {
    return Usuario(
      uid: uid,
      nome: (map['nome'] ?? '') as String,
      email: (map['email'] ?? '') as String,
    );
  }
}
