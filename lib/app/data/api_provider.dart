import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:get/get.dart' as Get;
import 'EndPoint.dart';
import 'Globel_veriables.dart';



class ApiProvider {
  static const requestTimeOut = Duration(seconds: 25);
  final _client = Dio(
    BaseOptions(
      receiveDataWhenStatusError: true,
      followRedirects: true,
      maxRedirects: 3,
      connectTimeout: Duration(seconds: 60),
      receiveTimeout: Duration(seconds: 60),
    ),
  );

  Future baseGetAPI(url, auth, context, {successMsg, loading, bool direct = false, String? fullUrl}) async {
    try {
      Response response;
      if (auth == null || auth == true) {
        Get.Get.log("[APIProvider.baseGetAPI Authed] called with : ${Globals.token}");
        response = await _client.get(fullUrl ?? (APIEndPoint.baseUrl + url),
            options: Options(headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'authorization': "Bearer ${Globals.token}"
            }));
      } else {
        response = await _client.get(fullUrl ?? (APIEndPoint.baseUrl + url),
            options: Options(headers: <String, String>{'Content-Type': 'application/json'}));
      }
      return _returnResponse(response);
    } on TimeoutException catch (_) {
      throw TimeOutException(null);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    } on DioError catch (e) {
      if (e.response != null) {
        return _returnResponse(e.response!);
      } else {
        return "No internet connection";
      }
    }
  }

  Future basePostAPI(url, body, auth, context, {successMsg, loading, bool direct = false, fullUrl}) async {
    try {
      Response response;
      if (auth == null || auth == true) {
        response = await _client.post(fullUrl ?? (APIEndPoint.baseUrl + url),
            data: jsonEncode(body),
            options: Options(headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'authorization': "Bearer ${Globals.token}"
            }));
      } else {
        Get.Get.log(jsonEncode(body));
        response = await _client.post(fullUrl ?? (APIEndPoint.baseUrl + url),
            data: jsonEncode(body),
            options: Options(
                headers: <String, String>{'Content-Type': 'application/json'}));
      }
      return _returnResponse(response);
    } on TimeoutException catch (_) {
      throw TimeOutException(null);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    } on DioError catch (e) {
      print(e.response?.statusCode);
      print(e.response?.data);
      if (e.response?.data.runtimeType == String) {
        if (e.response?.data.contains("limit")) {
          return null;
        } else {
          // Utils().showBottomSheetWidget();
          return {"statusCode": 401};
        }
      } else {
        return e.response?.data;
      }
    }
  }

  Future basePutAPI(url, body, auth, context, {successMsg, loading, bool direct = false, fullUrl}) async {
    try {
      Response response;
      if (auth == null || auth == true) {
        response = await _client.put(fullUrl ?? (APIEndPoint.baseUrl + url),
            data: body,
            options: Options(headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'authorization': "Bearer ${Globals.token}"
            }));
      } else {
        response = await _client.put(fullUrl ?? (APIEndPoint.baseUrl + url),
            data: body,
            options: Options(headers: <String, String>{'Content-Type': 'application/json'}));
      }
      return _returnResponse(response);
    } on TimeoutException catch (_) {
      throw TimeOutException(null);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    } on DioError catch (e) {
      print(e.response?.statusCode);
      print(e.response?.data);
      if (e.response?.data.runtimeType == String) {
        if (e.response?.data.contains("limit")) {
          return null;
        } else {
          // Utils.showBottomSheetWidget();
          return {"statusCode": 401};
        }
      } else {
        return e.response?.data;
      }
    }
  }

  Future baseDeleteAPI(url, body, auth, context, {successMsg, loading, bool direct = false}) async {
    try {
      Response response;
      if (auth == null || auth == true) {
        response = await _client.delete(APIEndPoint.baseUrl + url,
            data: body,
            options: Options(headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'authorization': "Bearer ${Globals.token}"
            }));
      } else {
        response = await _client.delete(APIEndPoint.baseUrl + url,
            data: body,
            options: Options(
                headers: <String, String>{'Content-Type': 'application/json'}));
      }
      return _returnResponse(response);
    } on TimeoutException catch (_) {
      throw TimeOutException(null);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    } on DioError catch (e) {
      print(e.response?.statusCode);
      print(e.response?.data);
      if (e.response?.data.runtimeType == String) {
        if (e.response?.data.contains("limit")) {
          return null;
        } else {
          // Utils.showBottomSheetWidget();
          return {"statusCode": 401};
        }
      } else {
        return e.response?.data;
      }
    }
  }


  Future baseMultiPartAPI(url, body, auth, context, File file, {successMsg, loading, bool direct = false,
    Function(int sent, int total)? progress}) async {
    String fileName = file.path.split("/").last;
    try {
      FormData? formData;
      _client.options.headers
          .addAll({"authorization": "Bearer ${Globals.token}"});
      Response response;
      formData = FormData.fromMap({
        ...body,
        "images": await MultipartFile.fromFile(file.path,
            filename: fileName,
            contentType: MediaType('image', fileName.split(".").last.toLowerCase())),
      });
      response = await _client.post(
        APIEndPoint.baseUrl + url,
        data: formData,
        onSendProgress: (int sent, int total) {
          print('$sent : $total');
          if (progress != null) {
            progress(sent, total);
          }
        },
      );

      return _returnResponse(response);
    } on TimeoutException catch (_) {
      throw TimeOutException(null);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    } on DioError catch (e) {
      print(e.response?.statusCode);
      print(e.response?.data);
      if (e.response?.data.runtimeType == String) {
        if (e.response?.data.contains("limit")) {
          return null;
        } else {
          // Utils.showBottomSheetWidget();
          return {"statusCode": 401};
        }
      } else {
        return e.response?.data;
      }
    }
  }

  Future baseMultiPartPostAPI(url, body, auth, context, List<File> files, {successMsg, loading, bool direct = false,
    Function(int sent, int total)? progress}) async {
    try {
      FormData? formData;
      _client.options.headers
          .addAll({"authorization": "Bearer ${Globals.token}"});
      List<MultipartFile> multipartFiles = [];
      for (File file in files) {
        String fileName = file.path.split("/").last;
        MultipartFile multipartFile = await MultipartFile.fromFile(file.path,
            filename: fileName,
            contentType: MediaType('image', fileName.split(".").last.toLowerCase()));
        multipartFiles.add(multipartFile);
      }
      formData = FormData.fromMap({
        ...body,
        "images": multipartFiles,
      });
      Response response = await _client.post(
        APIEndPoint.baseUrl + url,
        data: formData,
        onSendProgress: (int sent, int total) {
          print('$sent : $total');
          if (progress != null) {
            progress(sent, total);
          }
        },
      );
      return _returnResponse(response);
    } on TimeoutException catch (_) {
      throw TimeOutException(null);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    } on DioError catch (e) {
      print(e.response?.statusCode);
      print(e.response?.data);
      if (e.response?.data.runtimeType == String) {
        if (e.response?.data.contains("limit")) {
          return null;
        } else {
          // Utils.showBottomSheetWidget();
          return {"statusCode": 401};
        }
      } else {
        return e.response?.data;
      }
    }
  }


  Future<dynamic> multiPartWithPostAPI({
    required String url,
    required Map<String, dynamic> body,
    required bool auth,
    required context,
    required Map<String, File> files, // Map of keys and corresponding files
    String? successMsg,
    bool? loading,
    bool direct = false,
    Function(int sent, int total)? progress,
  }) async {
    try {
      FormData formData = FormData.fromMap(body);

      for (var entry in files.entries) {
        String key = entry.key;
        File file = entry.value;
        String fileName = file.path.split("/").last;
        String fileType = fileName.split(".").last.toLowerCase();
        formData.files.add(MapEntry(
          key,
          await MultipartFile.fromFile(
            file.path,
            filename: fileName,
            contentType: MediaType(fileType.contains('mp4') ? 'video' : 'image', fileType),
          ),
        ));
      }

      if (auth) {
        _client.options.headers.addAll({
          "authorization": "Bearer ${Globals.token}",
        });
      }

      Response response = await _client.post(
        APIEndPoint.baseUrl + url,
        data: formData,
        onSendProgress: (int sent, int total) {
          print('$sent : $total');
          if (progress != null) {
            progress(sent, total);
          }
        },
      );

      return _returnResponse(response);
    } on TimeoutException catch (_) {
      throw TimeOutException(null);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    } on DioError catch (e) {
      print('DioError: ${e.response?.statusCode}');
      print('DioError data: ${e.response?.data}');
      if (e.response?.data.runtimeType == String) {
        if (e.response?.data.contains("limit")) {
          return null;
        } else {
          return {"statusCode": 401};
        }
      } else {
        return e.response?.data;
      }
    }
  }


  Future<dynamic> multiPartPostAPI({
    required String url,
    required Map<String, dynamic> body,
    required bool auth,
    required context,
    dynamic fileOrFiles, // Can be File or List<File>
    required String fileKey, // New parameter for the JSON key
    String? successMsg,
    bool? loading,
    bool direct = false,
    Function(int sent, int total)? progress,
  }) async {
    try {
      FormData formData;
      List<MultipartFile> multipartFiles = [];

      if (fileOrFiles is File) {
        // Single file (either image or video)
        String fileName = fileOrFiles.path.split("/").last;
        String fileType = fileName.split(".").last.toLowerCase();
        multipartFiles.add(await MultipartFile.fromFile(
          fileOrFiles.path,
          filename: fileName,
          contentType: MediaType(fileType.contains('mp4') ? 'video' : 'image', fileType),
        ));
      } else if (fileOrFiles is List<File>) {
        // Multiple files (either images or videos)
        for (File file in fileOrFiles) {
          String fileName = file.path.split("/").last;
          String fileType = fileName.split(".").last.toLowerCase();
          multipartFiles.add(await MultipartFile.fromFile(
            file.path,
            filename: fileName,
            contentType: MediaType(fileType.contains('mp4') ? 'video' : 'image', fileType),
          ));
        }
      }

      formData = FormData.fromMap({
        ...body,
        if (multipartFiles.length == 1)
          fileKey: multipartFiles.first
        else
          fileKey: multipartFiles,
      });

      if (auth) {
        _client.options.headers.addAll({
          "authorization": "Bearer ${Globals.token}",
        });
      }

      Response response = await _client.post(
        APIEndPoint.baseUrl + url,
        data: formData,
        onSendProgress: (int sent, int total) {
          print('$sent : $total');
          if (progress != null) {
            progress(sent, total);
          }
        },
      );

      return _returnResponse(response);
    } on TimeoutException catch (_) {
      throw TimeOutException(null);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    } on DioError catch (e) {
      print('DioError: ${e.response?.statusCode}');
      print('DioError data: ${e.response?.data}');
      if (e.response?.data.runtimeType == String) {
        if (e.response?.data.contains("limit")) {
          return null;
        } else {
          return {"statusCode": 401};
        }
      } else {
        return e.response?.data;
      }
    }
  }


  dynamic _returnResponse(Response<dynamic> response) {
    switch (response.statusCode) {
      case 200:
        print("200");
        return response.data;
        case 201:
        print("201");
        return response.data;
      case 400:
        throw BadRequestException(response.data.toString());
      case 401:
        throw BadRequestException(response.data.toString());
      case 403:
        throw UnauthorisedException(response.data.toString());
      case 404:
        throw BadRequestException('Not found');
      case 406:
        throw BadRequestException(response.data.toString());
      case 500:
        throw FetchDataException('Internal Server Error');
      default:
        print("default");
        throw FetchDataException(
            'Error occurred while Communication with Server with StatusCode : ${response.statusCode}');
    }
  }

  Future imageUpload(url, body, auth, context, File file,
      {String? caption, String? status, List? tags, successMsg, loading, bool direct = false,
        Function(int sent, int total)? progress}) async {
    String fileName = file.path.split("/").last;
    try {
      FormData? formData;
      _client.options.headers
          .addAll({"authorization": "Bearer ${Globals.token}"});
      Response response;
      formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(
          file.path,
          filename: fileName,
        ),
        "type": "$status",
      });
      response = await _client.post(
        APIEndPoint.baseUrl + url,
        data: formData,
        onSendProgress: (int sent, int total) {
          print('$sent : $total');
          if (progress != null) {
            progress(sent, total);
          }
        },
      );

      return _returnResponse(response);
    } on TimeoutException catch (_) {
      throw TimeOutException(null);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    } on DioError catch (e) {
      print(e.response?.statusCode);
      print(e.response?.data);
      if (e.response?.data.runtimeType == String) {
        if (e.response?.data.contains("limit")) {
          return null;
        } else {
          // Utils.showBottomSheetWidget();
          return {"statusCode": 401};
        }
      } else {
        return e.response?.data;
      }
    }
  }
}

class AppException implements Exception {
  final code;
  final message;
  final details;

  AppException({this.code, this.message, this.details});

  String toString() {
    return "[$code]: $message \n $details";
  }
}

class FetchDataException extends AppException {
  FetchDataException(String? details)
      : super(
          code: "fetch-data",
          message: "Error During Communication",
          details: details,
        );
}

class BadRequestException extends AppException {
  BadRequestException(String? details)
      : super(
          code: "invalid-request",
          message: "Invalid Request",
          details: details,
        );
}

class UnauthorisedException extends AppException {
  UnauthorisedException(String? details)
      : super(
          code: "unauthorised",
          message: "Unauthorised",
          details: details,
        );
}

class InvalidInputException extends AppException {
  InvalidInputException(String? details)
      : super(
          code: "invalid-input",
          message: "Invalid Input",
          details: details,
        );
}

class AuthenticationException extends AppException {
  AuthenticationException(String? details)
      : super(
          code: "authentication-failed",
          message: "Authentication Failed",
          details: details,
        );
}

class TimeOutException extends AppException {
  TimeOutException(String? details)
      : super(
          code: "request-timeout",
          message: "Request TimeOut",
          details: details,
        );
}
