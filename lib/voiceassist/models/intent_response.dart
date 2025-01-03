class IntentResponse {
  final String predictedIntent;
  final String tag;
  final List<dynamic> entities;
  final List<String> prompt;
  final List<String> confirmation;
  final List<String> denial;

  IntentResponse({
    required this.predictedIntent,
    required this.tag,
    required this.entities,
    required this.prompt,
    required this.confirmation,
    required this.denial,
  });

  factory IntentResponse.fromJson(Map<String, dynamic> json) {
    return IntentResponse(
      predictedIntent: json['predictedIntent'] ?? 'unknown',
      tag: json['tag'] ?? 'unknown_command',
      entities: json['entities'] != null
          ? List<dynamic>.from(json['entities'])
          : [],
      prompt: json['prompt'] != null
          ? List<String>.from(json['prompt'])
          : ['Can you please confirm that?'],
      confirmation: json['confirmation'] != null
          ? List<String>.from(json['confirmation'])
          : ['yes', 'sure'],
      denial: json['denial'] != null
          ? List<String>.from(json['denial'])
          : ['no', 'cancel'],
    );
  }
}


class Entity {
  final String name;
  final String type;
  final dynamic value;

  Entity({
    required this.name,
    required this.type,
    this.value,
  });

  factory Entity.fromJson(Map<String, dynamic> json) {
    return Entity(
      name: json['name'],
      type: json['type'],
      value: json['value'] ?? json['examples']?[0], // Adjust as needed
    );
  }
}
