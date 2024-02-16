import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project2/cart.dart';

class ProductDetail extends StatelessWidget {
  final int? productId;
  final String? productImage;
  final String? productName;
  final double? productPrice;

  ProductDetail({
    required this.productImage,
    required this.productId,
    required this.productName,
    required this.productPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        color: Colors.grey[900],
        margin: EdgeInsets.only(top: 50.0, left: 20.0, right: 20.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Image.network(
                productImage!,
                height: 250,
              ),
              SizedBox(height: 20),
              Text(
                'Product Details',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              SizedBox(height: 10),
              Text(
                ' $productName',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal, color: Colors.white),
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '\$${productPrice!.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  var userId = FirebaseAuth.instance.currentUser?.uid;

                  if (userId != null) {
                    var cartItemRef = await FirebaseFirestore.instance
                        .collection('carts')
                        .where('userId', isEqualTo: userId)
                        .where('productId', isEqualTo: productId)
                        .get();

                    if (cartItemRef.docs.isNotEmpty) {
                      var cartItemId = cartItemRef.docs.first.id;
                      var currentQuantity = cartItemRef.docs.first['quantity'];
                      await FirebaseFirestore.instance
                          .collection('carts')
                          .doc(cartItemId)
                          .update({'quantity': currentQuantity + 1});
                    } else {
                      await FirebaseFirestore.instance
                          .collection('carts')
                          .add({
                        'userId': userId,
                        'productId': productId,
                        'productImage': productImage,
                        'productName': productName,
                        'quantity': 1,
                        'price': productPrice,
                      });
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.orangeAccent,
                        content: Text('Product added to the cart'),
                      ),
                    );

                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CartPage()), 
                    );
                  }
                },
                child: Row(
                  children: [
                    Icon(Icons.shopping_cart),
                    SizedBox(width: 5),
                    Text(
                      'Add to Cart',
                      style: TextStyle(color: Colors.black, fontSize: 16.1),
                    ),
                  ],
                ),
                style: ElevatedButton.styleFrom(
                  primary: Colors.yellow,
                  onPrimary: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
