class Action {
  Action({this.type, this.value});

  final String type;
  final dynamic value;

  Map<String, dynamic> toJson() {
    return {'type': type, 'value': value};
  }
}

enum VisibilityFilter { showAll, showCompleted, showActive }

String filterToJson(VisibilityFilter filter) {
  if (filter == VisibilityFilter.showAll) {
    return 'SHOW_ALL';
  } else if (filter == VisibilityFilter.showCompleted) {
    return 'SHOW_COMPLETED';
  } else if (filter == VisibilityFilter.showActive) {
    return 'SHOW_ACTIVE';
  } else {
    return filter.toString();
  }
}

class AddTodo extends Action {
  AddTodo([String text]) : super(type: 'ADD_TODO', value: text);
}

class ToggleTodo extends Action {
  ToggleTodo([int index]) : super(type: 'TOGGLE_TODO', value: index);
}

class SetVisibilityFilter extends Action {
  SetVisibilityFilter([VisibilityFilter filter]) : super(type: 'SET_VISIBILITY_FILTER', value: filter);
}
