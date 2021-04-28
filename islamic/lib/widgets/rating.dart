import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../utils/localization.dart';

class RatingDialog extends StatefulWidget {
  /// Disables the cancel button and forces the user to leave a rating
  final bool force;

  /// The initial rating of the rating bar
  final int initialRating;

  /// Returns a RatingDialogResponse with user's rating and comment values
  final Function(RatingDialogResponse)? onSubmitted;

  /// called when user cancels/closes the dialog
  final Function? onCancelled;

  const RatingDialog({
    this.onSubmitted,
    this.onCancelled,
    this.force = false,
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
          // ClipRRect(
          //   borderRadius: BorderRadius.circular(12.0),
          // child:
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
                          if (!widget.force) Navigator.pop(context);
                          _response.comment = _commentController.text;
                          widget.onSubmitted?.call(_response);
                        },
                ),
              ],
            ),
            // ),
          ),
          if (!widget.force && widget.onCancelled != null) ...[
            IconButton(
              icon: const Icon(Icons.close, size: 18),
              onPressed: () {
                Navigator.pop(context);
                widget.onCancelled!.call();
              },
            )
          ]
        ],
      ),
    );
  }
}

class RatingDialogResponse {
  /// The user's comment response
  String comment = '';

  /// The user's rating response
  int rating = 0;
}
