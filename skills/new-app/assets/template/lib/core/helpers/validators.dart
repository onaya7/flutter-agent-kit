import 'package:flutter/widgets.dart';
import 'package:kit_template_app/core/helpers/phone_country.dart';

abstract class Validators {
  static String? required(
    String? v, {
    String message = 'This field is required',
  }) => (v == null || v.trim().isEmpty) ? message : null;

  static String? email(
    String? v, {
    String message = 'Please enter a valid email address',
  }) {
    if (v == null || v.trim().isEmpty) {
      return 'Email address is required';
    }
    return _emailRegex.hasMatch(v.trim()) ? null : message;
  }

  /// `required: false` passes an empty value and rejects only a malformed one.
  static String? phone(
    String? v, {
    PhoneCountry country = PhoneCountry.fallback,
    bool required = true,
    String? message,
  }) {
    final value = v?.trim() ?? '';
    if (value.isEmpty) return required ? 'Phone number is required' : null;
    if (country.isValid(value)) return null;
    return message ?? 'Enter a valid phone number, e.g. ${country.example}';
  }

  static String? minLength(String? v, int min, {String? message}) {
    if (v == null || v.length < min) {
      return message ?? 'Must be at least $min characters';
    }
    return null;
  }

  static String? password(String? v, {int minLength = 8}) {
    if (v == null || v.isEmpty) return 'Password is required';
    if (v.length < minLength) {
      return 'Password must be at least $minLength characters';
    }
    return null;
  }

  static String? match(
    String? v,
    String other, {
    String message = "Values don't match",
  }) => v == other ? null : message;

  /// Runs [validators] in order and returns the first error.
  static FormFieldValidator<String> compose(
    List<FormFieldValidator<String>> validators,
  ) => (v) {
    for (final validate in validators) {
      final result = validate(v);
      if (result != null) return result;
    }
    return null;
  };

  static final _emailRegex = RegExp(
    r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$",
  );
}
