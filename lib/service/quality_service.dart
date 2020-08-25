import 'package:nowyoucan/utils/ApiConstants.dart';
import 'package:nowyoucan/utils/requestHandler.dart';
import 'package:nowyoucan/model/qualityInterval.dart';

class QualityService
{

  static getReviewInprogressCount() async
  {
    var response = await RequestHandler.GET(ApiConstants.QUALITY_INTERVAL + "/InprogressCount");
    return response["data"];
  }
  
  static discardReviewInterval(reviewIntervalId) async
  {
    var res = await RequestHandler.DELETE(ApiConstants.QUALITY_INTERVAL + "/" + reviewIntervalId);
    return res;
  }

  static getReviewIntervalList(buildingId) async
  {
    var response = await RequestHandler.GET(ApiConstants.QUALITY_INTERVAL , {
      "building" : buildingId
    });
    InProgressAndCompleted reviewList = new InProgressAndCompleted(response["data"]);

    return reviewList;
  }


  static getReviewFacilityList(reviewIntervalId) async {
    print(reviewIntervalId.toString());
    var response = await RequestHandler.GET(ApiConstants.QUALITY_INTERVAL + "/" + reviewIntervalId.toString() + "/task-facilities" ,{
      "type" : "Mobile"
    });

    // print("response+++++++++ ${response["data"].toString()}");
    List<QualityFacilityFloor> facilityList = QualityFacilityFloor.fromJSONList(response["data"]);

    return facilityList;
  }

  static getReviewAnalytics(reviewIntervalId) async
  {
    var response = await RequestHandler.GET(ApiConstants.QUALITY_INTERVAL + "/"  + reviewIntervalId + "/"+ "qualityReviewFacility/count");
    if(response["data"].length>0)
    return response["data"][0];
    else
    return null;
  }

  static getReviewFacility(reviewFacilityId) async {
    // print(reviewFacilityId.toString());
    var response = await RequestHandler.GET(ApiConstants.QUALITY_REVIEW_FACILITY + "/" + reviewFacilityId.toString());
    QualityReviewFacility facilityObj = new QualityReviewFacility(response["data"]);
    // print(response);
    return facilityObj;
  }


  static markReviewed(body , reviewIntervalId , facilityId) async
  {
    var respone = await RequestHandler.POST(ApiConstants.QUALITY_INTERVAL + "/" + reviewIntervalId.toString() + "/task-facilities/" +  facilityId.toString() + "/mark-reviewed", body);
    return respone;
  }

  // https://dev.nowyoucan.io/api/v1/qualityReviewInterval/5f100a3c76c2c0fc371c0e02
  static getReviewDetails(qualityReviewId) async {
    // print("QC -------------- " + qualityReviewId.toString());
    var response = await RequestHandler.GET(ApiConstants.QUALITY_INTERVAL + "/" + qualityReviewId.toString());
    // print(response);
    QualityInterval qualityIntervalObj = new QualityInterval(response["data"]);    
    return qualityIntervalObj;
  }

  static getFloorSuiteCategory(body) async
  {
    var response = await RequestHandler.GET(ApiConstants.FLOOR_SUITE_CATEGORY , body);

    print(response);

    return response["data"];
  }
  
  
  static createReviewInterval(body) async
  {
    var response = await RequestHandler.POST(ApiConstants.QUALITY_INTERVAL, body);
    print(response.toString());

    return response;
  }

}