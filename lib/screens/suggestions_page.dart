import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';

import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import 'package:liftr/model/model.dart';
import 'package:liftr/redux/actions.dart';

class SuggestionsPage extends StatefulWidget {

  @override
  SuggestionsPageState createState() => new SuggestionsPageState();
}

class SuggestionsPageState extends State<SuggestionsPage> {
  final List<WordPair> _suggestions = <WordPair>[];

  SuggestionsPageState();

  @override
  Widget build(BuildContext context) {
    return new StoreConnector<AppState, _ViewModel>(
        converter: (Store<AppState> store) => _ViewModel.create(store),
        onInit: (store) => store.dispatch(InitAction()),
        builder: (context, viewModel) {
          return new ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemBuilder: (BuildContext _context, int i) {
                if (i.isOdd) {
                  return new Divider();
                }

                final int index = i ~/ 2;
                if (index >= _suggestions.length) {
                  _suggestions.addAll(generateWordPairs().take(10));
                }
                return _buildRow(_suggestions[index], viewModel);
              });
        });
  }

  Widget _buildRow(WordPair pair, _ViewModel viewModel) {
    return new ListTile(
      title: new Text(
        pair.asPascalCase,
        style: TextStyle(fontSize: 18.0),
      ),
      onTap: () {
        _suggestions.remove(pair);
        viewModel.onAddStartup(pair.asPascalCase);
      },
    );
  }
}

class _ViewModel {
  final List<Startup> startups;
  final Function(String) onAddStartup;

  _ViewModel({this.startups, this.onAddStartup});

  factory _ViewModel.create(Store<AppState> store) {
    _onAddStartup(String name) {
      store.dispatch(AddStartupAction(Startup(name: name)));
    }

    return _ViewModel(
      startups: store.state.startups,
      onAddStartup: _onAddStartup,
    );
  }
}
