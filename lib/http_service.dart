import 'dart:convert';
import 'package:googleai_dart/googleai_dart.dart';
import 'package:http/http.dart' as http;

class OpenAI {
  static const String openAiApiKey = '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'; // Replace with your OpenAI API key
  static final List<Map<String, String>> messages = [];

  static Future<String> dallEAPI(String prompt) async {
    messages.add({
      'role': 'user',
      'content': prompt,
    });
    try {
      final res = await http.post(
        Uri.parse('https://api.openai.com/v1/images/generations'), // Replace with the correct DALL·E endpoint
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openAiApiKey',
        },
        body: jsonEncode({
          'prompt': prompt,
        }),
      );

      if (res.statusCode == 200) {
        String imageUrl = jsonDecode(res.body)['data'][0]['url'];
        imageUrl = imageUrl.trim();

        messages.add({
          'role': 'assistant',
          'content': imageUrl,
        });
        return imageUrl;
      }
      return res.body;
    } catch (e) {
      return e.toString();
    }
  }

  static Future<String> chatGPTAPI(String prompt) async {
    messages.add({
      'role': 'user',
      'content': prompt,
    });
    try {
      final res = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'), // Replace with the correct GPT-3.5-turbo endpoint
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openAiApiKey',
        },
        body: jsonEncode({
          "model": "gpt-3.5-turbo",
          "messages": messages,
        }),
      );

      if (res.statusCode == 200) {
        String content = jsonDecode(res.body)['choices'][0]['message']['content'];
        content = content.trim();

        messages.add({
          'role': 'assistant',
          'content': content,
        });
        return content;
      }
      print(res.body);
      return jsonDecode(res.body)['choices'][0]['message']['content'];
    } catch (e) {
      return e.toString();
    }
  }

  static Future<String> getPromptResponse(String prompt) async {
    try {
      final res = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'), // Replace with the correct GPT-3.5-turbo endpoint
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openAiApiKey',
        },
        body: jsonEncode({
          "model": "gpt-3.5-turbo",
          "messages": [
            {
              'role': 'user',
              'content': 'Does this message want to generate an AI picture, image, art or anything similar? $prompt . Simply answer with a yes or no.'
            }
          ],
        }),
      );
      print(res.body);
      print(res.statusCode);
      if (res.statusCode == 200) {
        String content = jsonDecode(res.body)['choices'][0]['message']['content'];
        content = content.trim();
        print(content);

        switch (content.toLowerCase()) {
          case 'yes':
          case 'yes.':
            return await dallEAPI(prompt);
          default:
            return await chatGPTAPI(prompt);
        }
      }
      print(res.body);
      print(res.statusCode);

      return jsonDecode(res.body)['choices'][0]['message']['content'];
    } catch (e) {
      return e.toString();
    }
  }
  static Future<String> getGeminiResponse(String prompt) async {
    final client = GoogleAIClient(apiKey: 'AIzaSyDCjvw6pABBh93cHYZ7Q6pbfLNvrYXb32s');
    final res = await client.generateContent(
      modelId: 'gemini-pro',
      request: GenerateContentRequest(
        contents: [
          Content(parts: [
            Part(text: prompt),
          ]),
        ],
        generationConfig: GenerationConfig(temperature: 0.8),
      ),
    );
    print(res.candidates?.first.content?.parts?.first.text);

    return res.candidates?.first.content?.parts?.first.text ??'Nooutput';
  }
}
