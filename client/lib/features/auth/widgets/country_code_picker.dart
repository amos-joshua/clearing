import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';

import '../model/country_code.dart';

class CountryCodePicker extends StatelessWidget {
  final CountryCode? selectedCountry;
  final ValueChanged<CountryCode> onCountrySelected;
  final String? errorText;

  const CountryCodePicker({
    super.key,
    required this.selectedCountry,
    required this.onCountrySelected,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showCountryPicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(
            color: errorText != null
                ? Theme.of(context).colorScheme.error
                : Theme.of(context).colorScheme.outline,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            if (selectedCountry != null) ...[
              Text(selectedCountry!.flag, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      selectedCountry!.name,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '+${selectedCountry!.phoneCode}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              const Icon(Icons.flag, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Select Country',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
            Icon(
              Icons.arrow_drop_down,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  void _showCountryPicker(BuildContext context) {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      countryListTheme: CountryListThemeData(
        flagSize: 25,
        backgroundColor: Theme.of(context).colorScheme.surface,
        textStyle: Theme.of(context).textTheme.bodyMedium!,
        bottomSheetHeight: 500,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
        inputDecoration: InputDecoration(
          labelText: 'Search',
          hintText: 'Start typing to search',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ),
      ),
      onSelect: (Country country) {
        final countryCode = CountryCode(
          name: country.name,
          flag: country.flagEmoji,
          phoneCode: country.phoneCode,
          countryCode: country.countryCode,
        );
        onCountrySelected(countryCode);
      },
    );
  }
}
