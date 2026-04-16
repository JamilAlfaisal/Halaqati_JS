extension StringTransformations on String {
  /// Capitalizes only the first letter of the string.
  String toFirstLetterUpper() {
    if (this.isEmpty) return this;
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }

  /// Converts a sentence (e.g., "hello world") into camelCase ("helloWorld").
  String toCamelCase() {
    if (this.isEmpty) return this;

    List<String> words = this.toLowerCase().split(RegExp(r'[\s_-]+'));
    if (words.isEmpty) return this;

    String result = words[0]; // Keep the first word lowercase
    for (int i = 1; i < words.length; i++) {
      result += words[i].toFirstLetterUpper();
    }
    return result;
  }

  String truncate({int maxLength = 10}) {
    if (this.length <= maxLength) {
      return this;
    }
    return '${this.substring(0, maxLength)}...';
  }
}