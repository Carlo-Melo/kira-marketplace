Map<String, dynamic>? asMap(dynamic value) {
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }
  return null;
}

int? asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

double? asDouble(dynamic value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

String? asString(dynamic value) {
  if (value == null) return null;
  return value.toString();
}

DateTime? asDateTime(dynamic value) {
  final text = asString(value);
  if (text == null || text.isEmpty) return null;
  return DateTime.tryParse(text);
}
