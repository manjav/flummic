import 'package:cached_network_image/cached_network_image.dart';
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
