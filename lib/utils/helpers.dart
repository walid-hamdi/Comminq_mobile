import 'dart:convert';

import 'package:flutter/material.dart';

void navigateToRoute(BuildContext context, String routeName) {
  Navigator.of(context).pushReplacementNamed(routeName);
}

void pushToRoute(BuildContext context, String routeName) {
  Navigator.of(context).pushNamed(routeName);
}

Map<String, dynamic> extractFromResponse(dynamic responseData) {
  return json.decode(responseData);
}

String capitalizeFirstLetter(String text) {
  if (text.isEmpty) {
    return text;
  }
  return text[0].toUpperCase() + text.substring(1);
}
