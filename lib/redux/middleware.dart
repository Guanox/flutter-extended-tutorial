import 'dart:async';
import 'dart:convert';

import 'package:redux/redux.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:liftr/model/model.dart';
import 'package:liftr/redux/actions.dart';

List<Middleware<AppState>> appStateMiddleware([
  AppState state = const AppState(startups: []),
]) {
  final loadStartups = _loadFromPrefs(state);
  final saveStartups = _saveToPrefs(state);

  return [
    TypedMiddleware<AppState, AddStartupAction>(saveStartups),
    TypedMiddleware<AppState, RemoveStartupAction>(saveStartups),
    TypedMiddleware<AppState, GetStartupsAction>(loadStartups),
  ];
}

Middleware<AppState> _loadFromPrefs(AppState state) {
  return (Store<AppState> store, action, NextDispatcher next) {
    next(action);

    loadFromPrefs()
        .then((state) => store.dispatch(LoadedStartupsAction(state.startups)));
  };
}

Middleware<AppState> _saveToPrefs(AppState state) {
  return (Store<AppState> store, action, NextDispatcher next) {
    next(action);

    saveToPrefs(store.state);
  };
}

Future<AppState> loadFromPrefs() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  var string = preferences.getString('startupsState');
  if (string != null) {
    Map map = json.decode(string);
    return AppState.fromJson(map);
  }
  return AppState.initialState();
}

void saveToPrefs(AppState state) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  var string = json.encode(state.toJson());
  await preferences.setString('startupsState', string);
}
