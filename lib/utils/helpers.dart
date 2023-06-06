import 'dart:convert';

import 'package:flutter/material.dart';

void navigateToRoute(BuildContext context, String routeName) {
  Navigator.of(context).pushReplacementNamed(routeName);
}

Map<String, dynamic> extractFromResponse(dynamic responseData) {
  return json.decode(responseData);
}
