extension FilterNonNull<T> on List<T?> {
  List<T> filterNonNull() => where((e) => e != null).cast<T>().toList();
}
