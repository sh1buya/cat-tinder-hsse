import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cat_tinder_hsse/models/cat_model.dart';

class CatApi {
  static const _baseUrl = 'https://api.thecatapi.com/v1';
  static const _apiKey =
      'live_dPpCwLmmW4tBo9Pco8clGxW5TbOPvVITCr60g05KwxFGihYAgmDPjv5BZHacRkFe';

  Future<Cat> fetchRandomCat() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/images/search?has_breeds=1&api_key=$_apiKey'),
    );

    if (response.statusCode == 200) {
      return Cat.fromJson(json.decode(response.body)[0]);
    } else {
      throw Exception('Failed to load cat');
    }
  }
}
