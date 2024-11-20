import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;

class AnaliseComentariosPage extends StatefulWidget {
  const AnaliseComentariosPage({super.key});

  @override
  State<AnaliseComentariosPage> createState() => _AnaliseComentariosPageState();
}

class _AnaliseComentariosPageState extends State<AnaliseComentariosPage> {
  static const Color kRoxo = Color(0xFFBA68C8);
  static const Color kCinza = Color(0xFF263339);
  final TextEditingController _controller = TextEditingController();
  String _resultado = '';
  String _intencao = '';
  bool _isLoading = false;
  Sentimento _sentimento = Sentimento.padrao;

  // Constantes da API
  final String witAiAccessToken =
      "3D7VQHGSO7D7ABSJD7I7QLQNHO2TWRO7"; // Insira sua chave aqui
  final String witAiUrl = "https://api.wit.ai/message?v=20241116&q=";

  Future<void> analisarSentimento(String mensagem) async {
    setState(() {
      _isLoading = true;
      _resultado = '';
    });

    try {
      validarEntradaValida(mensagem);
      String mensagemFormatada = Uri.encodeComponent(mensagem);
      String jsonResponse = await realizarRequisicao(
          "$witAiUrl$mensagemFormatada", witAiAccessToken);
      String resposta = obterRespostaDeJson(jsonResponse);

      _sentimento = Sentimento.fromString(_intencao);
      setState(() => _resultado = resposta);
    } catch (e) {
      setState(() => _resultado = "Erro ao analisar sentimento: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void validarEntradaValida(String? mensagem) {
    if (mensagem == null || mensagem.isEmpty) {
      throw ArgumentError("Mensagem inválida");
    }
  }

  Future<String> realizarRequisicao(String url, String accessToken) async {
    final response = await http.get(
      Uri.parse(url),
      headers: {
        "Authorization": "Bearer $accessToken",
      },
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception("Erro na requisição: ${response.statusCode}");
    }
  }

  String obterRespostaDeJson(String jsonResponse) {
    final jsonMap = jsonDecode(jsonResponse);

    if (jsonMap.containsKey('intents') &&
        (jsonMap['intents'] as List).isNotEmpty) {
      final intent = jsonMap['intents'][0]['name'];
      setState(() => _intencao = intent);
      return "Intenção detectada: $intent";
    } else {
      setState(() => _intencao = "");
      return "Sentimento não detectado";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCinza,
      appBar: AppBar(
        backgroundColor: kRoxo,
        title: const Center(
          child: Text(
            "Análise de Comentários",
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!_isLoading)
              SvgPicture.asset(
                _sentimento.imagem,
                width: 300,
                height: 300,
              ),
            if (_isLoading)
              const SizedBox(
                width: 300,
                height: 300,
              ),
            const SizedBox(height: 32),
            Container(
              constraints: const BoxConstraints(maxWidth: 400),
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: "Digite um comentário",
                  hintStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 320,
              child: ElevatedButton(
                onPressed: () => analisarSentimento(_controller.text),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kRoxo,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.black,
                  elevation: 5,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 60,
                    vertical: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.search, size: 24),
                    SizedBox(width: 8),
                    Text(
                      "Analisar",
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            if (_resultado.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _resultado,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

enum Sentimento {
  padrao("assets/padrao.svg"),
  positivo("assets/positivo.svg"),
  negativo("assets/negativo.svg"),
  neutro("assets/neutro.svg"),
  misto("assets/misto.svg"),
  expectativa("assets/expectativa.svg");

  final String imagem;

  const Sentimento(this.imagem);

  static Sentimento fromString(String sentimento) {
    switch (sentimento.toLowerCase()) {
      case "positivo":
        return Sentimento.positivo;
      case "negativo":
        return Sentimento.negativo;
      case "neutro":
        return Sentimento.neutro;
      case "misto":
        return Sentimento.misto;
      case "expectativa":
        return Sentimento.expectativa;
      default:
        return Sentimento.padrao;
    }
  }
}
