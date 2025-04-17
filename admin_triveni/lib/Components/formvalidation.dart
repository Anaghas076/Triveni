// form_validation.dart

class FormValidation {
  // Email Validation
  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Please enter an email';
    }
    String pattern =
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'; // Regular expression for email
    RegExp regExp = RegExp(pattern);
    if (!regExp.hasMatch(email)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  // Password Validation
  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Please enter a password';
    }
    // Check for minimum 6 characters
    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  // Confirm Password Validation
  static String? validateConfirmPassword(
      String? confirmPassword, String? password) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'Please confirm your password';
    }
    if (confirmPassword != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  // Contact Number Validation (example: 10 digits)
  static String? validateContact(String? contact) {
    if (contact == null || contact.isEmpty) {
      return 'Please enter a contact number';
    }
    // Regex for 10-digit contact number (you can modify this pattern for specific formats)
    String pattern = r'^[0-9]{10}$';
    RegExp regExp = RegExp(pattern);
    if (!regExp.hasMatch(contact)) {
      return 'Please enter a valid 10-digit contact number';
    }
    return null;
  }

  // Name Validation
  static String? validateName(String? name) {
    if (name == null || name.isEmpty) {
      return 'Please enter your name';
    }
    return null;
  }

  // Address Validation
  static String? validateAddress(String? address) {
    if (address == null || address.isEmpty) {
      return 'Please enter your address';
    }
    return null;
  }

  static String? validateDetails(String? details) {
    if (details == null || details.isEmpty) {
      return 'Please enter details';
    }
    return null;
  }

  static String? validatePrice(String? price) {
    if (price == null || price.isEmpty) {
      return 'Please enter your price';
    }
    final numValue = num.tryParse(price);
    if (numValue == null) {
      return 'Only numbers are allowed';
    }
    if (numValue <= 0) {
      return 'Amount must be greater than zero';
    }
    return null;
  }

  static String? validateCategory(String? category) {
    if (category == null || category.isEmpty) {
      return 'Please enter your category';
    }
    return null;
  }

  static String? validateSubategory(String? category) {
    if (category == null || category.isEmpty) {
      return 'Please enter your subcategory';
    }
    return null;
  }

  static String? validateDescription(String? description) {
    if (description == null || description.isEmpty) {
      return 'Please enter your description';
    }
    return null;
  }

  static String? validatAttribute(String? attribute) {
    if (attribute == null || attribute.isEmpty) {
      return 'Please enter your attribute';
    }
    return null;
  }

  static String? validatPattribute(String? pattribute) {
    if (pattribute == null || pattribute.isEmpty) {
      return 'Please enter your pattribute';
    }
    return null;
  }

  // Dropdown Validation
  static String? validateDropdown(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select an option';
    }
    return null;
  }

  static String? validateDOB(String? value) {
    if (value == null || value.isEmpty) {
      return 'Date of Birth is required';
    }
    DateTime dob = DateTime.parse(value);
    DateTime today = DateTime.now();
    int age = today.year - dob.year;
    if (today.month < dob.month ||
        (today.month == dob.month && today.day < dob.day)) {
      age--;
    }
    if (age < 18) {
      return 'You must be at least 18 years old';
    }
    return null;
  }
}
