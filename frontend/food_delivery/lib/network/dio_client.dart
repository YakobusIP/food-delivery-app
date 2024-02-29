import "package:dio/dio.dart";
import "package:food_delivery/network/interceptor.dart";

class DioClient {
  Dio dio = Dio(BaseOptions(baseUrl: "http://localhost:8000/api"));

  DioClient() {
    dio.interceptors.add(TokenInterceptor());
  }
}
