import 'package:over_react/over_react_redux.dart';
// import 'package:redux/redux.dart';
import 'package:redux_dart_basic_tutorial/src/reducers.dart';

// Redux dev tool.
import 'package:redux_dev_tools/redux_dev_tools.dart';

// Store store = Store<AppState>(appStateReducer, initialState: AppState.emptyState());

var store = DevToolsStore<AppState>(
  appStateReducer,
  initialState: AppState.emptyState(),
  middleware: [overReactReduxDevToolsMiddleware],
);

/* Some code to see the store in action.
import 'package:redux_dart_basic_tutorial/src/actions.dart';
void main() {
  // Log the initial state
  print(store.state);

  // Every time the state changes, log it
  // Note that listen() returns an StreamSubscription for
  // unregistering the listener
  final subscription = store.onChange.listen(print);

  // Dispatch some actions
  store.dispatch(AddTodo('Learn about actions'));
  store.dispatch(AddTodo('Learn about reducers'));
  store.dispatch(AddTodo('Learn about store'));
  store.dispatch(ToggleTodo(0));
  store.dispatch(ToggleTodo(1));
  store.dispatch(SetVisibilityFilter(VisibilityFilter.showCompleted));

  // Stop listening to state updates
  subscription.cancel();
}
 */
