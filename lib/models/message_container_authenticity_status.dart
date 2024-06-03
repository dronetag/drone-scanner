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
