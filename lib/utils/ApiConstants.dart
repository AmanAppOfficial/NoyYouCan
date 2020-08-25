class ApiConstants
{

  static const String URL = "https://dev.nowyoucan.io/api/";
//  static const String URL = "https://app.nowyoucan.io/api/";

  // For local  host
  // static const String URL = "http://192.168.0.109:9000/api/";
  
  static const String LOGIN_ENDPOINT = "/v1/auth/local";
  static const String FORGOT_PASSWORD = "v1/users/forgotPassword";
  static const String USERS= "v1/users";
  static const String SHIFT_ROTATION = "v1/shift-rotation";
  static const String SHIFT_ALLOCATION = "/v2/shift-allocation";
  static const String SCHEDULED_TASK = "/v1/scheduled_tasks";
  static const String SCHEDULED_TASK_V2 = "/v2/scheduled_tasks";
  static const String SCHEDULED_TASK_V3 = "/v3/scheduled_tasks";
  static const String COMMENT_CATEGORY = "/v1/commentCategory";
  static const String SHIFT_ATTENDANCE = "v1/shift-attendance";
  static const String BUILDING = "v1/building";
  static const String INCIDENT = "v1/incident";
  static const String INCIDENT_GRAPH = "v1/incidentGraph";
  static const String MARK_UNAVAILABLE = "v1/mark-unavailabe?type=allocated";
  static const String TRADE_EXPERT_COMPANY = "v1/tradeExpertCompany";
  static const String INCIDENT_GRAPH_V2 = "v2/incidentGraph";
  static const String NOTIFICATIONS = "v1/notification";
  static const String SHIFTS = "v1/shifts";
  static const String REQUEST_SWAP = "v1/request-shift-swap";
  static const String REQUEST_SWAP_V2= "v2/request-shift-swap";
  static const String QUALITY_INTERVAL = "v1/qualityReviewInterval";
  static const String QUALITY_REVIEW_ITEM = "v1/qualityReviewItem";
  static const String QUALITY_REVIEW_COMMENT = "v1/qualityReviewComment";
  static const String QUALITY_REVIEW_FACILITY = "v1/qualityReviewFacility";
  static const String INCIDENT_COMMENT_V2 = "v2/comment";
  static const String INCIDENT_COMMENT_V1 = "v1/comment";
  static const String FLOOR_SUITE_CATEGORY = "v1/qualityReviewInterval/FloorSuiteCategory";
  static const String MESSAGES = "v1/message";
  static const String TRADE_EXPERT_CATEGORIES = "v1/tradeExpertCategories";
  static const String FACILITY_ITEM = "v1/facilityItem";
}