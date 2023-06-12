import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../widgets/my_app.dart';
import 'environment.dart';

Future<void> main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  await SentryFlutter.init(
    (options) {
      options.dsn = Environment.sentryDsn;
      options.tracesSampleRate = 1.0;
    },
    // Init your App.
    appRunner: () => runApp(const MyApp()),
  );
}
