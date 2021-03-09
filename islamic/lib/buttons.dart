import 'package:flutter/material.dart';

class CircleButton extends GestureDetector {
  // final textStyle = TextStyle(fontFamily: 'Uthmani', fontSize: 30);
  CircleButton(
      {IconData icon,
      String text,
      Color color,
      VoidCallback onPressed,
      bool selected = true})
      : super(
            onTap: onPressed,
            child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: text == null
                      ? Icon(
                          icon,
                        )
                      : Text(text,
                          style: TextStyle(
                              fontFamily: 'Uthmani', fontSize: 24, height: 1)),
                ))
            // ),
            // elevation: 0,
            // fillColor: Colors.white,
            // child: icon == null
            //     ? Text(text,
            //         style: TextStyle(
            //             fontFamily: 'Uthmani', fontSize: 30, height: 0.5))
            //     : Icon(
            //         icon,
            //       ),
            // padding: EdgeInsets.all(15.0),
            // shape: CircleBorder(),
            );
}
