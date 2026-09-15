import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'api_client.g.dart';

@RestApi()
abstract class ApiClient {
  factory ApiClient(Dio dio, {String baseUrl}) = _ApiClient;

  @POST('{path}')
  Future<HttpResponse<dynamic>> postRequest({
    @Path() required String path,
    @Body() required dynamic body,
    @Header('Accept') String accept = 'application/json',
  });

  /// Query arguments with the standard envelope; [postPlain] for text.
  @POST('{path}')
  Future<HttpResponse<dynamic>> postRequestWithQuery({
    @Path() required String path,
    @Body() required dynamic body,
    @Queries() Map<String, dynamic>? query,
    @Header('Accept') String accept = 'application/json',
  });

  /// [extras] reaches the interceptors as `RequestOptions.extra`.
  @POST('{path}')
  Future<String> postPlain({
    @Path() required String path,
    @Body() required dynamic body,
    @Queries() Map<String, dynamic>? query,
    @Extras() Map<String, dynamic>? extras,
    @Header('Accept') String accept = 'application/json',
  });

  @GET('{path}')
  Future<HttpResponse<dynamic>> getRequest({
    @Path() required String path,
    @Queries() required Map<String, dynamic> query,
    @Header('Accept') String accept = 'application/json',
  });

  @PUT('{path}')
  Future<HttpResponse<dynamic>> putRequest({
    @Path() required String path,
    @Body() required Map<String, dynamic> body,
    @Queries() Map<String, dynamic>? query,
    @Header('Accept') String accept = 'application/json',
  });

  @PUT('{path}')
  Future<HttpResponse<dynamic>> putFormData({
    @Path() required String path,
    @Body() required FormData body,
    @Header('Accept') String accept = 'application/json',
  });

  @PUT('{path}')
  Future<HttpResponse<dynamic>> putFormDataWithQuery({
    @Path() required String path,
    @Body() required FormData body,
    @Queries() Map<String, dynamic>? query,
    @Header('Accept') String accept = 'application/json',
  });

  @POST('{path}')
  Future<HttpResponse<dynamic>> postFormData({
    @Path() required String path,
    @Body() required FormData body,
    @Header('Accept') String accept = 'application/json',
  });

  @POST('{path}')
  Future<HttpResponse<dynamic>> postFormDataWithQuery({
    @Path() required String path,
    @Body() required FormData body,
    @Queries() Map<String, dynamic>? query,
    @Header('Accept') String accept = 'application/json',
  });

  @PATCH('{path}')
  Future<HttpResponse<dynamic>> patchRequest({
    @Path() required String path,
    @Body() required dynamic body,
    @Queries() Map<String, dynamic>? query,
    @Header('Accept') String accept = 'application/json',
  });

  @DELETE('{path}')
  Future<HttpResponse<dynamic>> deleteRequest({
    @Path() required String path,
    @Queries() required Map<String, dynamic> query,
    @Header('Accept') String accept = 'application/json',
  });
}
