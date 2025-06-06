/*
 * Copyright (c) 2022 Simform Solutions
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

import 'chat_view_locale.dart';

class PackageStrings {
  static final Map<String, ChatViewLocale> _localeObjects = {
    'en': ChatViewLocale.en,
  };

  static String _currentLocale = 'en';

  /// Set the current locale for the package strings (e.g., 'en', 'es').
  static void setLocale(String locale) {
    assert(_localeObjects.containsKey(locale),
        'Locale "$locale" not found. Please add it using PackageStrings.addLocaleObject("$locale", ChatViewLocale(...)) before setting.');
    if (_localeObjects.containsKey(locale)) {
      _currentLocale = locale;
    }
  }

  /// Allow developers to add or override locales at runtime using a class
  static void addLocaleObject(String locale, ChatViewLocale localeObj) {
    _localeObjects[locale] = localeObj;
  }

  static ChatViewLocale get currentLocale =>
      _localeObjects[_currentLocale] ?? ChatViewLocale.en;
}
