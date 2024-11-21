
// Helper for formatted dates
String formatDate(DateTime date) {
  return "${date.day}-${date.month}-${date.year}";
}

// Helper for validating email input
bool isValidEmail(String email) {
  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
  return emailRegex.hasMatch(email);
}
