import 'package:dart_openai/dart_openai.dart';

class OpenAIService {
  static Future<String> generateTextFromPrompt(
    String system,
    String text,
  ) async {
    final definitionSystem = OpenAIChatCompletionChoiceMessageModel(
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(
          system,
        ),
      ],
      role: OpenAIChatMessageRole.assistant,
    );
    final solution = await OpenAI.instance.chat.create(
      model: 'gpt-4-1106-preview',
      responseFormat: {"type": "json_object"},
      messages: [
        definitionSystem,
        OpenAIChatCompletionChoiceMessageModel(
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text(
              "<<<$text>>>",
            ),
          ],
          role: OpenAIChatMessageRole.user,
        )
      ],
      temperature: 0.8,
      frequencyPenalty: 0,
    );

    return solution.choices.first.message.content?.first.text ?? '';
  }
}
