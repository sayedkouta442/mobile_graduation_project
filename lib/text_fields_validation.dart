class TextFieldsValidation {
  static String? emailValidation(String? email) {
    if (email == null || email.isEmpty) {
      return 'Email is Required';
    }

    if (!email.contains('@gmail.com')) {
      return 'Email is not Valid';
    }

    return null;
  }

  static String? emptyValidation(String? value) {
    if (value == null || value.isEmpty) {
      return 'This Field is Required';
    }
    return null;
  }
}
