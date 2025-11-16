import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
final class Env {
  @EnviedField(varName: 'GEMINI_API_KEY')
  static const String geminiApiKey = _Env.geminiApiKey;
}
