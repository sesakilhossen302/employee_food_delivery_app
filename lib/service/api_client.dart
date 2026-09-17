import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/request/request.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../Utils/AppConst/app_const.dart' show AppConstants;
import '../global/Model/error_response.dart' show ErrorResponse;
import '../helper/shared_prefe/shared_prefe.dart' show SharePrefsHelper;
import 'api_url.dart';
import 'package:mime/mime.dart';

class ApiClient extends GetxService {

  static var client = http.Client();

  static const String noInternetMessage = "Can't connect to the internet!";
  static const int timeoutInSeconds = 30;

  static String bearerToken = "";

  ///<======================== This is for get methode =======================>
  static Future<Response> getData(String uri,
      {Map<String, dynamic>? query, Map<String, String>? headers}) async {
    bearerToken = await SharePrefsHelper.getString(AppConstants.bearerToken);

    var mainHeaders = {
      //'Content-Type': 'application/x-www-form-urlencoded',
      'Accept': 'application/json',

      'Authorization': 'Bearer $bearerToken'
    };
    try {
      debugPrint('====> API Call: $uri\nHeader: ${headers ?? mainHeaders}');

      http.Response response = await client
          .get(
        Uri.parse(ApiConstant.baseUrl + uri),
        headers: headers ?? mainHeaders,
      )
          .timeout(const Duration(seconds: timeoutInSeconds));
      return handleResponse(response, uri);
    } catch (e) {
      debugPrint('------------${e.toString()}');
      return const Response(statusCode: 1, statusText: noInternetMessage);
    }
  }


