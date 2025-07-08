import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

import '../bloc.dart';
import '../model/country_code.dart';
import '../model/login_method.dart';
import 'country_code_picker.dart';

class PhoneAuthLoginButton extends StatefulWidget {
  const PhoneAuthLoginButton({super.key});

  @override
  State<PhoneAuthLoginButton> createState() => _PhoneAuthLoginButtonState();
}

class _PhoneAuthLoginButtonState extends State<PhoneAuthLoginButton> {
  final _phoneController = TextEditingController();
  final _smsController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSendingCode = false;
  bool _isVerifyingCode = false;
  bool _codeSent = false;
  String? _errorMessage;
  CountryCode? _selectedCountry;

  @override
  void initState() {
    super.initState();

    _selectedCountry = const CountryCode(
      name: 'United States',
      flag: '🇺🇸',
      phoneCode: '1',
      countryCode: 'US',
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _smsController.dispose();
    super.dispose();
  }

  void _resetState() {
    setState(() {
      _isSendingCode = false;
      _isVerifyingCode = false;
      _codeSent = false;
      _errorMessage = null;
      _selectedCountry = null;
      _phoneController.clear();
      _smsController.clear();
    });
  }

  String _formatPhoneNumber(String input) {
    // Remove all non-digit characters
    final cleanNumber = input.replaceAll(RegExp(r'[^\d]'), '');

    // If no country is selected, return the input as is
    if (_selectedCountry == null) {
      return cleanNumber;
    }

    // Return with country code prefix
    return '+${_selectedCountry!.phoneCode}$cleanNumber';
  }

  String _extractErrorMessage(dynamic error) {
    final errorString = error.toString();

    // Check if this is the expected phone verification initiated exception
    if (errorString.contains('Phone verification initiated')) {
      return ''; // This is not an error, it's the expected flow
    }

    // Extract the actual error message from Firebase exceptions
    if (errorString.contains('Phone verification failed:')) {
      final startIndex =
          errorString.indexOf('Phone verification failed:') +
          'Phone verification failed:'.length;
      return errorString.substring(startIndex).trim();
    }

    // Remove "Exception:" prefix if present
    if (errorString.startsWith('Exception:')) {
      return errorString.substring('Exception:'.length).trim();
    }

    return errorString;
  }

  void _sendVerificationCode() {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSendingCode = true;
      _errorMessage = null;
    });

    final formattedPhone = _formatPhoneNumber(_phoneController.text);
    final loginMethod = LoginMethodPhone(phoneNumber: formattedPhone);

    context.read<AuthBloc>().add(AuthEvent.login(loginMethod));
  }

  void _verifyCode() {
    if (_smsController.text.isEmpty) return;

    setState(() {
      _isVerifyingCode = true;
      _errorMessage = null;
    });

    final formattedPhone = _formatPhoneNumber(_phoneController.text);
    final loginMethod = LoginMethodPhone(
      phoneNumber: formattedPhone,
      smsCode: _smsController.text,
    );

    context.read<AuthBloc>().add(AuthEvent.login(loginMethod));
  }

  void _resendCode() {
    setState(() {
      _isSendingCode = true;
      _errorMessage = null;
    });

    final formattedPhone = _formatPhoneNumber(_phoneController.text);
    final loginMethod = LoginMethodPhone(phoneNumber: formattedPhone);

    context.read<AuthBloc>().add(AuthEvent.login(loginMethod));
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    if (authState is! AuthStateSignedOut) {
      return const Text(
        "ERROR: Phone login button should only be shown when signed out",
      );
    }

    // Handle state changes from the bloc
    if (authState.error != null && _errorMessage != authState.error) {
      final extractedError = _extractErrorMessage(authState.error!);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _errorMessage = extractedError.isEmpty ? null : extractedError;
          _isSendingCode = false;
          _isVerifyingCode = false;

          // If the error is empty (phone verification initiated), mark code as sent
          if (extractedError.isEmpty && _isSendingCode) {
            _codeSent = true;
          }
        });
      });
    }

    // Handle successful phone verification initiation (no error, not logging in, was sending code)
    if (authState.error == null && !authState.isLoggingIn && _isSendingCode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _codeSent = true;
          _isSendingCode = false;
        });
      });
    }

    // If we're not logging in anymore and there's no error, the verification was successful
    if (!authState.isLoggingIn && _isVerifyingCode && _errorMessage == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _isVerifyingCode = false;
        });
      });
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!_codeSent) ...[
                  // Country code picker
                  CountryCodePicker(
                    selectedCountry: _selectedCountry,
                    onCountrySelected: (country) {
                      setState(() {
                        _selectedCountry = country;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  // Phone number input
                  TextFormField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      hintText: _selectedCountry != null
                          ? 'Enter your phone number'
                          : 'Select country first',
                      prefixIcon: const Icon(Icons.phone),
                      helperText: _selectedCountry != null
                          ? 'Enter your phone number without country code'
                          : 'Please select a country first',
                      suffixText:
                          _selectedCountry != null &&
                              _phoneController.text.isNotEmpty
                          ? '+${_selectedCountry!.phoneCode}${_phoneController.text}'
                          : null,
                    ),
                    keyboardType: TextInputType.phone,
                    enabled: _selectedCountry != null,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (_selectedCountry == null) {
                        return 'Please select a country first';
                      }
                      if (value == null || value.isEmpty) {
                        return 'Please enter a phone number';
                      }
                      if (value.length < 7) {
                        return 'Please enter a complete phone number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _isSendingCode ? null : _sendVerificationCode,
                    icon: _isSendingCode
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                          )
                        : const Icon(Icons.send),
                    label: _isSendingCode
                        ? Shimmer.fromColors(
                            baseColor: Colors.black12,
                            highlightColor: Colors.white,
                            child: const Text('Sending...'),
                          )
                        : const Text('Send Verification Code'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ] else ...[
                  // SMS code input
                  TextFormField(
                    controller: _smsController,
                    decoration: const InputDecoration(
                      labelText: 'Verification Code',
                      hintText: '',
                      prefixIcon: Icon(Icons.sms),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the verification code';
                      }
                      if (value.length != 6) {
                        return 'Please enter a 6-digit code';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isVerifyingCode ? null : _verifyCode,
                          icon: _isVerifyingCode
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Theme.of(context).colorScheme.onPrimary,
                                    ),
                                  ),
                                )
                              : const Icon(Icons.verified),
                          label: _isVerifyingCode
                              ? Shimmer.fromColors(
                                  baseColor: Colors.black12,
                                  highlightColor: Colors.white,
                                  child: const Text('Verifying...'),
                                )
                              : const Text('Verify Code'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: _isSendingCode ? null : _resendCode,
                        child: _isSendingCode
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Resend'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _resetState,
                    child: const Text('Change Phone Number'),
                  ),
                ],
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onErrorContainer,
                          ),
                        ),
                        if (!_codeSent) ...[
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: _isSendingCode
                                ? null
                                : _sendVerificationCode,
                            icon: _isSendingCode
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.refresh),
                            label: Text(
                              _isSendingCode ? 'Retrying...' : 'Retry',
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
