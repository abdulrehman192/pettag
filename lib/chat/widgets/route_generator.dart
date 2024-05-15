import 'package:flutter/material.dart';
import 'package:pettag/chat/chat.dart';
import 'package:pettag/chat/repo/route_argument.dart';

class RouteGenerator {
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    // Getting arguments passed in while calling Navigator.pushNamed
    final RouteArgument args = settings.arguments as RouteArgument;
    switch (settings.name) {

      case '/chat':
        return MaterialPageRoute(
            builder: (_) => Chat(
                  routeArgument: args,
                ));
      // case '/order':
      //   return MaterialPageRoute(
      //       builder: (_) => Order(routeArgumentModel: args));
      // case '/coupen':
      //   return MaterialPageRoute(builder: (_) => Coupen());
      // case '/payment':
      //   return MaterialPageRoute(builder: (_) => Payment());
      // case '/forgot':
      //   return MaterialPageRoute(builder: (_) => Forgot());
      // case '/book':
      //   return MaterialPageRoute(
      //       builder: (_) => Book(
      //             routeArgumentModel: args,
      //           ));
      // case '/settings':
      //   return MaterialPageRoute(builder: (_) => Settings());
      // case '/personalInfo':
      //   return MaterialPageRoute(
      //       builder: (_) => PersonalInfo(
      //             routeArgumentModel: args,
      //           ));
      default:
        return null;
      // If there is no such named route in the switch statement, e.g. /third
      //return MaterialPageRoute(builder: (_) => PagesTestWidget(currentTab: 1));
    }
  }
}
