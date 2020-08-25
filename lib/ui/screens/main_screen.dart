/**
 * @descrption Buttom navigation screen
 * @author Aman Srivastava
 */


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

import 'dashboard_screen.dart';
import 'notification_screen.dart';

class MainScreen extends StatefulWidget {
  var userRole;
  var currentUser;
  MainScreen(this.userRole, this.currentUser);


  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  PersistentTabController _controller;


  @override
  void initState() {
    super.initState();
    _controller = PersistentTabController(initialIndex: 0);

  }

  List<Widget> _buildScreens() {
    return [
      DashboardScreen(context , widget.userRole , widget.currentUser),
      NotificationScreen(context , widget.userRole , widget.currentUser)
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: Icon(Icons.home , size: 25,),
        title: ("Home"),
        activeColor: Colors.orange,
        inactiveColor: CupertinoColors.systemGrey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.notifications),
        title: ("Notification"),
        activeColor: Colors.orange,
        inactiveColor: CupertinoColors.systemGrey,
      ),
    ];
  }



  @override
  Widget build(BuildContext context) {

    return PersistentTabView(
      controller: _controller,
      items: _navBarsItems(),
      screens: _buildScreens(),
      confineInSafeArea: true,
      handleAndroidBackButtonPress: true,
      iconSize: 26.0,
      navBarStyle: NavBarStyle.style6, // Choose the nav bar style with this property
      onItemSelected: (index) {
        print(index);
      },
    );
  }


}
