import 'package:get/get.dart';

import '../controllers/wallpaper_adjust_controller.dart';

class WallpaperAdjustBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WallpaperAdjustController>(
      () => WallpaperAdjustController(),
    );
  }
}
