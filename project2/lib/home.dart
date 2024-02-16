import 'package:flutter/material.dart';

import 'package:project2/api.dart';
import 'package:project2/cart.dart';


import 'package:project2/modelclass.dart';
import 'package:project2/productdetail.dart';


class ProductHomePage extends StatefulWidget {
  @override
  _ProductHomePageState createState() => _ProductHomePageState();
}

class _ProductHomePageState extends State<ProductHomePage> {
  List<Products> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    getProducts();
  }

  Future<void> getProducts() async {
    try {
      FakeStoreApi api = FakeStoreApi();
      _products = await api.getProducts();
    } catch (e) {
      print('Error fetching products: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product Homepage'),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              print('Cart icon clicked');
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>CartPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemCount: _products.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    print('Product tapped');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetail(
                          productImage: _products[index].image ?? '',
                          productName: _products[index].title ?? '',
                          productPrice: double.parse(_products[index].price ?? '0.0'),
                          productId: _products[index].id ?? 0,
                        ),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 2.0,
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.network(
                          _products[index].image ?? '',
                          height: 80.0,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            _products[index].title ?? '',
                            style: TextStyle(
                              fontSize: 12.0,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
