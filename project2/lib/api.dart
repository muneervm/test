import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:project2/modelclass.dart';

class FakeStoreApi {
  final String baseUrl = "https://fakestoreapi.com/products";

  Future<List<Products>> getProducts() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      List<Products> products = jsonResponse
          .map((data) => Products.fromJson(data))
          .toList();

      return products;
    } else {
      throw Exception('Failed to load products');
    }
  }
}
