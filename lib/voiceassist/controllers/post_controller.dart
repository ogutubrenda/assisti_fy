import 'package:assisti_fy/voiceassist/data/models/post.dart';
import 'package:assisti_fy/voiceassist/data/services/api_service.dart';
import 'package:get/get.dart';


class PostController extends GetxController {
  final ApiService _apiService = ApiService();
  var posts = <Post>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPosts();
  }

  void fetchPosts() async {
    try {
      isLoading(true);
      posts.value = await _apiService.fetchPosts();
      print(posts.value);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load posts');
    } finally
      {
      isLoading(false);
    }
  }
}