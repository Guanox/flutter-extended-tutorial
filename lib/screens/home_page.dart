import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import 'package:liftr/model/model.dart';
import 'package:liftr/redux/actions.dart';

import 'favorites_page.dart';
import 'profile_page.dart';
import 'suggestions_page.dart';

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final _widgetTabs = [
    SuggestionsPage(),
    FavoritesPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ViewModel>(
        converter: (Store<AppState> store) => _ViewModel.create(store),
        onInit: (store) => store.dispatch(InitAction()),
        builder: (context, viewModel) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Startup Name Generator'),
              actions: <Widget>[
                Container(
                  height: 50,
                  width: 50,
                  child: FlatButton(
                    onPressed: () => _openSettingsPage(context),
                    // onPressed: () {

                    // final isAnonymous = viewModel.user != null ? viewModel.user.isAnonymous : false;
                    // if (isAnonymous) {
                    //   viewModel.login();
                    // } else {
                    //   viewModel.logout();
                    // }
                    // },
                    child: ConstrainedBox(
                      constraints: BoxConstraints.expand(),
                    ),
                  ),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25.0),
                      border: Border.all(
                          color: Colors.white,
                          style: BorderStyle.solid,
                          width: 2.0),
                      image: DecorationImage(
                          image: viewModel.user?.isAnonymous ?? true
                              ? AssetImage('assets/user.png')
                              : NetworkImage(viewModel.user.photoUrl))),
                ),
              ],
            ),
            body: _widgetTabs.elementAt(_selectedIndex),
            bottomNavigationBar: BottomNavigationBar(
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                    icon: Icon(Icons.home), title: Text('Suggestions')),
                BottomNavigationBarItem(
                    icon: Icon(Icons.favorite), title: Text('Favorites'))
              ],
              fixedColor: Colors.lightBlue,
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
            ),
          );
        });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _openSettingsPage(BuildContext context) async {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (BuildContext context) {
      return SettingsPage();
    }));
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
