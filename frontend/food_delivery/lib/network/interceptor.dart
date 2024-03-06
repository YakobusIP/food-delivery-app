import "package:dio/dio.dart";
import "package:food_delivery/components/snackbars.dart";
import "package:food_delivery/main.dart";
import "package:food_delivery/services/storage_service.dart";

class TokenInterceptor extends Interceptor {
  final Dio _tokenDio = Dio(BaseOptions(baseUrl: "http://10.0.2.2:8000/api"));
  final SecureStorageService _storageService = SecureStorageService();

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    if (!options.path.contains("/auth")) {
      var accessToken = await _storageService.get("accessToken");
      options.headers["Authorization"] = "Bearer $accessToken";
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      try {
        RequestOptions options = err.response!.requestOptions;
        var refreshToken = await _storageService.get("refreshToken");
        var response = await _tokenDio.post(
          "/auth/refresh-token",
          data: {"refresh": refreshToken},
        );

        await _storageService.set("accessToken", response.data["access"]);
        options.headers["Authorization"] = "Bearer ${response.data["access"]}";
        var followUpResponse = await _tokenDio.fetch(options);
        return handler.resolve(followUpResponse);
      } on DioException {
        _storageService.delete("accessToken");
        _storageService.delete("refreshtoken");

        navigatorKey.currentState?.pushNamedAndRemoveUntil(
          "login",
          (_) => false,
        );

        snackbarKey.currentState?.showSnackBar(
          showInvalidSnackbar("Session expired"),
        );
      }
    }
    return super.onError(err, handler);
  }
}
