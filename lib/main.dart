import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../widgets/my_app.dart';
import 'models/environment.dart';

Future<void> main() async {
  await dotenv.load(fileName: Environment.filename);
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
// -- Web -- 
// get profile
// guard routes
// update profile
// validation email
// forgot password
// check internet

// -- Mobile -- 
// disable button (sign in/sign up + sign in with Google) when loading
// check internet before anything 
// hide env
// change home page looking
// change profile page looking
// update profile page with good looking
// run on release issues
// send apk via email
// update dialogs modals
// validation email
// forget password


// flutter run -d chrome --web-port=50951

