import 'package:flutter/material.dart';

import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux_dev_tools/redux_dev_tools.dart';
import 'package:redux/redux.dart';

import 'package:liftr/model/model.dart';
import 'package:liftr/redux/actions.dart';

import 'package:liftr/redux/reducers.dart';
import 'package:liftr/redux/middleware.dart';

import 'screens/home_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final DevToolsStore<AppState> store = DevToolsStore<AppState>(
      appStateReducer,
      initialState: AppState.initialState(),
      middleware: appStateMiddleware(),
    );

    return StoreProvider<AppState>(
      store: store,
      child: MaterialApp(
        title: 'Startup Name Generator',
        theme: ThemeData(
          primaryColor: Colors.white,
        ),
        home: StoreBuilder<AppState>(
          onInit: (store) => store.dispatch(InitAction()),
          builder: (BuildContext context, Store<AppState> store) =>
              HomePage(),
        ),
      ),
    );
  }
}