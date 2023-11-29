// lib/env/env.dart
import 'package:envied/envied.dart';
part 'env.g.dart';

@Envied(path: '.env.dev')
abstract class Env {
  @EnviedField(varName: 'OPEN_AI_API_KEY')
  static const String openAIAPIKey = _Env.openAIAPIKey;
}
