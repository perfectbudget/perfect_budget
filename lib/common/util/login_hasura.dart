import 'package:dio/dio.dart';

Future<void> signInSocials(String _token) async {
  try {
    // MUST-CONFIG
    final response = await Dio()
        .get<dynamic>('https://perfect-budget-backend.vercel.app/webhook',
            options: Options(headers: <String, dynamic>{
              'Authorization': '$_token',
              'content-type': 'application/json',
            }));
    print('Respuesta de Hasura: $response');
  } catch (e) {
    print(e);
  }
}
