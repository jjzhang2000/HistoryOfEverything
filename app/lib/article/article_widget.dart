// import 'package:flare_flutter/flare_actor.dart';  // TODO: Reimplement with Rive
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:timeline/animation/animation_exports.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:timeline/article/timeline_entry_widget.dart';
import 'package:timeline/bloc_provider.dart';
import 'package:timeline/colors.dart';
import 'package:timeline/timeline/timeline_entry.dart';

/// This widget will paint the article page.
/// It stores a reference to the [TimelineEntry] that contains the relevant information.
class ArticleWidget extends StatefulWidget {
  final TimelineEntry article;
  const ArticleWidget({required this.article, super.key});

  @override
  State<ArticleWidget> createState() => _ArticleWidgetState();
}

/// The [State] for the [ArticleWidget] will change based on the [article]
/// parameter that's used to build it.
/// It is stateful because we rely on some information like the title, subtitle, and the article
/// contents to change when a new article is displayed. Moreover the [FlareWidget]s that are used 
/// on this page (i.e. the top [TimelineEntryWidget] the favorite button) rely on life-cycle parameters.
class _ArticleWidgetState extends State<ArticleWidget> {
  /// The information for the current page.
  String _articleMarkdown = "";
  String _title = "";
  String _subTitle = "";
  /// This page uses the `flutter_markdown` package, and thus needs its styles to be defined
  /// with a custom objects. This is created in [initState()].
  MarkdownStyleSheet? _markdownStyleSheet;

  /// Whether the [FlareActor] favorite button is active or not. 
  /// Triggers a Flare animation upon change.
  bool _isFavorite = false;
  
  /// Error state for markdown loading
  bool _loadError = false;
  String _errorMessage = "";

  /// This parameter helps control the Amelia Earhart and the Newton animations.
  /// Test it out yourself! =)
  Offset? _interactOffset;

  /// Set up the markdown style and the local field variables for this page.
  @override
  initState() {
    super.initState();

    TextStyle style = TextStyle(
        color: darkText.withValues(alpha: darkText.a * 0.68),
        fontSize: 17.0,
        height: 1.5,
        fontFamily: "Roboto");
    TextStyle h1 = TextStyle(
        color: darkText.withValues(alpha: darkText.a * 0.68),
        fontSize: 32.0,
        height: 1.625,
        fontFamily: "Roboto",
        fontWeight: FontWeight.bold);
    TextStyle h2 = TextStyle(
        color: darkText.withValues(alpha: darkText.a * 0.68),
        fontSize: 24.0,
        height: 2,
        fontFamily: "Roboto",
        fontWeight: FontWeight.bold);
    TextStyle strong = TextStyle(
        color: darkText.withValues(alpha: darkText.a * 0.68),
        fontSize: 17.0,
        height: 1.5,
        fontFamily: "RobotoMedium");
    TextStyle em = TextStyle(
        color: darkText.withValues(alpha: darkText.a * 0.68),
        fontSize: 17.0,
        height: 1.5,
        fontFamily: "Roboto",
        fontStyle: FontStyle.italic);
    _markdownStyleSheet = MarkdownStyleSheet(
      a: style,
      p: style,
      code: style,
      h1: h1,
      h2: h2,
      h3: style,
      h4: style,
      h5: style,
      h6: style,
      em: em,
      strong: strong,
      blockquote: style,
      img: style,
      blockSpacing: 20.0,
      listIndent: 20.0,
      blockquotePadding: const EdgeInsets.all(20.0),
    );
    setState(() {
      _title = widget.article.label;
      _subTitle = widget.article.formatYearsAgo();
      _articleMarkdown = "";
      if (widget.article.articleFilename != null) {
        loadMarkdown(widget.article.articleFilename!);
      }
    });
  }

  /// Load the markdown file from the assets and set the contents of the page to its value.
  /// Handles errors gracefully by showing an error message to the user.
  Future<void> loadMarkdown(String filename) async {
    try {
      final data = await rootBundle.loadString("assets/Articles/$filename");
      if (mounted) {
        setState(() {
          _articleMarkdown = data;
          _loadError = false;
          _errorMessage = "";
        });
      }
    } catch (error) {
      debugPrint('Error loading article "$filename": $error');
      if (mounted) {
        setState(() {
          _loadError = true;
          _errorMessage = 'Failed to load article content';
          _articleMarkdown = "";
        });
      }
    }
  }

