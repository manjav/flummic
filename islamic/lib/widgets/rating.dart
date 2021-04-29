import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../utils/localization.dart';

class RatingDialog extends StatefulWidget {
  /// The initial rating of the rating bar
  final int initialRating;

  const RatingDialog({
    this.initialRating = 1,
  });
  @override
  State<RatingDialog> createState() => RatingDialogState();
}

class RatingDialogState extends State<RatingDialog> {
  final _commentController = TextEditingController();
  final _response = RatingDialogResponse();
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      titlePadding: EdgeInsets.zero,
      scrollable: true,
      title: Stack(
        alignment: Alignment.topRight,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 24, 8, 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  "rating_l".l(),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headline6,
                ),
                const SizedBox(height: 15),
                Text(
                  "rating_m".l(),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyText2,
                ),
                const SizedBox(height: 24),
                Center(
                  child: RatingBar.builder(
                    initialRating: widget.initialRating.toDouble(),
                    itemSize: 36,
                    glowColor: Colors.amber,
                    textDirection: Localization.dir,
                    minRating: 1.0,
                    direction: Axis.horizontal,
                    allowHalfRating: false,
                    itemCount: 5,
                    itemPadding: EdgeInsets.symmetric(horizontal: 3.0),
                    onRatingUpdate: (rating) {
                      _response.rating = rating.toInt();
                      setState(() {});
                    },
                    itemBuilder: (context, _) => Icon(
                      Icons.star,
                      color: Colors.amber[_response.rating == 0 ? 800 : 500],
                    ),
                  ),
                ),
                _response.rating < 5
                    ? TextField(
                        controller: _commentController,
                        textAlign: TextAlign.center,
                        textInputAction: TextInputAction.newline,
                        minLines: 1,
                        maxLines: 5,
                        decoration: InputDecoration(
                          hintText: "rating_p".l(),
                        ),
                      )
                    : SizedBox(height: 56),
                TextButton(
                  child: Text(
                    "save_l".l(),
                  ),
                  onPressed: _response.rating == 0
                      ? null
                      : () {
                          _response.comment = _commentController.text;
                          Navigator.pop(context, _response);
                        },
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: () => Navigator.pop(context, _response),
          )
        ],
      ),
    );
  }
}

class RatingDialogResponse {
  String comment = '';
  int rating = 0;
}
