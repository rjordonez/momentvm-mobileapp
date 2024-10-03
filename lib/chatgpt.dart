import 'package:dart_openai/dart_openai.dart';
import 'env/env.dart';

class OpenAIService {
  OpenAIService() {
    OpenAI.apiKey = Env.apiKey;
  }

  Future<String> gptAPICall(String prompt) async {
    final completion = await OpenAI.instance.completion.create(
      model: "gpt-3.5-turbo-instruct",
      prompt: prompt,
      maxTokens: 250,
    );

    // Log tokens used if available
    int? tokensUsed = completion.usage?.totalTokens;
    if (tokensUsed != null) {
      _logTokens(tokensUsed);
    }

    return completion.choices[0].text;
  }

  void _logTokens(int tokens) {
    print('Tokens used: $tokens');
  }
}
