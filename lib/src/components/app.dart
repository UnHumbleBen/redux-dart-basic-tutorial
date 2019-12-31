import 'package:over_react/over_react.dart';
import 'package:redux_dart_basic_tutorial/src/components/add_todo_input.dart';
import 'package:redux_dart_basic_tutorial/src/components/footer.dart';
import 'package:redux_dart_basic_tutorial/src/components/todo_list.dart';
part 'app.over_react.g.dart';

@Factory()
UiFactory<AppProps> App = _$App;

@Props()
class _$AppProps extends UiProps {}

@Component2()
class AppComponent extends UiComponent2<AppProps> {
  @override
  dynamic render() {
    return Dom.div()(
      ConnectedAddTodoInput()(),
      ConnectedTodoList()(),
      Footer()(),
    );
  }
}
