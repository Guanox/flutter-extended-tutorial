import 'package:liftr/model/model.dart';
import 'package:liftr/redux/actions.dart';

import 'package:redux/redux.dart';

AppState appStateReducer(AppState state, action) {
  return AppState(
    startups: startupReducer(state.startups, action),
  );
}

Reducer<List<Startup>> startupReducer = combineReducers<List<Startup>>([
  TypedReducer<List<Startup>, AddStartupAction>(addStartupReducer),
  TypedReducer<List<Startup>, RemoveStartupAction>(removeStartupReducer),
  TypedReducer<List<Startup>, LoadedStartupsAction>(loadStartupsReducer),
]);

List<Startup> addStartupReducer(List<Startup> startups, AddStartupAction action) {
  return []
    ..addAll(startups)
    ..add(Startup(id: action.id, name: action.name));
}

List<Startup> removeStartupReducer(List<Startup> startups, RemoveStartupAction action) {
  return List.unmodifiable(List.from(startups)..remove(action.startup)); // FIX: try remove List.from
}

List<Startup> loadStartupsReducer(List<Startup> startups, LoadedStartupsAction action) {
  return action.startups; // FIX: try add List.unmodifiable her
}




