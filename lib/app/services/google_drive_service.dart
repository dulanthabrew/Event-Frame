import 'dart:typed_data';

import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import '../providers/google_sign_in_provider.dart';

/// Service for syncing photos to the user's Google Drive.
class GoogleDriveService {
  static final _googleSignIn = appGoogleSignIn;

  /// Update the Google Sign In configuration (useful if needed at runtime)
  static void configure({String? clientId}) {
    // This is no longer strictly necessary because we use a singleton,
    // but we keep the method for API compatibility if needed.
  }

  /// Ensure user is signed in with Drive scope, returns Drive API client.
  static Future<drive.DriveApi?> _getDriveApi() async {
    try {
      var account = _googleSignIn.currentUser;
      account ??= await _googleSignIn.signInSilently();
      account ??= await _googleSignIn.signIn();

      if (account == null) {
        debugPrint('DriveService: User cancelled sign-in');
        return null;
      }

      // On Web, explicitly check and request scopes if needed
      if (kIsWeb) {
        final hasScope = await _googleSignIn
            .canAccessScopes([drive.DriveApi.driveFileScope]);
        if (!hasScope) {
          debugPrint('DriveService: Scopes missing, requesting...');
          final granted = await _googleSignIn
              .requestScopes([drive.DriveApi.driveFileScope]);
          if (!granted) {
            debugPrint('DriveService: Scopes rejected');
            return null;
          }
        }
      }

      final authClient = await _googleSignIn.authenticatedClient();
      if (authClient == null) {
        debugPrint('DriveService: Failed to get auth client even after check');
        return null;
      }

      return drive.DriveApi(authClient);
    } catch (e) {
      debugPrint('DriveService: Error getting Drive API — $e');
      return null;
    }
  }

  /// Find or create the EventFrame folder in Drive root.
  static Future<String?> _getOrCreateFolder(
      drive.DriveApi driveApi, String folderName) async {
    // Search for existing folder
    final query =
        "name = '$folderName' and mimeType = 'application/vnd.google-apps.folder' and trashed = false";
    final fileList = await driveApi.files.list(q: query, spaces: 'drive');

    if (fileList.files != null && fileList.files!.isNotEmpty) {
      return fileList.files!.first.id;
    }

    // Create new folder
    final folder = drive.File()
      ..name = folderName
      ..mimeType = 'application/vnd.google-apps.folder';

    final created = await driveApi.files.create(folder);
    return created.id;
  }

  /// Upload a single photo to Google Drive under EventFrame/<eventName>/.
  static Future<bool> uploadPhotoToDrive({
    required String eventName,
    required String photoUrl,
    required String fileName,
  }) async {
    final driveApi = await _getDriveApi();
    if (driveApi == null) return false;

    try {
      // Create EventFrame folder
      final rootFolderId = await _getOrCreateFolder(driveApi, 'EventFrame');
      if (rootFolderId == null) return false;

      // Create event subfolder
      final query =
          "name = '$eventName' and '$rootFolderId' in parents and mimeType = 'application/vnd.google-apps.folder' and trashed = false";
      final existing = await driveApi.files.list(q: query, spaces: 'drive');

      String eventFolderId;
      if (existing.files != null && existing.files!.isNotEmpty) {
        eventFolderId = existing.files!.first.id!;
      } else {
        final eventFolder = drive.File()
          ..name = eventName
          ..mimeType = 'application/vnd.google-apps.folder'
          ..parents = [rootFolderId];
        final created = await driveApi.files.create(eventFolder);
        eventFolderId = created.id!;
      }

      // Download the photo
      final response = await http.get(Uri.parse(photoUrl));
      if (response.statusCode != 200) {
        debugPrint('DriveService: Failed to download photo');
        return false;
      }

      // Upload to Drive
      final driveFile = drive.File()
        ..name = fileName
        ..parents = [eventFolderId];

      final media = drive.Media(
        Stream.value(response.bodyBytes),
        response.bodyBytes.length,
      );

      await driveApi.files.create(driveFile, uploadMedia: media);
      debugPrint('DriveService: Uploaded $fileName to Drive');
      return true;
    } catch (e) {
      debugPrint('DriveService: Upload error — $e');
      if (e.toString().contains('403') ||
          e.toString().contains('Drive API has not been used')) {
        // This is a common setup error
        debugPrint(
            'IMPORTANT: Ensure Google Drive API is enabled in Cloud Console!');
      }
      return false;
    }
  }

  /// Sync all event photos to Google Drive.
  static Future<int> syncEventToDrive({
    required String eventName,
    required List<Map<String, String>> photos, // [{url, fileName}]
    required Function(int current, int total) onProgress,
  }) async {
    final driveApi = await _getDriveApi();
    if (driveApi == null) return 0;

    int uploaded = 0;
    for (int i = 0; i < photos.length; i++) {
      final success = await uploadPhotoToDrive(
        eventName: eventName,
        photoUrl: photos[i]['url']!,
        fileName: photos[i]['fileName']!,
      );
      if (success) uploaded++;
      onProgress(i + 1, photos.length);
    }
    return uploaded;
  }

  /// Download a photo as bytes (for local save / share).
  static Future<Uint8List?> downloadPhotoBytes(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      }
    } catch (e) {
      debugPrint('DriveService: Download error — $e');
    }
    return null;
  }
}
