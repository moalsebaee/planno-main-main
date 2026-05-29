import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  static const String apiKey =
      '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';

  static Future<String> ask(String prompt) async {
    final url = Uri.parse("https://openrouter.ai/api/v1/chat/completions");

    try {
      final response = await http.post(
        url,
        headers: {
          "Authorization": "Bearer $apiKey",
          "Content-Type": "application/json",

          // مهم جدًا في OpenRouter (يحسن الاستقرار)
          "HTTP-Referer": "https://your-app.com",
          "X-Title": "Flutter Chatbot",
        },
        body: jsonEncode({
          "model": "openai/gpt-4o-mini",
          "messages": [
            {"role": "user", "content": prompt},
          ],
        }),
      );

      // 🔥 أهم تعديل: إظهار الخطأ الحقيقي
      if (response.statusCode != 200) {
        return "Server error ${response.statusCode}\n${response.body}";
      }

      final data = jsonDecode(response.body);

      final content = data["choices"]?[0]?["message"]?["content"];

      if (content == null || content.toString().trim().isEmpty) {
        return "Empty response from AI.";
      }

      return content.toString().trim();
    } catch (e) {
      return "Network/Error: $e";
    }
  }
}
