// import 'dart:convert';

// import 'package:nowyoucan/model/incident_details.model.dart';
// import 'package:nowyoucan/model/incident_details.model.dart';
import 'package:nowyoucan/utils/ApiConstants.dart';
import 'package:nowyoucan/utils/requestHandler.dart';
import 'package:nowyoucan/model/qualityReviewItem.model.dart';

class QualityReviewItemService {
    static list(qualityReviewFacilityId) async {
      var response = await RequestHandler.GET(ApiConstants.QUALITY_REVIEW_ITEM, {
        "qualityReviewFacilityId": qualityReviewFacilityId
      });
      List<QualiltyReviewItem> itemList = QualiltyReviewItem.fromJSONList(response["data"]);
      // print(response);
      return itemList;
    }

    static addQualityItem(body) async
    {
      var response = await RequestHandler.POST(ApiConstants.QUALITY_REVIEW_ITEM, body);
      return response;
    }

    static deleteQualityItem(itemId) async
    {
      var response = await RequestHandler.DELETE(ApiConstants.QUALITY_REVIEW_ITEM + "/" + itemId);
      return response;
    }

}