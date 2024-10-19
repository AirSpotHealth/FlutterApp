import 'package:airspothealth/core/utils/constants.dart';
import 'package:dio/dio.dart';

/// this class will be used to handle all network related operations
/// It uses dio package to make network requests
class NetworkService {
  // singleton instance of Dio

  NetworkService._();

  static final NetworkService instance = NetworkService._();

  final Dio _dio = Dio()
    ..options = BaseOptions(
      baseUrl: Constants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      contentType: Headers.jsonContentType,
    );

  Future<Response> get(String url, Map<String, dynamic> body) async {
    return _dio.get(url, data: body);
  }

  Future<Response> post(String url, dynamic data) async {
    return _dio.post(url, data: data);
  }

  Future<Response> put(String url, dynamic data) async {
    return _dio.put(url, data: data);
  }

  Future<Response> delete(String url) async {
    return _dio.delete(url);
  }

  Future<Response> download(String url, String savePath,
      {ProgressCallback? onReceiveProgress}) {
    return _dio.download(url, savePath, onReceiveProgress: onReceiveProgress);
  }
}
