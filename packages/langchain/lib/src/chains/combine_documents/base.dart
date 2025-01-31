import 'package:meta/meta.dart';

import '../../documents/models/models.dart';
import '../../model_io/prompts/base_prompt.dart';
import '../../model_io/prompts/models/models.dart';
import '../base.dart';
import '../models/models.dart';

/// {@template base_combine_documents_chain}
/// Base interface for chains combining documents,
/// such as [StuffDocumentsChain].
///
/// Subclasses of this chain deal with combining documents in a variety of
/// ways. This base class exists to add some uniformity in the interface these
/// types of chains should expose. Namely, they expect an input key related to
/// the documents to use (default [defaultInputKey]), and then also expose a
/// method to calculate the length of a prompt from documents (useful for
/// outside callers to use to determine whether it's safe to pass a list of
/// documents into this chain or whether that will longer than the context
/// length).
/// {@endtemplate}
abstract class BaseCombineDocumentsChain extends BaseChain {
  /// {@macro base_combine_documents_chain}
  const BaseCombineDocumentsChain({
    this.inputKey = defaultInputKey,
    this.outputKey = defaultOutputKey,
  });

  /// Key to use for input documents.
  final String inputKey;

  /// Key to use for output text.
  final String outputKey;

  /// Default [inputKey] value.
  static const String defaultInputKey = 'input_documents';

  /// Default [outputKey] value.
  static const String defaultOutputKey = 'output_text';

  /// Prompt variable to use for the page content.
  static const pageContentPromptVar = 'page_content';

  @override
  Set<String> get inputKeys => {inputKey};

  @override
  Set<String> get outputKeys => {outputKey};

  @override
  Future<ChainValues> callInternal(final ChainValues inputs) async {
    final docs = inputs[inputKey] as List<Document>;
    final otherInputKeys = inputs.keys.toSet().difference({inputKey});
    final otherInputs = {
      for (final key in otherInputKeys) key: inputs[key],
    };
    final (output, extraInfo) = await combineDocs(docs, inputs: otherInputs);
    return {
      outputKey: output,
      ...extraInfo,
    };
  }

  // TODO add promptLength method to base chain the prompt length given the documents passed in

  /// Combines the given [docs] into a single string.
  ///
  /// - [docs] is the list of documents to combine.
  /// - [inputs] is a map of other inputs to use in the combination.
  ///
  /// Returns a tuple of the output string and any extra info to return.
  Future<(dynamic output, Map<String, dynamic> extraInfo)> combineDocs(
    final List<Document> docs, {
    final InputValues inputs = const {},
  });

  /// Formats a document into a string based on a prompt template.
  @protected
  String formatDocument(final Document doc, final BasePromptTemplate prompt) {
    final baseInfo = {
      pageContentPromptVar: doc.pageContent,
      ...doc.metadata,
    };

    final missingMetadata =
        prompt.inputVariables.difference(baseInfo.keys.toSet());
    if (missingMetadata.isNotEmpty) {
      final requiredMetadata =
          prompt.inputVariables.difference({pageContentPromptVar});
      throw PromptException(
        message: 'Document prompt requires documents to have metadata '
            'variables: $requiredMetadata. Received document with missing '
            'metadata: $missingMetadata',
      );
    }

    return prompt.format({
      for (final key in prompt.inputVariables) key: baseInfo[key],
    });
  }
}
