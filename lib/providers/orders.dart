import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    @required this.amount,
    @required this.id,
    @required this.dateTime,
    @required this.products,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _order = [];
  final String authToken;
  final String userId;
  Orders(
    this._order,
    this.authToken,
    this.userId,
  );

  List<OrderItem> get orders {
    return [..._order];
  }

//  void addOrder(List<CartItem> cartProducts, double total) {
//    //index 0 because we want more recent item in top of the list
//    _order.insert(
//        0,
//        OrderItem(
//          amount: total,
//          id: DateTime.now().toString(),
//          dateTime: DateTime.now(),
//          products: cartProducts,
//        ));
//    notifyListeners();
//    //now we add a method in cart.dart , clearCart , when we click on place order item will add in orderitem and cleared from cart Screen
//  }
//}

  Future<void> fetchAndSetOrders() async {
    final url =
        'https://flutter-update-90ea9-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken';
    final response = await http.get(url);
    final List<OrderItem> loadedOrders = [];
    final extractedData = json.decode(response.body) as Map<String, dynamic>;
    if (extractedData == null) {
      return;
    }
    extractedData.forEach((orderId, orderData) {
      loadedOrders.add(
        OrderItem(
          id: orderId,
          amount: orderData['amount'],
          dateTime: DateTime.parse(orderData['dateTime']),
          products: (orderData['products'] as List<dynamic>)
              .map(
                (item) => CartItem(
                  id: item['id'],
                  price: item['price'],
                  quantity: item['quantity'],
                  title: item['title'],
                ),
              )
              .toList(),
        ),
      );
    });
    _order = loadedOrders.reversed.toList();
    notifyListeners();
  }

//now from cart screen when we click on order now we should show a spinner
  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url =
        'https://flutter-update-90ea9-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken';
    final timestamp = DateTime.now();
    final response = await http.post(
      url,
      body: json.encode({
        'amount': total,
        'dateTime': timestamp.toIso8601String(),
        'products': cartProducts
            .map((cp) => {
                  'id': cp.id,
                  'title': cp.title,
                  'quantity': cp.quantity,
                  'price': cp.price,
                })
            .toList(),
      }),
    );
    _order.insert(
      0,
      OrderItem(
        id: json.decode(response.body)['name'],
        amount: total,
        dateTime: timestamp,
        products: cartProducts,
      ),
    );
    notifyListeners();
  }
}
