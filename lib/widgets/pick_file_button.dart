import 'package:document_organizer/screens/home.dart';
import 'package:flutter/material.dart';

class PickButton extends StatefulWidget {
  final HomeState homeState;

  PickButton(this.homeState);
  @override
  _PickButtonState createState() => _PickButtonState();
}

class _PickButtonState extends State<PickButton> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(3),
            decoration:
                BoxDecoration(shape: BoxShape.circle, color: Colors.blueGrey),
            child: IconButton(
              icon: Icon(Icons.note_add),
              color: Colors.white,
              iconSize: 45,
              onPressed: () {
                widget.homeState.getFile(context);
              },
              tooltip: 'Pick File',
              hoverColor: Colors.red,
            ),
          ),
          SizedBox(
            height: 7,
          ),
          Text('Pick a file'),
        ],
      ),
    );
  }
}
