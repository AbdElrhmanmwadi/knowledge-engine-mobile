typedef JsonMap = Map<String, dynamic>;

/// Base API response model containing the common signal field.
class ApiResponseBase {
  const ApiResponseBase({required this.signal});

  final String signal;

  bool get isSuccess => signal.toLowerCase() == 'success';

  factory ApiResponseBase.fromJson(JsonMap json) {
    return ApiResponseBase(signal: readRequiredString(json, 'signal'));
  }

  ApiResponseBase copyWith({String? signal}) {
    return ApiResponseBase(signal: signal ?? this.signal);
  }

  JsonMap toJson() {
    return <String, dynamic>{'signal': signal};
  }

  static String readRequiredString(JsonMap json, String key) {
    final value = json[key];
    if (value is String) {
      return value;
    }
    if (value != null) {
      return value.toString();
    }
    throw FormatException('Missing required field "$key".');
  }

  static String? readOptionalString(JsonMap json, String key) {
    final value = json[key];
    if (value == null) {
      return null;
    }
    if (value is String) {
      return value;
    }
    return value.toString();
  }

  static int readRequiredInt(JsonMap json, String key) {
    final value = readOptionalInt(json, key);
    if (value == null) {
      throw FormatException('Missing required integer field "$key".');
    }
    return value;
  }

  static int? readOptionalInt(JsonMap json, String key) {
    final value = json[key];
    if (value == null) {
      return null;
    }
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value);
    }
    throw FormatException('Invalid integer value for field "$key".');
  }

  static double readRequiredDouble(JsonMap json, String key) {
    final value = readOptionalDouble(json, key);
    if (value == null) {
      throw FormatException('Missing required double field "$key".');
    }
    return value;
  }

  static double? readOptionalDouble(JsonMap json, String key) {
    final value = json[key];
    if (value == null) {
      return null;
    }
    if (value is double) {
      return value;
    }
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value);
    }
    throw FormatException('Invalid double value for field "$key".');
  }

  static bool? readOptionalBool(JsonMap json, String key) {
    final value = json[key];
    if (value == null) {
      return null;
    }
    if (value is bool) {
      return value;
    }
    if (value is String) {
      final normalized = value.toLowerCase();
      if (normalized == 'true') {
        return true;
      }
      if (normalized == 'false') {
        return false;
      }
    }
    throw FormatException('Invalid boolean value for field "$key".');
  }

  static DateTime? readOptionalDateTime(JsonMap json, String key) {
    final value = json[key];
    if (value == null) {
      return null;
    }
    if (value is DateTime) {
      return value;
    }
    if (value is String) {
      return DateTime.tryParse(value);
    }
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    throw FormatException('Invalid date value for field "$key".');
  }

  static JsonMap readRequiredJsonMap(JsonMap json, String key) {
    final value = json[key];
    if (value == null) {
      throw FormatException('Missing required map field "$key".');
    }
    return normalizeJsonMap(value, fieldName: key);
  }

  static JsonMap? readOptionalJsonMap(JsonMap json, String key) {
    final value = json[key];
    if (value == null) {
      return null;
    }
    return normalizeJsonMap(value, fieldName: key);
  }

  static List<JsonMap>? readOptionalJsonMapList(JsonMap json, String key) {
    final value = json[key];
    if (value == null) {
      return null;
    }
    if (value is! List) {
      throw FormatException('Field "$key" must be a list.');
    }
    return value
        .map((item) => normalizeJsonMap(item, fieldName: key))
        .toList(growable: false);
  }

  static JsonMap normalizeJsonMap(dynamic value, {required String fieldName}) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return value.map(
        (dynamic key, dynamic item) => MapEntry(key.toString(), item),
      );
    }
    throw FormatException('Field "$fieldName" must be a JSON object.');
  }
}
