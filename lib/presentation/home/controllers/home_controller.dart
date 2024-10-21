import 'package:get/get.dart';

import '../../../app/data/reposeteries.dart';
import '../../../app/modules/wallpaperApi.dart';

class HomeController extends GetxController {
  var isLoading = false.obs;
  bool isSearch = false;
  double downloadPercentage = 0;
  bool isDownloading = false;
  Repository repository = Repository();
  Wallpaper? wallpaper;
  List<Wallpaper> wallpaperList = [];

  @override
  void onInit() {
    super.onInit();
    getWallpaper();
  }
  Future<void> getWallpaper() async {
    isLoading.value = true;

    Map<String, dynamic>? resp;
    try {
      resp = await repository.wallpaper();
      if (resp != null && resp.isNotEmpty) {
        print(
            '.....wallpaper........................................Response: $resp');
        wallpaperList =
            resp['data'].map<Wallpaper>((e) => Wallpaper.fromJson(e)).toList();
        // wallpaper = Wallpaper.fromJson(resp);
        print('.............................................Response: $resp');
      } else {
        Get.snackbar('Error', 'Something went wrong');
      }
    } catch (e) {
      print(e);
      Get.snackbar('Error', 'An exception occurred');
    } finally {
      isLoading.value = false;
    }
    update();
  }


  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }


}
