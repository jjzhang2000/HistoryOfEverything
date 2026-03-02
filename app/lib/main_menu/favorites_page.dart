// TODO: Replace with Rive or other animation library
// import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:timeline/bloc_provider.dart';
import 'package:timeline/colors.dart';
import 'package:timeline/main_menu/menu_data.dart';
import 'package:timeline/main_menu/thumbnail_detail_widget.dart';
import 'package:timeline/timeline/timeline_entry.dart';
import 'package:timeline/timeline/timeline_widget.dart';
import 'package:timeline/l10n/app_localizations.dart';

/// This widget is displayed when tapping on the Favorites button in the [MainMenuWidget].
/// 
/// It displays the list of favorites kept by the [BlocProvider], and moves into the timeline
/// when tapping on one of them.
/// 
/// To add any item as favorite, go to the [ArticleWidget] and tap on the heart button.
class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  
  /// This widget displays a [ListView] for all the elements in the favorites.
  @override
  Widget build(BuildContext context) {

    /// Access the favorites list from the [BlocProvider], which is available as a root
    /// element of the app.
    List<TimelineEntry> entries = BlocProvider.favorites(context)?.favorites ?? [];

    /// Add all the elements into a [List<Widget>] so that we can pass it to the [ListView] in the [Scaffold] body.
    Widget buildItem(int index) {
      TimelineEntry entry = entries[index];
      return ThumbnailDetailWidget(entry, hasDivider: index != 0,
          tapSearchResult: (TimelineEntry entry) {
        MenuItemData item = MenuItemData.fromEntry(entry);
        Navigator.of(context).push(MaterialPageRoute(
            builder: (BuildContext context) =>
                TimelineWidget(item, BlocProvider.getTimeline(context)!)));
      });
    }

    /// Use the same style for the top bar, with the usual colors and the correct icons.
    /// By pressing the back arrow, [Navigator.pop()] smoothly closes this view and returns 
    /// the app back to the [MainMenuWidget].
    /// If no entry has been added to the favorites yet, a placeholder [Column] is shown with a 
    /// a few lines of text and a [FlareActor] animation of a broken heart.
    /// Check it out at: https://www.2dimensions.com/a/pollux/files/flare/broken-heart/preview
    return Scaffold(
        appBar: AppBar(
          backgroundColor: lightGrey,
          iconTheme: IconThemeData(
            color: Colors.black.withValues(alpha: 0.54),
          ),
          elevation: 0.0,
          centerTitle: false,
          leading: IconButton(
            alignment: Alignment.centerLeft,
            icon: const Icon(Icons.arrow_back),
            padding: const EdgeInsets.only(left: 20.0, right: 20.0),
            color: Colors.black.withValues(alpha: 0.5),
            onPressed: () {
              Navigator.pop(context, true);
            },
          ),
          titleSpacing:
              9.0, /// Note that the icon has 20 on the right due to its padding, so we add 10 to get our desired 29
          title: Text(AppLocalizations.of(context)?.yourFavorites ?? "Your Favorites",
              style: TextStyle(
                  fontFamily: "RobotoMedium",
                  fontSize: 20.0,
                  color: darkText.withValues(alpha: darkText.a * 0.75))),
        ),
        body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: entries.isEmpty
                ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Container(
                              width: 128.0,
                              height: 114.0,
                              margin: const EdgeInsets.only(bottom: 30),
                              // TODO: Replace with Rive or other animation widget
                            // child: FlareActor("assets/Broken Heart.flr",
                            //       animation: "Heart Break", shouldClip: false)
                            child: const Icon(
                              Icons.heart_broken,
                              size: 64.0,
                              color: Colors.grey,
                            )),
                          Container(
                            padding: const EdgeInsets.only(bottom: 21),
                            width: 250,
                            child: Text(AppLocalizations.of(context)?.noFavoritesYet ?? "You haven't favorited anything yet.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: "RobotoMedium",
                                  fontSize: 25,
                                  color: darkText
                                      .withValues(alpha: darkText.a * 0.75),
                                  height: 1.2,
                                )),
                          ),
                          Container(
                            width: 270,
                            margin: const EdgeInsets.only(bottom: 114),
                            child: Text(
                                "Browse to an event in the timeline and tap on the heart icon to save something in this list.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontFamily: "Roboto",
                                    fontSize: 17,
                                    height: 1.5,
                                    color: Colors.black.withValues(alpha: 0.75))),
                          ),
                        ])
                  ])
                : ListView.builder(
                    itemCount: entries.length,
                    itemBuilder: (context, index) => buildItem(index),
                  )));
  }
}