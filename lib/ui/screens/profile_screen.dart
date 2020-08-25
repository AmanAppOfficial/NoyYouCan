import 'package:flutter/material.dart';
import 'package:nowyoucan/service/user.dart';
import 'package:nowyoucan/ui/screens/change_password_screen.dart';
import 'package:nowyoucan/ui/widgets/loader.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  var fName = "", lName = "" , pNo = "";
  var businessName = "" , email="" , address = "Address" , webAddress = "Web Address";
  var categories = [
  ];

  var role;

  bool isLoading = true;

  var myCategories = [], myItems = [];

  var items = [
  ];

  final TYPE_BUSINESS_NAME =  "Business Name";
  final TYPE_EMAIL = "Email";
  final TYPE_ADDRESS = "Address";
  final TYPE_WEB_ADDRESS = "Web Address";
  final TYPE_EXPERTISE = "Expertise";

  var selectedCategories = [] , selectedItems=[] ;

  var expertise = "";
  bool externalJobs = false;

  TextEditingController _fieldController = TextEditingController();
  TextEditingController _fNameController = TextEditingController();
  TextEditingController _lNameController = TextEditingController();
  TextEditingController _pNoController = TextEditingController();


  @override
  void initState() => {
    (() async {

      await initFields();

      isLoading = false;
      setState(() {
      });
    })()
  };

  initFields() async
  {

    var res = await getUser();

    role = res["role"][0];

    fName = res["firstName"];
    lName = res["lastName"];
    pNo = res["phone"];
    businessName = res["tradeExpert"]["company"]["name"];
    email = res["email"];
    address = res["tradeExpert"]["company"]["address"];
    webAddress = res["tradeExpert"]["company"]["webAddress"];
    externalJobs = res["tradeExpert"]["company"]["externalJobs"];
    myCategories = res["tradeExpert"]["company"]["categories"];
    myItems = res["tradeExpert"]["company"]["items"];

    categories = await User.getTadeExpertCategories();

    if(categories.length>0)
      {
        categories.forEach((element) {         //un select all categories initially...
          selectedCategories.add(false);
        });

        for(int i=0 ; i<myCategories.length ; i++){       //select already selected categories...
          String id = myCategories[i]["_id"];

          for(int j=0 ; j<categories.length ; j++)
          {
            if(categories[j]["_id"] == id)
              selectedCategories[i] = true;
          }
        }
      }


    items = await User.getFacilityItem();

    if(items.length>0)
      {
        items.forEach((element) {         //un select all items initially...
          selectedItems.add(false);
        });

        for(int i=0 ; i<myItems.length ; i++){       //select already selected items...
          String id = myItems[i]["_id"];

          for(int j=0 ; j<items.length ; j++)
          {
            if(items[j]["_id"] == id)
              selectedItems[i] = true;
          }
        }
      }

  }


  getUser() async
  {
    var response  = await User.me();
    return response;
  }

  update(body) async
  {
    await User.updateProfile(body);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: (!isLoading) ? SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 50.0 , horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Profile' , style: TextStyle(
                fontSize: 32.0,
                fontWeight: FontWeight.bold,
              ),),
              SizedBox(height: 20.0,),
              _profileRow(),
              SizedBox(height: 30.0),
              Text('Account' , style: TextStyle(fontSize: 20.0 , fontWeight: FontWeight.bold),),
              SizedBox(height: 20.0,),
              _passwordCard(),
              SizedBox(height: 30.0),
              Text('Contact Info' , style: TextStyle(fontSize: 20.0 , fontWeight: FontWeight.bold),),
              SizedBox(height: 20.0,),
              _profileAccountCard(),
              SizedBox(height: 30.0),
              Text('Trade Expert Categories' , style: TextStyle(fontSize: 20.0 , fontWeight: FontWeight.bold),),
              SizedBox(height: 20.0,),
              _categoriesCard(),
              SizedBox(height: 30.0),
              Text('Items Of Expertise' , style: TextStyle(fontSize: 20.0 , fontWeight: FontWeight.bold),),
              SizedBox(height: 20.0,),
              _expertiseItemCard(),
              SizedBox(height: 30.0),
              (role == "Trade Expert Company") ? Text('Others' , style: TextStyle(fontSize: 20.0 , fontWeight: FontWeight.bold),) : Container(),
              (role == "Trade Expert Company") ? SizedBox(height: 20.0,) : Container(),
              (role == "Trade Expert Company") ? _otherCard() : Container(),
              updateButton()
            ],
          ),
        ),
      ) : Center(
        child: Loader.getLoader(),
      ),
    );
  }

  Widget _profileAccountCard()
  {
    return Card(
      elevation: 3.0,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            (role == "Trade Expert Company") ? Padding(
              padding: const EdgeInsets.symmetric(vertical : 5.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: <Widget>[
                          Icon(Icons.person, color: Colors.blue,),
                          SizedBox(width: 15.0,),
                          Text('Business Name' , style: TextStyle(fontSize: 16.0),),
                        ],
                      ),
                      GestureDetector(
                          onTap: (){
                            fieldDialog(TYPE_BUSINESS_NAME);
                          },
                          child: Icon(Icons.edit))
                    ],
                  ),
                  SizedBox(height: 10,),
                  Text('         $businessName' ,  style: TextStyle(fontSize: 16.0 , color: Colors.grey[600]),)
                ],
              ),
            ) : Container(),
            Divider(height: 10.0,color: Colors.grey,),
            Padding(
              padding: const EdgeInsets.symmetric(vertical : 5.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: <Widget>[
                          Icon(Icons.email, color: Colors.blue,),
                          SizedBox(width: 15.0,),
                          Text('Email' , style: TextStyle(fontSize: 16.0),),
                        ],
                      ),
                      GestureDetector(
                          onTap: (){
                            fieldDialog(TYPE_EMAIL);
                          },
                          child: Icon(Icons.edit))
                    ],
                  ),
                  SizedBox(height: 10,),
                  Text('         $email' ,  style: TextStyle(fontSize: 16.0 , color: Colors.grey[600]),)
                ],
              ),
            ),
            Divider(height: 10.0,color: Colors.grey,),
            Padding(
              padding: const EdgeInsets.symmetric(vertical : 5.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: <Widget>[
                          Icon(Icons.location_city, color: Colors.blue,),
                          SizedBox(width: 15.0,),
                          Text('Address' , style: TextStyle(fontSize: 16.0),),
                        ],
                      ),
//                      GestureDetector(
//                          onTap: (){
//                            fieldDialog(TYPE_ADDRESS);
//                          },
//                          child: Icon(Icons.edit))
                    ],
                  ),
                  SizedBox(height: 10,),
                  Text('         $address' ,  style: TextStyle(fontSize: 16.0 , color: Colors.grey[600]),)
                ],
              ),
            ),
            Divider(height: 10.0,color: Colors.grey,),
            (role == "Trade Expert Company") ? Padding(
              padding: const EdgeInsets.symmetric(vertical : 5.0),
              child:Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: <Widget>[
                          Icon(Icons.location_on, color: Colors.blue,),
                          SizedBox(width: 15.0,),
                          Text('Web Address' , style: TextStyle(fontSize: 16.0),),
                        ],
                      ),
                      GestureDetector(
                          onTap: (){
                            fieldDialog(TYPE_WEB_ADDRESS);
                          },
                          child: Icon(Icons.edit))
                    ],
                  ),
                  SizedBox(height: 10,),
                  Text('         $webAddress' ,  style: TextStyle(fontSize: 16.0 , color: Colors.grey[600]),)
                ],
              ),
            ) : Container(),
            Divider(height: 10.0,color: Colors.grey,),
          ],
        ),
      ),
    );
  }

  Widget _categoriesCard()
  {
    return Card(
      elevation: 3.0,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical : 5.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: <Widget>[
                          SizedBox(width: 15.0,),
                          Text('Add Categories' , style: TextStyle(fontSize: 16.0),),
                        ],
                      ),
                      GestureDetector(
                        onTap: () async {
                          await categoryDialog();
                        },
                        child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[400],
                              shape: BoxShape.circle
                            ),
                            child: Icon(Icons.add , size: 26, )),
                      )
                    ],
                  ),
                  SizedBox(height: 7,),
                  ListView.builder(
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                      itemCount: categories.length,
                      itemBuilder: (BuildContext context , int index)
                      {
                    if(selectedCategories[index] == true)
                      {
                        return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              margin: EdgeInsets.all(8),
                              alignment: Alignment.topLeft,
                              color: Colors.grey[300],
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: FittedBox(child: Text('         ${categories[index]["name"].toString()}' ,  style: TextStyle(fontSize: 22.0 , color: Colors.black),)),
                              )),
                        ],
                      );
                      }
                    else
                    return Container();
                  })
                ],
              ),
            ),
            Divider(height: 10.0,color: Colors.grey,),
          ],
        ),
      ),
    );
  }


  Widget _profileRow()
  {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Container(
          height: 120.0,
          width: 120.0,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(60.0),
              boxShadow:[
                BoxShadow(
                    blurRadius: 3.0,
                    offset: Offset(0,4.0),
                    color: Colors.black38
                ),
              ],
              image: DecorationImage(
                  image: AssetImage('images/profle.png',),
                  fit: BoxFit.cover
              )
          ),
        ),
        SizedBox(width: 20.0,),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(fName + " " + lName , style: TextStyle(fontSize: 16.0 , ),),
            SizedBox(height: 10.0,),
            Text(pNo , style: TextStyle(color: Colors.grey),),
            SizedBox(height: 20.0,),
            GestureDetector(
              onTap: () async {
                await profileDialog();
                setState(() {
                });
              },
              child: Container(
                 height: 25.0,
                 width: 60.0,
                 decoration: BoxDecoration(
                  border: Border.all(
                   color: Colors.blue
                        ),
                        borderRadius: BorderRadius.circular(20.0)
                         ),
                         child: Center(
                           child: Text('Edit' , style: TextStyle(
                                color: Colors.blue , fontSize: 16.0),),),
                           ),
            )
          ],
        ),
      ],
    );
  }

  Widget _expertiseItemCard()
  {
    return Card(
      elevation: 3.0,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical : 5.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: <Widget>[
                          Icon(Icons.star, color: Colors.blue,),
                          SizedBox(width: 15.0,),
                          Text('Expertise' , style: TextStyle(fontSize: 16.0),),
                        ],
                      ),
                      GestureDetector(
                          onTap: (){
                            expertiseDialog();
                          },
                          child: Icon(Icons.edit))
                    ],
                  ),
                  SizedBox(height: 10,),
                  Text('         $expertise' ,  style: TextStyle(fontSize: 16.0 , color: Colors.grey[600]),)
                ],
              ),
            ),
            Divider(height: 10.0,color: Colors.grey,),
          ],
        ),
      ),
    );
  }

  Widget _otherCard()
  {
    return Card(
      elevation: 3.0,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical : 5.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: <Widget>[
                          Icon(Icons.work, color: Colors.blue,),
                          SizedBox(width: 15.0,),
                          Text('External Jobs: ' , style: TextStyle(fontSize: 16.0),),
                        ],
                      ),
                      Switch(
                        onChanged: (value){
                          setState(() {
                            externalJobs = value;
                          });
                        },
                        value: externalJobs,
                      )
                    ],
                  ),
                  SizedBox(height: 10,),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _passwordCard()
  {
    return Card(
      elevation: 3.0,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical : 5.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: <Widget>[
                          Icon(Icons.security, color: Colors.blue,),
                          SizedBox(width: 15.0,),
                          Text('Change Password ' , style: TextStyle(fontSize: 16.0),),
                        ],
                      ),
                      GestureDetector(
                          onTap: (){
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ChangePasswordScreen()),
                            );                          },
                          child: Icon(Icons.edit))
                    ],
                  ),
                  SizedBox(height: 10,),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }



  categoryDialog() async
  {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Select Category'),
            content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return  Container(
                  height: 400,
                  width: 500,
                  child: ListView.builder(
                      itemCount: categories.length,
                      itemBuilder: (BuildContext context , int index){

                        return Container(
                          margin: EdgeInsets.all(10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              GestureDetector(
                                onTap: (){

                                  setState(() {
                                    if(selectedCategories[index] == true)
                                    {
                                      selectedCategories[index] = false;
                                    }
                                    else
                                    {
                                      selectedCategories[index] = true;
                                    }

                                  });


                                },
                                child: Container(
                                  height: 30,
                                  width: 30,
                                  child: (selectedCategories[index] == true) ? Icon(Icons.done) : null,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(3),
                                      border: Border.all(color: Colors.black)
                                  ),
                                ),
                              ),
                              SizedBox(width: 60,),
                              Expanded(child: Text(categories[index]["name"].toString() , style: TextStyle(fontSize: 20),))
                            ],
                          ),
                        );
                      }),
                );
              },
            ),
            actions: <Widget>[
              new FlatButton(
                  child: new Text('Done'),
                  onPressed: () {

                    Navigator.pop(context);
                  }
              )
            ],
          );
        });
  }



  expertiseDialog() async
  {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Select Items'),
            content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return  Container(
                  height: 400,
                  width: 500,
                  child: ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (BuildContext context , int index){

                        return Container(
                          margin: EdgeInsets.all(10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              GestureDetector(
                                onTap: (){

                                  setState(() {
                                    if(selectedItems[index] == true)
                                    {
                                      selectedItems[index] = false;
                                      expertise = "";
                                      for(int i=0 ; i<items.length ; i++)
                                        {
                                          if(selectedItems[i] == true)
                                            {
                                              expertise = expertise  + items[i] + ",";
                                            }
                                        }
                                    }
                                    else
                                    {
                                      selectedItems[index] = true;
                                      expertise = "";
                                      for(int i=0 ; i<items.length ; i++)
                                      {
                                        if(selectedItems[i] == true)
                                        {
                                          expertise = expertise + items[i] + ",";
                                        }
                                      }
                                    }

                                  });


                                },
                                child: Container(
                                  height: 30,
                                  width: 30,
                                  child: (selectedItems[index] == true) ? Icon(Icons.done) : null,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(3),
                                      border: Border.all(color: Colors.black)
                                  ),
                                ),
                              ),
                              SizedBox(width: 60,),
                              Text(items[index].toString() , style: TextStyle(fontSize: 20),)
                            ],
                          ),
                        );
                      }),
                );
              },
            ),
            actions: <Widget>[
              new FlatButton(
                  child: new Text('Done'),
                  onPressed: () {

                    Navigator.pop(context);
                  }
              )
            ],
          );
        });
  }



  profileDialog() async
  {

    _fNameController.text = fName;
    _lNameController.text = lName;
    _pNoController.text = pNo;

    return await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Set Details'),
            content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return  Container(
                  height: MediaQuery.of(context).size.height/2.5,
                  width: 500,
                  child: ListView(
                    shrinkWrap: true,
//                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('First name' , style: TextStyle(fontSize: 15 , fontWeight: FontWeight.bold),),
                      SizedBox(height: 10,),
                      TextField(
                        controller: _fNameController,
                        decoration: InputDecoration(
                          hintText: 'First name',
                          border: new OutlineInputBorder()
                        ),
                      ),
                      SizedBox(height: 20,),
                      Text('Last name' , style: TextStyle(fontSize: 15 , fontWeight: FontWeight.bold),),
                      SizedBox(height: 10,),
                      TextField(
                        controller: _lNameController,
                        decoration: InputDecoration(
                            hintText: 'Last name',
                            border: new OutlineInputBorder()
                        ),
                      ),
                      SizedBox(height: 20,),
                      Text('Phone number' , style: TextStyle(fontSize: 15 , fontWeight: FontWeight.bold),),
                      SizedBox(height: 10,),
                      TextField(
                        controller: _pNoController,
                        decoration: InputDecoration(
                            hintText: 'Phone number',
                            border: new OutlineInputBorder()
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            actions: <Widget>[
              new FlatButton(
                  child: new Text('Cancel'),
                  onPressed: () {
                    Navigator.pop(context);
                  }
              ),
              new FlatButton(
                  child: new Text('Done'),
                  onPressed: () {

                    if(_fNameController.text != "" && _lNameController.text !="" && _pNoController.text!="")
                    {
                      fName = _fNameController.text;
                      lName = _lNameController.text;
                      pNo = _pNoController.text;
                    }
                    Navigator.pop(context , "done");
                  }
              )
            ],
          );
        });
  }





  fieldDialog(type)                 //to change single text fields.eg:- business Name, email, etc...
  {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Set $type'),
            content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return  Container(
                  child: TextField(
                    controller: _fieldController,
                    decoration: InputDecoration(
                    ),
                  ),
                );
              },
            ),
            actions: <Widget>[
              new FlatButton(
                  child: new Text('Cancel'),
                  onPressed: () {
                    _fieldController.text = "";
                    Navigator.pop(context);
                  }
              ),
              new FlatButton(
                  child: new Text('Done'),
                  onPressed: () {

                    if(_fieldController.text != "")
                      {
                        validateFields(type , _fieldController.text);
                      }

                    setState(() {
                    });

                    _fieldController.text = "";
                    Navigator.pop(context , "done");
                  }
              )
            ],
          );
        });
  }

  void validateFields(type, text)
  {
    if(type == TYPE_BUSINESS_NAME)
      businessName = text;
    else if(type == TYPE_ADDRESS)
      address = text;
    else if(type == TYPE_WEB_ADDRESS)
      webAddress = text;
    else if(type == TYPE_EMAIL)
      email = text;
    else if(type == TYPE_EXPERTISE)
      expertise = text;
  }

  updateButton()
  {

    List selectedCategory = [];
    List selectedItem = [];

    return GestureDetector(
      onTap: () async {
//        print("------fName-----${fName}");
//        print("------lName-----${lName}");
//        print("------email-----${email}");
//        print("------businessName-----${businessName}");
//        print("------pNo-----${pNo}");
//        print("------address-----${address}");
//        print("------web address-----${webAddress}");
//        print("------fName-----${fName}");

      isLoading = true;
      setState(() {

      });

        for(int i=0 ; i<categories.length ; i++)
          {
            if(selectedCategories[i] == true)
              {
                selectedCategory.add(categories[i]);
              }
          }

        for(int i=0 ; i<items.length ; i++)
        {
          if(selectedItem[i] == true)
          {
            selectedItem.add(items[i]);
          }
        }

        var body = {
          "firstName"  : fName,
          "lastName" : lName,
          "phone" : pNo,
          "tradeExpertUpdateObj" : {
            "address" : address ,
            "businessName" : businessName,
            "categories" :  selectedCategory,
            "externalJobs" : externalJobs,
            "items" : selectedItem,
            "webAddress" : webAddress
          }
        };


       await update(body);

        isLoading = false;
        setState(() {
        });


        selectedItem.clear();
        selectedCategory.clear();

      },
      child: Container(
        margin: const EdgeInsets.only(left: 45 , right: 45 , top: 40),
        alignment: Alignment.center,
        height: 55,
        child: Text('Update' , style: TextStyle(fontSize: 20 , color: Colors.white)),
        decoration: BoxDecoration(
            color : Colors.blue ,
            borderRadius: BorderRadius.circular(30)
        ),
      ),
    );
  }


}
