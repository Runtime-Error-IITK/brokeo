// TODO: Make SMS class
import 'dart:convert';

class Sms {
  int smsId;
  String message;

  Sms({
    required this.smsId,
    required this.message,
  });

  factory Sms.fromJson(String json) {
    Map<String, dynamic> decodedJson = jsonDecode(json) as Map<String, dynamic>;

    return Sms(
      smsId: decodedJson[smsIdColumn] as int,
      message: decodedJson[messageColumn] as String,
    );
  }
  String toJson() {
    return "";
  }
}

const String smsIdColumn = "smsId";
const String messageColumn = "message";
