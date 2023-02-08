import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './screens/splash_screen.dart';
import './providers/auth.dart';
import 'screens/auth_screen.dart';
import './screens/cart_screen.dart';
import './screens/products_overview_screen.dart';
import './screens/product_detail_screen.dart';
import './providers/products.dart';
import './providers/cart.dart';
import './providers/orders.dart';
import './screens/orders_screen.dart';
import './screens/user_products_screen.dart';
import './screens/edit_product_screen.dart';
import './helpers/custom_route.dart';

//hello
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: Auth(),
        ),
        //ChangeNotifierProvider.value(
        //  value: Products(...),
        //),
        //this will depend on auth provider
        //use this when u have one dependency else can  use ChangeNotifierProxyProvider2 , 3 ,....
        ChangeNotifierProxyProvider<Auth, Products>(
          update: (ctx, auth, PrevProducts) => Products(
            PrevProducts == null ? [] : PrevProducts.items,
            auth.token,
            auth.userId,
          ),
        ),
        ChangeNotifierProvider.value(
          value: Cart(),
        ),
        //ChangeNotifierProvider.value(
        //  value: Orders(),
        //),
        ChangeNotifierProxyProvider<Auth, Orders>(
          update: (ctx, auth, PrevOrders) => Orders(
              PrevOrders == null ? [] : PrevOrders.orders,
              auth.token,
              auth.userId),
        ),
      ],
      //using consumer because we want if user already authentication on opening app simply show shop screen or switch to authscreen
      //so foe rebuilting the material apop
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
            title: 'MyShop',
            theme: ThemeData(
                primarySwatch: Colors.teal,
                accentColor: Colors.deepOrange,
                fontFamily: 'Lato',
                pageTransitionsTheme: PageTransitionsTheme(
                  builders: {
                    TargetPlatform.android: CustomPageTransitionBuilder(),
                  },
                )),
            home: auth.isAuth //if authenticated then productoverview screen
                ? ProductsOverviewScreen() //if not then futurebuilder try to auto login
                : FutureBuilder(
                    future: auth
                        .tryAutoLogin(), //if we are waiting for the result show the splash screen
                    builder: (ctx, authResultSnapshot) =>
                        authResultSnapshot.connectionState ==
                                ConnectionState.waiting
                            ? SplashScreen()
                            : AuthScreen(),
                  ),
            routes: {
              ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
              CartScreen.routeName: (ctx) => CartScreen(),
              OrdersScreen.routeName: (ctx) => OrdersScreen(),
              UserProductScreen.routeName: (ctx) => UserProductScreen(),
              EditProductScreen.routeName: (ctx) => EditProductScreen(),
              //ProductsOverviewScreen.routeName: (ctx) => ProductsOverviewScreen(),
            }),
      ),
    );
  }
}
