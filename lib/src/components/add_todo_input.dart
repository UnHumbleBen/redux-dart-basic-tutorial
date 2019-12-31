import 'dart:html';

import 'package:over_react/over_react.dart';
import 'package:over_react/over_react_redux.dart';
import 'package:redux_dart_basic_tutorial/src/actions.dart';
import 'package:redux_dart_basic_tutorial/src/reducers.dart';

part 'add_todo_input.over_react.g.dart';

@Factory()
UiFactory<AddTodoInputProps> AddTodoInput = _$AddTodoInput;

@Props()
class _$AddTodoInputProps extends UiProps with ConnectPropsMixin {
  // dynamic Function(dynamic) dispatch;
}

@Component2()
class AddTodoInputComponent extends UiComponent2<AddTodoInputProps> {
  @override
  dynamic render() {
    var input;
    return (Dom.div()(
      (Dom.form()
            ..onSubmit = (e) {
              e.preventDefault();
              if (input.value.trim() == '') {
                return;
              }
              props.dispatch(AddTodo(input.value));
              input.value = '';
            })(
          (Dom.input()
            ..ref = (InputElement node) {
              input = node;
            })(),
          (Dom.button()..type = 'submit')(
            'Add Todo',
          )),
    ));
  }
}

UiFactory<AddTodoInputProps> ConnectedAddTodoInput = connect<AppState, AddTodoInputProps>()(AddTodoInput);
