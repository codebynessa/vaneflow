import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

import '../models/tarefa.dart';
import '../models/usuario.dart';

/// Acesso ao Firebase Realtime Database.
///
/// Estrutura no banco:
///   usuarios/{uid}          -> dados do usuario
///   tarefas/{uid}/{id}      -> tarefas de CADA usuario
///
/// Como as tarefas ficam dentro de tarefas/{uid}, e as regras do banco
/// (database.rules.json) so liberam o acesso para o dono do uid,
/// cada usuario so enxerga e altera as proprias tarefas.
class FirebaseService {
  final FirebaseDatabase _db = FirebaseDatabase.instance;

  DatabaseReference _refUsuario(String uid) => _db.ref('usuarios/$uid');
  DatabaseReference _refTarefas(String uid) => _db.ref('tarefas/$uid');

  void _logErro(Object erro) {
    debugPrint('Erro no Realtime Database: $erro');
  }

  // ---------------------------------------------------------------- Usuario

  Future<void> salvarUsuario(Usuario usuario) {
    return _refUsuario(usuario.uid).set(usuario.toMap());
  }

  /// Acompanha os dados do usuario em tempo real.
  Stream<Usuario?> usuarioStream(String uid) {
    return _refUsuario(uid).onValue.map((event) {
      final valor = event.snapshot.value;
      if (valor == null) return null;
      return Usuario.fromMap(uid, valor as Map);
    }).handleError(_logErro);
  }

  // ---------------------------------------------------------------- Tarefas

  /// LISTENER em tempo real: emite a lista nova sempre que algo mudar.
  Stream<List<Tarefa>> tarefasStream(String uid) {
    return _refTarefas(uid).onValue.map((event) {
      final lista = <Tarefa>[];
      for (final filho in event.snapshot.children) {
        final valor = filho.value;
        if (valor is Map && filho.key != null) {
          lista.add(Tarefa.fromMap(filho.key!, valor));
        }
      }
      lista.sort((a, b) => a.dataVencimento.compareTo(b.dataVencimento));
      return lista;
    }).handleError(_logErro);
  }

  /// CONSULTA de uma tarefa (tela de detalhes), tambem em tempo real.
  Stream<Tarefa?> tarefaStream(String uid, String id) {
    return _refTarefas(uid).child(id).onValue.map((event) {
      final valor = event.snapshot.value;
      if (valor == null) return null;
      return Tarefa.fromMap(id, valor as Map);
    }).handleError(_logErro);
  }

  /// CREATE: push() gera um id unico automaticamente.
  Future<void> criarTarefa(String uid, Tarefa tarefa) async {
    final ref = _refTarefas(uid).push();
    await ref.set(tarefa.toMap());
  }

  /// UPDATE: atualiza todos os campos da tarefa.
  Future<void> atualizarTarefa(String uid, Tarefa tarefa) {
    return _refTarefas(uid).child(tarefa.id).update(tarefa.toMap());
  }

  /// UPDATE: troca so a situacao (Pendente <-> Concluida).
  Future<void> alterarSituacao(String uid, String id, bool concluida) {
    return _refTarefas(uid).child(id).update({'concluida': concluida});
  }

  /// DELETE
  Future<void> excluirTarefa(String uid, String id) {
    return _refTarefas(uid).child(id).remove();
  }
}
