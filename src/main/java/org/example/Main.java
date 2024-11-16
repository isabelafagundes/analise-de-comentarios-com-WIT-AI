package org.example;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.Scanner;

public class Main {
    //Chave de acesso da API do Wit.ai
    private static final String WIT_AI_ACCESS_TOKEN = "";
    private static final String WIT_AI_URL = "https://api.wit.ai/message?v=20241116&q=";

    public static void main(String[] args) {
        while (true) {
            Scanner scanner = new Scanner(System.in);
            System.out.println("\nDigite um comentário sobre um filme para analisarmos o sentimento:");
            String mensagem = "";
            try {
                mensagem = scanner.nextLine();
                validarEntradaValida(mensagem);
                String resultado = analisarSentimento(mensagem);
                System.out.println(resultado);
                System.out.println("-- Inserir mais um comentário? [S/N] --");
                String continuar = scanner.nextLine();
                if (continuar.equalsIgnoreCase("N")) {
                    break;
                }
            } catch (Exception e) {
                System.out.println("Erro ao analisar sentimento, tente novamente");
            }

        }
    }


    public static void validarEntradaValida(String mensagem) {
        if (mensagem == null || mensagem.isEmpty()) {
            throw new IllegalArgumentException("Mensagem inválida");
        }
    }

    public static String analisarSentimento(String message) {
        try {
            String mensagemFormatada = java.net.URLEncoder.encode(message, "UTF-8");
            String jsonResponse = realizarRequisicao(WIT_AI_URL + mensagemFormatada);
            String resposta = obterRespostaDeJson(jsonResponse);
            return "\n" + resposta;
        } catch (Exception e) {
            e.printStackTrace();
            return "\nErro na requisição: " + e.getMessage();
        }
    }

    //Realiza a requisição GET para a API do Wit.ai enviando a mensagem e retornando o JSON de resposta
    public static String realizarRequisicao(String urlString) {
        try {
            URL url = new URL(urlString);
            HttpURLConnection connection = (HttpURLConnection) url.openConnection();
            connection.setRequestMethod("GET");
            connection.setRequestProperty("Authorization", "Bearer " + WIT_AI_ACCESS_TOKEN);
            BufferedReader in = new BufferedReader(new InputStreamReader(connection.getInputStream()));
            String inputLine;
            StringBuilder response = new StringBuilder();
            while ((inputLine = in.readLine()) != null) {
                response.append(inputLine);
            }
            in.close();
            return response.toString();
        } catch (Exception e) {
            e.printStackTrace();
            return "Erro na requisição: " + e.getMessage();
        }
    }

    //Obtem a resposta do JSON, validando a existência da chave "intents"
    // e retornando a intenção detectada ou a mensagem de sentimento não detectado
    public static String obterRespostaDeJson(String json) {
        org.json.JSONObject jsonObject = new org.json.JSONObject(json);
        if (jsonObject.has("intents") && !jsonObject.getJSONArray("intents").isEmpty()) {
            String intent = jsonObject.getJSONArray("intents").getJSONObject(0).getString("name");
            return "Intenção detectada: " + intent;
        } else {
            return "Sentimento não detectado";
        }
    }

}


