String normalisephonenumber(String phonenumber) {
  final digitsOnly = phonenumber.replaceAll(RegExp(r'\D'), '');
  if (digitsOnly.length == 10) {
    return '+91$digitsOnly';
  } else if (digitsOnly.startsWith('91') && digitsOnly.length == 12) {
    return digitsOnly;
  } else if (digitsOnly.startsWith('0') && digitsOnly.length == 11) {
    return '+91${digitsOnly.substring(1)}';
  }
  return '+$digitsOnly';
}
