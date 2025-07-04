class CountryCode {
  final String name;
  final String flag;
  final String phoneCode;
  final String countryCode;

  const CountryCode({
    required this.name,
    required this.flag,
    required this.phoneCode,
    required this.countryCode,
  });

  @override
  String toString() => '$flag $name (+$phoneCode)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CountryCode &&
        other.name == name &&
        other.flag == flag &&
        other.phoneCode == phoneCode &&
        other.countryCode == countryCode;
  }

  @override
  int get hashCode => Object.hash(name, flag, phoneCode, countryCode);
}
