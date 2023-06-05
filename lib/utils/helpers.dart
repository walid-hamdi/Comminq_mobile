import 'package:flutter/material.dart';

void navigateToRoute(BuildContext context, String routeName) {
  Navigator.of(context).pushReplacementNamed(routeName);
}
