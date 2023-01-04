extension StringExtention on String {
  String removeNonAlphanumeric() {
    return replaceAll(RegExp('[^A-Za-z0-9]'), '');
  }
}
