// Wraps the Google Generative AI client with a fixed system prompt, safety settings, and error mapping.

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:personal_fitness_tracker/data/models/activity_log.dart';
import 'package:personal_fitness_tracker/data/models/fitness_goal.dart';
import 'package:personal_fitness_tracker/data/models/user_profile.dart';
import 'package:personal_fitness_tracker/util/gemini_config.dart';

/// Calls Gemini with fitness-only instructions. The [apiKey] is always the user’s own key.
class GeminiFitnessClient {
  GeminiFitnessClient._(this._model);
  final GenerativeModel _model;

  /// Builds a model with [apiKey] and a strong system role for this app.
  factory GeminiFitnessClient.withUserKey(String apiKey) {
    return GeminiFitnessClient._(
      GenerativeModel(
        model: GeminiConfig.modelName,
        apiKey: apiKey,
        systemInstruction: Content.system(_systemInstruction),
        safetySettings: <SafetySetting>[
          SafetySetting(HarmCategory.harassment, HarmBlockThreshold.medium),
          SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.medium),
          SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.medium),
          SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.high),
        ],
        generationConfig: GenerationConfig(
          temperature: 0.7,
          maxOutputTokens: 800,
        ),
      ),
    );
  }

  /// Sends the user [message] with your [profile] and last few [logs] in context.
  Future<String> getAdvice({required String message, UserProfile? profile, List<ActivityLog> logs = const <ActivityLog>[]}) async {
    final buf = StringBuffer()..write(_userContextBlock(profile, logs))..write('\nUser question: ')..write(message);
    final response = await _model.generateContent([Content.text(buf.toString())]);
    final t = response.text;
    if (t == null || t.trim().isEmpty) {
      if (response.promptFeedback?.blockReason != null) {
        return 'The model declined to answer (safety or policy). Try rephrasing with general training context.';
      }
      return 'The model did not return text. Check your key and try again.';
    }
    return t;
  }
}

String _userContextBlock(UserProfile? p, List<ActivityLog> logs) {
  final b = StringBuffer()..write('Context from this app (do not treat as a medical file):\n');
  if (p == null) {
    b.write('- Profile: not completed yet. Ask them to set name, age, and goal in Profile.\n');
  } else {
    b.write('- Name: ${p.name}; age: ${p.age}; focus: ${p.goal.shortLabel}.\n');
  }
  if (logs.isEmpty) {
    b.write('- Logged activities: none yet. Encourage logging a session.\n');
  } else {
    b.write('- Last activities (rough guide only):\n');
    for (final a in logs.take(8)) {
      b.write('  * ${a.title} — ${a.minutes}m, how it felt: ${a.feel1to5}/5, date: ${a.loggedAt.toLocal().toIso8601String()}\n');
    }
  }
  b.write('Give concise, non-alarming, general fitness / habit guidance only. End with: not medical advice.');
  return b.toString();
}

String get _systemInstruction {
  return '''
You are a supportive fitness and movement coach in a personal tracker web app. You are NOT a doctor, physiotherapist, or registered dietitian. 
Rules:
- Be honest about limits. Encourage a clinician for pain, heart symptoms, or eating disorders.
- No medication or supplement dosing. No PEDs or "cutting" drug stacks.
- Prefer sustainable weekly habits, balance, and gradual progression. Avoid fear-based language.
- If a plan sounds impossible (e.g. 6 hours training daily, zero calories), reframe to something realistic.
- Keep answers short, structured with bullets if helpful, and empathetic. Avoid shame.
- Never claim to diagnose. Use "can help discuss" and "generally" language.
- If the user is under 16 in context, keep guidance conservative and suggest guardian involvement for major changes.
''';
}
