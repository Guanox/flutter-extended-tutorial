import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import 'package:liftr/model/model.dart';
import 'package:liftr/redux/actions.dart';

class SettingsPage extends StatefulWidget {
  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<SettingsPage> {


  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ViewModel>(
      converter: (Store<AppState> store) => _ViewModel.create(store),
      builder: (context, viewModel) {
        return Scaffold(
            appBar: AppBar(title: Text('Profile')),
            body: Column(
              children: const <Widget>[
                Text('hello')
                // Profile
                // Settings
              ],
            ));
      },
    );
  }
}

class _ViewModel {
  final FirebaseUser user;
  final Function() login;
  final Function() logout;

  _ViewModel({this.user, this.login, this.logout});

  factory _ViewModel.create(Store<AppState> store) {
    void _login() {
      store.dispatch(GoogleLoginAction(cachedStartups: store.state.startups));
    }

    void _logout() {
      store.dispatch(GoogleLogoutAction());
    }

    return _ViewModel(
        user: store.state.firebaseState.user, login: _login, logout: _logout);
  }
}
