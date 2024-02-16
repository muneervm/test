import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
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
                        // Reload the cart items when an item is removed
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
                        // Implement your checkout logic here
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

  const CartItemWidget({super.key, required this.cartItem, required this.onRemove});

  @override
  _CartItemWidgetState createState() => _CartItemWidgetState();
}

class _CartItemWidgetState extends State<CartItemWidget> {
  var quantity;
  
  var cartItems;

  void _removeFromCart() {
    FirebaseFirestore.instance
        .collection('carts')
        .doc(widget.cartItem['cartItemId']) // Assuming there's a unique identifier for each cart item
        .delete()
        .then((_) {
          // Call the onRemove callback to trigger UI update
          widget.onRemove();
        })
        .catchError((error) {
          print('Error removing item from cart: $error');
        });
  }
@override
  void initState() {
    // TODO: implement initState
    super.initState();
    cartItems=widget.cartItem;
    quantity=widget.cartItem['quantity'];
  }
  @override
  Widget build(BuildContext context) {
    double productTotal = widget.cartItem['quantity'] * widget.cartItem['price'];

    return ListTile(
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: const Color.fromARGB(255, 232, 225, 226) ,
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
              if (quantity > 1) {
                setState(() {
                  quantity--;
                });
              }
            },
          ),
          Text('Quantity: $quantity', style: const TextStyle(color: Colors.white)),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              setState(() {
                quantity++;
               
              });
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

  const TotalPriceWidget({super.key, required this.cartItems});

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
