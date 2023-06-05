import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../widgets/my_app.dart';
import 'models/environment.dart';

void main() async {
  await dotenv.load(fileName: Environment.filename);
  runApp(const MyApp());
}


// flutter run --web-port=50951