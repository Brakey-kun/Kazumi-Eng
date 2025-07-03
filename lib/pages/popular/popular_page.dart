import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:kazumi/bean/dialog/dialog_helper.dart';
import 'package:kazumi/bean/widget/error_widget.dart';
import 'package:kazumi/pages/popular/popular_controller.dart';
import 'package:kazumi/bean/card/bangumi_card.dart';
import 'package:kazumi/utils/constants.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';
import 'package:kazumi/bean/appbar/sys_app_bar.dart';
import 'package:logger/logger.dart';
import 'package:kazumi/utils/logger.dart';
import 'package:kazumi/bean/widget/scrollable_wrapper.dart';
import 'package:kazumi/pages/menu/menu.dart';
import 'package:provider/provider.dart';

class PopularPage extends StatefulWidget {
  const PopularPage({super.key});

  @override
  State<PopularPage> createState() => _PopularPageState();
}

class _PopularPageState extends State<PopularPage>
    with AutomaticKeepAliveClientMixin {
  DateTime? _lastPressedAt;
  bool showTagFilter = true;
  late NavigationBarState navigationBarState;
  final FocusNode _focusNode = FocusNode();
  final ScrollController scrollController = ScrollController();
  final PopularController popularController = Modular.get<PopularController>();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(scrollListener);
    if (popularController.trendList.isEmpty) {
      popularController.queryBangumiByTrend();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    navigationBarState = Provider.of<NavigationBarState>(context, listen: true);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    scrollController.removeListener(scrollListener);
    super.dispose();
  }

  void scrollListener() {
    popularController.scrollOffset = scrollController.offset;
    if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200 &&
        !popularController.isLoadingMore) {
      KazumiLogger().log(Level.info, 'Popular is loading more');
      if (popularController.currentTag != '') {
        popularController.queryBangumiByTag();
      } else {
        popularController.queryBangumiByTrend();
      }
    }
  }

  void onBackPressed(BuildContext context) {
    if (_lastPressedAt == null ||
        DateTime.now().difference(_lastPressedAt!) >
            const Duration(seconds: 2)) {
      // The interval between two clicks exceeds 2 seconds, record the timestamp again
      _lastPressedAt = DateTime.now();
      KazumiDialog.showToast(message: "Press again to exit the app", context: context);
      return;
    }
    SystemNavigator.pop(); // Exit the app
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return OrientationBuilder(builder: (context, orientation) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, Object? result) {
          if (didPop) {
            return;
          }
          onBackPressed(context);
        },
        child: Scaffold(
          appBar: SysAppBar(
            needTopOffset: false,
            // default 56 + 10
            leadingWidth: 66,
            leading: (navigationBarState.isBottom)
                ? Row(
                    children: [
                      const SizedBox(
                        width: 10,
                      ),
                      ClipOval(
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () {
                            Modular.to.pushNamed('/settings/history');
                          },
                          child: Image.asset(
                            'assets/images/logo/logo_android.png',
                          ),
                        ),
                      )
                    ],
                  )
                : null,
            backgroundColor: Colors.transparent,
            actions: [
              IconButton(
                  onPressed: () {
                    Modular.to.pushNamed('/search/');
                  },
                  icon: const Icon(Icons.search))
            ],
            title: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onPanStart: (_) => windowManager.startDragging(),
              child: Container(),
            ),
          ),
          body: Column(
            children: [
              SizedBox(
                height: showTagFilter ? 50 : 0,
                child: tagFilter(),
              ),
              Expanded(
                child: CustomScrollView(
                  controller: scrollController,
                  slivers: [
                    SliverToBoxAdapter(
                      child: Observer(
                        builder: (_) => Padding(
                          padding: const EdgeInsets.only(
                              top: 0, bottom: 10, left: 0),
                          child: popularController.isLoadingMore
                              ? const LinearProgressIndicator()
                              : const SizedBox(
                                  height: 4.0,
                                ),
                        ),
                      ),
                    ),
                    SliverPadding(
                        padding: const EdgeInsets.fromLTRB(
                            StyleString.cardSpace, 0, StyleString.cardSpace, 0),
                        sliver: Observer(builder: (_) {
                          if (popularController.isTimeOut) {
                            return SliverToBoxAdapter(
                              child: SizedBox(
                                height: 400,
                                child: GeneralErrorWidget(
                                  errMsg: 'Nothing found (´;ω;`)',
                                  actions: [
                                    GeneralErrorButton(
                                      onPressed: () {
                                        if (popularController
                                            .trendList.isEmpty) {
                                          popularController
                                              .queryBangumiByTrend();
                                        } else {
                                          popularController.queryBangumiByTag();
                                        }
                                      },
                                      text: 'Click to retry',
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                          return contentGrid(
                              (popularController.currentTag == '')
                                  ? popularController.trendList
                                  : popularController.bangumiList,
                              orientation);
                        })),
                  ],
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              scrollController.jumpTo(0.0);
            },
            child: const Icon(Icons.arrow_upward),
          ),
          // backgroundColor: themedata.colorScheme.primaryContainer,
        ),
      );
    });
  }

  Widget contentGrid(bangumiList, Orientation orientation) {
    int crossCount = orientation != Orientation.portrait ? 6 : 3;
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        // Row spacing
        mainAxisSpacing: StyleString.cardSpace - 2,
        // Column spacing
        crossAxisSpacing: StyleString.cardSpace,
        // Number of columns
        crossAxisCount: crossCount,
        mainAxisExtent: MediaQuery.of(context).size.width / crossCount / 0.65 +
            MediaQuery.textScalerOf(context).scale(32.0),
      ),
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          return bangumiList!.isNotEmpty
              ? BangumiCardV(bangumiItem: bangumiList[index])
              : null;
        },
        childCount: bangumiList!.isNotEmpty ? bangumiList!.length : 10,
      ),
    );
  }

  Widget tagFilter() {
    List<String> tags = [
      'Daily',
      'Original',
      'Campus',
      'Comedy',
      'Fantasy',
      'Yuri',
      'Romance',
      'Suspense',
      'Hot-blooded',
      'Harem',
      'Mecha',
      'Light adaptation',
      'Idol',
      'Healing',
      'Isekai',
    ];

    final ScrollController tagScrollController = ScrollController();

    return Row(
      children: <Widget>[
        Expanded(
          child: ScrollableWrapper(
            scrollController: tagScrollController,
            child: ListView.builder(
              controller: tagScrollController,
              scrollDirection: Axis.horizontal,
              itemCount: tags.length,
              itemBuilder: (context, index) {
                final filter = tags[index];
                return Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 8, left: 8),
                  child: Observer(
                    builder: (_) => filter == popularController.currentTag
                        ? FilledButton(
                            child: Text(filter),
                            onPressed: () async {
                              scrollController.jumpTo(0.0);
                              popularController.setCurrentTag('');
                              popularController.clearBangumiList();
                            },
                          )
                        : FilledButton.tonal(
                            child: Text(filter),
                            onPressed: () async {
                              _focusNode.unfocus();
                              scrollController.jumpTo(0.0);
                              popularController.setCurrentTag(filter);
                              await popularController.queryBangumiByTag(
                                  type: 'init');
                            },
                          ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
