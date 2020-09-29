import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {

  List<bool> progressList=[false, false, false, false]; 

  LoadingWidget({this.progressList});

  Widget _buildProgressRows(String desc, bool progress) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          margin: EdgeInsets.all(10.0),
          child: 
          progress
          ?
          Icon(
            Icons.done,
            color: Color(0xff1abc9c),
            size: 21.0
          )
          :
          SizedBox(
            height: 21.0,
            width: 21.0,
            child: CircularProgressIndicator(),
          ),
        ),
        Container(
          margin: EdgeInsets.all(10.0),
          child: Text(
            desc,
            style: TextStyle(
              fontSize: 18.0
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height*0.4,
      width: MediaQuery.of(context).size.width*0.8,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          _buildProgressRows('Fetching mail IDs', progressList[0]),
          _buildProgressRows('Fetching attachment IDs', progressList[1]),
          _buildProgressRows('Fetching attachments', progressList[2]),
          _buildProgressRows('Processing attachments', progressList[3]),
        ],
      ),
    );
  }
}
