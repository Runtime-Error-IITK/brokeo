// TODO: Make SMS class
import 'dart:convert';

class Sms {
  int smsId;
  String message;

  Sms({
    required this.smsId,
    required this.message,
  });
}

const String smsIdColumn = "smsId";
const String messageColumn = "message";
