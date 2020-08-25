import 'package:nowyoucan/model/scheduledTaskConfig.dart';
import 'package:nowyoucan/ui/popUps/requestSwap.dart';
import 'package:nowyoucan/model/facilityCategory.model.dart';
import 'package:nowyoucan/model/floor.model.dart';
import 'package:nowyoucan/model/suite.model.dart';

class QualityInterval {
  String id;
  String name;

  String frequency;
  String status;
  List<FacilityCategory> categories;
  List<FloorInfo> floor;
  List<SuiteInfo> suite;
  String startDate;

  QualityInterval(createObj) {
    this.id = createObj["_id"];
    this.name = createObj["name"];

    this.frequency = createObj["frequency"];
    this.startDate = createObj["startDate"];
    this.status = createObj["status"];

    if(createObj["categories"] != null) {
      this.categories = FacilityCategory.fromJSONList(createObj["categories"]);
    }

    if(createObj["floor"] != null) {
      this.floor = FloorInfo.fromJSONList(createObj["floor"]);
    }

    if(createObj["suite"] != null) {
      this.suite = SuiteInfo.fromJSONList(createObj["suite"]);
    }
  }

  static fromJSONList(list) {
//    print(list);
    List<QualityInterval> newShiftList = [];
    if(list != null)
      {
        list.forEach((element) {
          newShiftList.add(new QualityInterval(element));
        });
      }

    return newShiftList;
  }
}

class InProgressAndCompleted {
  List<QualityInterval> inProgress;
  List<QualityInterval> completed;

  InProgressAndCompleted(createObj) {
    print(createObj);
    this.inProgress = QualityInterval.fromJSONList(createObj["inProgress"]);
    this.completed = QualityInterval.fromJSONList(createObj["completed"]);
  }
}

class QualityFacilityFloor {
  String floorAlias;
  int floorNumber;
  int total;
  int completed;
  List<QualityFacilityList> list;

  QualityFacilityFloor(createObj) {
    this.floorNumber = createObj["_id"]["floorNumber"];
    this.floorAlias = createObj["_id"]["floorAlias"];
    this.total = createObj["_id"]["total"];
    this.completed = createObj["_id"]["completed"];
    this.list = QualityFacilityList.fromJSONList(createObj["list"]);
  }

  static fromJSONList(list) {
    print(list);
    List<QualityFacilityFloor> newShiftList = [];
    list.forEach((element) {
      newShiftList.add(new QualityFacilityFloor(element));
    });
    return newShiftList;
  }
}

class QualityFacilityList {
  String suiteNo;
  List<QualityReviewFacility> facilityList;

  QualityFacilityList(createObj) {
    this.suiteNo = createObj["suiteNo"];
    if(createObj["facilityList"] != null) {
      this.facilityList = QualityReviewFacility.fromJSONList(createObj["facilityList"]);  
    }
  }
  
  static fromJSONList(list) {
    // print(list);
    List<QualityFacilityList> newShiftList = [];
    list.forEach((element) {
      newShiftList.add(new QualityFacilityList(element));
    });
    return newShiftList;
  }
}

class QualityReviewFacility {
  String id;
  List<ScheduledTaskConfig> scheduledTaskConfig;
  String facilityName;
  String facilityAlias;
  
  // String tEMemberId;
  // String teMemberFirstName;
  // String teMemberLastName;
  // String teMemberEmail;


  String reviewedById;
  String reviewedByFirstName;
  String reviewedByLastName;
  String reviewedByEmail;

  String tradeExpertCategoryName;
  String tradeExpertCategoryProperties;

  List<String> images;

  int rating;

  List<String> facilityCategories;
  List<TEMemberAssigned> teMemberList;
  QualityReviewFacility(createObj) {
    this.id = createObj["_id"];
    if(createObj["ScheduledTaskConfig"] != null && createObj["ScheduledTaskConfig"].length > 0) {
      this.scheduledTaskConfig = ScheduledTaskConfig.fromJSONList(createObj["ScheduledTaskConfig"]);
      this.facilityName = createObj["facilityName"];
      this.facilityAlias = createObj["facilityAlias"];  
    }
    
    if(createObj["TEMemberAssigned"] != null && createObj["TEMemberAssigned"].length > 0) {
      this.teMemberList = TEMemberAssigned.fromJSONList(createObj["TEMemberAssigned"]);
    }

    // this.tEMemberId = createObj["TEMemberAssigned"][0]["_id"];
    // this.teMemberFirstName = createObj["TEMemberAssigned"][0]["firstName"];
    // this.teMemberLastName = createObj["TEMemberAssigned"][0]["lastName"];
    // this.teMemberEmail = createObj["TEMemberAssigned"][0]["email"];

    if(createObj["tadeExpertType"] != null) {
      this.tradeExpertCategoryName = createObj["tadeExpertType"]["name"];
      this.tradeExpertCategoryProperties = createObj["tadeExpertType"]["properties"];
    }
    

    if(createObj["reviewedBy"] != null) {
      this.reviewedById = createObj["reviewedBy"]["_id"];
      this.reviewedByFirstName = createObj["reviewedBy"]["firstName"];
      this.reviewedByLastName = createObj["reviewedBy"]["lastName"];
      this.reviewedByEmail = createObj["reviewedBy"]["email"];
    }

    this.rating = createObj["rating"];
    this.images = [];
    print("createObj['images']");
    if (createObj["images"] != null ){
      createObj["images"].forEach((url) => {
        this.images.add(url)
      });
    }
 

    this.facilityCategories = [];
    createObj["facilityCategories"].forEach((category) => {
      this.facilityCategories.add(category)
    });
    // this.facilityCategories = createObj["facilityCategories"];
  }

  static fromJSONList(list) {
    List<QualityReviewFacility> newShiftList = [];
    list.forEach((element) {
      newShiftList.add(new QualityReviewFacility(element));
    });
    return newShiftList;
  }
}

class TEMemberAssigned {
  String id;
  String firstName;
  String lastName;
  String email;

  TEMemberAssigned(createObj) {
    this.id = createObj["_id"];
    this.firstName = createObj["firstName"];
    this.lastName = createObj["lastName"];
    this.email = createObj["email"];
  }

  static fromJSONList(list) {
    List<TEMemberAssigned> newShiftList = [];
    list.forEach((element) {
      newShiftList.add(new TEMemberAssigned(element));
    });
    return newShiftList;
  }
}