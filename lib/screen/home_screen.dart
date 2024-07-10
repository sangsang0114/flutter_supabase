import 'package:flutter/material.dart';
import 'package:flutter_supabase/common/component/root_tab.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: RootTab(),
      ),
    );
  }
}
