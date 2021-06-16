import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:islamic/models.dart';

class Avatar extends CachedNetworkImage {
  final String path;
  final double radius;
  Avatar(this.path, this.radius)
      : super(
            imageUrl: "${Configs.baseURL}images/$path.png",
            width: radius * 2.0,
            placeholder: (context, url) =>
                SvgPicture.asset("images/person.svg"),
            height: radius * 2.0);
}

class ButtonGroup extends StatelessWidget {
  static const double _radius = 12.0;
  static const double _outerPadding = 4.0;

  final int current;
  final List<String> titles;
  final ValueChanged<int> onTab;
  final Color color;
  final Color secondaryColor;

  const ButtonGroup(
      {Key? key,
      required this.titles,
      required this.onTab,
      int? current,
      Color? color,
      Color? secondaryColor})
      : current = current ?? 0,
        color = color ?? Colors.blue,
        secondaryColor = secondaryColor ?? Colors.white,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(_radius),
      child: Padding(
        padding: const EdgeInsets.all(_outerPadding),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(_radius - _outerPadding),
          child: Column(
            // mainAxisSize: MainAxisSize.min,
            children: _buttonList(),
          ),
        ),
      ),
    );
  }

  List<Widget> _buttonList() {
    final buttons = <Widget>[];
    for (int i = 0; i < items.length; i++) {
      buttons.add(_button(items[i], i));
    }
    return buttons;
  }

  Widget _button(String title, int index) {
    if (index == this.current)
      return _activeButton(title);
    else
      return _inActiveButton(title, index);
  }

  Widget _activeButton(String title) => Container(
      height: 56,
      alignment: Alignment.center,
      color: secondaryColor,
      child: Text(title, style:TextStyle(color: color)));

  Widget _inActiveButton(String title, int index) => GestureDetector(
      // materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      child: Container(
          height: 48,
          alignment: Alignment.center,
          color: color,
          child: Text(title)),
      onTap: () => onTab.call(index));
}
