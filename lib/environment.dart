// import 'dart:io';

class Environment {
  static const endPoint = String.fromEnvironment('ENDPOINT');
  static const clientId = String.fromEnvironment('CLIENT_ID');
  static const sentryDsn = String.fromEnvironment('SENTRY_DSN');
}
