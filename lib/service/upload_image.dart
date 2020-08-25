import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:async/async.dart';
import 'dart:convert';
import 'package:nowyoucan/utils/ApiConstants.dart';

class ImageUploadService
{
  static upload(imageList , endpoint) async {
    var uri = Uri.parse(ApiConstants.URL + "/v1/upload/" + endpoint);
    List<Future> futureList = [];
    for(File image in imageList) {
      print(image.toString());
         var stream = new http.ByteStream(DelegatingStream.typed(image.openRead()));
         var length = await image.length();
         var request = new http.MultipartRequest("POST", uri);
         var multipartFile = new http.MultipartFile('file', stream, length,
             filename: basename(image.path));
         request.files.add(multipartFile);
         var response = await request.send();
         
         futureList.add(http.Response.fromStream(response));

    }
    // print("----- future created");
    List<String> imageUrlList = [];
    var results = await Future.wait(futureList); 
    for (var response in results) {
        // print(response.statusCode);
        // todo - parse the response - perhaps JSON
        // print(json.decode(response.body)["data"]);
        imageUrlList.add(json.decode(response.body)["data"].toString());
        // value.add(json.decode(response.body)["data"]);
    }
    return imageUrlList;
  }

}