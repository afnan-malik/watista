import 'package:get/get.dart';
import 'EndPoint.dart';
import 'api_provider.dart';

class Repository {
  late ApiProvider apiProvider;

  Repository() {
    apiProvider = ApiProvider();
  }

   Future wallpaper() async {
    Map<String, dynamic> data = await apiProvider.baseGetAPI(
      '${APIEndPoint.walpaperUrl}?0WqDCqeNsvPm1bouyAJjxdjZF9jFvdsK',
      true,
      Get.context,
    );
    return data;
  }
}



// Future getWeather(latitude, longitude) async {
//   Map<String, dynamic> data = await apiProvider.baseGetAPI(
//     '${APIEndPoint.weatherUrl}?lat=${latitude}&lon=${longitude}&appid=63699119457b24501b6fd5c2d6cf3bae',
//     true,
//     Get.context,
//   );
//   return data;
// }