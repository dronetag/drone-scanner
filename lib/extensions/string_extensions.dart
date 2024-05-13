extension StringExtention on String {
  String removeNonAlphanumeric() {
    return replaceAll(RegExp('[^A-Za-z0-9]'), '');
  }

  String capitalize() {
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }
}
