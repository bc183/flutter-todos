extension Fiter<T> on Stream<List<T>> {
  Stream<List<T>> filter(bool Function(T) where) => map(
        (items) => items.where(where).toList(),
      );
}
