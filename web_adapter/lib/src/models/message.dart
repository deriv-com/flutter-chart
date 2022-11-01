import 'dart:collection';

class Message {
  late String type;
  dynamic payload;

  Message(this.type, this.payload);

  Message.fromMap(LinkedHashMap<dynamic, dynamic> map) {
    type = map["type"];
    payload = map["payload"];
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'payload': payload,
      };
}
