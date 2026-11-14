/// Prioridade da tarefa (Baixa, Media ou Alta).
enum Prioridade {
  baixa('Baixa'),
  media('Média'),
  alta('Alta');

  final String rotulo;
  const Prioridade(this.rotulo);

  /// Converte o texto salvo no Firebase de volta para o enum.
  static Prioridade fromNome(String? nome) {
    return Prioridade.values.firstWhere(
      (p) => p.name == nome,
      orElse: () => Prioridade.media,
    );
  }
}

/// Model que representa uma tarefa.
/// Guardada no Realtime Database em: tarefas/{uid}/{id}
class Tarefa {
  final String id;
  final String titulo;
  final String descricao;
  final DateTime dataVencimento;
  final Prioridade prioridade;
  final bool concluida; // false = Pendente, true = Concluida

  const Tarefa({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.dataVencimento,
    required this.prioridade,
    required this.concluida,
  });

  /// Tarefa pendente com data de vencimento anterior a hoje.
  bool get atrasada {
    final agora = DateTime.now();
    final hoje = DateTime(agora.year, agora.month, agora.day);
    return !concluida && dataVencimento.isBefore(hoje);
  }

  /// Converte para Map (o id nao entra: ele e a chave do registro).
  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'descricao': descricao,
      'dataVencimento': dataVencimento.toIso8601String(),
      'prioridade': prioridade.name,
      'concluida': concluida,
    };
  }

  /// Cria uma Tarefa a partir do Map lido do Firebase.
  factory Tarefa.fromMap(String id, Map<dynamic, dynamic> map) {
    return Tarefa(
      id: id,
      titulo: (map['titulo'] ?? '') as String,
      descricao: (map['descricao'] ?? '') as String,
      dataVencimento:
          DateTime.tryParse((map['dataVencimento'] ?? '') as String) ??
              DateTime.now(),
      prioridade: Prioridade.fromNome(map['prioridade'] as String?),
      concluida: (map['concluida'] ?? false) as bool,
    );
  }

  Tarefa copyWith({
    String? id,
    String? titulo,
    String? descricao,
    DateTime? dataVencimento,
    Prioridade? prioridade,
    bool? concluida,
  }) {
    return Tarefa(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
      dataVencimento: dataVencimento ?? this.dataVencimento,
      prioridade: prioridade ?? this.prioridade,
      concluida: concluida ?? this.concluida,
    );
  }
}
