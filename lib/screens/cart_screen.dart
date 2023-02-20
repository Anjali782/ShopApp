// ignore_for_file: deprecated_member_use

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart.dart'
// beacuse there is two class of same name so from cart.dart i want only cart so use it
    show
        Cart;
import '../widgets/cart_item.dart'; //or we can add as ci
import '../providers/orders.dart';

class CartScreen extends StatelessWidget {
//will make a route of screen and register it in main screen
  static const routeName = '/cartscreen';
//now use this routename to show our cartscreen from overview screen when ckick on cart icon

  @override
  Widget build(BuildContext context) {
//to show the changes with the change in cart , when new item will add total amount will change
    final cart = Provider.of<Cart>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Cart'),
      ),
      body: Column(children: [
        Card(
          margin: EdgeInsets.all(15),
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: TextStyle(fontSize: 20),
                ),
                //it is like the badge widget , will show a lebel with rounded corners
                //we use it foe showing total amount , to get total amount in cart make a method to get total amount
                Spacer(),
                Chip(
                  label: Text(
                    '\$${cart.totalAmount.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Theme.of(context).primaryTextTheme.headline6.color,
                    ),
                  ),
                  backgroundColor: Theme.of(context).primaryColor,
                ),
                OrderButton(cart: cart)
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Expanded(
          child: ListView.builder(
            itemCount: cart.items.length,
            itemBuilder: (ctx, i) => CartItem(
              //ci.CartItem
              cart.items.values.toList()[i].id,
              cart.items.keys.toList()[i],
              cart.items.values.toList()[i].price,
              cart.items.values.toList()[i].title,
              cart.items.values.toList()[i].quantity,
            ),
          ),
        )
      ]),
    );
  }
}

//to show spinner either we have to make cartScreen stateful or we have created this orderbutton as stete\ful widget
class OrderButton extends StatefulWidget {
  const OrderButton({
    Key key,
    @required this.cart,
  }) : super(key: key);

  final Cart cart;

  @override
  //now this is here to plaxe the order
  _OrderButtonState createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  var _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return TextButton(
        child: _isLoading ? CircularProgressIndicator() : Text('ORDER NOW'),
        onPressed: (widget.cart.totalAmount <= 0 || _isLoading)
            ? null //will disiable the button
            : () async {
                setState(() {
                  _isLoading = true;
                });
                await Provider.of<Orders>(context, listen: false).addOrder(
                  widget.cart.items.values.toList(),
                  widget.cart.totalAmount,
                );
                setState(() {
                  _isLoading = false;
                });
                // clear the card after items will add into order
                widget.cart.clear();
              },
        style: TextButton.styleFrom(
          textStyle: TextStyle(
            color: Theme.of(context).primaryColor,
          ),
        ));
  }
}
