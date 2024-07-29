class BaseUiState<T> {
  /// Holds error is state is [UIState.error]
  dynamic error;

  /// Holds data is state is [UIState.completed]
  T? data;

  /// Holds current [UIState]
  UIState? _state;

  BaseUiState();

  /// Returns [BaseUiState] with [UIState.loading]
  BaseUiState.loading() : _state = UIState.loading;

  /// Returns [BaseUiState] with [UIState.completed]
  BaseUiState.completed({this.data}) : _state = UIState.completed;

  /// Returns [BaseUiState] with [UIState.error]
  BaseUiState.error(this.error) : _state = UIState.error;

  /// Returns true if the current [state] is [UIState.loading]
  bool isLoading() => _state == UIState.loading;

  /// Returns true if the current [state] is [UIState.completed]
  bool isCompleted() => _state == UIState.completed;

  /// Returns true if the current [state] is [UIState.error]
  bool isError() => _state == null || _state == UIState.error;

  @override
  String toString() {
    return 'State is $_state';
  }
}

/// UI States
enum UIState {
  loading,
  completed,
  error,
}
