import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:meno_moni/profile.dart';

class LlmCommunicationClient {
  final String url = 'https://integrate.api.nvidia.com/v1/chat/completions';
  final String apiKey = 'ADD YOUR NVIDIA API KEY!';
  final String message;

  LlmCommunicationClient(
      {required this.message});

  Future<String> sendMessage() async {
    String promptMessage = this.message;
    Map<String, dynamic> jsonMap = {
      "messages": [
        {"role": "user", "content": promptMessage}
      ],
      "model": "meta/llama-3.1-8b-instruct",
      "temperature": 0.2,
      "top_p": 0.7,
      "frequency_penalty": 0,
      "presence_penalty": 0,
      "max_tokens": 1024,
    };

    HttpClient httpClient = new HttpClient();
    HttpClientRequest request = await httpClient.postUrl(Uri.parse(url));
    request.headers.set('content-type', 'application/json');
    request.headers.set('Authorization', apiKey);
    request.add(utf8.encode(json.encode(jsonMap)));
    HttpClientResponse response = await request.close();
    String reply = await response.transform(utf8.decoder).join();

    httpClient.close();

    Map<String, dynamic> map = json.decode(reply);
    var message = map["choices"][0]["message"]["content"];
    return message;
  }
}