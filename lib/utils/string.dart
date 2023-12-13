extension SuffixOperation on String {
  String removeSuffix(String suffix) {
    if (endsWith(suffix)) {
      return substring(0, length - suffix.length);
    }
    return this;
  }

  String replaceSuffix(String suffix, String replacement) {
    if (endsWith(suffix)) {
      return substring(0, length - suffix.length) + replacement;
    }
    return this;
  }
}
