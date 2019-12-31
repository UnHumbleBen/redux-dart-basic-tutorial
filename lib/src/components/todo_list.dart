import 'package:over_react/over_react.dart';
import 'package:over_react/over_react_redux.dart';
import 'package:redux_dart_basic_tutorial/src/actions.dart';
import 'package:redux_dart_basic_tutorial/src/components/todo_list_item.dart';
import 'package:redux_dart_basic_tutorial/src/reducers.dart';

part 'todo_list.over_react.g.dart';

@Factory()
UiFactory<TodoListProps> TodoList = _$TodoList;

@Props()
class _$TodoListProps extends UiProps {
  List<Todo> todos;
  void Function(int index) onTodoClick;
}

@Component2()
class TodoListComponent extends UiComponent2<TodoListProps> {
  @override
  dynamic render() {
    var children = props.todos
        .asMap()
        .map((index, todo) => (MapEntry(
            index,
            (TodoListItem()
              ..key = index
              ..completed = todo.completed
              ..text = todo.text
              ..toggleTodo = () => props.onTodoClick(index))())))
        .values
        .toList();

    return Dom.ul()(children);
  }
}

List<Todo> getVisibleTodos(List<Todo> todos, VisibilityFilter filter) {
  if (filter == VisibilityFilter.showCompleted) {
    return todos.where((todo) => todo.completed).toList();
  } else if (filter == VisibilityFilter.showActive) {
    return todos.where((todo) => !todo.completed).toList();
  } else {
    return todos;
  }
}

TodoListProps mapStateToProps(AppState state) {
  return TodoList()..todos = getVisibleTodos(state.todos, state.visibilityFilter);
}

TodoListProps mapDispatchToProps(dynamic Function(dynamic) dispatch) {
  return TodoList()..onTodoClick = (index) => dispatch(ToggleTodo(index));
}

UiFactory<TodoListProps> ConnectedTodoList = connect<AppState, TodoListProps>(
  mapDispatchToProps: mapDispatchToProps,
  mapStateToProps: mapStateToProps,
)(TodoList);
