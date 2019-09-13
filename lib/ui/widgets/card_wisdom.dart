import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:wisgen/models/wisdom.dart';

import '../ui_helper.dart';

/**
 * Card View That displays a given Wisdom.
 * Images are Loaded from the given URL once and then cashed.
 * Information about Fav-Status are loaded with a Consumer from the CardFeed
 */
class CardWisdom extends StatelessWidget {
  static const double _smallPadding = 4;
  static const double _largePadding = 8;
  static const double _imageHeight = 300;
  static const double _cardElevation = 2;
  static const double _cardBorderRadius = 7;


  final Wisdom wisdom;
  final VoidCallback onLike;

  CardWisdom({Key key, this.wisdom, this.onLike}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_cardBorderRadius),
      ),
      clipBehavior: Clip.antiAlias,
      elevation: _cardElevation,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _image(context),
          _content(context),
        ],
      ),
    );
  }

  Widget _image(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: wisdom.imgURL,
      fit: BoxFit.cover,
      height: _imageHeight,
      errorWidget: (context, url, error) => Container(
        child: Icon(Icons.error),
        height: _imageHeight,
      ),
      placeholder: (context, url) => Container(
          alignment: Alignment(0.0, 0.0),
          height: _imageHeight,
          child: new SpinKitCircle(
            color: Theme.of(context).accentColor,
            size: UIHelper.loadingAnimSize,
          )),
    );
  }

  Widget _content(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: _largePadding, bottom: _largePadding),
      child: Row(
        children: <Widget>[
          Expanded(
              flex: 5,
              child: ListTile(
                title: Text(wisdom.text),
                subtitle: Container(
                    padding: EdgeInsets.only(top: _smallPadding),
                    child: Text(wisdom.type + ' #' + '${wisdom.id}',
                        textAlign: TextAlign.left)),
              )),
          Expanded(
            flex: 1,
            child: IconButton(
              icon: Icon(Icons.share),
              color: Colors.grey,
              onPressed: () {
                onShare();
              },
            ),
          ),
          // Expanded(
          //   flex: 1,
          //   child: Consumer<WisdomFavList>(
          //     builder: (context, favorites, _) => IconButton(
          //       icon: Icon(favorites.contains(wisdom)
          //           ? Icons.favorite
          //           : Icons.favorite_border),
          //       color: favorites.contains(wisdom) ? Colors.red : Colors.grey,
          //       onPressed: onLike,
          //       padding: EdgeInsets.only(right: _smallPadding),
          //     ),
          //   ),
          // )
        ],
      ),
    );
  }

  void onShare() {
    String shareText =
        "Check out this peace of Wisdom I found using Wisgen 🔮:\n\n" +
            "\"" +
            wisdom.text +
            "\"\n" +
            "Related Image: " +
            wisdom.imgURL +
            "\n\n... Pretty Deep 🤔";
    Share.share(shareText);
  }
}