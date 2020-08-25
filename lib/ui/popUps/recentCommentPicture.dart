import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RecentCommentsPicture extends StatefulWidget {
  String imageName;
  RecentCommentsPicture(this.imageName);

  @override
  _RecentCommentsPictureState createState() => _RecentCommentsPictureState();
}

class _RecentCommentsPictureState extends State<RecentCommentsPicture> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    print(widget.imageName);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(20),
      height: 400,
      width: 400,
      child: Image.network(
        widget.imageName,
        fit: BoxFit.contain,
      )
    );
        //  child: Image.asset(widget.imageName , fit: BoxFit.contain,),
        //      );
  }
}
