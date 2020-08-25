import 'package:nowyoucan/utils/ApiConstants.dart';
import 'package:nowyoucan/utils/requestHandler.dart';
import 'package:nowyoucan/model/commentCategory.model.dart';

class CommentCategoryService {
    static get() async {
      var response = await RequestHandler.GET(ApiConstants.COMMENT_CATEGORY);
      // print(response);
      List<CommentCategory> categoryList = CommentCategory.fromJSONList(response["data"]); 
      // print("@CommentCategoryService" + categoryList[0].icon );
      return categoryList;
    }
}