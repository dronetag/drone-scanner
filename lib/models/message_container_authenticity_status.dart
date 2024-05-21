/// Represents the level of trust in the authenticity of collected data.
enum MessageContainerAuthenticityStatus {
  // verified by authority/multilateration
  verified,
  // default
  untrusted,
  // signs if questionable authenticity exist
  suspicious,
  // high certainty of falsehood
  counterfeit
}

// only suspicious and counterfeit statuses are displayed in UI,
// temporary measure until verification is complete
extension MessageContainerAuthenticityStatusExtension
    on MessageContainerAuthenticityStatus {
  bool get shouldBeDisplayed {
    return this == MessageContainerAuthenticityStatus.suspicious ||
        this == MessageContainerAuthenticityStatus.counterfeit;
  }
}
