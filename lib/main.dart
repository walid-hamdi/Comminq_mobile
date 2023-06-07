import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../widgets/my_app.dart';
import 'models/environment.dart';

Future<void> main() async {
  await dotenv.load(fileName: Environment.filename);
  await SentryFlutter.init(
    (options) {
      options.dsn = Environment.sentryDsn;
      options.tracesSampleRate = 1.0;
    },
    // Init your App.
    appRunner: () => runApp(const MyApp()),
  );
}

// TODO:
// hide env variables
// handle sentry
// login icon google



// flutter run --web-port=50951