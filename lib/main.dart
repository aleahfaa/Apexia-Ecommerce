import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext cfontext) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: CartPage());
  }
}

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<dynamic> cartItems = [];
  bool isLoading = false;
  double totalPrice = 0;

  @override
  void initState() {
    super.initState();
    loadCart();
  }

  void loadCart() async {
    setState(() => isLoading = true);

    var response = await http.get(
      Uri.parse('https://api.shop.com/cart?userId=123'),
    );

    var data = json.decode(response.body);
    setState(() {
      cartItems = data['items'];
      isLoading = false;
    });

    calculateTotal();
  }

  void calculateTotal() {
    totalPrice = 0;
    for (var i = 0; i < cartItems.length; i++) {
      totalPrice += cartItems[i]['price'] * cartItems[i]['quantity'];
    }
    setState(() {});
  }

  void updateQuantity(int index, int newQty) async {
    cartItems[index]['quantity'] = newQty;
    setState(() {});

    await http.post(
      Uri.parse('https://api.shop.com/cart/update'),
      body: json.encode({'itemId': cartItems[index]['id'], 'quantity': newQty}),
    );

    calculateTotal();
  }

  void removeItem(int index) async {
    var itemId = cartItems[index]['id'];
    cartItems.removeAt(index);
    setState(() {});

    await http.delete(Uri.parse('https://api.shop.com/cart/item/$itemId'));

    calculateTotal();
  }

  void checkout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Processing...'),
        content: CircularProgressIndicator(),
      ),
    );

    var response = await http.post(
      Uri.parse('https://api.shop.com/checkout'),
      body: json.encode({
        'userId': '123',
        'items': cartItems,
        'total': totalPrice,
      }),
    );

    Navigator.pop(context);

    if (response.statusCode == 200) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Success'),
          content: Text('Order placed successfully!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shopping Cart'),
        actions: [IconButton(icon: Icon(Icons.refresh), onPressed: loadCart)],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : cartItems.length == 0
          ? Center(child: Text('Cart is empty'))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: EdgeInsets.all(8),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 1,
                              blurRadius: 3,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Image.network(
                              cartItems[index]['image'],
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    cartItems[index]['name'],
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Rp ${cartItems[index]['price']}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.green,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          if (cartItems[index]['quantity'] >
                                              1) {
                                            updateQuantity(
                                              index,
                                              cartItems[index]['quantity'] - 1,
                                            );
                                          }
                                        },
                                        child: Container(
                                          width: 30,
                                          height: 30,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.grey,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: Icon(Icons.remove, size: 18),
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Text(
                                        '${cartItems[index]['quantity']}',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      SizedBox(width: 12),
                                      InkWell(
                                        onTap: () {
                                          updateQuantity(
                                            index,
                                            cartItems[index]['quantity'] + 1,
                                          );
                                        },
                                        child: Container(
                                          width: 30,
                                          height: 30,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.grey,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: Icon(Icons.add, size: 18),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => removeItem(index),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Rp ${totalPrice.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: cartItems.length > 0 ? checkout : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Checkout',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
