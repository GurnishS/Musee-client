// data/models/suggestion_model.dart
import '../../domain/entities/suggestion.dart';

class SuggestionModel extends Suggestion {
  SuggestionModel(super.text);

  factory SuggestionModel.fromJson(String suggestion) {
    return SuggestionModel(suggestion);
  }
}
