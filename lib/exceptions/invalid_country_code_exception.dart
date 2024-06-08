class InvalidCountryCodeException implements Exception {
  final String message;

  InvalidCountryCodeException([this.message = "Invalid country code"]);
}
