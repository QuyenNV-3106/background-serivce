import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class FpitService extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }

  Future<http.Response> postDemo(String func) {
    return http.post(
      Uri.parse('https://5sm.uat.byover.com:37527/API/FPIT'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization':
            'Basic ${base64Encode(utf8.encode('dinh.nguyen.test:Hello@123'))}',
        'Func': func
      },
      body: jsonEncode(<String, String>{
        "USER_CODE": "",
        "USER_TYPE": "",
        "Data": "[{\"USER_CD\": 2,\"GROUP_TYPE\": 1 }]"
      }),
    );
  }
}
