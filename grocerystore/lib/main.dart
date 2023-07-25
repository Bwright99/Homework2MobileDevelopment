import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'product.dart';
import 'cart.dart';
import 'package:firebase_core/firebase_core.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ShoppingCartScreen(),
    );
  }
}

class ShoppingCartScreen extends StatefulWidget {
  @override
  _ShoppingCartScreenState createState() => _ShoppingCartScreenState();
}

class _ShoppingCartScreenState extends State<ShoppingCartScreen> {
  ShoppingCart _cart = ShoppingCart();
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shopping Cart'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _cart.items.length,
              itemBuilder: (context, index) {
                final item = _cart.items[index];
                // Filter the items based on the search query
                if ((searchQuery.isEmpty ||
                        item.name.toLowerCase().contains(searchQuery)) &&
                    (item is Product || searchQuery.isEmpty)) {
                  return ListTile(
                    title: Text(item.name),
                    subtitle: Text('\$${item.price.toStringAsFixed(2)}'),
                    onTap: () {
                      _showItemDescription(item);
                    },
                    trailing: IconButton(
                      icon: Icon(Icons.remove_circle),
                      onPressed: () {
                        _removeFromCart(index);
                      },
                    ),
                  );
                }
                return SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addToCart();
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _addToCart() {
    String itemName = '';
    double itemPrice = 0.0;
    String itemDescription = '';

    late DatabaseReference dbRef;
    @override
    void initState() {
      super.initState();
      dbRef = FirebaseDatabase.instance.ref().child("Product");
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Item to Cart'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) {
                  itemName = value;
                },
                decoration: InputDecoration(labelText: 'Item Name'),
              ),
              TextField(
                onChanged: (value) {
                  itemPrice = double.tryParse(value) ?? 0.0;
                },
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: 'Item Price'),
              ),
              TextField(
                onChanged: (value) {
                  itemDescription = value;
                },
                decoration: InputDecoration(labelText: 'Item Description'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (itemName.isNotEmpty && itemPrice > 0.0) {
                  setState(() {
                    _cart.addToCart(Product(itemName, itemPrice,
                        description: itemDescription));
                  });
                  Navigator.pop(context);
                } else {}
                Map<String, dynamic> productData = {
                  "name": itemName,
                  "price": itemPrice,
                  "description": itemDescription,
                };
                dbRef.push().set(productData).then((value) {
                  Navigator.pop(context);
                });
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _removeFromCart(int index) {
    setState(() {
      _cart.items.removeAt(index);
    });
  }

  void _showItemDescription(Product product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(product.name),
          content: Text(product.description),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
