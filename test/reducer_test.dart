import 'package:flutter_test/flutter_test.dart';

import 'package:liftr/model/model.dart';
import 'package:liftr/redux/reducers.dart';
import 'package:liftr/redux/actions.dart';
import 'package:firebase_database/firebase_database.dart';

// void main() {
//   test('Add Startup reducer test', () {
//     var state = AppState.initialState();

//     Object snapshot = {
//       "key": "1234",
      
//     };

//     state = appStateReducer(state, AddedStartupAction(snapshot));

//     // Verify that list of Startups has length 1
//     expect(state.startups.length, 1);
//   });
// }