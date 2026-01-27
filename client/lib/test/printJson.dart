import 'dart:developer' as dev;
import 'dart:convert';


void printJson(json, String location){
  String prettyJson = const JsonEncoder.withIndent('  ').convert(json);
  dev.log(
    prettyJson,
    name: location, // Labels the log in the debugger
  );
}

void printString(data){
  dev.log(
    data,
    name: 'MODEL_DEBUG',
  );
}