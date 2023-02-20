import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';
import '../screens/product_detail_screen.dart';
import '../providers/product.dart';
import '../providers/cart.dart';

class ProductItem extends StatelessWidget {
  // final String id;
  // final String title;
  // final String imageUrl;

  // ProductItem(this.id, this.title, this.imageUrl);

  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context, listen: false);
    final cart = Provider.of<Cart>(context, listen: false);
    final authData = Provider.of<Auth>(context, listen: false);
    return ClipRRect(//cliprrect forces the child to be in some shape
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        //with this allows us to add on tap listner
        child: GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed(
                ProductDetailScreen.routeName,
                arguments: product.id,
              );
            },
            child: Hero(
              tag: product.id,
              child: FadeInImage(
                placeholder:
                    AssetImage('assets/images/product-placeholder.png'),
                image: NetworkImage(product.imageUrl),
                fit: BoxFit.cover,
              ),
            )),
        footer: GridTileBar(
          backgroundColor: Colors.black87,
          leading: SizedBox(
            // width: MediaQuery.of(context).size.width * 0.02,
            child: Consumer<Product>(
              builder: (ctx, product, _) => IconButton(
                icon: Icon(
                  product.isFavorite ? Icons.favorite : Icons.favorite_border,
                ),
                color: Theme.of(context).colorScheme.secondary,
                onPressed: () {
                  product.toggleFavoriteStatus(
                    authData.token,
                    authData.userId,
                  );
                },
              ),
            ),
          ),
          title: Text(
            product.title,
            textAlign: TextAlign.center,
          ),
          trailing: IconButton(
            icon: const Icon(
              Icons.shopping_cart,
              // color: Colors.lightGreen,
            ),
            onPressed: () {
              cart.addItem(product.id, product.price, product.title);
              //if we rapidly add another item then hide prev appbar if it is showing till now
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              //we want to show some info while press on cart icon , vo jo neeche ataa hai black patti si whi h snackbar
              //with .of method we stablish a connection to nearest scaffold which is scaffold of overview screen
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                  'Added item to the cart',
                  style: TextStyle(fontSize: 20),
                ),
                duration: Duration(seconds: 2),
                //foe undo implementation add a method in cart.dart
                action: SnackBarAction(
                  label: 'UNDO',
                  onPressed: () {
                    //we call function from cart provider from here
                    cart.removeSingleItem(product.id);
                  },
                ),
              ));
            },
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
      ),
    );
  }
}
