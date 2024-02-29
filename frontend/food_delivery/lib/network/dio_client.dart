import "package:dio/dio.dart";
import "package:food_delivery/network/interceptor.dart";

class DioClient {
  Dio dio = Dio(BaseOptions(baseUrl: "http://10.0.2.2:8000/api"));

  DioClient() {
    dio.interceptors.add(TokenInterceptor());
    dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true));
  }
}
