import 'package:firebase_database/firebase_database.dart';
import 'package:redux/redux.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:liftr/model/model.dart';
import 'package:liftr/redux/actions.dart';
import 'dart:async';

final GoogleSignIn _googleSignIn = new GoogleSignIn();

List<Middleware<AppState>> appStateMiddleware([
  AppState state = const AppState(startups: [], firebaseState: FirebaseState()),
]) {
  final init = _handleInitAction(state);
  final userLoad = _handleUserLoadedAction(state);
  final googleLogin = _handleGoogleLoginAction(state);
  final googleLogout = _handleGoogleLogoutAction(state);
  final addStartup = _handleAddStartupAction(state);
  final removeStartup = _handleRemoveStartupAction(state);

  return [
    TypedMiddleware<AppState, InitAction>(init),
    TypedMiddleware<AppState, UserLoadedAction>(userLoad),
    TypedMiddleware<AppState, GoogleLoginAction>(googleLogin),
    TypedMiddleware<AppState, GoogleLogoutAction>(googleLogout),
    TypedMiddleware<AppState, AddStartupAction>(addStartup),
    TypedMiddleware<AppState, RemoveStartupAction>(removeStartup),
  ];
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

    GoogleSignInAccount googleUser = await _getGoogleUser();
    GoogleSignInAuthentication credentials = await googleUser.authentication;

    // try {
    // await FirebaseAuth.instance.linkWithGoogleCredential(
    //     idToken: credentials.idToken, accessToken: credentials.accessToken);
    // } catch (e) {
    await FirebaseAuth.instance.signInWithGoogle(
      idToken: credentials.idToken,
      accessToken: credentials.accessToken,
    );
    // }

    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    await user.updateProfile(new UserUpdateInfo()
      ..photoUrl = googleUser.photoUrl
      ..displayName = googleUser.displayName);
    user.reload();

    store.dispatch(new UserLoadedAction(user));
  };
}

Future<GoogleSignInAccount> _getGoogleUser() async {
  GoogleSignInAccount googleUser = _googleSignIn.currentUser;
  // if (googleUser == null) {
  //   googleUser = await _googleSignIn.signInSilently(suppressErrors: true);
  // }
  if (googleUser == null) {
    googleUser = await _googleSignIn.signIn();
  }
  return googleUser;
}

Middleware<AppState> _handleUserLoadedAction(AppState state) {
  return (Store<AppState> store, action, NextDispatcher next) {
    next(action);

    store.dispatch(RemoveStartupsAction()); // reset startups

    store.dispatch(AddDatabaseReferenceAction(
      FirebaseDatabase.instance
          .reference()
          .child(store.state.firebaseState.user.uid)
          .child('startups')
            ..onChildAdded
                .listen((event) => store.dispatch(AddedStartupAction(event)))
            ..onChildRemoved
                .listen((event) => store.dispatch(RemovedStartupAction(event))),
    ));
  };
}

Middleware<AppState> _handleInitAction(AppState state) {
  return (Store<AppState> store, action, NextDispatcher next) {
    next(action);

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