  ///<====================== This is for post methode ========================>
  static Future<Response> postData(String uri, dynamic body,
      {Map<String, String>? headers})async{
    bearerToken = await SharePrefsHelper.getString(AppConstants.bearerToken);

    debugPrint("This one is the  base url=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-${ApiConstant.baseUrl}");


    var mainHeaders = {
      // 'Content-Type': 'application/x-www-form-urlencoded',
      'Accept': 'application/json',
      'Authorization': 'Bearer $bearerToken'
    };
    try {
      debugPrint('====> API Call: $uri\nHeader: ${headers ?? mainHeaders}');
      debugPrint('====> API Body: $body');

      http.Response response = await client
          .post(
        Uri.parse(ApiConstant.baseUrl + uri),
        body: body,
        headers: headers ?? mainHeaders,
      )
       .timeout(const Duration(seconds: timeoutInSeconds));
      return handleResponse(response, uri);
    } catch (e) {
      debugPrint('------------${e.toString()}');

      return const Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  ///<====================== This is for patch methode ========================>
  static Future<Response> patchData(String uri, dynamic body,
      {Map<String, String>? headers}) async {
    bearerToken = await SharePrefsHelper.getString(AppConstants.bearerToken);

    var mainHeaders = {
      // 'Content-Type': 'application/x-www-form-urlencoded',
      'Accept': 'application/json',
      'Authorization': 'Bearer $bearerToken'
    };
    try {
      debugPrint('====> API Call: $uri\nHeader: ${headers ?? mainHeaders}');
      debugPrint('====> API Body: $body');

      http.Response response = await client
          .patch(
        Uri.parse(ApiConstant.baseUrl + uri),
        body: body,
        headers: headers ?? mainHeaders,
      )
          .timeout(const Duration(seconds: timeoutInSeconds));
      return handleResponse(response, uri);
    } catch (e) {
      debugPrint('------------${e.toString()}');

      return const Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  ///<====================== This is for postMultipartData  methode ========================>

  static Future<Response> postMultipartData(
      String uri, dynamic body,
     // String uri, Map<String, String> body,
      {List<MultipartBody>? multipartBody,
        Map<String, String>? headers}) async {
    try {
      bearerToken = await SharePrefsHelper.getString(AppConstants.bearerToken);

      var mainHeaders = {
        'Accept': 'multipart/form-data',
        'Authorization': 'Bearer $bearerToken'
      };

      debugPrint('====> API Call: $uri\nHeader: ${headers ?? mainHeaders}');
      debugPrint('====> API Body: $body with ${multipartBody?.length} picture');
      //http.MultipartRequest _request = http.MultipartRequest('POST', Uri.parse("https://b936-114-130-157-130.ngrok-free.app/api/v1/user/profile/store/degree"));
      //_request.headers.addAll(headers ?? mainHeaders);
      // for(MultipartBody multipart in multipartBody!) {
      //   if(multipart.file != null) {
      //     Uint8List _list = await multipart.file.readAsBytes();
      //     _request.files.add(http.MultipartFile(
      //       multipart.key, multipart.file.readAsBytes().asStream(), _list.length,
      //       filename: '${DateTime.now().toString()}.png',
      //     ));
      //   }
      // }
      var request =
      http.MultipartRequest('POST', Uri.parse(ApiConstant.baseUrl + uri));
      request.fields.addAll(body);

      if (multipartBody!.isNotEmpty) {
        // ignore: avoid_function_literals_in_foreach_calls
        multipartBody.forEach((element) async {
          debugPrint("path : ${element.file.path}");

          var mimeType = lookupMimeType(element.file.path);

          debugPrint("MimeType================$mimeType");

          var multipartImg = await http.MultipartFile.fromPath(
            element.key,
            element.file.path,
            contentType: MediaType.parse(mimeType!),
          );
          request.files.add(multipartImg);
          //request.files.add(await http.MultipartFile.fromPath(element.key, element.file.path,contentType: MediaType('video', 'mp4')));
        });
      }

      request.headers.addAll(mainHeaders);
      http.StreamedResponse response = await request.send();
      final content = await response.stream.bytesToString();
      debugPrint(
          '====> API Response: [${response.statusCode}}] $uri\n$content');

      return Response(
          statusCode: response.statusCode,
          statusText: noInternetMessage,
          body: content);
    } catch (e) {
      debugPrint('------------${e.toString()}');

      return const Response(statusCode: 1, statusText: noInternetMessage);
    }
  }


  ///<====================== This is for patchMultipartData methode ========================>

  static Future<Response> patchMultipartData(
      String uri, Map<String, String> body,
      {List<MultipartBody>? multipartBody,
        Map<String, String>? headers}) async {
    try {
      bearerToken = await SharePrefsHelper.getString(AppConstants.bearerToken);

      var mainHeaders = {
        'Accept': 'multipart/form-data',
        'Authorization': 'Bearer $bearerToken'
      };

      debugPrint('====> API Call: $uri\nHeader: ${headers ?? mainHeaders}');
      debugPrint('====> API Body: $body with ${multipartBody?.length} picture');
      //http.MultipartRequest _request = http.MultipartRequest('POST', Uri.parse("https://b936-114-130-157-130.ngrok-free.app/api/v1/user/profile/store/degree"));
      //_request.headers.addAll(headers ?? mainHeaders);
      // for(MultipartBody multipart in multipartBody!) {
      //   if(multipart.file != null) {
      //     Uint8List _list = await multipart.file.readAsBytes();
      //     _request.files.add(http.MultipartFile(
      //       multipart.key, multipart.file.readAsBytes().asStream(), _list.length,
      //       filename: '${DateTime.now().toString()}.png',
      //     ));
      //   }
      // }
      var request =
      http.MultipartRequest('PATCH', Uri.parse(ApiConstant.baseUrl + uri));
      request.fields.addAll(body);

      if (multipartBody!.isNotEmpty) {
        // ignore: avoid_function_literals_in_foreach_calls
        multipartBody.forEach((element) async {
          debugPrint("path : ${element.file.path}");

          var mimeType = lookupMimeType(element.file.path);

          debugPrint("MimeType================$mimeType");

          var multipartImg = await http.MultipartFile.fromPath(
            element.key,
            element.file.path,
            contentType: MediaType.parse(mimeType!),
          );
          request.files.add(multipartImg);
          //request.files.add(await http.MultipartFile.fromPath(element.key, element.file.path,contentType: MediaType('video', 'mp4')));
        });
      }

      request.headers.addAll(mainHeaders);
      http.StreamedResponse response = await request.send();
      final content = await response.stream.bytesToString();
      debugPrint(
          '====> API Response: [${response.statusCode}}] $uri\n$content');

      return Response(
          statusCode: response.statusCode,
          statusText: noInternetMessage,
          body: content);
    } catch (e) {
      debugPrint('------------${e.toString()}');

      return const Response(statusCode: 1, statusText: noInternetMessage);
    }
  }



  /// ========================= MultiPart Request   its a spacial method  =====================

 static  Future<Response> multipartRequest(
      {required String url,
        required String reqType,
        bool isBasic = false,
        Map<String, String>? body,
        required List<MultipartBody> multipartBody,
        required Map<String,String> header,
        bool showResult = true}) async {
    try {

      final request = http.MultipartRequest(
        reqType,
        Uri.parse(url),
      )..fields.addAll(body ?? {})
        ..headers.addAll(header);

      if (multipartBody.isNotEmpty) {
        // ignore: avoid_function_literals_in_foreach_calls
        multipartBody.forEach((element) async {
          if (element.file.path.isEmpty) {
            return;
          }
          debugPrint("path : ${element.file.path}");

          var mimeType = lookupMimeType(element.file.path);

          debugPrint("MimeType================$mimeType");

          var multipartImg = await http.MultipartFile.fromPath(
            element.key,
            element.file.path,
            contentType: MediaType.parse(mimeType!),
          );
          request.files.add(multipartImg);
          //request.files.add(await http.MultipartFile.fromPath(element.key, element.file.path,contentType: MediaType('video', 'mp4')));
        });
      }

      // ..files.add(await http.MultipartFile.fromPath(filedName!, filepath!));
      var response = await request.send();
      var jsonData = await http.Response.fromStream(response);
      //
      // if (showResult) {
      //   log.i("===> Response Body => ${jsonData.body}");
      //
      //   log.i("===> Status Code =>${response.statusCode}");
      //
      //   log.i(
      //       '|📒📒📒|-----------------[[ MULTIPART $reqType ]] method response end --------------------|📒📒📒|');
      // }

      var decodeBody = jsonDecode(jsonData.body);

      return Response(
        body: decodeBody,
        statusCode: response.statusCode,
      );
    } catch(e){



      print("-=-==-=-=-=-=-=-==--=--=-=-${e}");

      return Response(
        body:{},
        statusCode: 400,
      );
    }
  }


  ///<====================== This is for patch methode ========================>
  Future<Response> putData(String uri, dynamic body,
      {Map<String, String>? headers}) async {
    bearerToken = await SharePrefsHelper.getString(AppConstants.bearerToken);

    var mainHeaders = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': 'Bearer $bearerToken'
    };
    try {
      debugPrint('====> API Call: $uri\nHeader: ${headers ?? mainHeaders}');
      debugPrint('====> API Body: $body');

      http.Response response = await http
          .put(
        Uri.parse(ApiConstant.baseUrl + uri),
        body: jsonEncode(body),
        headers: headers ?? mainHeaders,
      )
          .timeout(const Duration(seconds: timeoutInSeconds));
      return handleResponse(response, uri);
    } catch (e) {
      return const Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  static Future<Response> putMultipartData(String uri, Map<String, String> body,
      {List<MultipartBody>? multipartBody,
        List<MultipartListBody>? multipartListBody,
        Map<String, String>? headers}) async {
    try {
      bearerToken = await SharePrefsHelper.getString(AppConstants.bearerToken);

      var mainHeaders = {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': 'Bearer $bearerToken'
      };

      debugPrint('====> API Call: $uri\nHeader: ${headers ?? mainHeaders}');
      debugPrint('====> API Body: $body with ${multipartBody?.length} picture');

      //http.MultipartRequest _request = http.MultipartRequest('POST', Uri.parse("https://b936-114-130-157-130.ngrok-free.app/api/v1/user/profile/store/degree"));
      //_request.headers.addAll(headers ?? mainHeaders);
      // for(MultipartBody multipart in multipartBody!) {
      //   if(multipart.file != null) {
      //     Uint8List _list = await multipart.file.readAsBytes();
      //     _request.files.add(http.MultipartFile(
      //       multipart.key, multipart.file.readAsBytes().asStream(), _list.length,
      //       filename: '${DateTime.now().toString()}.png',
      //     ));
      //   }
      // }

      var request =
      http.MultipartRequest('PUT', Uri.parse(ApiConstant.baseUrl + uri));
      request.fields.addAll(body);

      if (multipartBody!.isNotEmpty) {
        // ignore: avoid_function_literals_in_foreach_calls
        multipartBody.forEach((element) async {
          debugPrint("path : ${element.file.path}");

          if (element.file.path.contains(".mp4")) {
            debugPrint("media type mp4 ==== ${element.file.path}");
            request.files.add(http.MultipartFile(
              element.key,
              element.file.readAsBytes().asStream(),
              element.file.lengthSync(),
              filename: 'video.mp4',
              contentType: MediaType('video', 'mp4'),
            ));
          } else if (element.file.path.contains(".png")) {
            debugPrint("media type png ==== ${element.file.path}");
            request.files.add(http.MultipartFile(
              element.key,
              element.file.readAsBytes().asStream(),
              element.file.lengthSync(),
              filename: 'image.png',
              contentType: MediaType('image', 'png'),
            ));
          }

          //request.files.add(await http.MultipartFile.fromPath(element.key, element.file.path,contentType: MediaType('video', 'mp4')));
        });
      }

      request.headers.addAll(mainHeaders);
      http.StreamedResponse response = await request.send();
      final content = await response.stream.bytesToString();
      debugPrint(
          '====> API Response: [${response.statusCode}}] $uri\n$content');

      return Response(
          statusCode: response.statusCode,
          statusText: noInternetMessage,
          body: content);
    } catch (e) {
      return const Response(statusCode: 1, statusText: noInternetMessage);
    }
  }


  ///<====================== This is for delete methode ========================>
  static Future<Response> deleteData(String uri,
      {Map<String, String>? headers, dynamic body}) async {
    bearerToken = await SharePrefsHelper.getString(AppConstants.bearerToken);

    var mainHeaders = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': 'Bearer $bearerToken'
    };
    try {
      debugPrint('====> API Call: $uri\nHeader: ${headers ?? mainHeaders}');
      debugPrint('====> API Call: $uri\n Body: $body');

      http.Response response = await http
          .delete(Uri.parse(ApiConstant.baseUrl + uri),
          headers: headers ?? mainHeaders, body: body)
          .timeout(const Duration(seconds: timeoutInSeconds));
      return handleResponse(response, uri);
    } catch (e) {
      return const Response(statusCode: 1, statusText: noInternetMessage);
    }
  }


  ///<====================== This is for handle response methode ========================>
  static Response handleResponse(http.Response response, String uri) {
    dynamic body;
    try {
      body = jsonDecode(response.body);
    } catch (e) {
      debugPrint(e.toString());
    }
    Response response0 = Response(
      body: body ?? response.body,
      bodyString: response.body.toString(),
      request: Request(
          headers: response.request!.headers,
          method: response.request!.method,
          url: response.request!.url),
      headers: response.headers,
      statusCode: response.statusCode,
      statusText: response.reasonPhrase,
    );

    if (response0.statusCode != 200 &&
        response0.body != null &&
        response0.body is! String) {
      ErrorResponse errorResponse = ErrorResponse.fromJson(response0.body);
      response0 = Response(
          statusCode: response0.statusCode,
          body: response0.body,
          statusText: errorResponse.message);

      // if(_response.body.toString().startsWith('{errors: [{code:')) {
      //   ErrorResponse _errorResponse = ErrorResponse.fromJson(_response.body);
      //   _response = Response(statusCode: _response.statusCode, body: _response.body, statusText: _errorResponse.errors[0].message);
      // }else if(_response.body.toString().startsWith('{message')) {
      //   _response = Response(statusCode: _response.statusCode, body: _response.body, statusText: _response.body['message']);
      // }
      // response0 = Response(
      //   statusCode: response0.statusCode,
      //   body: response0.body,
      // );
    } else if (response0.statusCode != 200 && response0.body == null) {
      response0 = const Response(statusCode: 0, statusText: noInternetMessage);
    }

    debugPrint(
        '====> API Response: [${response0.statusCode}] $uri\n${response0.body}');
    // log.e("Handle Response error} ");
    return response0;
  }
}

class MultipartBody {
  String key;
  File file;
  MultipartBody(this.key, this.file);
}

class MultipartListBody {
  String key;
  String value;
  MultipartListBody(this.key, this.value);
}
