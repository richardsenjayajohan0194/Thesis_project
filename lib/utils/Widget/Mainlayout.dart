import 'package:flutter/material.dart';

class MainLayout extends StatefulWidget {
  final Widget child;
  const MainLayout({
    super.key,
    required this.child
    });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color(0xFFC0C78C),
        child: SafeArea(
          bottom: false,
          child: widget.child,
        ),
      ),
    );
  }
}