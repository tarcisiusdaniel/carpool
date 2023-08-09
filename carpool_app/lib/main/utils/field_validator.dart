class FieldValidator {
  /// Uses [RegExp] to verify that provided [String] email is valid format
  /// Email must belong to neu or gmail domain
  static bool validateEmail(String value) {
    String pattern = r'^[A-Za-z0-9\._%+-]+@northeastern\.edu$';
    String gmail = r'^[A-Za-z0-9\._%+-]+@gmail\.com$';
    RegExp regExp = RegExp(pattern);
    RegExp regExp2 = RegExp(gmail);
    return value.isNotEmpty &&
        (regExp.hasMatch(value) || regExp2.hasMatch(value));
  }

  /// Uses [RegExp] to validate provided [String] password meets required security rules
  static bool validatePassword(String value) {
    RegExp hasNumber = RegExp(r'\d');
    RegExp hasLetter = RegExp(r'[a-zA-Z]');
    RegExp hasSpecialChar = RegExp(r'[!@#$%^&*(),.?":{}|<>]');
    return value.isNotEmpty &&
        value.length >= 6 &&
        hasLetter.hasMatch(value) &&
        hasNumber.hasMatch(value) &&
        hasSpecialChar.hasMatch(value);
  }

  /// Validates that a [String] value and [String} confirm-value are equal
  /// - Used when confirming email during signup
  /// - Used when confirming password during signup
  static bool inputsMatch(String val1, String val2) {
    return val1.isNotEmpty && val2.isNotEmpty && val1.trim() == val2.trim();
  }

  /// Validates that the [String] NUID representation matches expected format
  static bool validateNUID(String value) {
    return value.isNotEmpty &&
        (double.tryParse(value) != null) &&
        value.length == 9;
  }

  /// Uses [RegExp] to validate the [String] Phone# matches one of several valid formats
  static bool validatePhoneNo(String value) {
    RegExp isPhoneNo =
        RegExp(r'^(\+\d{1,2}\s)?\(?\d{3}\)?[\s.-]?\d{3}[\s.-]?\d{4}$');
    return value.isNotEmpty && isPhoneNo.hasMatch(value);
  }
}
