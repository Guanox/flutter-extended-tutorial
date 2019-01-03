import 'package:liftr/model/model.dart';
import 'package:liftr/redux/actions.dart';

import 'package:redux/redux.dart';

AppState appStateReducer(AppState state, action) {
  return AppState(
    startups: startupReducer(state.startups, action),
    firebaseState: firebaseReducer(state.firebaseState, action),
  );
}

Reducer<List<Startup>> startupReducer = combineReducers<List<Startup>>([
  TypedReducer<List<Startup>, AddedStartupAction>(addStartupReducer),
  TypedReducer<List<Startup>, RemovedStartupAction>(removeStartupReducer),
  TypedReducer<List<Startup>, RemoveStartupsAction>(removeStartupsReducer),
]);

Reducer<FirebaseState> firebaseReducer = combineReducers<FirebaseState>([
  TypedReducer<FirebaseState, AddDatabaseReferenceAction>(addDatabaseReferenceReducer),
  TypedReducer<FirebaseState, UserLoadedAction>(userLoadedReducer),
]);

List<Startup> addStartupReducer(List<Startup> startups, AddedStartupAction action) {
  return []
    ..addAll(startups)
    ..add(Startup.fromSnapshot(action.event.snapshot));
}

List<Startup> removeStartupReducer(List<Startup> startups, RemovedStartupAction action) {
  return List.unmodifiable(List.from(startups)..removeWhere((s) => s.key == action.event.snapshot.key));
}

FirebaseState addDatabaseReferenceReducer(FirebaseState firebaseState, AddDatabaseReferenceAction action) {
  return firebaseState.copyWith(mainReference: action.databaseReference, subAddStartup: action.subAddStartup, subRemoveStartup: action.subRemoveStartup);
}

FirebaseState userLoadedReducer(FirebaseState firebaseState, UserLoadedAction action) {
  return firebaseState.copyWith(user: action.user);
}

List<Startup> removeStartupsReducer(List<Startup> startups, RemoveStartupsAction action) {
  return List.unmodifiable([]);
}