

class IncidentComment
{
  String id;
  String incident;
  String commentId;
  String parentId;
  String message;
  CreatedBy createdBy;
  String createdAt;
  String imageUrl;
  List<IncidentComment> child;


  IncidentComment(obj)
  {
    this.id = obj["_id"];
    this.incident = obj["incident"];
    this.commentId = obj["commentId"];
    this.message = obj["message"];
    this.createdAt = obj["createdAt"];
    this.imageUrl = obj["fileUrl"];
    this.parentId = obj["parentId"];
    this.createdBy = CreatedBy(obj["createdBy"]);
    this.child = IncidentComment.fromJSONList(obj["child"]);

  }

  static fromJSONList(list)
  {
    List<IncidentComment> commentList = [];

    if(list != null)
      {
        list.forEach((element)
        {
          commentList.add(new IncidentComment(element));
        });
      }


    return commentList;

  }
}

class CreatedBy
{
  String id;
  String firstName;

  CreatedBy(obj)
  {
    this.id = obj["_id"];
    this.firstName = obj["firstName"];
  }

}