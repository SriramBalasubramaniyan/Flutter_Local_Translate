# Offline Translator — Flutter App

A simple, clean Flutter app for offline text translation using **Google ML Kit On-Device Translation**.

## How it works

- Language models are downloaded **once** on first use per language pair (requires internet)
- After that, all translations happen **100% offline** on-device
- Translations are deterministic — same input always gives same output

## Supported Languages (50+)

Afrikaans, Arabic, Bengali, Bulgarian, Catalan, Chinese, Croatian, Czech, Danish, Dutch,
English, Estonian, Finnish, French, Galician, German, Greek, Gujarati, Hebrew, Hindi,
Hungarian, Icelandic, Indonesian, Irish, Italian, Japanese, Kannada, Korean, Latvian,
Lithuanian, Macedonian, Malay, Maltese, Marathi, Norwegian, Persian, Polish, Portuguese,
Romanian, Russian, Slovak, Slovenian, Spanish, Swahili, Swedish, Tagalog, Tamil, Telugu,
Thai, Turkish, Ukrainian, Urdu, Vietnamese, Welsh

## Setup

```bash
flutter pub get
flutter run
```

### Android
- Minimum SDK: 21
- Add `INTERNET` permission in AndroidManifest.xml (already included — needed only for model download)

### iOS
- Add to `ios/Runner/Info.plist`:
```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

## Model sizes

Each language model is ~20–30 MB downloaded once. After download, no internet is needed.

## Features

- 50+ languages
- Swap source/target languages with one tap
- Copy input or output to clipboard
- Clear all button
- Deterministic offline translation