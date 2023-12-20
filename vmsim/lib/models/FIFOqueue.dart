class FIFOQueue<T> {
  List<T> data = [];

  void enqueue(T element) {
    data.add(element);
  }

  T dequeue() {
    if (data.isEmpty) {
      throw Exception('Queue is empty');
    }

    return data.removeAt(0);
  }

  T peek() {
    if (data.isEmpty) {
      throw Exception('Queue is empty');
    }

    return data.first;
  }

  void printQueue() {
    for (int i = data.length - 1; i >= 0; i--) {
      print(data[i]);
    }
  }

  int get length => data.length;
}
