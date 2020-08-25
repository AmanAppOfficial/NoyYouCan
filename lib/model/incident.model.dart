/**
 * @descrption Incident count data
 * @author Vignesh R
 */

class IncidentCount {
  int inProgress;
  int resolved;

  IncidentCount(createObj) {
    this.inProgress = createObj["InProgress"];
    this.resolved = createObj["Resolved"];
  }
}

/**
 * @descrption floor info data
 * @author Vignesh R
 */

class FloorInfo {
  int floorNumber;
  String floorAlias; 
  String floorName;

  FloorInfo(createObj) {
    this.floorNumber = createObj["floor"];
    this.floorAlias = createObj["alias"];
    this.floorName = createObj["name"];
  }
}

/**
 * @descrption suite info data
 * @author Vignesh R
 */

class SuiteInfo {

  int floorNumber;
  String floorAlias; 
  String floorName;
  String suiteNo;

  SuiteInfo(createObj) {
    this.floorNumber = createObj["floorNumber"];
    this.floorAlias = createObj["floorNo"]; 
    this.floorName = createObj["name"];
    this.suiteNo = createObj["suiteNo"];
  }

}

/**
 * @descrption Incident list model response data
 * @author Vignesh R
 */

class IncidentList {

  String id;

  FloorInfo floor;
  SuiteInfo suite;

  String facilityPerFloorId;
  String facilityPerFloorName;
  String facilityPerFloorAlias;
  String facilityPerFloorIcon;

  String facilityPerSuiteId;
  String facilityPerSuiteName;
  String facilityPerSuiteAlias;


  String severity;
  String status;
  List<String> images;

  String categoryId;
  String categoryName;

  String createdAt;

  String buildingId;
  String buildingName;
  String buildingAddress;

  String description;

  String itemId;
  String itemAlias;
  String itemIcon;

  String facilityItemIncidentTypeId;
  String facilityItemIncidentTypeName;

  String facilityIncidentTypeId;
  String facilityIncidentTypeName;

  String firstResponderCompanyId;
  String firstResponderCompanyFName;
  String firstResponderCompanyLName;
  String firstResponderCompanyEmail;

  String tradeExpertMemeberId;
  String tradeExpertMemeberEmail;
  String tradeExpertMemeberFName;
  String tradeExpertMemeberLName;

  IncidentList(createObj) {

    this.id = createObj["_id"];
    if(createObj["facilityPerFloor"] != null) {

      this.floor = new FloorInfo(createObj["floorInfo"]);
      this.facilityPerFloorId = createObj["facilityPerFloor"]["_id"];
      this.facilityPerFloorName =  createObj["facilityPerFloor"]["name"];
      this.facilityPerFloorAlias = createObj["facilityPerFloor"]["alias"];
      this.facilityPerFloorIcon = createObj["facilityPerFloor"]["icon"];

    } else if (createObj["facilityPerSuite"] != null) {

      this.suite = new SuiteInfo(createObj["suiteInfo"]);
      this.facilityPerSuiteId = createObj["facilityPerSuite"]["_id"];
      this.facilityPerSuiteName = createObj["facilityPerSuite"]["name"];
      this.facilityPerSuiteAlias = createObj["facilityPerSuite"]["alias"];

    }

    this.severity = createObj["severity"];
    this.status = createObj["status"];

    if(createObj["category"] != null) {
      this.categoryId = createObj["category"]["_id"];
      this.categoryName = createObj["category"]["name"];
    }

    if (createObj["item"] != null) {
      this.itemId = createObj["item"]["_id"];
      this.itemAlias = createObj["item"]["alias"];
      this.itemIcon = createObj["item"]["icon"];
    }

    if (createObj["facilityIncidentType"] != null) {
      this.facilityIncidentTypeId = createObj["facilityIncidentType"]["_id"];
      this.facilityIncidentTypeName = createObj["facilityIncidentType"]["name"];
    }

    if (createObj["facilityItemIncidentType"] != null) {
      this.facilityItemIncidentTypeId = createObj["facilityItemIncidentType"]["_id"];
      this.facilityItemIncidentTypeName = createObj["facilityItemIncidentType"]["name"];
    }

    this.buildingId = createObj["building"]["_id"];
    this.buildingName = createObj["building"]["name"];
    this.buildingAddress = createObj["building"]["address"];

    this.createdAt = createObj["createdAt"];

    if (createObj["firstResponderCompany"] != null && 
        !(createObj["firstResponderCompany"] is String) && 
        createObj["firstResponderCompany"]["user"] != null) {
        this.firstResponderCompanyId = createObj["firstResponderCompany"]["_id"];
        this.firstResponderCompanyFName = createObj["firstResponderCompany"]["user"]["firstName"];
        this.firstResponderCompanyLName = createObj["firstResponderCompany"]["user"]["lastName"];
        this.firstResponderCompanyEmail = createObj["firstResponderCompany"]["user"]["email"];
    }

    if (createObj["tradeExpert"] != null && !(createObj["tradeExpert"] is String)) {
        this.tradeExpertMemeberId = createObj["tradeExpert"]["_id"];
        this.tradeExpertMemeberFName = createObj["tradeExpert"]["user"]["firstName"];
        this.tradeExpertMemeberLName = createObj["tradeExpert"]["user"]["lastName"];
        this.tradeExpertMemeberEmail = createObj["tradeExpert"]["user"]["email"];
    }
    
  }

  static List<IncidentList> fromJSONList(list) {
    List<IncidentList> newList = [];
    list.forEach((element) {
      newList.add(
        new IncidentList(element)
      );
    });
    return newList;
  }
}