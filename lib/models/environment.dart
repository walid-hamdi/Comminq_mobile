import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environment {
  static String get filename {
    if (kReleaseMode) return ".env.production";

    return ".env.development";
  }

  static String get endPoint {
    return dotenv.env["ENDPOINT"] ?? "nothing";
  }
}
