import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

class TranslationScreen extends StatefulWidget {
  const TranslationScreen({super.key});

  @override
  State<TranslationScreen> createState() => _TranslationScreenState();
}

class _TranslationScreenState extends State<TranslationScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _outputScrollController = ScrollController();

  TranslateLanguage _sourceLang = TranslateLanguage.english;
  TranslateLanguage _targetLang = TranslateLanguage.tamil;

  String _translatedText = '';
  bool _isTranslating = false;
  bool _isDownloadingModel = false;
  String _statusMessage = '';

  OnDeviceTranslator? _translator;
  final OnDeviceTranslatorModelManager _modelManager = OnDeviceTranslatorModelManager();

  static const Map<TranslateLanguage, String> supportedLanguages = {
    TranslateLanguage.afrikaans: 'Afrikaans',
    TranslateLanguage.arabic: 'Arabic',
    TranslateLanguage.belarusian: 'Belarusian',
    TranslateLanguage.bulgarian: 'Bulgarian',
    TranslateLanguage.bengali: 'Bengali',
    TranslateLanguage.catalan: 'Catalan',
    TranslateLanguage.czech: 'Czech',
    TranslateLanguage.welsh: 'Welsh',
    TranslateLanguage.danish: 'Danish',
    TranslateLanguage.german: 'German',
    TranslateLanguage.greek: 'Greek',
    TranslateLanguage.english: 'English',
    TranslateLanguage.esperanto: 'Esperanto',
    TranslateLanguage.spanish: 'Spanish',
    TranslateLanguage.estonian: 'Estonian',
    TranslateLanguage.persian: 'Persian',
    TranslateLanguage.finnish: 'Finnish',
    TranslateLanguage.french: 'French',
    TranslateLanguage.irish: 'Irish',
    TranslateLanguage.galician: 'Galician',
    TranslateLanguage.gujarati: 'Gujarati',
    TranslateLanguage.hebrew: 'Hebrew',
    TranslateLanguage.hindi: 'Hindi',
    TranslateLanguage.croatian: 'Croatian',
    TranslateLanguage.hungarian: 'Hungarian',
    TranslateLanguage.indonesian: 'Indonesian',
    TranslateLanguage.icelandic: 'Icelandic',
    TranslateLanguage.italian: 'Italian',
    TranslateLanguage.japanese: 'Japanese',
    TranslateLanguage.georgian: 'Georgian',
    TranslateLanguage.kannada: 'Kannada',
    TranslateLanguage.korean: 'Korean',
    TranslateLanguage.lithuanian: 'Lithuanian',
    TranslateLanguage.latvian: 'Latvian',
    TranslateLanguage.macedonian: 'Macedonian',
    TranslateLanguage.marathi: 'Marathi',
    TranslateLanguage.malay: 'Malay',
    TranslateLanguage.maltese: 'Maltese',
    TranslateLanguage.dutch: 'Dutch',
    TranslateLanguage.norwegian: 'Norwegian',
    TranslateLanguage.polish: 'Polish',
    TranslateLanguage.portuguese: 'Portuguese',
    TranslateLanguage.romanian: 'Romanian',
    TranslateLanguage.russian: 'Russian',
    TranslateLanguage.slovak: 'Slovak',
    TranslateLanguage.slovenian: 'Slovenian',
    TranslateLanguage.albanian: 'Albanian',
    TranslateLanguage.swedish: 'Swedish',
    TranslateLanguage.swahili: 'Swahili',
    TranslateLanguage.tamil: 'Tamil',
    TranslateLanguage.telugu: 'Telugu',
    TranslateLanguage.thai: 'Thai',
    TranslateLanguage.tagalog: 'Tagalog',
    TranslateLanguage.turkish: 'Turkish',
    TranslateLanguage.ukrainian: 'Ukrainian',
    TranslateLanguage.urdu: 'Urdu',
    TranslateLanguage.vietnamese: 'Vietnamese',
    TranslateLanguage.chinese: 'Chinese',
  };

  @override
  void dispose() {
    _inputController.dispose();
    _outputScrollController.dispose();
    _translator?.close();
    super.dispose();
  }

  void _swapLanguages() {
    setState(() {
      final temp = _sourceLang;
      _sourceLang = _targetLang;
      _targetLang = temp;

      if (_translatedText.isNotEmpty) {
        _inputController.text = _translatedText;
        _translatedText = '';
      }
    });
    _translator?.close();
    _translator = null;
  }

  Future<void> _translate() async {
    final inputText = _inputController.text.trim();
    if (inputText.isEmpty) return;

    if (_sourceLang == _targetLang) {
      setState(() {
        _translatedText = inputText;
      });
      return;
    }

    setState(() {
      _isTranslating = true;
      _statusMessage = '';
      _translatedText = '';
    });

    try {
      final sourceDownloaded = await _modelManager.isModelDownloaded(_sourceLang.bcpCode);
      final targetDownloaded = await _modelManager.isModelDownloaded(_targetLang.bcpCode);

      if (!sourceDownloaded || !targetDownloaded) {
        setState(() {
          _isDownloadingModel = true;
          _statusMessage = 'Downloading language models...';
        });
      }

      _translator?.close();
      _translator = OnDeviceTranslator(
        sourceLanguage: _sourceLang,
        targetLanguage: _targetLang,
      );

      final result = await _translator!.translateText(inputText);

      setState(() {
        _translatedText = result;
        _isTranslating = false;
        _isDownloadingModel = false;
        _statusMessage = '';
      });
    } catch (e) {
      setState(() {
        _isTranslating = false;
        _isDownloadingModel = false;
        _statusMessage = 'Translation failed: ${e.toString()}';
      });
    }
  }

  void _clearAll() {
    setState(() {
      _inputController.clear();
      _translatedText = '';
      _statusMessage = '';
    });
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildLanguageDropdown({
    required TranslateLanguage value,
    required ValueChanged<TranslateLanguage?> onChanged,
    required String label,
  }) {
    final sortedEntries = supportedLanguages.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.primary,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.4),
            ),
            borderRadius: BorderRadius.circular(10),
            color: Theme.of(context).colorScheme.surface,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<TranslateLanguage>(
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              onChanged: (newVal) {
                if (newVal != null) {
                  setState(() {
                    _translatedText = '';
                  });
                  _translator?.close();
                  _translator = null;
                  onChanged(newVal);
                }
              },
              items: sortedEntries
                  .map(
                    (e) => DropdownMenuItem(
                  value: e.key,
                  child: Text(e.value),
                ),
              )
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: colorScheme.surfaceContainerLowest,
        elevation: 0,
        title: Icon(Icons.translate_rounded,
            color: colorScheme.primary, size: 22),
        actions: [
          if (_inputController.text.isNotEmpty || _translatedText.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.restart_alt),
              tooltip: 'Clear all',
              onPressed: _clearAll,
            ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Language selectors row
              Row(
                children: [
                  Expanded(
                    child: _buildLanguageDropdown(
                      value: _sourceLang,
                      label: 'FROM',
                      onChanged: (v) => setState(() => _sourceLang = v!),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      children: [
                        const SizedBox(height: 18),
                        InkWell(
                          onTap: _swapLanguages,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.swap_horiz_rounded,
                              color: colorScheme.onPrimaryContainer,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _buildLanguageDropdown(
                      value: _targetLang,
                      label: 'TO',
                      onChanged: (v) => setState(() => _targetLang = v!),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Input box
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: colorScheme.outline.withOpacity(0.25),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
                      child: Row(
                        children: [
                          Text(
                            supportedLanguages[_sourceLang] ?? '',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.primary,
                            ),
                          ),
                          const Spacer(),
                          if (_inputController.text.isNotEmpty)
                            InkWell(
                              onTap: () => _copyToClipboard(_inputController.text),
                              borderRadius: BorderRadius.circular(6),
                              child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: Icon(
                                  Icons.copy_rounded,
                                  size: 16,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    TextField(
                      controller: _inputController,
                      maxLines: 5,
                      minLines: 3,
                      style: TextStyle(
                        fontSize: 16,
                        color: colorScheme.onSurface,
                        height: 1.5,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter text to translate…',
                        hintStyle: TextStyle(
                          color: colorScheme.onSurfaceVariant.withOpacity(0.6),
                          fontSize: 15,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.fromLTRB(14, 4, 14, 12),
                      ),
                      onChanged: (_) => setState(() {}),
                      textInputAction: TextInputAction.done,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Translate button
              SizedBox(
                height: 50,
                child: FilledButton.icon(
                  onPressed: (_isTranslating || _inputController.text.trim().isEmpty)
                      ? null
                      : _translate,
                  icon: _isTranslating
                      ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.onPrimary,
                    ),
                  )
                      : const Icon(Icons.translate_rounded, size: 20),
                  label: Text(
                    _isTranslating
                        ? (_isDownloadingModel ? 'Downloading model…' : 'Translating…')
                        : 'Translate',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              // Status message (model download info)
              if (_statusMessage.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.info_outline_rounded,
                        size: 14, color: colorScheme.primary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _statusMessage,
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              // Output box
              if (_translatedText.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: colorScheme.primary.withOpacity(0.2),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
                        child: Row(
                          children: [
                            Text(
                              supportedLanguages[_targetLang] ?? '',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.primary,
                              ),
                            ),
                            const Spacer(),
                            InkWell(
                              onTap: () => _copyToClipboard(_translatedText),
                              borderRadius: BorderRadius.circular(6),
                              child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: Icon(
                                  Icons.copy_rounded,
                                  size: 16,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 4, 14, 16),
                        child: SelectableText(
                          _translatedText,
                          style: TextStyle(
                            fontSize: 17,
                            color: colorScheme.onSurface,
                            height: 1.6,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}