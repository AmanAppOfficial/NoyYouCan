import 'package:flutter/material.dart';
// import 'package:nowyoucan/ui/screens/assigned_task_screen.dart';
// import 'package:nowyoucan/ui/screens/available_shift_screen.dart';
// import 'package:nowyoucan/ui/screens/incident_screen.dart';
import 'package:nowyoucan/service/auth.dart';
// import 'package:nowyoucan/ui/screens/allocated_shift_screen.dart';
import 'package:nowyoucan/ui/widgets/routes.dart';

class DrawerElements {

  static getDrawer(var pageName , BuildContext context, String userRole, ctx, var currentUser) {
    return ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
                color: Colors.orangeAccent,
                gradient: LinearGradient(
                    begin: Alignment(0.4, 0.5),
                    end: Alignment(0, 0.7),
                    colors: [const Color(0xffec828c), const Color(0xfff6a04f)])

            ),
             child: SizedBox(width: 0),
          ),
          ...Routes.getUserRoutes(context, pageName, userRole , ctx , currentUser),                 //assigned collection of navigation elements
          ListTile(
            title: Text("Logout"),
            leading: Icon(Icons.refresh),
            onTap: (){
              AuthService.logout(ctx);
            },
          ),
        ],
      );
    }


  }
