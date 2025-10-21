import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../model/book_summary_model.dart';

class OpenRouterSummaryService {
  static const String apiKey = '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';

  static const String model = 'openai/gpt-3.5-turbo';

  Future<BookSummaryModel> generateSummary({
    required String bookId,
    required String bookName,
    required String author,
    String? genre,
  }) async {
    try {
      debugPrint('🔵 Generating summary for: $bookName by $author');
      debugPrint('🔵 Using model: $model');
      debugPrint('💰 Cost: ~0.001-0.002 (from your 1 credit)');

      final prompt = '''
Create a detailed book summary for "$bookName" by $author${genre != null ? ' (Genre: $genre)' : ''}.

Respond with ONLY valid JSON:
{
  "short_summary": "Write 2-3 sentences about this specific book",
  "detailed_summary": "Write 150-200 words covering plot, themes, and significance",
  "themes": ["List 3 main themes"],
  "key_takeaways": ["List 3 key insights"],
  "mood": "Describe overall mood/tone"
}
''';

      debugPrint('🔵 Sending request to OpenRouter...');

      final response = await http.post(
        Uri.parse('https://openrouter.ai/api/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
          'HTTP-Referer': 'https://github.com/books-app',
          'X-Title': 'Books Smart App',
        },
        body: jsonEncode({
          'model': model,
          'messages': [
            {
              'role': 'system',
              'content': 'You are a literary expert. Provide book summaries in JSON format only.'
            },
            {
              'role': 'user',
              'content': prompt,
            }
          ],
          'temperature': 0.7,
          'max_tokens': 800,
        }),
      ).timeout(const Duration(seconds: 40));

      debugPrint(' Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['choices'] == null || data['choices'].isEmpty) {
          throw Exception('No response from AI');
        }

        final text = data['choices'][0]['message']['content'] as String;
        debugPrint(' AI response received (${text.length} chars)');

        // Extract JSON
        String jsonText = text.trim();

        // Remove markdown
        if (jsonText.contains('```json')) {
          jsonText = jsonText.split('```json')[1].split('```')[0].trim();
        } else if (jsonText.contains('```')) {
          jsonText = jsonText.split('```')[1].split('```')[0].trim();
        }

        // Find JSON boundaries
        if (!jsonText.startsWith('{')) {
          final start = jsonText.indexOf('{');
          final end = jsonText.lastIndexOf('}');
          if (start != -1 && end != -1 && end > start) {
            jsonText = jsonText.substring(start, end + 1);
          }
        }

        debugPrint(' Parsing JSON...');
        final summaryData = jsonDecode(jsonText);

        debugPrint(' Summary generated successfully!');
        debugPrint(' Check usage at: https://openrouter.ai/activity');

        return BookSummaryModel(
          bookId: bookId,
          shortSummary: summaryData['short_summary']?.toString() ??
              '"$bookName" by $author is a compelling work exploring important themes.',
          detailedSummary: summaryData['detailed_summary']?.toString() ??
              'This book offers readers an engaging exploration of complex ideas and narratives.',
          themes: summaryData['themes'] is List
              ? List<String>.from(summaryData['themes'].map((e) => e.toString()))
              : [genre ?? 'Literature', 'Human Nature', 'Society'],
          keyTakeaways: summaryData['key_takeaways'] is List
              ? List<String>.from(summaryData['key_takeaways'].map((e) => e.toString()))
              : ['Engaging narrative', 'Deep insights', 'Thought-provoking themes'],
          mood: summaryData['mood']?.toString() ?? 'Engaging',
          generatedAt: DateTime.now(),
        );

      } else if (response.statusCode == 401) {
        debugPrint(' Invalid API key');
        throw Exception('Invalid API key. Check at: https://openrouter.ai/keys');
      } else if (response.statusCode == 402) {
        debugPrint('No credits. Add at: https://openrouter.ai/credits');
        throw Exception('Out of credits. Add more at: https://openrouter.ai/credits');
      } else if (response.statusCode == 429) {
        debugPrint(' Rate limit exceeded');
        throw Exception('Too many requests. Wait a moment.');
      } else {
        debugPrint('Error ${response.statusCode}: ${response.body}');
        throw Exception('API error: ${response.statusCode}');
      }

    } on FormatException catch (e) {
      debugPrint(' JSON parsing failed: $e');
      throw Exception('Failed to parse AI response');
    } catch (e) {
      debugPrint('Error: $e');
      rethrow;
    }
  }
}