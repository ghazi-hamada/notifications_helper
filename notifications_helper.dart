import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;

class NotificationsService {
  // ! get access token
  static Future<String> getAccessToken() async {
    final Map<String, String> serviceAccountJson = {
      // أدخل بيانات حساب الخدمة من ملف JSON هنا
      "type": "service_account",
      "project_id": "",
      "private_key_id": "",
      "private_key": "",
      "client_email": "",
      "client_id": "",
      "auth_uri": "",
      "token_uri": "",
      "auth_provider_x509_cert_url": "",
      "client_x509_cert_url": "",
      "universe_domain": ""
    };

    List<String> scopes = [
      "https://www.googleapis.com/auth/userinfo.email",
      "https://www.googleapis.com/auth/firebase.database",
      "https://www.googleapis.com/auth/firebase.messaging"
    ];

    http.Client client = await auth.clientViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes,
    );

    auth.AccessCredentials credentials =
        await auth.obtainAccessCredentialsViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes,
      client,
    );

    client.close();
    return credentials.accessToken.data;
  }

  // ! send topic notification
  static Future<void> sendNotificationToTopic({
    required String topic,
    required String title,
    required String body,
  }) async {
    final String accessToken = await getAccessToken();
    const String endpointFCM =
        'https://fcm.googleapis.com/v1/projects/[project-id]/messages:send'; // استبدل [project-id] بمعرف مشروعك في Firebase

    final Map<String, dynamic> message = {
      "message": {
        "topic": topic,
        "notification": {
          "title": title,
          "body": body,
        },
        "data": {
          "route": "serviceScreen",
        }
      }
    };

    final http.Response response = await http.post(
      Uri.parse(endpointFCM),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(message),
    );

    if (response.statusCode == 200) {
      print('✅ Notification sent to topic "$topic"');
    } else {
      print('❌ Failed to send notification: ${response.body}');
    }
  }
}
