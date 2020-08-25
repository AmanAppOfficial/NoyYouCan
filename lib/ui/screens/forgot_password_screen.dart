import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nowyoucan/service/auth.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {

  TextEditingController _emailController = new TextEditingController();

  @override
  Widget build(BuildContext context) {

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.black
    ));

    return Scaffold(
      body: Center(
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30)
          ),
          child: Card(
            elevation: 6,
            child: Container(
              height: MediaQuery.of(context).size.height/2,
              width: MediaQuery.of(context).size.width/1.4,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30)
              ),
              margin: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        height: 100,
                        width: 100,
                        child: Image.asset("images/new_logo.png" , fit: BoxFit.contain,),
                      ),
                      SizedBox(height: 15,),
                      Text('Forgot Your Password?' , style: TextStyle(fontSize: 20 , fontWeight: FontWeight.bold),),
                      SizedBox(height: 20,),
                      Container(
                        margin: const EdgeInsets.all(8),
                        child: TextField(
                          maxLines: 1,
                          controller: _emailController,
                          decoration: InputDecoration(
                            hintText: " Enter your email",
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: ()
                        {
                          if(_emailController.text!="")
                              forgotPassword(_emailController.text);
                        },
                        child: Container(
                          margin: const EdgeInsets.only(left: 45 , right: 45 , top: 40),
                          alignment: Alignment.center,
                          height: 55,
                          child: Text('Send' , style: TextStyle(fontSize: 20 , color: Colors.white)),
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
                          Text('Back to login'  , style: TextStyle(fontSize: 20 , color: Colors.grey),)
                        ],
                      ))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  forgotPassword(String text) async
  {
       await AuthService.forgotPassword({
      "email" : text.trim()
    });

    Fluttertoast.showToast(msg: "Forgot password mail sent to registered email" , textColor: Colors.black , backgroundColor: Colors.white);
  }
}
