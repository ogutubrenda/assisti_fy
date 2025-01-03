import 'package:assisti_fy/voiceassist/data/models/post.dart';
import 'package:dio/dio.dart';


class ApiService {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'https://jsonplaceholder.typicode.com/'));

  Future<List<Post>> fetchPosts() async {
    final response = await _dio.get('/posts');
    final List data = response.data;
    return data.map((json) => Post.fromJson(json)).toList();
  }
}