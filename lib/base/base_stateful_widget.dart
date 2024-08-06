import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

import 'base_bloc.dart';

abstract class BaseState<T extends StatefulWidget> extends State<T> {
  /// This will hold Rx subscriptions and clear
  /// them in dispose to avoid memory leaks.
  final subscriptions = CompositeSubscription();

  /// Enforce extender to return base bloc so we can clear on dispose.
  /// This will prevent mistakes of forgetting calling dispose of BLoC.
  BaseBloc? getBaseBloc();

  @override
  Widget build(BuildContext context) {
    return buildScreen(context);
  }

  Widget buildScreen(BuildContext context) {
    return const SizedBox.shrink();
  }

  @override
  void dispose() {
    super.dispose();
    subscriptions.clear();

    /// Extender might not have a BLoC implementation yet
    /// and will return null in that case.
    getBaseBloc()?.dispose();
  }

  void hideKeyboard() {
    /// Add hide keyboard event
    getBaseBloc()?.hideKeyboardSubject.add(true);
  }

  Size screenSize(BuildContext context) {
    return MediaQuery.of(context).size;
  }

  double screenWidth(BuildContext context, {double dividedBy = 1}) {
    return screenSize(context).width / dividedBy;
  }
}
