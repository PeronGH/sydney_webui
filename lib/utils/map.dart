extension CopyWithExtension<K, V> on Map<K, V> {
  Map<K, V> copyWith(K key, V value) {
    return Map<K, V>.from(this)..[key] = value;
  }
}
