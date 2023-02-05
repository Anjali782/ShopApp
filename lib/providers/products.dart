import 'package:flutter/material.dart';
//to convert our widgets into json because this web server accept data in json form not in string
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/http_exception.dart';

import './product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [
//    ),
//    Product(
//      id: 'p2',
//      title: 'Trousers',
//      description: 'A nice pair of trousers.',
//      price: 59.99,
//      imageUrl:
//          'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
//    ),
//    Product(
//      id: 'p3',
//      title: 'Yellow Scarf',
//      description: 'Warm and cozy - exactly what you need for the winter.',
//      price: 19.99,
//      imageUrl:
//          'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
//    ),
//    Product(
//      id: 'p4',
//      title: 'A Pan',
//      description: 'Prepare any meal you want.',
//      price: 49.99,
//      imageUrl:
//          'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
//    ),
  ];

  // var _showFavouritesOnly = false;
  final String authToken;
  final String userId;
  Products(
    this._items,
    this.authToken,
    this.userId,
  ); //add this toke in the fetch and set link in last

  List<Product> get items {
    //  if (_showFavouritesOnly) {
    //    return _items.where((prodItem) => prodItem.isFavorite).toList();
    //  }
    return [..._items]; //to return copy of items
  }

  List<Product> get favouriteItems {
    return _items.where((prodItem) => prodItem.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

//  void showFavouritesOnly() {
//    _showFavouritesOnly = true;
//    notifyListeners();
//  }

//  void all() {
//    _showFavouritesOnly = false;
//    notifyListeners();
//  }

  //to show the added product saved on firebase
  //call it in product overview screen
  //filterByUser is in square brackets to make it optional argument
  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    // final filterString = filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    final filterString =
        filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    //in user productScreen where calling fetchandset make filterbyuser true
    var url =
        'https://flutter-update-90ea9-default-rtdb.firebaseio.com/products.json?auth=$authToken&$filterString';
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      }
      url =
          'https://flutter-update-90ea9-default-rtdb.firebaseio.com/userFavourites/$userId.json?auth=$authToken';
      final favouriteResponse = await http.get(url);
      //to store the data locally
      final favouriteData = json.decode(favouriteResponse.body);
      final List<Product> loadedProducts = [];
      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(Product(
          id: prodId,
          title: prodData['title'],
          description: prodData['description'],
          price: prodData['price'],
          isFavorite: favouriteData == null
              ? false
              : favouriteData[prodId] ??
                  false, //?? if prodid is not there so check if it is null
          imageUrl: prodData['imageUrl'],
        ));
      });
      _items = loadedProducts;
      notifyListeners();
      //print(json.decode(response.body));
    } catch (error) {
      throw (error);
    }
  }

  Future<void> addProduct(Product product) async {
    //now we are adding are project and storing data on the database with the help of firebase web server
    final url =
        'https://flutter-update-90ea9-default-rtdb.firebaseio.com/products.json?auth=$authToken';
    //we can't pass our products but we can pass a map it know how to convert map
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'imageUrl': product.imageUrl,
          'price': product.price,
          'creatorId': userId,
        }),
      );
      final newProduct = Product(
        title: product.title,
        id: json.decode(response.body)['name'],
        description: product.description,
        imageUrl: product.imageUrl,
        price: product.price,
      );
      _items.add(newProduct);
      //_items.insert(0, newProduct);
      notifyListeners();
      //this is future or asunchronous code which will immidiately after request run , adding data to firebase
      //till this is saving data to firebase product will not appear on the screen so this is better to use some spinner instead of returning to screen
      //this will done in edit products screen not immidiatly pop the screen
      //instead of then use await
      //.then((response) {
      //print(json.decode(response.body)); , its a map with the name key which we can use as our id generated by fire base
    } catch (error) {
      print(error);
      throw error;
    }
    //print(error);
    //throw error;
  }

  //void updateProduct(String id, Product newProduct) {
  //  final prodIndex = _items.indexWhere((prod) => prod.id == id);
  //  if (prodIndex >= 0) {
  //    _items[prodIndex] = newProduct;
  //    notifyListeners();
  //  } else {
  //    print('...');
  //  }
  //}

//update detail also save in server
  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      final url =
          'https://flutter-update-90ea9-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken';
      await http.patch(url,
          body: json.encode({
            'title': newProduct.title,
            'description': newProduct.description,
            'imageUrl': newProduct.imageUrl,
            'price': newProduct.price,
          }));
      _items[prodIndex] = newProduct;
      notifyListeners();
    } else {
      print('...');
    }
  }

  Future<void> deleteProduct(String id) async {
    final url =
        'https://flutter-update-90ea9-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken';
    //copy data before del
    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    var existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();
    final response = await http.delete(url);
    //for understand which type of error is comming
    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not delete product.');
    }
    existingProduct = null;
  }
}
