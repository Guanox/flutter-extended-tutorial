import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:redux/redux.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:liftr/model/model.dart';
import 'package:liftr/redux/actions.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GoogleSignIn _googleSignIn = GoogleSignIn();

List<Middleware<AppState>> appStateMiddleware([
  AppState state = const AppState(
      fontSize: 18.0, startups: [], firebaseState: FirebaseState()),
]) {
  final Function init = _handleInitAction(state);
  final Function userLoad = _handleUserLoadedAction(state);
  final Function googleLogin = _handleGoogleLoginAction(state);
  final Function googleLogout = _handleGoogleLogoutAction(state);
  final Function addStartup = _handleAddStartupAction(state);
  final Function removeStartup = _handleRemoveStartupAction(state);
  final Function changeFontSize = _handleChangeFontSizeAction(state);

  return [
    TypedMiddleware<AppState, InitAction>(init),
    TypedMiddleware<AppState, UserLoadedAction>(userLoad),
    TypedMiddleware<AppState, GoogleLoginAction>(googleLogin),
    TypedMiddleware<AppState, GoogleLogoutAction>(googleLogout),
    TypedMiddleware<AppState, AddStartupAction>(addStartup),
    TypedMiddleware<AppState, RemoveStartupAction>(removeStartup),
    TypedMiddleware<AppState, ChangeFontSizeAction>(changeFontSize),
  ];
}

Middleware<AppState> _handleChangeFontSizeAction(AppState state) {
  return (Store<AppState> store, action, NextDispatcher next) async {
    next(action);

    _saveFontSizeToPrefs(store.state.fontSize);
  };
}

Future<void> _saveFontSizeToPrefs(double fontSize) async {
  final SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.setDouble('fontSize', fontSize);
}

Middleware<AppState> _handleGoogleLogoutAction(AppState state) {
  return (Store<AppState> store, action, NextDispatcher next) async {
    next(action);

    _googleSignIn.signOut();
    FirebaseAuth.instance.signOut().then((_) => FirebaseAuth.instance
        .signInAnonymously()
        .then((user) => store.dispatch(UserLoadedAction(user))));
  };
}

Middleware<AppState> _handleGoogleLoginAction(AppState state) {
  return (Store<AppState> store, action, NextDispatcher next) async {
    next(action);

    final GoogleSignInAccount googleUser = await _getGoogleUser();
    final GoogleSignInAuthentication credentials =
        await googleUser.authentication;

    await FirebaseAuth.instance.signInWithGoogle(
      idToken: credentials.idToken,
      accessToken: credentials.accessToken,
    );

    final FirebaseUser user = await FirebaseAuth.instance.currentUser();
    await user.updateProfile(UserUpdateInfo()
      ..photoUrl = googleUser.photoUrl
      ..displayName = googleUser.displayName);
    user.reload();

    store.dispatch(UserLoadedAction(user));
  };
}

Future<GoogleSignInAccount> _getGoogleUser() async {
  GoogleSignInAccount googleUser = _googleSignIn.currentUser;

  return googleUser ??= await _googleSignIn.signIn();
}

Middleware<AppState> _handleUserLoadedAction(AppState state) {
  return (Store<AppState> store, action, NextDispatcher next) {
    next(action);

    store.dispatch(RemoveStartupsAction()); // reset startups

    // remove previously added listeners
    store.state.firebaseState.subAddStartup?.cancel();
    store.state.firebaseState.subRemoveStartup?.cancel();

    final DatabaseReference ref = FirebaseDatabase.instance
        .reference()
        .child(store.state.firebaseState.user.uid)
        .child('startups');

    final subAdd = ref.onChildAdded
        .listen((event) => store.dispatch(AddedStartupAction(event.snapshot)));
    final subRemove = ref.onChildRemoved
        .listen((event) => store.dispatch(RemovedStartupAction(event.snapshot)));

    store.dispatch(AddDatabaseReferenceAction(ref, subAdd, subRemove));
  };
}

Middleware<AppState> _handleInitAction(AppState state) {
  return (Store<AppState> store, action, NextDispatcher next) {
    next(action);

    _loadFontSizeFromPrefs()
        .then((fontSize) => store.dispatch(ChangeFontSizeAction(fontSize)));

    if (store.state.firebaseState.user == null) {
      FirebaseAuth.instance.currentUser().then((user) {
        if (user != null) {
          store.dispatch(UserLoadedAction(user));
        } else {
          FirebaseAuth.instance
              .signInAnonymously()
              .then((user) => store.dispatch(UserLoadedAction(user)));
        }
      });
    }
  };
}

Future<double> _loadFontSizeFromPrefs() async {
  final SharedPreferences preferences = await SharedPreferences.getInstance();
  final double value = preferences.get('fontSize');
  return value != null ? value : 18.0;
}

Middleware<AppState> _handleAddStartupAction(AppState state) {
  return (Store<AppState> store, action, NextDispatcher next) {
    next(action);

    store.state.firebaseState.mainReference.push().set(action.startup.toJson());
  };
}

Middleware<AppState> _handleRemoveStartupAction(AppState state) {
  return (Store<AppState> store, action, NextDispatcher next) {
    next(action);

    store.state.firebaseState.mainReference.child(action.startup.key).remove();
  };
}
