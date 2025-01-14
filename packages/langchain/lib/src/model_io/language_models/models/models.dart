import 'package:meta/meta.dart';

/// {@template language_model_options}
/// Generation options to pass into the language model.
/// {@endtemplate
@immutable
abstract class LanguageModelOptions {
  /// {@macro language_model_options}
  const LanguageModelOptions({
    this.stop,
  });

  /// List of stop words to use when generating.
  final List<String>? stop;
}

/// {@template language_model}
/// Result returned by the model.
/// {@endtemplate}
@immutable
abstract class LanguageModelResult<O extends Object> {
  /// {@macro language_model}
  const LanguageModelResult({
    required this.generations,
    this.tokensUsage,
    this.modelOutput,
  });

  /// Generated outputs.
  final List<LanguageModelGeneration<O>> generations;

  /// The total number of tokens used for the generation.
  final int? tokensUsage;

  /// For arbitrary model provider specific output.
  final Map<String, dynamic>? modelOutput;

  /// Returns the first output as a string.
  String get firstOutputAsString {
    return generations.firstOrNull?.outputAsString ?? '';
  }
}

/// {@template language_model_generation}
/// Output of a single generation.
/// {@endtemplate}
@immutable
abstract class LanguageModelGeneration<O> {
  /// {@macro language_model_generation}
  const LanguageModelGeneration(
    this.output, {
    this.generationInfo,
  });

  /// Generated output.
  final O output;

  /// Raw generation info response from the provider.
  /// May include things like reason for finishing.
  final Map<String, dynamic>? generationInfo;

  /// Returns the output as string.
  String get outputAsString;
}
