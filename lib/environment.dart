import 'dart:io';

class Environment {
  static final endPoint = Platform.environment['ENDPOINT'];
  static final clientId = Platform.environment['CLIENT_ID'];
  static final sentryDsn = Platform.environment['SENTRY_DSN'];
}
