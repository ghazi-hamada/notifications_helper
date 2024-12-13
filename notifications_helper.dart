import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:googleapis/servicecontrol/v1.dart' as servicecontrol;

class NotificationsService {
  // ! get access token


  static Future<String> getAccessToken() async {
    final Map<String, String> serviceAccountJson = {
      // ! get this json from firebase project settings...
      "type": "",
      "project_id": "",
      "private_key_id": "",
      "private_key":
          "",
      "client_email":
          "",
      "client_id": "",
      "auth_uri": "",
      "token_uri": "",
      "auth_provider_x509_cert_url":
          "",
      "client_x509_cert_url":
          "",
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
            client);
    client.close();
    return credentials.accessToken.data;
  }

  // ! send notification
  static Future<void> sendNotification(
    
      String deviceToken, String title, String body) async {
        
    final String accessToken = await getAccessToken();
    String endpointFCM =                       // ! get this from firebase project settings...
        'https://fcm.googleapis.com/v1/projects/[project-id]/messages:send';

    final Map<String, dynamic> message = {
      "message": {
        "token": deviceToken,
        "notification": {"title": title, "body": body},
        "data": {
          "route": "serviceScreen",
        }
      }
    };
    final http.Response response = await http.post(
      Uri.parse(endpointFCM),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken'
      },
      body: jsonEncode(message),
    );

    if (response.statusCode == 200) {
      print('Notification sent successfully');
    } else {
      print('Failed to send notification');
    }
  }
}
