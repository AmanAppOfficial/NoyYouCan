// import 'dart:convert';

// import 'package:nowyoucan/model/incident_details.model.dart';
// import 'package:nowyoucan/model/incident_details.model.dart';
import 'package:nowyoucan/utils/ApiConstants.dart';
import 'package:nowyoucan/utils/requestHandler.dart';
import 'package:nowyoucan/model/qualityReviewComment.model.dart';

class QualityReviewCommentService {
    static list(qualityReviewFacilityId) async {
      var response = await RequestHandler.GET(ApiConstants.QUALITY_REVIEW_COMMENT, {
        "qualityReviewFacilityId": qualityReviewFacilityId
      });
      List<QualiltyReviewComment> commentList = QualiltyReviewComment.fromJSONList(response["data"]);
      // print(response);
      return commentList;
    }

    static addComment(body) async
    {
      var response = await RequestHandler.POST(ApiConstants.QUALITY_REVIEW_COMMENT, body);
      return response;
    }



    static deleteComment(itemId) async
    {
      var response = await RequestHandler.DELETE(ApiConstants.QUALITY_REVIEW_COMMENT + "/" + itemId);
      return response;
    }

}