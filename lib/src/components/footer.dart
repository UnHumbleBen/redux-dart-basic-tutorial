import 'package:over_react/over_react.dart';
import 'package:redux_dart_basic_tutorial/src/actions.dart';
import 'package:redux_dart_basic_tutorial/src/components/link.dart';

part 'footer.over_react.g.dart';

@Factory()
UiFactory<FooterProps> Footer = _$Footer;

@Props()
class _$FooterProps extends UiProps {}

@Component2()
class FooterComponent extends UiComponent2<FooterProps> {
  @override
  dynamic render() {
    return Dom.p()(
      'Show: ',
      (ConnectedLink()..filter = VisibilityFilter.showAll)(
        'All',
      ),
      (ConnectedLink()..filter = VisibilityFilter.showActive)(
        'Active',
      ),
      (ConnectedLink()..filter = VisibilityFilter.showCompleted)(
        'Completed',
      ),
    );
  }
}
