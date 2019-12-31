import 'package:redux/redux.dart';
import 'package:redux_dart_basic_tutorial/src/actions.dart';

class Todo {
  String text;
  bool completed;

  Todo(this.text) : completed = false;

  Todo.updateState(Todo oldTodo, {String text, bool completed})
      : text = text ?? oldTodo.text,
        completed = completed ?? oldTodo.completed;

  // For running demo main function below
  @override
  String toString() {
    return 'Todo {completed: ${completed}, text: "${text}"}';
  }

  // For ReduxDev tool
  Map<String, dynamic> toJson() {
    return {'text': text, 'completed': completed};
  }
}

class AppState {
  VisibilityFilter visibilityFilter;
  List<Todo> todos;

  AppState({this.visibilityFilter, this.todos});

  AppState.emptyState()
      : visibilityFilter = VisibilityFilter.showAll,
        todos = [];

  AppState.updateState(AppState oldState, {VisibilityFilter visibilityFilter, List<Todo> todos})
      : visibilityFilter = visibilityFilter ?? oldState.visibilityFilter,
        todos = todos ?? oldState.todos;

  // For running demo main function below
  @override
  String toString() {
    return 'AppState {visibleTodoFilter: ${visibilityFilter}, todos: ${todos}}';
  }

  // For ReduxDev tool
  Map<String, dynamic> toJson() {
    return {'todos': todos, 'visibilityFilter': filterToJson(visibilityFilter)};
  }
}

List<Todo> addTodoReducer(List<Todo> todos, AddTodo action) {
  return [...todos, Todo(action.value)];
}

List<Todo> toggleTodoReducer(List<Todo> todos, ToggleTodo action) {
  return todos
      .asMap()
      .map((index, todo) {
        if (index == action.value) {
          return MapEntry(index, Todo.updateState(todo, completed: !todo.completed));
        }
        return MapEntry(index, todo);
      })
      .values
      .toList();
}

Reducer<List<Todo>> todosReducer = combineReducers<List<Todo>>([
  TypedReducer<List<Todo>, AddTodo>(addTodoReducer),
  TypedReducer<List<Todo>, ToggleTodo>(toggleTodoReducer),
]);

VisibilityFilter visibilityFilterReducer(VisibilityFilter visibilityFilter, dynamic action) {
  if (action is SetVisibilityFilter) {
    return action.value;
  } else {
    return visibilityFilter;
  }
}

AppState appStateReducer(AppState state, dynamic action) => AppState(
      visibilityFilter: visibilityFilterReducer(state.visibilityFilter, action),
      todos: todosReducer(state.todos, action),
    );

/* Some code to see reducer in action.
void main() {
  var previousState = AppState(visibilityFilter: VisibilityFilter.showAll, todos: [Todo('Read the docs.')]);
  var action = AddTodo('Understand the flow.');
  var nextState = appStateReducer(previousState, action);

  print(previousState);
  print(nextState);
}
*/
