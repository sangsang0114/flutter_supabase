import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_supabase/board/view/board_view.dart';

class RootTab extends StatefulWidget {
  @override
  _RootTabState createState() => _RootTabState();
}

class _RootTabState extends State<RootTab> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    BoardView(),
    Container(), // Placeholder for the floating action button
    Container(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tabs[_currentIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Container()),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: CurvedNavigationBar(
        index: _currentIndex,
        height: 60.0,
        items: <Widget>[
          Icon(Icons.list, size: 30, color: Colors.white),
          Icon(Icons.add, size: 30, color: Colors.white),
          Icon(Icons.person, size: 30, color: Colors.white),
        ],
        color: Theme.of(context).primaryColor,
        buttonBackgroundColor: Theme.of(context).primaryColor,
        backgroundColor: Colors.white,
        animationCurve: Curves.easeInOut,
        animationDuration: Duration(milliseconds: 600),
        onTap: (index) {
          setState(() {
            if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Container()),
              );
            } else {
              _currentIndex = index;
            }
          });
        },
        letIndexChange: (index) => true,
      ),
    );
  }
}
