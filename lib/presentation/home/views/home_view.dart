import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_wallpaper_manager/flutter_wallpaper_manager.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import '../../../app/modules/wallpaperApi.dart';
import '../controllers/home_controller.dart';
import 'package:http/http.dart' as http;

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});
  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      init: HomeController(),
      builder: (controller) {
        return Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.red, Colors.pink],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: AppBar(
                title: Text('Wallpaper Gallery',
                  style: TextStyle(color: Colors.white,fontWeight: FontWeight.w600),
                ),
                centerTitle: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                actions: [
                  IconButton(
                    icon: Icon(Icons.info_outline,color: Colors.white,),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
              itemCount: controller.wallpaperList.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
                childAspectRatio: 0.7,
              ),
              itemBuilder: (context, index) {
                Wallpaper wallpaperList = controller.wallpaperList[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WallpaperPreviewPage(
                          imageUrl: wallpaperList.path ?? '',
                        ),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: wallpaperList.path ?? '',
                        placeholder: (context, url) =>
                         Center(child: CircularProgressIndicator(
                          color: Colors.white70,
                          backgroundColor: Colors.grey,
                          strokeWidth: 2.0,
                        )),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class WallpaperPreviewPage extends StatelessWidget {
  final String imageUrl;

  const WallpaperPreviewPage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wallpaper'),
        elevation: 1.0,
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            onPressed: () {
              downloadImg(imageUrl,context);
            },
          ),
          PopupMenuButton(
            onSelected: (String option) {
              if (option == 'Set as wallpaper') {
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return Container(
                      height: 200,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(14),
                          topRight: Radius.circular(14),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () {
                              setWallpaperWithLoader(imageUrl, context, WallpaperManager.HOME_SCREEN);
                              CircularProgressIndicator();
                            },
                            child: Text("Set as wallpaper for Home Screen"),
                          ),
                          TextButton(
                            onPressed: () {
                              setWallpaperWithLoader(imageUrl, context, WallpaperManager.LOCK_SCREEN);
                            },
                            child: Text("Set as wallpaper for Lock Screen"),
                          ),
                          TextButton(
                            onPressed: () {
                              setWallpaperWithLoader(imageUrl, context, WallpaperManager.BOTH_SCREEN);
                            },
                            child: Text("Set as wallpaper for Both Screens"),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }
              if(option=='share'){
                // downloadAndShareImage(imageUrl );
                print('......................................share');
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'Set as wallpaper',
                child: Text('Set as wallpaper'),
              ),
              const PopupMenuItem<String>(
                value: 'share',
                child: Text('share'),
              ),
            ],
          ),
        ],
      ),
      body: Center(
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.fill,
          placeholder: (context, url) =>   CircularProgressIndicator(
            color: Colors.white70,
            backgroundColor: Colors.grey,
            strokeWidth: 2.0,
          ),
          errorWidget: (context, url, error) => Icon(Icons.error),
        ),
      ),
    );
  }
}

Future<void> downloadImg(String imageUrl,context,) async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.white70,
          backgroundColor: Colors.grey,
          strokeWidth: 2.0,
        ),
      );
    },
  );
  try {
    bool? gallerySaver = await GallerySaver.saveImage(imageUrl);
    if (gallerySaver == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Image downloaded successfully!"),
          backgroundColor: Colors.green,
          duration: Duration(seconds:3),
        ),
      );

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Image not download!"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );

    }
  } finally {
    Get.back();
  }
}

Future<void> setWallpaperWithLoader(String imageUrl,context, int path) async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.white70,
          backgroundColor: Colors.grey,
          strokeWidth: 2.0,
        ),
      );
    },
  );
  try {
    await setWallpaper(imageUrl, context, path);
  } finally {
    Navigator.of(context).pop();
  }
}


Future<void> setWallpaper(String imageUrl,context, int path) async {
  try {
    var response = await http.get(Uri.parse(imageUrl));

    var documentDirectory = await getApplicationDocumentsDirectory();
    File file = File('${documentDirectory.path}/wallpaper.jpg');

    await file.writeAsBytes(response.bodyBytes);

    bool result = await WallpaperManager.setWallpaperFromFile(file.path,path);

    if (result) {
      Get.snackbar("Success", "Wallpaper set successfully!",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white);
    } else { Get.snackbar("UnSuccess", "Failed to set wallpaper.",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white);
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("An error occurred while setting the wallpaper."),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }
}
