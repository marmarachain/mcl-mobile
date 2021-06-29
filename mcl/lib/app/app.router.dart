// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// StackedRouterGenerator
// **************************************************************************

// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../ui/contact/contact_view.dart';
import '../ui/home/home_view.dart';
import '../ui/mcl_detail/mcl_detail_view.dart';
import '../ui/startup/startup_view.dart';

class Routes {
  static const String startUpView = '/';
  static const String homeView = '/home-view';
  static const String contactView = '/contact-view';
  static const String mclDetailView = '/mcl-detail-view';
  static const all = <String>{
    startUpView,
    homeView,
    contactView,
    mclDetailView,
  };
}

class StackedRouter extends RouterBase {
  @override
  List<RouteDef> get routes => _routes;
  final _routes = <RouteDef>[
    RouteDef(Routes.startUpView, page: StartUpView),
    RouteDef(Routes.homeView, page: HomeView),
    RouteDef(Routes.contactView, page: ContactView),
    RouteDef(Routes.mclDetailView, page: MclDetailView),
  ];
  @override
  Map<Type, StackedRouteFactory> get pagesMap => _pagesMap;
  final _pagesMap = <Type, StackedRouteFactory>{
    StartUpView: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => const StartUpView(),
        settings: data,
      );
    },
    HomeView: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => const HomeView(),
        settings: data,
      );
    },
    ContactView: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => const ContactView(),
        settings: data,
      );
    },
    MclDetailView: (data) {
      var args = data.getArgs<MclDetailViewArguments>(
        orElse: () => MclDetailViewArguments(),
      );
      return MaterialPageRoute<dynamic>(
        builder: (context) => MclDetailView(
          key: args.key,
          passwordServer: args.passwordServer,
        ),
        settings: data,
      );
    },
  };
}

/// ************************************************************************
/// Arguments holder classes
/// *************************************************************************

/// MclDetailView arguments holder class
class MclDetailViewArguments {
  final Key? key;
  final String? passwordServer;
  MclDetailViewArguments({this.key, this.passwordServer});
}
