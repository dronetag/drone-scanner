/// Represents the level of trust in the authenticity of collected data.
enum MessageContainerAuthenticityStatus {
  // verified by authority/multilateration
  verified,
  // reasonable signs of authenticity exist
  trusted,
  // default
  untrusted,
  // signs of questionable authenticity exist
  suspicious,
  // high certainty of falsehood
  counterfeit
}
