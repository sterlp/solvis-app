
// typedef AsyncWidgetBuilder<T> = Widget Function(BuildContext context, AsyncSnapshot<T> snapshot);

class EventCounter<T> {
  final int _maxCount;
  int _events = 0;
  T? _event;

  EventCounter(this._maxCount);

  EventCounter<T> count(T event) {
    ++_events;
    _event = event;
    return this;
  }

  EventCounter<T> reset() {
    _event = null;
    _events = 0;
    return this;
  }

  bool get isMaxReached => _events > _maxCount;
  bool get isMaxNotReached => _events <= _maxCount;
  int get eventCount => _events;

  T? get event => _event;

  void maxReached(T event) {
    _events = _maxCount + 1;
    _event = event;
  }
}