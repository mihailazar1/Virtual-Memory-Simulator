class StackLRU<T> {
  List<T> _data = [];

  /// Pushes an element onto the stack
  void push(T element) {
    _data.add(element);
  }

  /// Pops the top element off the stack
  T pop() {
    if (_data.isEmpty) {
      throw Exception('Stack is empty');
    }

    return _data.removeLast();
  }

  /// Returns the top element of the stack (without removing it)
  T peek() {
    if (_data.isEmpty) {
      throw Exception('Stack is empty');
    }
    return _data.last;
  }

  T lru() {
    if (_data.isEmpty) {
      throw Exception('Stack is empty');
    }
    return _data.first;
  }

  /// Moves an element to the top of the stack
  void moveToTop(T element) {
    if (!_data.contains(element)) {
      throw Exception('Element not found in the stack');
    }

    for (int i = _data.length - 1; i >= 0; i--) {
      if (_data[i] == element) {
        // Move the element to the top
        T topElement = _data.removeAt(i);
        _data.insert(_data.length, topElement);
        break;
      }
    }
  }

  void printStack() {
    for (int i = _data.length - 1; i >= 0; i--) {
      print(_data[i]);
      print(' ');
    }

    print('\n');
  }
}
