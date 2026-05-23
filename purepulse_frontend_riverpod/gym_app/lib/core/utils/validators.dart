class Validators {
  Validators._();

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email address is required';
    }

    final emailRegex = RegExp(
      r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$",
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full name is required';
    }
    if (value.trim().length < 3) {
      return 'Name must be at least 3 characters long';
    }
    return null;
  }
}