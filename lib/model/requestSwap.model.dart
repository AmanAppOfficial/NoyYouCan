class Shift
{
  String name;

  Shift(obj)
  {
    this.name = obj["name"];
  }

   getShiftName()
  {
    return name;
  }

}

class PreferredShift
{
  String _id;

  PreferredShift(obj)
  {
    this._id = obj["_id"];
  }

  getPreferredId()
  {
    return _id;
  }

}

class CreatedBy
{
  String name;

  CreatedBy(obj)
  {
    this.name = obj["firstName"] +  " " + obj["lastName"];
  }

  getRequestedByName()
  {
    return name;
  }

}

class RequestSwapList
{
  String id;
  String date;
  String shiftName;
  String requestBy;
  String preferredId;
  
  RequestSwapList(obj)
  {
    this.id = obj["_id"];
    this.date = obj["date"];
    this.shiftName = new Shift(obj["shift"]).getShiftName();
    this.requestBy = new CreatedBy(obj["createdBy"]).getRequestedByName();
    this.preferredId = new PreferredShift(obj["preferredShift"]).getPreferredId();
  }

  static fromJSONList(list) {
    List<RequestSwapList> newList = [];
    list.forEach((element) {
      newList.add(
          new RequestSwapList(element)
      );
    });
    return newList;
  }
  
}