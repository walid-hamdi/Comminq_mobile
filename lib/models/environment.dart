import 'package:flutter/foundation.dart';

class Environment {
  static String get filename {
    if (kReleaseMode) return ".env.production";

    return ".env.development";
  }
}
