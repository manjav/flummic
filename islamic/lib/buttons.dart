import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CircleButton extends GestureDetector {
  static TextStyle style =
      TextStyle(fontFamily: 'CubicSans', fontSize: 24, height: 1);
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
                      : Text(text, style: style),
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

class Avatar extends CachedNetworkImage {
  final String path;
  final double radius;
  Avatar(this.path, this.radius)
      : super(
            imageUrl: "https://grantech.ir/islam/images/$path.png",
            width: radius * 2.0,
            placeholder: (context, url) => CircleAvatar(
                backgroundColor: Colors.black12,
                backgroundImage: AssetImage("images/person.png"),
                radius: radius),
            // errorWidget: (context, url, error) => Icon(
            //       Icons.person,
            //       size: 56,
            //     )
            );
}
