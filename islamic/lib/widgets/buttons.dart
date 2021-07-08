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
  final Function(String, int) itemCreator;
  final List<String> items;
  final ValueChanged<int> onTab;
  final bool showSelection;
  final Color primaryColor;
  final Color selectColor;
  final Color deselectCOlor;

  final double buttonSize;

  const ButtonGroup(this.itemCreator,
      {Key? key,
      required this.items,
      required this.onTab,
      double? buttonSize,
      int? current,
      bool? showSelection,
      Color? primaryColor,
      Color? selectColor,
      Color? deselectColor})
      : current = current ?? 0,
        buttonSize = buttonSize ?? 56,
        showSelection = showSelection ?? false,
        primaryColor = primaryColor ?? Colors.teal,
        selectColor = selectColor ?? Colors.blue,
        deselectCOlor = deselectColor ?? Colors.white,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    // primaryColor = Theme.of(context).primaryColor;
    return Material(
        color: primaryColor,
        borderRadius: BorderRadius.circular(_radius),
        child: Padding(
            padding: const EdgeInsets.all(_outerPadding),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(_radius - _outerPadding),
                child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: Column(children: _buttonList())))));
  }

  List<Widget> _buttonList() {
    final buttons = <Widget>[];
    for (int i = 0; i < items.length; i++)
      buttons.add(i == this.current
          ? _selectButton(items[i], i)
          : _deselectButton(items[i], i));
    return buttons;
  }

  Widget _selectButton(String title, int index) => Container(
      height: buttonSize,
      alignment: Alignment.center,
      color: deselectCOlor,
      child: _itemCreator(title, index));

  Widget _deselectButton(String title, int index) => GestureDetector(
      child: Container(
          height: buttonSize,
          alignment: Alignment.center,
          color: selectColor,
          child: _itemCreator(title, index)),
      onTap: () => onTab.call(index));

  Widget _itemCreator(String title, int index) {
    if (!showSelection) return itemCreator(title, index);
    return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Expanded(child: itemCreator(title, index)),
      Container(
          alignment: Alignment.center,
          width: 48,
          child: index == current
              ? Icon(Icons.check_circle, color: primaryColor)
              : null)
    ]);
  }
}
