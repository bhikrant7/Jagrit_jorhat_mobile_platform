import 'package:flutter/material.dart';

class CustomBgScaffold extends StatelessWidget {
  const CustomBgScaffold({super.key, this.child});
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // This is important
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: true,
      ),
      body: Stack(
        children: [
          Image.asset(
            'assets/bgmain.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          SafeArea(
            child: Padding(padding: const EdgeInsets.all(16.0), child: child!),
          ),
        ],
      ),
    );
  }
}
