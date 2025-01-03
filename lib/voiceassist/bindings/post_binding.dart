import 'package:assisti_fy/voiceassist/controllers/post_controller.dart';
import 'package:get/get.dart';


class PostBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PostController>(() => PostController());
  }
}