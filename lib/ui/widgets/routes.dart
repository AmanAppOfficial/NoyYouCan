import 'package:nowyoucan/ui/screens/assigned_task_screen.dart';
import 'package:nowyoucan/ui/screens/available_screenv2.dart';
import 'package:nowyoucan/ui/screens/available_shift_screen.dart';
import 'package:nowyoucan/ui/screens/company_messaging_screen.dart';
import 'package:nowyoucan/ui/screens/incident_screen.dart';
import 'package:flutter/material.dart';
import 'package:nowyoucan/ui/screens/allocated_shift_screen.dart';
import 'package:nowyoucan/service/auth.dart';
import 'package:nowyoucan/ui/screens/profile_screen.dart';
import 'package:nowyoucan/ui/screens/quality_check_data_screen.dart';

class Routes {

  static List<dynamic> getUserRoutes(var context, var pageName, String userRole, mainCtx, var currentUser) {
    var incidentTab = ListTile(
        title: Text("Incident"),
        leading: Icon(Icons.edit),
        onTap: (){
          if(pageName!=("incident"))
            {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => IncidentScreen(userRole , mainCtx , currentUser)),
              );
            }

        },
      );

      var availableShiftTab = ListTile(
        title: Text("Available Shift"),
        leading: Icon(Icons.event_available),
        onTap: (){
          if(pageName!=("available shift"))
          {
            Navigator.of(context).pop();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AvailableShifts(userRole , mainCtx , currentUser)),
            );
          }
        },
      );

    var settingsTab = ListTile(
      title: Text("Settings"),
      leading: Icon(Icons.settings),
      onTap: (){
        if(pageName!=("settings"))
        {
          Navigator.of(context).pop();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProfileScreen()),
          );
        }
      },
    );

    var qualityCheckTab = ListTile(
      title: Text("Quality Check"),
      leading: Icon(Icons.high_quality),
      onTap: (){
        if(pageName!=("quality check"))
        {
          Navigator.of(context).pop();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => QualityCheckDataScreen(userRole , mainCtx , currentUser)),
          );
        }
      },
    );

    var companyMessagingTab = ListTile(
      title: Text("Messages"),
      leading: Icon(Icons.message),
      onTap: (){
        if(pageName!=("company message"))
        {
          Navigator.of(context).pop();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CompanyMessagingScreen(userRole , mainCtx , currentUser)),
          );
        }
      },
    );

      var assignedTaskTab = ListTile(
        title: Text("Assigned Task"),
        leading: Icon(Icons.event_available),
        onTap: (){
          if(pageName!=("assigned task"))
          {
            Navigator.of(context).pop();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AssignedScheduledTask(userRole , mainCtx , currentUser)),
            );
          }
        },
      );

      var allocatedShiftsTab = ListTile(
        title: Text("Allocated Shifts"),
        leading: Icon(Icons.work),
        onTap: (){
          if(pageName!=("allocated shift"))
          {
            Navigator.of(context).pop();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AllocatedShifts(userRole , mainCtx , currentUser)),
            );
          }
        },
      );

      // var userRole = await AuthService.getRole(); 
      
      if(userRole == "Trade Expert Company") {
        return [
          incidentTab,
          qualityCheckTab,
          companyMessagingTab,
          settingsTab
        ];
      } else {
        var tabs = [];
        if(currentUser["tradeExpert"]["userControl"] != null) {
          // print(currentUser["tradeExpert"]);
          tabs = [
            incidentTab,
            assignedTaskTab,
            settingsTab
          ];
          if(currentUser["tradeExpert"]["userControl"]["allocatedShift"] != null)
            {
              if(currentUser["tradeExpert"]["userControl"]["allocatedShift"] == true) {
                tabs.add(allocatedShiftsTab);
              }
            }


          if(currentUser["tradeExpert"]["userControl"]["availableShift"] != null)
            {
              if(currentUser["tradeExpert"]["userControl"]["availableShift"] == true) {
                tabs.add(availableShiftTab);
              }
            }


          
        } else {
          tabs = [
            incidentTab,
            assignedTaskTab,
            allocatedShiftsTab,
            availableShiftTab,
            settingsTab
          ];
        }
        return tabs;
      }
      
      // return [
      //   incidentTab,
      //   assignedTaskTab,
      //   allocatedShiftsTab,
      //   availableShiftTab
      // ];


  }
  
}