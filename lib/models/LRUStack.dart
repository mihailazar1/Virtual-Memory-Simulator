class StackLRU<T> {
  List<T> data = [];

  // Pushes an element onto the stack
  void push(T element) {
    data.add(element);
  }

  // Pops the top element off the stack
  T pop() {
    if (data.isEmpty) {
      throw Exception('Stack is empty');
    }

    return data.removeLast();
  }

  // Returns the top element of the stack without removing it
  T peek() {
    if (data.isEmpty) {
      throw Exception('Stack is empty');
    }
    return data.last;
  }

  T lru() {
    if (data.isEmpty) {
      throw Exception('Stack is empty');
    }
    return data.first;
  }

  void moveToTop(T element) {
    if (!data.contains(element)) {
      throw Exception('Element not found in the stack');
    }

    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == element) {
        T topElement = data.removeAt(i);
        data.insert(data.length, topElement);
        break;
      }
    }
  }

  void printStack() {
    for (int i = data.length - 1; i >= 0; i--) {
      print(data[i]);
      print(' ');
    }

    print('\n');
  }
}
