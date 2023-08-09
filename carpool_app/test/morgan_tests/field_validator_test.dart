import 'package:flutter_test/flutter_test.dart';
import 'package:carpool_app/main/utils/field_validator.dart';

void main() {
  test('Test Email Validation', () {
    String validEmail_1 = "valid@northeastern.edu";
    String validEmail_2 = "valid@gmail.com";
    String invalidEmail_1 = "invalidEmail@hotmail.com";
    String invalidEmail_2 = "invalid@northeastern.com";
    String invalidEmail_3 = "";
    expect(FieldValidator.validateEmail(validEmail_1), true);
    expect(FieldValidator.validateEmail(validEmail_2), true);
    expect(FieldValidator.validateEmail(invalidEmail_1), false);
    expect(FieldValidator.validateEmail(invalidEmail_2), false);
    expect(FieldValidator.validateEmail(invalidEmail_3), false);
  });

  test('Test password Validation', () {
    String pwdValid = "Alpha1!";
    String pwdNoNumber = "Alpha!!";
    String pwdNoChar = "123456!";
    String pwdNoSpecial = "Alpha12";
    String pwdEmpty = "";
    String pwdTooShort = "Aaa1!";
    expect(FieldValidator.validatePassword(pwdValid), true);
    expect(FieldValidator.validatePassword(pwdNoNumber), false);
    expect(FieldValidator.validatePassword(pwdNoChar), false);
    expect(FieldValidator.validatePassword(pwdNoSpecial), false);
    expect(FieldValidator.validatePassword(pwdEmpty), false);
    expect(FieldValidator.validatePassword(pwdTooShort), false);
  });

  test('Test nuid Validation', () {
    String nuidValid = "002765433";
    String nuidEmpty = "";
    String nuidNonParseable = "oo2765433";
    expect(FieldValidator.validateNUID(nuidValid), true);
    expect(FieldValidator.validateNUID(nuidEmpty), false);
    expect(FieldValidator.validateNUID(nuidNonParseable), false);
  });

  test('Test phone number Validation', () {
    String validPhone1 = "123-456-7890";
    String validPhone2 = "123 456 7890";
    String validPhone3 = "(123) 456-7890";
    String validPhone4 = "123.456.7890";
    String validPhone5 = "+91 (123) 456-7890";
    String invalidPhone1 = "555-5555";
    String invalidPhone2 = "non-number";
    String invalidPhone3 = "";
    expect(FieldValidator.validatePhoneNo(validPhone1), true);
    expect(FieldValidator.validatePhoneNo(validPhone2), true);
    expect(FieldValidator.validatePhoneNo(validPhone3), true);
    expect(FieldValidator.validatePhoneNo(validPhone4), true);
    expect(FieldValidator.validatePhoneNo(validPhone5), true);
    expect(FieldValidator.validatePhoneNo(invalidPhone1), false);
    expect(FieldValidator.validatePhoneNo(invalidPhone2), false);
    expect(FieldValidator.validatePhoneNo(invalidPhone3), false);
  });

  test('Test matching inputs Validation', () {
    String matches1 = "MatchingInput";
    String matches2 = "MatchingInput";
    String nonMatch = "Match!ngInput";
    String empty1 = "";
    String empty2 = "";
    expect(FieldValidator.inputsMatch(matches1, matches2), true);
    expect(FieldValidator.inputsMatch(matches1, nonMatch), false);
    expect(FieldValidator.inputsMatch(empty1, empty2), false);
  });
}
