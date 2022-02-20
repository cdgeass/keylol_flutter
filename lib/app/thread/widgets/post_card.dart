import 'package:flutter/material.dart';
import 'package:keylol_flutter/components/avatar.dart';
import 'package:keylol_flutter/app/thread/widgets/reply_modal.dart';
import 'package:keylol_flutter/api/models/post.dart';

typedef PostBuilder = Widget Function(Post post);

class PostCard extends StatelessWidget {
  final Post post;
  final PostBuilder builder;

  const PostCard({Key? key, required this.post, required this.builder})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(top: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Avatar(
              uid: post.authorId,
              size: AvatarSize.middle,
              width: 40.0,
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(post.author),
                Text('${post.number}楼'),
              ],
            ),
            subtitle: Text(post.dateline),
          ),
          builder.call(post),
          ButtonBar(
            alignment: MainAxisAlignment.start,
            children: [
              IconButton(
                  onPressed: () {
                    Navigator.of(context).push(ReplyRoute(null, post, () {}));
                  },
                  icon: Icon(Icons.reply_outlined)),
              // if (Provider.of<ProfileProvider>(context).profile?.memberUid ==
              //     post.authorId)
              //   IconButton(
              //       onPressed: () {
              //         // TODO 编辑
              //       },
              //       icon: Icon(Icons.edit)),
            ],
          )
        ],
      ),
    );
  }
}