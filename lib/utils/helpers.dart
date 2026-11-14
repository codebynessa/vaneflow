import 'package:flutter/material.dart';

/// Formata a data como dd/mm/aaaa.
String formatarData(DateTime d) {
  final dia = d.day.toString().padLeft(2, '0');
  final mes = d.month.toString().padLeft(2, '0');
  return '$dia/$mes/${d.year}';
}

/// Decoracao padrao dos campos de texto.
InputDecoration decoracaoCampo(
  String rotulo, {
  IconData? icone,
  Widget? sufixo,
}) {
  return InputDecoration(
    labelText: rotulo,
    prefixIcon: icone == null ? null : Icon(icone),
    suffixIcon: sufixo,
    border: const OutlineInputBorder(),
  );
}

// ------------------------------------------------------------- Validacoes

String? validarObrigatorio(String? valor, String campo) {
  if (valor == null || valor.trim().isEmpty) {
    return 'Informe $campo.';
  }
  return null;
}

String? validarEmail(String? valor) {
  if (valor == null || valor.trim().isEmpty) {
    return 'Informe o e-mail.';
  }
  final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  if (!regex.hasMatch(valor.trim())) {
    return 'E-mail inválido.';
  }
  return null;
}

String? validarSenha(String? valor) {
  if (valor == null || valor.isEmpty) {
    return 'Informe a senha.';
  }
  if (valor.length < 6) {
    return 'A senha deve ter pelo menos 6 caracteres.';
  }
  return null;
}

// ------------------------------------------------------------- Interface

void mostrarMensagem(BuildContext context, String texto) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(texto)));
}

/// Mostra uma caixa de confirmacao. Retorna true se o usuario confirmar.
Future<bool> confirmarAcao(
  BuildContext context, {
  required String titulo,
  required String mensagem,
  String confirmar = 'Confirmar',
}) async {
  final resultado = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(titulo),
      content: Text(mensagem),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(confirmar),
        ),
      ],
    ),
  );
  return resultado ?? false;
}
