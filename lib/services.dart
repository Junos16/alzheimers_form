import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis/sheets/v4.dart' as sheets;
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GoogleServices {
  // Load credentials from assets
  static Future<Map<String, dynamic>> _loadCredentials() async {
    try {
      // Store your credentials JSON in assets/credentials/service_account.json
      final String jsonString = await rootBundle.loadString(
        'assets/credentials.json',
      );
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to load Google credentials: $e');
    }
  }

  // Create a constants class for configuration
  /*static const String _spreadsheetId = String.fromEnvironment(
    'SPREADSHEET_ID',
    defaultValue: 'your-default-spreadsheet-id',
  );

  static const String _driveFolderId = String.fromEnvironment(
    'DRIVE_FOLDER_ID',
    defaultValue: 'your-default-drive-folder-id',
  );*/

  static String get _spreadsheetId =>
      dotenv.env['SPREADSHEET_ID'] ?? 'your-default-spreadsheet-id';
  static String get _driveFolderId =>
      dotenv.env['DRIVE_FOLDER_ID'] ?? 'your-default-drive-folder-id';

  // Get authenticated HTTP client
  static Future<http.Client> _getAuthClient() async {
    final credentials = await _loadCredentials();
    final accountCredentials = ServiceAccountCredentials.fromJson(credentials);

    return await clientViaServiceAccount(accountCredentials, [
      drive.DriveApi.driveFileScope,
      sheets.SheetsApi.spreadsheetsScope,
    ]);
  }

  // Get the next available ID from Google Sheets
  static Future<String> getNextAvailableId() async {
    try {
      final client = await _getAuthClient();
      final sheetsApi = sheets.SheetsApi(client);

      // First, check if the sheet exists and get ID column
      final response = await sheetsApi.spreadsheets.values.get(
        _spreadsheetId,
        'Sheet1!A:A', // Assuming ID is in column A
      );

      int nextId = 1; // Default starting ID

      if (response.values != null && response.values!.isNotEmpty) {
        // Skip header row and filter out any non-numeric values
        final ids =
            response.values!
                .skip(1) // Skip header row
                .where(
                  (row) =>
                      row.isNotEmpty && row[0].toString().trim().isNotEmpty,
                )
                .map((row) {
                  try {
                    return int.parse(row[0].toString());
                  } catch (_) {
                    return 0; // For any non-parseable values
                  }
                })
                .where((id) => id > 0)
                .toList();

        if (ids.isNotEmpty) {
          nextId = ids.reduce((max, id) => id > max ? id : max) + 1;
        }
      }

      client.close();
      return nextId.toString();
    } catch (e) {
      print('Error getting next ID: $e');
      // Fallback to timestamp-based ID if there's an error
      return DateTime.now().millisecondsSinceEpoch.toString();
    }
  }

  // Upload audio file to Google Drive with ID in filename
  static Future<String?> uploadAudioToDrive(String filePath, String id) async {
    try {
      print('test');
      final client = await _getAuthClient();
      final driveApi = drive.DriveApi(client);

      print(filePath);
      final File file = File(filePath);
      final String originalFileName = filePath.split('/').last;
      // Add ID at the beginning of filename
      final String fileName = "${id}_$originalFileName";

      final fileContent = await file.readAsBytes();

      final driveFile =
          drive.File()
            ..name = fileName
            ..parents = [_driveFolderId];

      final media = drive.Media(Stream.value(fileContent), fileContent.length);

      final result = await driveApi.files.create(driveFile, uploadMedia: media);

      client.close();
      return result.id;
    } catch (e) {
      print('Error uploading file to Drive: $e');
      return null;
    }
  }

  // Save survey data to Google Sheets with ID
  static Future<bool> saveSurveyToSheets(
    String id,
    Map<String, dynamic> surveyData,
    String? audioFileId,
  ) async {
    try {
      final client = await _getAuthClient();
      final sheetsApi = sheets.SheetsApi(client);

      // Add the ID and audio file ID to the survey data
      final dataWithId = {
        'id': id,
        ...surveyData,
        'audioFileId': audioFileId ?? 'Not uploaded',
        'submissionTime': DateTime.now().toIso8601String(),
        // Always include these fields in the data structure,
        // but only set values if it's a retake
        'isRetake': surveyData['isRetake'] ?? '',
        'retakeTime': surveyData['retakeTime'] ?? '',
      };

      // Get all keys for the header row
      final headerRow = dataWithId.keys.toList();

      // Create a data row with values in the same order as headers
      final dataRow =
          headerRow.map((key) => dataWithId[key]?.toString() ?? '').toList();

      // First, check if the sheet exists and has headers
      final response = await sheetsApi.spreadsheets.values.get(
        _spreadsheetId,
        'Sheet1!A1:ZZ1',
      );

      final List<List<Object>> values = [dataRow];

      if (response.values == null || response.values!.isEmpty) {
        // If no headers exist, add them first
        final List<List<Object>> headerValues = [headerRow];
        await sheetsApi.spreadsheets.values.append(
          sheets.ValueRange(values: headerValues),
          _spreadsheetId,
          'Sheet1!A1',
          valueInputOption: 'USER_ENTERED',
        );
      } else {
        // Check if we need to update headers with new fields
        final existingHeaders =
            response.values![0].map((e) => e.toString()).toList();
        final newHeaders =
            headerRow.where((h) => !existingHeaders.contains(h)).toList();

        if (newHeaders.isNotEmpty) {
          // Add new headers and reorder data row
          final updatedHeaders = [...existingHeaders, ...newHeaders];
          final updatedDataRow =
              updatedHeaders
                  .map((h) => dataWithId[h]?.toString() ?? '')
                  .toList();
          values[0] = updatedDataRow;
        }
      }

      // Append data row
      await sheetsApi.spreadsheets.values.append(
        sheets.ValueRange(values: values),
        _spreadsheetId,
        'Sheet1!A2',
        valueInputOption: 'USER_ENTERED',
      );

      client.close();
      return true;
    } catch (e) {
      print('Error saving to Google Sheets: $e');
      return false;
    }
  }

  // Main method to submit survey data
  static Future<bool> submitSurvey() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Check if already submitted to prevent duplication
      final bool alreadySubmitted = prefs.getBool('surveySubmitted') ?? false;
      if (alreadySubmitted) {
        return false; // Prevent resubmission
      }

      // Generate a new ID
      final String id = await getNextAvailableId();

      // Generate date of recording
      final String recordingDate = DateTime.now().toIso8601String();

      // Collect all survey data
      final surveyData = <String, dynamic>{
        // Personal info
        'name': prefs.getString('name') ?? '',
        'gender': prefs.getString('gender') ?? '',
        'dob': prefs.getString('dob') ?? '',
        'doRecording': recordingDate,
        'homeTown': prefs.getString('homeTown') ?? '',
        'region': prefs.getString('region') ?? '',
        'currentCity': prefs.getString('currentCity') ?? '',
        'duration': prefs.getString('duration') ?? '',
        'birthPlace': prefs.getString('birthPlace') ?? '',
        'adDiagnosis': prefs.getBool('adDiagnosis') ?? false,

        // MMSE scores
        'mmseScore': prefs.getInt('mmseScore') ?? 0,
        'orientationTimeScore': prefs.getInt('orientationTimeScore') ?? 0,
        'orientationPlaceScore': prefs.getInt('orientationPlaceScore') ?? 0,
        'registrationScore': prefs.getInt('registrationScore') ?? 0,
        'attentionScore': prefs.getInt('attentionScore') ?? 0,
        'recallScore': prefs.getInt('recallScore') ?? 0,
        'namingScore': prefs.getInt('namingScore') ?? 0,
        'repetitionScore': prefs.getInt('repetitionScore') ?? 0,
        'commandScore': prefs.getInt('commandScore') ?? 0,
        'readingScore': prefs.getInt('readingScore') ?? 0,
        'writingScore': prefs.getInt('writingScore') ?? 0,
        'copyingScore': prefs.getInt('copyingScore') ?? 0,

        // ADL scores
        'adlScore': prefs.getInt('adlScore') ?? 0,
        'bathingScore': prefs.getBool('bathingScore') ?? false ? 1 : 0,
        'dressingScore': prefs.getBool('dressingScore') ?? false ? 1 : 0,
        'toiletingScore': prefs.getBool('toiletingScore') ?? false ? 1 : 0,
        'transferringScore':
            prefs.getBool('transferringScore') ?? false ? 1 : 0,
        'continenceScore': prefs.getBool('continenceScore') ?? false ? 1 : 0,
        'feedingScore': prefs.getBool('feedingScore') ?? false ? 1 : 0,
      };

      // Find audio recording file
      String? audioFileId;
      final directory = await getApplicationDocumentsDirectory();
      final recordingsDir = Directory('${directory.path}/recordings');

      if (await recordingsDir.exists()) {
        final files = await recordingsDir.list().toList();
        for (final file in files) {
          if (file is File && file.path.contains('cookie_theft')) {
            // Upload audio file to Google Drive with ID prefixed
            audioFileId = await uploadAudioToDrive(file.path, id);
            break;
          }
        }
      }

      // Save data to Google Sheets
      final success = await saveSurveyToSheets(id, surveyData, audioFileId);

      if (success) {
        // Mark as submitted to prevent duplication
        await prefs.setBool('surveySubmitted', true);
        // Save the ID for reference
        await prefs.setString('surveyId', id);
      }

      return success;
    } catch (e) {
      print('Error submitting survey: $e');
      return false;
    }
  }

  // Submit retake data
  static Future<bool> submitRetake(
    bool mmseRetaken,
    bool adlRetaken,
    bool audioRetaken,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Get the original survey ID
      final String id = prefs.getString('surveyId') ?? '';
      if (id.isEmpty) {
        return false; // Cannot submit retake without original ID
      }

      // Collect only retaken data
      final retakeData = <String, dynamic>{
        // Add a retake identifier
        'isRetake': true,
        'retakeTime': DateTime.now().toIso8601String(),
      };

      // Add MMSE data if retaken
      if (mmseRetaken) {
        retakeData.addAll({
          'mmseScore': prefs.getInt('mmseScore') ?? 0,
          'orientationTimeScore': prefs.getInt('orientationTimeScore') ?? 0,
          'orientationPlaceScore': prefs.getInt('orientationPlaceScore') ?? 0,
          'registrationScore': prefs.getInt('registrationScore') ?? 0,
          'attentionScore': prefs.getInt('attentionScore') ?? 0,
          'recallScore': prefs.getInt('recallScore') ?? 0,
          'namingScore': prefs.getInt('namingScore') ?? 0,
          'repetitionScore': prefs.getInt('repetitionScore') ?? 0,
          'commandScore': prefs.getInt('commandScore') ?? 0,
          'readingScore': prefs.getInt('readingScore') ?? 0,
          'writingScore': prefs.getInt('writingScore') ?? 0,
          'copyingScore': prefs.getInt('copyingScore') ?? 0,
        });
      }

      // Add ADL data if retaken
      if (adlRetaken) {
        retakeData.addAll({
          'adlScore': prefs.getInt('adlScore') ?? 0,
          'bathingScore': prefs.getBool('bathingScore') ?? false ? 1 : 0,
          'dressingScore': prefs.getBool('dressingScore') ?? false ? 1 : 0,
          'toiletingScore': prefs.getBool('toiletingScore') ?? false ? 1 : 0,
          'transferringScore':
              prefs.getBool('transferringScore') ?? false ? 1 : 0,
          'continenceScore': prefs.getBool('continenceScore') ?? false ? 1 : 0,
          'feedingScore': prefs.getBool('feedingScore') ?? false ? 1 : 0,
        });
      }

      // Handle audio retake
      String? audioFileId;
      if (audioRetaken) {
        final directory = await getApplicationDocumentsDirectory();
        final recordingsDir = Directory('${directory.path}/recordings');

        if (await recordingsDir.exists()) {
          final files = await recordingsDir.list().toList();
          for (final file in files) {
            if (file is File && file.path.contains('cookie_theft')) {
              // Upload retake audio file with ID prefixed
              audioFileId = await uploadAudioToDrive(file.path, id + "_retake");
              break;
            }
          }
        }

        retakeData['audioFileId'] = audioFileId ?? 'Not uploaded';
      }

      // Save retake data to Google Sheets
      final success = await saveSurveyToSheets(id, retakeData, null);
      return success;
    } catch (e) {
      print('Error submitting retake: $e');
      return false;
    }
  }
}
