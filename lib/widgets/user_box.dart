import 'package:flutter/material.dart';
import 'package:social_media_app/screens/user_profile_screen.dart';
import 'package:social_media_app/widgets/text_styles.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';

Widget buildUserTile(Map<String, dynamic> userData, BuildContext context) {
  var bio =
      userData['metadata']['bio'] as String?; // Cast to String? for safety

  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(userData['imageUrl'] ?? ''),
        ),
        title: Text(userData['firstName'] ?? '', style: biggerTextStyle()),
        subtitle: Text(bio != null
            ? '${bio.substring(0, bio.length < 30 ? bio.length : 30)}...'
            : 'No bio available'),
        onTap: () {
          PersistentNavBarNavigator.pushNewScreen(
            context,
            screen: ProfileScreen(userID: userData['uid']),
            withNavBar: false, // OPTIONAL VALUE. True by default.
            pageTransitionAnimation: PageTransitionAnimation.cupertino,
          );
        },
      ),
    ),
  );
}
