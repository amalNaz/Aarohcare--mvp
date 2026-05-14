import 'package:flutter/material.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const supportedLocales = [Locale('en'), Locale('ml')];

  static AppLocalizations of(BuildContext context) {
    final localization = Localizations.of<AppLocalizations>(
      context,
      AppLocalizations,
    );
    assert(localization != null, 'No AppLocalizations found in context');
    return localization!;
  }

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appTitle': 'Doctor Booking App',
      'hospitalName': 'AL SHIFA',
      'profile': 'Profile',
      'logout': 'Logout',
      'bookAppointment': 'Book Appointment',
      'name': 'Name',
      'age': 'Age',
      'selectDoctor': 'Select Doctor',
      'pleaseEnterName': 'Please enter name',
      'pleaseEnterAge': 'Please enter age',
      'enterValidAge': 'Enter valid age between 1 and 120',
      'pleaseSelectDoctor': 'Please select doctor',
      'clinicName': 'Alshifa Medicals (Staffs)',
      'language': 'Language',
      'english': 'English',
      'malayalam': 'Malayalam',
      'bookingConfirmation': 'Booking Confirmation',
      'bookingSuccessful': 'Booking Successful!',
      'appointmentConfirmed': 'Your appointment has been confirmed',
      'appointmentDetails': 'Appointment Details',
      'liveTokenStatus': 'Live Token Status',
      'tokenNumber': 'Token Number',
      'otpNumber': 'OTP Number',
      'patientName': 'Patient Name',
      'clinic': 'Clinic',
      'doctor': 'Doctor',
      'years': 'years',
      'yourTokenNumber': 'Your Token Number',
      'viewLiveTokenStatus': 'View Live Token Status',
      'bookAnotherAppointment': 'Book Another Appointment',
      'guest': 'Guest'
      ,
      'login': 'Login',
      'signIn': 'Sign In',
      'loginHelpText': 'Use your username or phone number and password',
      'usernameOrPhone': 'Username or Phone Number',
      'pleaseEnterUsernameOrPhone': 'Please enter username or phone number',
      'password': 'Password',
      'confirmPassword': 'Confirm Password',
      'pleaseEnterPassword': 'Please enter password',
      'newUserRegisterHere': 'New user? Register here',
      'accountNotFound': 'Account not found. Please register first.',
      'loginSuccess': 'Login successful. Welcome back!',
      'createAccount': 'Create Account',
      'freshUserRegistration': 'Fresh User Registration',
      'userName': 'User Name',
      'phoneNumber': 'Phone Number',
      'place': 'Place',
      'pleaseEnterUserName': 'Please enter user name',
      'pleaseEnterPhoneNumber': 'Please enter phone number',
      'invalidTenDigitPhone': 'Enter a valid 10-digit phone number',
      'pleaseEnterPlace': 'Please enter place',
      'passwordMinLength': 'Password must be at least 6 characters',
      'pleaseConfirmPassword': 'Please confirm password',
      'passwordsDoNotMatch': 'Passwords do not match',
      'register': 'Register',
      'phoneExistsLogin': 'Phone number already exists. Please login.',
      'registrationSuccess': 'Registration successful. You can login now.'
      ,
      'bookingDate': 'Booking Date',
      'pleaseSelectDate': 'Please select date',
      'downloadBookingDetails': 'Download Booking Details',
      'downloadSuccess': 'Booking details downloaded',
      'downloadNotSupported': 'Download is supported on web build.',
      'areYouAdmin': 'Are you an admin user?',
      'adminLogin': 'Admin Login',
      'adminLoginSuccess': 'Admin login successful. Welcome!',
      'invalidAdminCredentials': 'Invalid admin credentials',
      'adminHome': 'Admin Dashboard',
      'manageBookings': 'Manage Bookings',
      'viewReports': 'View Reports',
      'systemSettings': 'System Settings',
      'adminUsers': 'Admin Users',
      'allBookings': 'All Bookings',
      'pending': 'Pending',
      'completed': 'Completed',
      'cancelled': 'Cancelled'
    },
    'ml': {
      'appTitle': 'ഡോക്ടർ ബുക്കിംഗ് ആപ്പ്',
      'hospitalName': 'അൽ ഷിഫ',
      'profile': 'പ്രൊഫൈൽ',
      'logout': 'ലോഗ്ഔട്ട്',
      'bookAppointment': 'അപ്പോയിന്റ്മെന്റ് ബുക്ക് ചെയ്യുക',
      'name': 'പേര്',
      'age': 'പ്രായം',
      'selectDoctor': 'ഡോക്ടറെ തിരഞ്ഞെടുക്കുക',
      'pleaseEnterName': 'ദയവായി പേര് നൽകുക',
      'pleaseEnterAge': 'ദയവായി പ്രായം നൽകുക',
      'enterValidAge': '1 മുതൽ 120 വരെ സാധുവായ പ്രായം നൽകുക',
      'pleaseSelectDoctor': 'ദയവായി ഡോക്ടറെ തിരഞ്ഞെടുക്കുക',
      'clinicName': 'അൽഷഫാ മെഡിക്കൽസ് (സ്റ്റാഫ്)',
      'language': 'ഭാഷ',
      'english': 'ഇംഗ്ലീഷ്',
      'malayalam': 'മലയാളം',
      'bookingConfirmation': 'ബുക്കിംഗ് സ്ഥിരീകരണം',
      'bookingSuccessful': 'ബുക്കിംഗ് വിജയിച്ചു!',
      'appointmentConfirmed': 'നിങ്ങളുടെ അപ്പോയിന്റ്മെന്റ് സ്ഥിരീകരിച്ചു',
      'appointmentDetails': 'അപ്പോയിന്റ്മെന്റ് വിശദാംശങ്ങൾ',
      'liveTokenStatus': 'ലൈവ് ടോക്കൺ നില',
      'tokenNumber': 'ടോക്കൺ നമ്പർ',
      'otpNumber': 'ഒടിപി നമ്പർ',
      'patientName': 'രോഗിയുടെ പേര്',
      'clinic': 'ക്ലിനിക്',
      'doctor': 'ഡോക്ടർ',
      'years': 'വയസ്',
      'yourTokenNumber': 'നിങ്ങളുടെ ടോക്കൺ നമ്പർ',
      'viewLiveTokenStatus': 'ലൈവ് ടോക്കൺ നില കാണുക',
      'bookAnotherAppointment': 'മറ്റൊരു അപ്പോയിന്റ്മെന്റ് ബുക്ക് ചെയ്യുക',
      'guest': 'അതിഥി',
      'login': 'ലോഗിൻ',
      'signIn': 'സൈൻ ഇൻ',
      'loginHelpText': 'ഉപയോക്തൃനാമം അല്ലെങ്കിൽ ഫോൺ നമ്പർയും പാസ്‌വേഡും ഉപയോഗിക്കുക',
      'usernameOrPhone': 'ഉപയോക്തൃനാമം അല്ലെങ്കിൽ ഫോൺ നമ്പർ',
      'pleaseEnterUsernameOrPhone': 'ദയവായി ഉപയോക്തൃനാമം അല്ലെങ്കിൽ ഫോൺ നമ്പർ നൽകുക',
      'password': 'പാസ്‌വേഡ്',
      'confirmPassword': 'പാസ്‌വേഡ് സ്ഥിരീകരിക്കുക',
      'pleaseEnterPassword': 'ദയവായി പാസ്‌വേഡ് നൽകുക',
      'newUserRegisterHere': 'പുതിയ ഉപയോക്താവാണോ? ഇവിടെ രജിസ്റ്റർ ചെയ്യൂ',
      'accountNotFound': 'അക്കൗണ്ട് കണ്ടെത്തിയില്ല. ആദ്യം രജിസ്റ്റർ ചെയ്യുക.',
      'loginSuccess': 'ലോഗിൻ വിജയകരം. വീണ്ടും സ്വാഗതം!',
      'createAccount': 'അക്കൗണ്ട് സൃഷ്ടിക്കുക',
      'freshUserRegistration': 'പുതിയ ഉപയോക്തൃ രജിസ്ട്രേഷൻ',
      'userName': 'ഉപയോക്തൃനാമം',
      'phoneNumber': 'ഫോൺ നമ്പർ',
      'place': 'സ്ഥലം',
      'pleaseEnterUserName': 'ദയവായി ഉപയോക്തൃനാമം നൽകുക',
      'pleaseEnterPhoneNumber': 'ദയവായി ഫോൺ നമ്പർ നൽകുക',
      'invalidTenDigitPhone': 'സാധുവായ 10 അക്ക ഫോൺ നമ്പർ നൽകുക',
      'pleaseEnterPlace': 'ദയവായി സ്ഥലം നൽകുക',
      'passwordMinLength': 'പാസ്‌വേഡ് കുറഞ്ഞത് 6 അക്ഷരങ്ങളെങ്കിലും വേണം',
      'pleaseConfirmPassword': 'ദയവായി പാസ്‌വേഡ് സ്ഥിരീകരിക്കുക',
      'passwordsDoNotMatch': 'പാസ്‌വേഡുകൾ പൊരുത്തപ്പെടുന്നില്ല',
      'register': 'രജിസ്റ്റർ',
      'phoneExistsLogin': 'ഈ ഫോൺ നമ്പർ നിലവിലുണ്ട്. ദയവായി ലോഗിൻ ചെയ്യുക.',
      'registrationSuccess': 'രജിസ്ട്രേഷൻ വിജയകരം. ഇനി ലോഗിൻ ചെയ്യാം.',
      'bookingDate': 'ബുക്കിംഗ് തീയതി',
      'pleaseSelectDate': 'ദയവായി തീയതി തിരഞ്ഞെടുക്കുക',
      'downloadBookingDetails': 'ബുക്കിംഗ് വിശദാംശങ്ങൾ ഡൗൺലോഡ് ചെയ്യുക',
      'downloadSuccess': 'ബുക്കിംഗ് വിശദാംശങ്ങൾ ഡൗൺലോഡ് ചെയ്തു',
      'downloadNotSupported': 'ഡൗൺലോഡ് വെബ് പതിപ്പിൽ മാത്രമേ ലഭ്യമാകൂ.',
      'areYouAdmin': 'നിങ്ങൾ ഒരു അഡ്മിൻ ഉപയോക്താവാണോ?',
      'adminLogin': 'അഡ്മിൻ ലോഗിൻ',
      'adminLoginSuccess': 'അഡ്മിൻ ലോഗിൻ വിജയകരം. സ്വാഗതം!',
      'invalidAdminCredentials': 'അസാധുവായ അഡ്മിൻ കണക്കുകൾ',
      'adminHome': 'അഡ്മിൻ ഡാഷ്‌ബോർഡ്',
      'manageBookings': 'ബുക്കിംഗുകൾ കൈകാര്യം ചെയ്യുക',
      'viewReports': 'റിപ്പോർട്ടുകൾ കാണുക',
      'systemSettings': 'സിസ്റ്റം സെറ്റിംഗ്‌സ്',
      'adminUsers': 'അഡ്മിൻ ഉപയോക്താക്കൾ',
      'allBookings': 'എല്ലാ ബുക്കിംഗുകൾ',
      'pending': 'പെൻഡിംഗ്',
      'completed': 'പൂർത്തിയായ',
      'cancelled': 'റദ്ദായ്‌ക്കπ്പെട്ട'
    },
  };

  String _t(String key) => _localizedValues[locale.languageCode]?[key] ??
      _localizedValues['en']![key]!;

  String get appTitle => _t('appTitle');
  String get hospitalName => _t('hospitalName');
  String get profile => _t('profile');
  String get logout => _t('logout');
  String get bookAppointment => _t('bookAppointment');
  String get name => _t('name');
  String get age => _t('age');
  String get selectDoctor => _t('selectDoctor');
  String get pleaseEnterName => _t('pleaseEnterName');
  String get pleaseEnterAge => _t('pleaseEnterAge');
  String get enterValidAge => _t('enterValidAge');
  String get pleaseSelectDoctor => _t('pleaseSelectDoctor');
  String get clinicName => _t('clinicName');
  String get language => _t('language');
  String get english => _t('english');
  String get malayalam => _t('malayalam');
  String get bookingConfirmation => _t('bookingConfirmation');
  String get bookingSuccessful => _t('bookingSuccessful');
  String get appointmentConfirmed => _t('appointmentConfirmed');
  String get appointmentDetails => _t('appointmentDetails');
  String get liveTokenStatus => _t('liveTokenStatus');
  String get tokenNumber => _t('tokenNumber');
  String get otpNumber => _t('otpNumber');
  String get patientName => _t('patientName');
  String get clinic => _t('clinic');
  String get doctor => _t('doctor');
  String get years => _t('years');
  String get yourTokenNumber => _t('yourTokenNumber');
  String get viewLiveTokenStatus => _t('viewLiveTokenStatus');
  String get bookAnotherAppointment => _t('bookAnotherAppointment');
  String get guest => _t('guest');
  String get login => _t('login');
  String get signIn => _t('signIn');
  String get loginHelpText => _t('loginHelpText');
  String get usernameOrPhone => _t('usernameOrPhone');
  String get pleaseEnterUsernameOrPhone => _t('pleaseEnterUsernameOrPhone');
  String get password => _t('password');
  String get confirmPassword => _t('confirmPassword');
  String get pleaseEnterPassword => _t('pleaseEnterPassword');
  String get newUserRegisterHere => _t('newUserRegisterHere');
  String get accountNotFound => _t('accountNotFound');
  String get loginSuccess => _t('loginSuccess');
  String get createAccount => _t('createAccount');
  String get freshUserRegistration => _t('freshUserRegistration');
  String get userName => _t('userName');
  String get phoneNumber => _t('phoneNumber');
  String get place => _t('place');
  String get pleaseEnterUserName => _t('pleaseEnterUserName');
  String get pleaseEnterPhoneNumber => _t('pleaseEnterPhoneNumber');
  String get invalidTenDigitPhone => _t('invalidTenDigitPhone');
  String get pleaseEnterPlace => _t('pleaseEnterPlace');
  String get passwordMinLength => _t('passwordMinLength');
  String get pleaseConfirmPassword => _t('pleaseConfirmPassword');
  String get passwordsDoNotMatch => _t('passwordsDoNotMatch');
  String get register => _t('register');
  String get phoneExistsLogin => _t('phoneExistsLogin');
  String get registrationSuccess => _t('registrationSuccess');
  String get bookingDate => _t('bookingDate');
  String get pleaseSelectDate => _t('pleaseSelectDate');
  String get downloadBookingDetails => _t('downloadBookingDetails');
  String get downloadSuccess => _t('downloadSuccess');
  String get downloadNotSupported => _t('downloadNotSupported');
  String get areYouAdmin => _t('areYouAdmin');
  String get adminLogin => _t('adminLogin');
  String get adminLoginSuccess => _t('adminLoginSuccess');
  String get invalidAdminCredentials => _t('invalidAdminCredentials');
  String get adminHome => _t('adminHome');
  String get manageBookings => _t('manageBookings');
  String get viewReports => _t('viewReports');
  String get systemSettings => _t('systemSettings');
  String get adminUsers => _t('adminUsers');
  String get allBookings => _t('allBookings');
  String get pending => _t('pending');
  String get completed => _t('completed');
  String get cancelled => _t('cancelled');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      AppLocalizations.supportedLocales
          .map((supported) => supported.languageCode)
          .contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
