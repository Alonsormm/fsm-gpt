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
      model: 'gpt-3.5-turbo',
      messages: [
        definitionSystem,
        OpenAIChatCompletionChoiceMessageModel(
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text(
                "<<<$text>>>"),
          ],
          role: OpenAIChatMessageRole.user,
        )
      ],
    );

    return solution.choices.first.message.content?.first.text ?? '';
  }
}
