import 'package:over_react/over_react.dart';

part 'todo_list_item.over_react.g.dart';

@Factory()
UiFactory<TodoListItemProps> TodoListItem = _$TodoListItem;

@Props()
class _$TodoListItemProps extends UiProps {
  void Function() toggleTodo;
  bool completed;
  String text;
}

@Component2()
class TodoListItemComponent extends UiComponent2<TodoListItemProps> {
  @override
  dynamic render() {
    return (Dom.li()
      ..style = {'textDecoration': props.completed ? 'line-through' : 'none'}
      ..onClick = (_) {
        props.toggleTodo();
      })(
      '${props.text}',
    );
  }
}
