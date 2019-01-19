import 'package:shared_preferences/shared_preferences.dart';

class TropePreferences {
  SharedPreferences _prefs;
  static bool _testing = true;
  Map<String, dynamic> _defaults = {
    "darkmodeEnabled": _testing ? true : false
  };

  TropePreferences(SharedPreferences instance) {
    _prefs = instance;
    print('got prefs');

    setDefaults();
  }

  void setDefaults() {
    for (String key in _defaults.keys) {
      if (_prefs.get(key) == null) {
        dynamic value = _defaults[key];
        if (value is bool) {
          _prefs.setBool(key, value).then((b) {});
        }
      }
    }
  }

  bool get darkmodeEnabled {
    return _prefs.getBool("darkmodeEnabled");
  }

  set darkmodeEnabled(bool setting) {
    _prefs.setBool("darkmodeEnabled", setting).then((b) {});
  }
}