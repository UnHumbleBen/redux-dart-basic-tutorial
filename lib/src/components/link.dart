import 'package:over_react/over_react.dart';
import 'package:over_react/over_react_redux.dart';
import 'package:redux_dart_basic_tutorial/src/actions.dart';
import 'package:redux_dart_basic_tutorial/src/reducers.dart';

part 'link.over_react.g.dart';

@Factory()
UiFactory<LinkProps> Link = _$Link;

@Props()
class _$LinkProps extends UiProps {
  bool active;
  VisibilityFilter filter;
  void Function() setVisibilityFilter;
}

@Component2()
class LinkComponent extends UiComponent2<LinkProps> {
  @override
  dynamic render() {
    return (Dom.button()
      ..style = {'marginLeft': '4px'}
      ..disabled = props.active
      ..onClick = (e) {
        e.preventDefault();
        props.setVisibilityFilter();
      })(
      props.children,
    );
  }
}

LinkProps mapStateToPropsWithOwnProps(AppState state, LinkProps ownProps) {
  return Link()..active = state.visibilityFilter == ownProps.filter;
}

LinkProps mapDispatchToPropsWithOwnProps(dynamic Function(dynamic) dispatch, LinkProps ownProps) {
  return Link()..setVisibilityFilter = () => dispatch(SetVisibilityFilter(ownProps.filter));
}

UiFactory<LinkProps> ConnectedLink = connect<AppState, LinkProps>(
  mapStateToPropsWithOwnProps: mapStateToPropsWithOwnProps,
  mapDispatchToPropsWithOwnProps: mapDispatchToPropsWithOwnProps,
)(Link);
