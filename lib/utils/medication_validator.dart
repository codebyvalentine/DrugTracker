// lib/utils/medication_validator.dart
class MedicationValidator {
  static String? validateMedicationName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the medication name';
    }
    return null;
  }

  static String? validateMedicationForm(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select the medication form';
    }
    return null;
  }

  static String? validatePills(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the quantity';
    }
    return null;
  }

  static String? validateFrequencyInterval(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select how often you take this';
    }
    return null;
  }

  static String? validateFrequencyTime(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select when you want to take this';
    }
    return null;
  }
}