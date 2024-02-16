import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 133, 113, 113),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 232, 231, 231),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Your Cart'),
      ),
      body: StreamBuilder(
        stream: _fetchCartItemsStream(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          var cartItems = snapshot.data?.docs ?? [];

          if (cartItems.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart, size: 40, color: Colors.white),
                  Text('No items in the cart', style: TextStyle(fontSize: 20, color: Colors.white)),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    var cartItem = cartItems[index].data() as Map<String, dynamic>;

                    return CartItemWidget(
                      cartItem: cartItem,
                      onRemove: () {
                      
                        setState(() {});
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    TotalPriceWidget(cartItems: cartItems),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                     
                      },
                      child: const Text('Checkout'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Stream<QuerySnapshot> _fetchCartItemsStream() {
    var userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return const Stream.empty();
    }

    var query = FirebaseFirestore.instance
        .collection('carts')
        .where('userId', isEqualTo: userId)
        .snapshots();

    return query;
  }
}

class CartItemWidget extends StatefulWidget {
  final Map<String, dynamic> cartItem;
  final VoidCallback onRemove;

  const CartItemWidget({Key? key, required this.cartItem, required this.onRemove}) : super(key: key);

  @override
  _CartItemWidgetState createState() => _CartItemWidgetState();
}

class _CartItemWidgetState extends State<CartItemWidget> {
  late int quantity;

  void _updateQuantity(int newQuantity) {
    String? cartItemId = widget.cartItem['cartItemId'];

    if (cartItemId != null) {
      FirebaseFirestore.instance
          .collection('carts')
          .doc(cartItemId)
          .get()
          .then((docSnapshot) {
            if (docSnapshot.exists) {
            
              docSnapshot.reference.update({'quantity': newQuantity}).then((_) {
               
                widget.onRemove();
              }).catchError((error) {
                print('Error updating quantity in cart: $error');
              });
            } else {
              print('Document with ID $cartItemId does not exist.');
            }
          })
          .catchError((error) {
            print('Error getting document: $error');
          });
    } else {
      print('CartItemId is null');
    }
  }

  void _increaseQuantity() {
    setState(() {
      quantity++;
      _updateQuantity(quantity);
    });
  }

  void _decreaseQuantity() {
    if (quantity > 1) {
      setState(() {
        quantity--;
        _updateQuantity(quantity);
      });
    }
  }

  void _removeFromCart() {
    String? cartItemId = widget.cartItem['cartItemId'];

    if (cartItemId != null) {
      FirebaseFirestore.instance
          .collection('carts')
          .doc(cartItemId)
          .get()
          .then((docSnapshot) {
            if (docSnapshot.exists) {
             
              docSnapshot.reference.delete().then((_) {
             
                widget.onRemove();
              }).catchError((error) {
                print('Error removing item from cart: $error');
              });
            } else {
              print('Document with ID $cartItemId does not exist.');
            }
          })
          .catchError((error) {
            print('Error getting document: $error');
          });
    } else {
      print('CartItemId is null');
    }
  }

  @override
  void initState() {
    super.initState();
    quantity = widget.cartItem['quantity'];
  }

  @override
  Widget build(BuildContext context) {
    double productTotal = widget.cartItem['quantity'] * widget.cartItem['price'];

    return ListTile(
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: const Color.fromARGB(255, 232, 225, 226),
        backgroundImage: NetworkImage(widget.cartItem['productImage']),
      ),
      title: Text(
        widget.cartItem['productName'],
        style: const TextStyle(fontSize: 15, color: Colors.white),
      ),
      subtitle: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: () {
              _decreaseQuantity();
            },
          ),
          Text('Quantity: $quantity', style: const TextStyle(color: Colors.white)),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _increaseQuantity();
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              _removeFromCart();
            },
          ),
        ],
      ),
      trailing: Text(
        '\$${productTotal.toStringAsFixed(2)}',
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}

class TotalPriceWidget extends StatelessWidget {
  final List cartItems;

  const TotalPriceWidget({Key? key, required this.cartItems}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double totalPrice = 0.0;

    for (var cartItem in cartItems) {
      totalPrice += cartItem['quantity'] * cartItem['price'];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'Total: \$${totalPrice.toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
