import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import 'package:liftr/model/model.dart';
import 'package:liftr/redux/actions.dart';

import 'suggestions_page.dart';
import 'favorites_page.dart';

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => new HomePageState();
}

class HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final _widgetTabs = [
    new SuggestionsPage(),
    new FavoritesPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return new StoreConnector<AppState, _ViewModel>(
        converter: (Store<AppState> store) => _ViewModel.create(store),
        onInit: (store) => store.dispatch(InitAction()),
        builder: (context, viewModel) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Startup Name Generator'),
              actions: <Widget>[
                new Container(
                  height: 50,
                  width: 50,
                  child: new FlatButton(
                    onPressed: () {
                      if (viewModel.user?.isAnonymous) {
                        viewModel.login();
                      } else {
                        viewModel.logout();
                      }
                    },
                    child: new ConstrainedBox(
                      constraints: new BoxConstraints.expand(),
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
              items: <BottomNavigationBarItem>[
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
}

class _ViewModel {
  final FirebaseUser user;
  final Function() login;
  final Function() logout;

  _ViewModel({this.user, this.login, this.logout});

  factory _ViewModel.create(Store<AppState> store) {
    _login() {
      store.dispatch(GoogleLoginAction(cachedStartups: store.state.startups));
    }

    _logout() {
      store.dispatch(GoogleLogoutAction());
    }

    return _ViewModel(
        user: store.state.firebaseState.user, login: _login, logout: _logout);
  }
}