  /// This widget is wrapped in a [Scaffold] to have the classic Material Design visual layout structure.
  /// It uses the [BlocProvider] to find out if this element is part of the favorites, to have the icon properly set up.
  /// A [SingleChildScrollView] contains a [Column] that lays out the [TimelineEntryWidget] on top, and the [MarkdownBody] 
  /// right below it. 
  /// A [GestureDetector] is used to control the [TimelineEntryWidget], if it allows it (...try Amelia Earhart or Newton!)
  @override
  Widget build(BuildContext context) {
    EdgeInsets devicePadding = MediaQuery.of(context).padding;
    List<TimelineEntry> favs = BlocProvider.favorites(context)?.favorites ?? [];
    bool isFav = favs.any(
        (TimelineEntry te) => te.label.toLowerCase() == _title.toLowerCase());
    return Scaffold(
        body: Container(
            color: const Color.fromRGBO(255, 255, 255, 1),
            child: Stack(children: <Widget>[
              Column(children: <Widget>[
                Container(height: devicePadding.top),
                SizedBox(
                    height: 56.0,
                    width: double.infinity,
                    child: IconButton(
                      alignment: Alignment.centerLeft,
                      icon: const Icon(Icons.arrow_back),
                      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                      color: Colors.black.withValues(alpha: 0.5),
                      onPressed: () {
                        Navigator.pop(context, true);
                      },
                    )),
                Expanded(
                    child: SingleChildScrollView(
                        padding:
                            const EdgeInsets.only(left: 20, right: 20, bottom: 30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            GestureDetector(
                                onPanStart: (DragStartDetails details) {
                                  setState(() {
                                    _interactOffset = details.globalPosition;
                                  });
                                },
                                onPanUpdate: (DragUpdateDetails details) {
                                  setState(() {
                                    _interactOffset = details.globalPosition;
                                  });
                                },
                                onPanEnd: (DragEndDetails details) {
                                  setState(() {
                                    _interactOffset = null;
                                  });
                                },
                                child: SizedBox(
                                    height: 280,
                                    child: TimelineEntryWidget(
                                        isActive: true,
                                        timelineEntry: widget.article,
                                        interactOffset: _interactOffset))),
                            Padding(
                              padding: const EdgeInsets.only(top: 30.0),
                              child: Row(children: [
                                Expanded(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(_title,
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                              color: darkText.withValues(
                                                  alpha: darkText.a * 0.87),
                                              fontSize: 25.0,
                                              height: 1.1,
                                              fontFamily: "Roboto",
                                            )),
                                        Text(_subTitle,
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                                color: darkText.withValues(
                                                    alpha: darkText.a * 0.5),
                                                fontSize: 17.0,
                                                height: 1.5,
                                                fontFamily: "Roboto"))
                                      ]),
                                ),
                                AnimatedFavoriteButton(
                                  isFavorite: isFav,
                                  color: Colors.red,
                                  onTap: () {
                                    setState(() {
                                      _isFavorite = !_isFavorite;
                                    });
                                    if (_isFavorite) {
                                      BlocProvider.favorites(context)
                                          ?.addFavorite(widget.article);
                                    } else {
                                      BlocProvider.favorites(context)
                                          ?.removeFavorite(widget.article);
                                    }
                                  },
                                )
                              ]),
                            ),
                            Container(
                                margin: const EdgeInsets.only(top: 20, bottom: 20),
                                height: 1,
                                color: Colors.black.withValues(alpha: 0.11)),
                            // Show error message or markdown content
                            if (_loadError)
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.red.shade200),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.error_outline, color: Colors.red.shade400),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Unable to load article',
                                            style: TextStyle(
                                              color: Colors.red.shade700,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _errorMessage,
                                            style: TextStyle(
                                              color: Colors.red.shade600,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else if (_articleMarkdown.isEmpty)
                              const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(20),
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            else
                              MarkdownBody(
                                  data: _articleMarkdown,
                                  styleSheet: _markdownStyleSheet!),
                            const SizedBox(height: 100),
                          ],
                        )))
              ])
            ])));
  }
}
