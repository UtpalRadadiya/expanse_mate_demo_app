import 'package:rxdart/rxdart.dart';

abstract class BaseBloc {
  final subscriptions = CompositeSubscription();

  void dispose() {
    subscriptions.dispose();
  }
}
