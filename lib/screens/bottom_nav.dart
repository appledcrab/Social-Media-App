import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:social_media_app/screens/user_profile_screen.dart';

// Possible way to implement a bottom navigation bar
//I dont know too much about it, need to have the same number of screens as the number of items in the bottom nav bar
//There is a way to have it go to a screen without the navbar, need to check the documentation
// https://pub.dev/packages/persistent_bottom_nav_bar

class BottomNav extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    PersistentTabController _controller =
        PersistentTabController(initialIndex: 0);

    List<Widget> _buildScreens() {
      return [
        // Adding the screens here
        Scaffold(
          appBar: AppBar(title: Text('Home Feed')),
          body: Center(child: Text('Screen 1')),
          // Add the homecreen to the body when its made
        ),
        Scaffold(
          appBar: AppBar(title: Text('Settings')),
          body: Center(child: Text('Screen 2')),
          // Add the Settings... or could try explore to the body when its made
        ),
        Scaffold(
          appBar: AppBar(title: Text('Screen 3')),
          body: Center(child: Text('Screen 3')),
          // Add the Adding post to the body when its made
        ),
        Scaffold(
          appBar: AppBar(title: Text('Screen 4')),
          body: Center(child: Text('Screen 4')),
          // Add the messages screen to the body when its made
        ),
        Scaffold(
          appBar: AppBar(title: Text('Your Profile')),
          body: ProfileScreen(
            username: 'JohnDoe',
            profileImageUrl: 'assets/test.jpg',
            // would want to change it to probably only giving the user id by firebase
            //but this was just an initial test to see if it would work.
          ),
        ),
      ];
    }

    List<PersistentBottomNavBarItem> _navBarsItems() {
      return [
        PersistentBottomNavBarItem(
          icon: Icon(Icons.home),
          title: 'Home',
          activeColorPrimary: Colors.deepOrange,
          inactiveColorPrimary: Colors.grey,
        ),
        PersistentBottomNavBarItem(
          icon: Icon(Icons.settings),
          title: 'Search',
          activeColorPrimary: const Color.fromARGB(255, 233, 33, 243),
          inactiveColorPrimary: Colors.grey,
        ),
        PersistentBottomNavBarItem(
          icon: const Icon(Icons.add),
          title: "Add",
          activeColorPrimary: Color.fromARGB(255, 19, 141, 47),
          inactiveColorPrimary: Color.fromARGB(255, 50, 75, 59),
        ),
        PersistentBottomNavBarItem(
          icon: const Icon(Icons.message),
          title: "Chats",
          activeColorPrimary: Colors.blue,
          inactiveColorPrimary: Colors.grey,
        ),
        PersistentBottomNavBarItem(
          icon: const Icon(Icons.person),
          title: "Profile",
          activeColorPrimary: const Color.fromARGB(255, 150, 0, 0),
          inactiveColorPrimary: Colors.grey,
        ),

        // Add more items as needed
      ];
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Social Media App'),
      ),
      body: PersistentTabView(
        context,
        controller: _controller,
        screens: _buildScreens(),
        items: _navBarsItems(),
        confineInSafeArea: true,
        backgroundColor: Color.fromARGB(255, 213, 233, 242),
        handleAndroidBackButtonPress: true,
        resizeToAvoidBottomInset: true,
        stateManagement: true,
        hideNavigationBarWhenKeyboardShows: true,
        decoration: NavBarDecoration(
          // borderRadius: BorderRadius.circular(10.0),
          colorBehindNavBar: Colors.white,
        ),
        popAllScreensOnTapOfSelectedTab: true,
        popActionScreens: PopActionScreensType.all,
        itemAnimationProperties: ItemAnimationProperties(
          duration: Duration(milliseconds: 200),
          curve: Curves.ease,
        ),
        screenTransitionAnimation: ScreenTransitionAnimation(
          animateTabTransition: true,
          curve: Curves.ease,
          duration: Duration(milliseconds: 200),
        ),
        navBarStyle: NavBarStyle.style4,
      ),
    );
  }
}
