import 'package:nowyoucan/utils/ApiConstants.dart';
import 'package:nowyoucan/utils/requestHandler.dart';
import 'package:nowyoucan/model/tradeExpert.model.dart';
class TradeExpertCompanyService {
    static getMember(companyId) async {
      var response = await RequestHandler.GET(ApiConstants.TRADE_EXPERT_COMPANY + "/" + companyId + "/tradeExpert", {
        "deleted": false,
        "embed": "user",
        "searchFields": "user"
      });
      List<TradeExpert> trdaeExpertList = TradeExpert.fromJSONList(response["data"]);
      // trdaeExpertList.forEach((element) { 
      //   print(element.id + " - " + element.userId);
      // });
      // print(trdaeExpertList);
      return trdaeExpertList;
    }
}
