import 'dart:html';

import 'package:over_react/over_react.dart';
import 'package:over_react/over_react_redux.dart';
import 'package:over_react/react_dom.dart' as react_dom;

import 'package:redux_dart_basic_tutorial/redux_dart_basic_tutorial.dart';

void main() {
  setClientConfiguration();

  final output = querySelector('#output');

  final app = (ReduxProvider()..store = store)(
    App()(),
  );

  react_dom.render(app, output);
}
