import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/wallpaper_adjust_controller.dart';

class WallpaperAdjustView extends GetView<WallpaperAdjustController> {
  const WallpaperAdjustView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WallpaperAdjustView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'WallpaperAdjustView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
