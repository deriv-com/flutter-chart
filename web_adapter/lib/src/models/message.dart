/// Message class
class Message {
  /// Initializes a Message class.
  Message(this.type, this.payload);

  /// Type of the message
  late String type;

  /// Payload Information
  late dynamic payload;

  /// Serialization to JSON.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'type': type,
        'payload': payload,
      };
}
