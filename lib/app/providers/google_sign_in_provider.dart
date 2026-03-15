import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;

/// Global Google Sign-In instance.
/// Using a singleton ensures that we don't initialize the OAuth client multiple times,
/// which causes "Failed to get auth client" errors on Web.
final appGoogleSignIn = GoogleSignIn(
  clientId: kIsWeb
      ? '21331862028-5pe8ipprrfr3la3lgjl9n4qid8dbjbp4.apps.googleusercontent.com'
      : null,
  scopes: [
    'email',
    'profile',
    drive.DriveApi.driveFileScope,
  ],
);
