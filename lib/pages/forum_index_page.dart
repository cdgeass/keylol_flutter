import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:keylol_flutter/common/keylol_client.dart';
import 'package:keylol_flutter/components/throwable_future_builder.dart';
import 'package:keylol_flutter/components/user_account_drawer.dart';
import 'package:keylol_flutter/models/cat.dart';

class ForumIndexPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ForumIndexPageState();
}

class ForumIndexPageState extends State<ForumIndexPage> {
  var _selectedIndex = 0;
  late Future<List<Cat>> _future;

  @override
  void initState() {
    super.initState();

    _future = KeylolClient().fetchForumIndex();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: buildAppBarLeading(),
        title: Text('版块'),
        centerTitle: true,
      ),
      drawer: UserAccountDrawer(),
      body: ThrowableFutureBuilder(
        future: _future,
        builder: (context, List<Cat> cats) {
          return Row(
            children: [
              NavigationRail(
                destinations: [
                  for (final cat in cats)
                    NavigationRailDestination(
                      icon: SizedBox.shrink(),
                      label: Text(cat.name),
                    )
                ],
                labelType: NavigationRailLabelType.all,
                selectedIndex: _selectedIndex,
                onDestinationSelected: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
              ),
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 8.0, 0.0, 0.0),
                child: MediaQuery.removePadding(
                    removeTop: true,
                    context: context,
                    child: ListView(
                      children: [
                        for (final forum in cats[_selectedIndex].forums)
                          InkWell(
                            child: ListTile(
                              leading: forum.icon == null
                                  ? ClipOval(
                                      child: Image.asset(
                                        'images/forum.gif',
                                        width: 40.0,
                                      ),
                                    )
                                  : CachedNetworkImage(
                                      imageUrl: forum.icon!,
                                      width: 40.0,
                                    ),
                              title: Text(forum.name),
                              subtitle: forum.description == null
                                  ? null
                                  : Text(forum.description!),
                            ),
                            onTap: () {
                              Navigator.of(context)
                                  .pushNamed('/forum', arguments: forum.fid);
                            },
                          )
                      ],
                    )),
              ))
            ],
          );
        },
      ),
    );
  }
}
