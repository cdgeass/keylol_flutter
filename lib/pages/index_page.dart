import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:keylol_flutter/common/keylol_client.dart';
import 'package:keylol_flutter/components/avatar.dart';
import 'package:keylol_flutter/components/sliver_tab_bar_delegate.dart';
import 'package:keylol_flutter/components/thread_card.dart';
import 'package:keylol_flutter/components/user_account_drawer.dart';
import 'package:keylol_flutter/models/index.dart';
import 'package:keylol_flutter/pages/thread_author.dart';

// 聚焦
class IndexPage extends StatefulWidget {
  const IndexPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  late Future<Index> _future;

  @override
  void initState() {
    super.initState();

    _onRefresh();
  }

  Future<void> _onRefresh() async {
    final index = KeylolClient().fetchIndex();
    setState(() {
      _future = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        notificationPredicate: (notification) {
          if (notification is OverscrollNotification || Platform.isIOS) {
            return notification.depth == 2;
          }
          return notification.depth == 0;
        },
        onRefresh: _onRefresh,
        child: FutureBuilder(
          future: _future,
          builder: (context, AsyncSnapshot<Index> snapshot) {
            late Widget body;
            if (snapshot.hasData) {
              var index = snapshot.data!;
              body = _buildTabPage(index);
            } else {
              body = Center(
                child: CircularProgressIndicator(),
              );
            }
            return Scaffold(
                backgroundColor: Theme.of(context).backgroundColor,
                drawer: UserAccountDrawer(),
                body: body);
          },
        ));
  }

  // 轮播图
  Widget _buildSlidView(Index index) {
    return CarouselSlider(
      options: CarouselOptions(
        height: 300.0,
        enableInfiniteScroll: true,
        viewportFraction: 1.0,
        autoPlay: true,
      ),
      items: index.slideViewItems
          .map((slideViewItem) => _SlideViewItem(slideViewItem: slideViewItem))
          .toList(),
    );
  }

  // tabBar带轮播图
  Widget _buildTabPage(Index index) {
    // 轮播图
    final slideView = _buildSlidView(index);

    // tabBar
    final tabs =
        index.tabThreadsMap.keys.map((key) => Tab(text: key.name)).toList();
    final tabChildren = index.tabThreadsMap.keys.map((key) {
      final threads = index.tabThreadsMap[key]!;
      return ListView.builder(
        padding: EdgeInsets.zero,
        addAutomaticKeepAlives: true,
        addRepaintBoundaries: true,
        itemCount: threads.length,
        itemBuilder: (context, index) {
          return _ThreadItem(thread: threads[index]);
        },
      );
    }).toList();

    return DefaultTabController(
        length: tabs.length,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                leading: buildAppBarLeading(),
                expandedHeight: 275.0,
                flexibleSpace: slideView,
              ),
              SliverPersistentHeader(
                  delegate: SliverTabBarDelegate(TabBar(
                tabs: tabs,
                isScrollable: true,
                labelColor: Theme.of(context).tabBarTheme.labelColor,
                unselectedLabelColor:
                    Theme.of(context).tabBarTheme.unselectedLabelColor,
              )))
            ];
          },
          body: TabBarView(
            children: tabChildren,
          ),
        ));
  }
}

// 轮播图 item
class _SlideViewItem extends StatelessWidget {
  final IndexSlideViewItem slideViewItem;

  const _SlideViewItem({Key? key, required this.slideViewItem})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 图片
    final img = Material(
      child: Container(
        child: FadeInImage(
          image: CachedNetworkImageProvider(slideViewItem.img),
          placeholder: AssetImage("images/slide_view_placeholder.jpg"),
          fit: BoxFit.cover,
        ),
      ),
    );

    // 页脚
    final footer = Material(
      clipBehavior: Clip.antiAlias,
      color: Colors.transparent,
      child: GridTileBar(
        backgroundColor: Colors.black45,
        title: Text(
          slideViewItem.title,
          softWrap: true,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );

    return Container(
      child: InkWell(
        onTap: () {
          // 跳转到帖子页面
          Navigator.of(context)
              .pushNamed("/thread", arguments: slideViewItem.tid);
        },
        child: GridTile(
          footer: footer,
          child: img,
        ),
      ),
    );
  }
}

// 帖子 item
class _ThreadItem extends StatelessWidget {
  final IndexTabThreadItem thread;

  const _ThreadItem({Key? key, required this.thread}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IndexThreadCard(
        tid: thread.tid,
        title: thread.title,
        dateline: thread.dateline,
        authorId: thread.memberUid,
        author: thread.memberUsername);
  }
}
