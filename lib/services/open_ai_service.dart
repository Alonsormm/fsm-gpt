import 'package:dart_openai/dart_openai.dart';

class OpenAIService {
  static Future<String> generateTextFromPrompt(
      String system, String text) async {
    final definitionSystem = OpenAIChatCompletionChoiceMessageModel(
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(
          system,
        ),
      ],
      role: OpenAIChatMessageRole.system,
    );
    final solution = await OpenAI.instance.chat.create(
      model: 'gpt-3.5-turbo-1106',
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
      temperature: 1,
    );

    return solution.choices.first.message.content?.first.text ?? '';
  }
}
