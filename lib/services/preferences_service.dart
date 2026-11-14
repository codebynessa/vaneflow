import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Preferencias locais (salvas no aparelho) com SharedPreferences.
/// Se o aparelho nao conseguir usar o SharedPreferences, o app nao quebra:
/// ele apenas usa o tema claro e segue funcionando.
class PreferencesService {
  static const String _chaveTemaEscuro = 'tema_escuro';

  /// Le o tema salvo. Se nunca foi salvo (ou der erro), usa o tema claro.
  Future<ThemeMode> carregarTema() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final escuro = prefs.getBool(_chaveTemaEscuro) ?? false;
      return escuro ? ThemeMode.dark : ThemeMode.light;
    } catch (e) {
      debugPrint('Erro ao ler a preferencia de tema: $e');
      return ThemeMode.light;
    }
  }

  /// Salva o tema escolhido.
  Future<void> salvarTema(ThemeMode modo) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_chaveTemaEscuro, modo == ThemeMode.dark);
    } catch (e) {
      debugPrint('Erro ao salvar a preferencia de tema: $e');
    }
  }
}