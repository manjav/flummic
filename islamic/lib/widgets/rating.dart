import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../utils/localization.dart';

class RatingDialog extends StatefulWidget {
  /// The initial rating of the rating bar
  final int initialRating;

  const RatingDialog({super.key, 
    this.initialRating = 1,
  });
  @override
  State<RatingDialog> createState() => RatingDialogState();
}

class RatingDialogState extends State<RatingDialog> {
  int _response = 0;
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
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  "rate_l".l(),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: 15),
                Text(
                  "rate_m".l(),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
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
                    itemPadding: const EdgeInsets.symmetric(horizontal: 3.0),
                    onRatingUpdate: (rating) {
                      _response = rating.toInt();
                      setState(() {});
                    },
                    itemBuilder: (context, _) => Icon(
                      Icons.star,
                      color: Colors.amber[_response == 0 ? 800 : 500],
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _response == 0
                      ? null
                      : () {
                          Navigator.pop(context, _response);
                        },
                  child: Text(
                    "save_l".l(),
                  ),
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

class ReviewDialog extends StatefulWidget {
  const ReviewDialog({super.key});

  @override
  State<ReviewDialog> createState() => ReviewDialogState();
}

class ReviewDialogState extends State<ReviewDialog> {
  final _commentController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _commentController.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        titlePadding: EdgeInsets.zero,
        title: SizedBox(
          width: 360,
          child: Stack(
            alignment: Alignment.topRight,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const SizedBox(height: 15),
                    TextField(
                        autofocus: true,
                        controller: _commentController,
                        textInputAction: TextInputAction.newline,
                        minLines: 1,
                        maxLines: 5,
                        decoration: InputDecoration(
                          hintText: "rate_p".l(),
                        )),
                    TextButton(
                      onPressed: _commentController.text == ""
                          ? null
                          : () {
                              Navigator.pop(context, _commentController.text);
                            },
                      child: Text(
                        "save_l".l(),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: () =>
                    Navigator.pop(context, _commentController.text),
              )
            ],
          ),
        ));
  }
}
