import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nowyoucan/service/user.dart';

class ChangePasswordScreen extends StatefulWidget {
  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {

  bool isLoading = false;

  TextEditingController _oldPasswordController = new TextEditingController();
  TextEditingController _newPasswordController = new TextEditingController();
  TextEditingController _confirmPasswordController = new TextEditingController();

  bool isOldPasswordVisible = true , isNewPasswordVisible = true , isConfirmPasswordVisible = true;

@override
  void initState() {
    super.initState();


    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.black
    ));
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height,
              margin: EdgeInsets.all(20),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30)
              ),
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        height: 140,
                        width: 140,
                        child: Image.asset("images/new_logo.png" , fit: BoxFit.contain,),
                      ),
                      SizedBox(height: 15,),
                      Text('Change Your Password' , style: TextStyle(fontSize: 20 , fontWeight: FontWeight.bold),),
                      SizedBox(height: 20,),
                      Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.all(8),
                            child: TextField(
                              obscureText: isOldPasswordVisible,
                              maxLines: 1,
                          controller: _oldPasswordController,
                              decoration: InputDecoration(
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      isOldPasswordVisible = !isOldPasswordVisible;
                                    });
                                  },
                                  icon: isOldPasswordVisible
                                      ? Icon(Icons.visibility_off)
                                      : Icon(Icons.visibility),
                                  color: Colors.black,
                                ),
                                hintText: " Old password",
                              ),
                            ),
                          ),
                          SizedBox(height: 10,),
                          Container(
                            margin: const EdgeInsets.all(8),
                            child: TextField(
                              obscureText: isNewPasswordVisible,
                              maxLines: 1,
                          controller: _newPasswordController,
                              decoration: InputDecoration(
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      isNewPasswordVisible = !isNewPasswordVisible;
                                    });
                                  },
                                  icon: isNewPasswordVisible
                                      ? Icon(Icons.visibility_off)
                                      : Icon(Icons.visibility),
                                  color: Colors.black,
                                ),
                                hintText: " New password",
                              ),
                            ),
                          ),
                          SizedBox(height: 10,),
                          Container(
                            margin: const EdgeInsets.all(8),
                            child: TextField(
                              obscureText: isConfirmPasswordVisible,
                              maxLines: 1,
                          controller: _confirmPasswordController,
                              decoration: InputDecoration(
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      isConfirmPasswordVisible = !isConfirmPasswordVisible;
                                    });
                                  },
                                  icon: isConfirmPasswordVisible
                                      ? Icon(Icons.visibility_off)
                                      : Icon(Icons.visibility),
                                  color: Colors.black,
                                ),
                                hintText: " Confirm password",
                              ),
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: ()
                        {
                          validateFields();
                        },
                        child: Container(
                          margin: const EdgeInsets.only(left: 45 , right: 45 , top: 40),
                          alignment: Alignment.center,
                          height: 55,
                          child: Text('Change Password' , style: TextStyle(fontSize: 20 , color: Colors.white)),
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  begin: Alignment(0, 1.9),
                                  end: Alignment(0.6, 0.2),
                                  colors: [const Color(0xffec828c), const Color(0xfff6a04f)]),
                              borderRadius: BorderRadius.circular(30)
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                      margin: const EdgeInsets.only(left: 10 , top: 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          GestureDetector(
                              onTap: (){
                                Navigator.pop(context);
                              },
                              child: Icon(Icons.arrow_back , size: 50, color: Colors.grey,)),
                          SizedBox(width: 10,),
                          Text('Back to profile'  , style: TextStyle(fontSize: 20 , color: Colors.grey),)
                        ],
                      ))
                ],
              ),
            )  ,  (isLoading) ? Container(
              alignment: Alignment.center,
              height: MediaQuery.of(context).size.width,
              child: SpinKitCircle(
                color: Colors.orange,
                size: 150,
              ),
            ) : Container(),
          ],
        ),
      ),
    );
  }

  Future<void> validateFields()
  async {
    String oldPass = _oldPasswordController.text;
    String newPass = _newPasswordController.text;
    String confirmPass = _confirmPasswordController.text;

    if(oldPass == "" || newPass == "" || confirmPass == "")
      {
        Fluttertoast.showToast(msg: "Fields can't be empty!" , backgroundColor : Colors.black , textColor: Colors.white);
      }
//    else if(oldPass == newPass)
//      {
//        Fluttertoast.showToast(msg: "Old and new password can't be same!" , backgroundColor : Colors.black , textColor: Colors.white);
//      }
    else if(newPass != confirmPass)
      {
        Fluttertoast.showToast(msg: "Password different!" , backgroundColor : Colors.black , textColor: Colors.white);
      }
    else
      {
        isLoading = true;
        setState(() {
        });
        var res = await changePassword(oldPass , newPass);
        if(res!=null)
        Fluttertoast.showToast(msg: res.toString() , backgroundColor : Colors.black , textColor: Colors.white);
        else
          Fluttertoast.showToast(msg: "Oops something went wrong!" , backgroundColor : Colors.black , textColor: Colors.white);

        isLoading = false;
        setState(() {

        });

      }
  }

  changePassword(String oldPass, String newPass) async
  {
    var res = await User.changePassword(oldPass , newPass);
    print(res.toString());
    if(res!=null)
    return res["message"];
    else
      return res;

  }
}
