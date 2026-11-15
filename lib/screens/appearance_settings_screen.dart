import 'dart:ui' show ImageFilter;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';

import '../state/appearance_controller.dart';

class AppearanceSettingsScreen extends StatefulWidget {
  const AppearanceSettingsScreen({super.key});

  @override
  State<AppearanceSettingsScreen> createState() =>
      _AppearanceSettingsScreenState();
}

class _AppearanceSettingsScreenState extends State<AppearanceSettingsScreen> {
  String? _fontFamily;
  String? _fontFileName;
  String? _fontExtension;
  bool _isUploading = false;
  bool _isDragHovering = false;
  double _fontSize = 24;
  double _fontWeight = 500;
  double _letterSpacing = 0;
  double _uploadProgress = 0;
  int _fontLoadId = 0;
  DropzoneViewController? _dropzoneController;
  final TextEditingController _sampleController = TextEditingController(
    text: 'SonicFlow makes every detail sound effortless.',
  );

  @override
  void dispose() {
    _sampleController.dispose();
    super.dispose();
  }

  Future<void> _selectFont() async {
    try {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: const ['ttf', 'otf', 'woff', 'woff2'],
      );
      if (file == null) return;
      await _loadFontFile(file.name, file.extension, await file.readAsBytes());
    } on PlatformException catch (error) {
      _showMessage(
        'Could not open the font picker: ${error.message ?? error.code}',
      );
    } catch (error) {
      _showMessage('Could not select a font: $error');
    }
  }

  Future<void> _loadFontFile(
    String fileName,
    String? fileExtension,
    Uint8List? bytes,
  ) async {
    final extension =
        fileExtension?.toLowerCase() ??
        (fileName.contains('.')
            ? fileName.split('.').last.toLowerCase()
            : null);
    if (extension == null ||
        !const {'ttf', 'otf', 'woff', 'woff2'}.contains(extension)) {
      _showMessage('Choose a .ttf, .otf, .woff, or .woff2 font file.');
      return;
    }
    if (bytes == null || bytes.isEmpty) {
      _showMessage('The selected font file could not be read.');
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.12;
    });

    try {
      final family = 'AppearanceFont${++_fontLoadId}';
      final loader = FontLoader(family)
        ..addFont(Future<ByteData>.value(ByteData.sublistView(bytes)));
      setState(() => _uploadProgress = 0.55);
      await loader.load();
      if (!mounted) return;
      setState(() {
        _fontFamily = family;
        _fontFileName = fileName;
        _fontExtension = extension.toUpperCase();
        _uploadProgress = 1;
      });
      await Future<void>.delayed(const Duration(milliseconds: 220));
      if (mounted) setState(() => _isUploading = false);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isUploading = false;
        _uploadProgress = 0;
      });
      _showMessage('This font could not be loaded: $error');
    }
  }

  Future<void> _handleWebDrop(DropzoneFileInterface file) async {
    final controller = _dropzoneController;
    if (controller == null) {
      _showMessage(
        'The font drop area is not ready yet. Try browsing instead.',
      );
      return;
    }
    try {
      final fileName = await controller.getFilename(file);
      final bytes = await controller.getFileData(file);
      final extension = fileName.contains('.')
          ? fileName.split('.').last.toLowerCase()
          : null;
      await _loadFontFile(fileName, extension, bytes);
    } catch (error) {
      _showMessage('Could not read the dropped font file: $error');
    }
  }

  Future<void> _handlePlatformDrop(PlatformFile file) async {
    try {
      await _loadFontFile(file.name, file.extension, await file.readAsBytes());
    } catch (error) {
      _showMessage('Could not read the selected font file: $error');
    }
  }

  void _resetFont() {
    setState(() {
      _fontFamily = null;
      _fontFileName = null;
      _fontExtension = null;
      _fontSize = 24;
      _fontWeight = 500;
      _letterSpacing = 0;
    });
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _selectMode(AppAppearanceMode mode) async {
    try {
      await AppearanceController.instance.select(mode);
    } catch (error) {
      _showMessage('Could not save your appearance setting: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final appearance = AppearanceController.instance;
    return ListenableBuilder(
      listenable: appearance,
      builder: (context, _) {
        final isDark = appearance.isDark;
        final colors = _SettingsColors(isDark);
        return Theme(
          data: ThemeData(
            useMaterial3: true,
            brightness: isDark ? Brightness.dark : Brightness.light,
            colorScheme: ColorScheme(
              brightness: isDark ? Brightness.dark : Brightness.light,
              primary: colors.accent,
              onPrimary: colors.accentText,
              secondary: colors.accent,
              onSecondary: colors.accentText,
              error: const Color(0xFFFF453A),
              onError: Colors.white,
              surface: colors.surface,
              onSurface: colors.text,
            ),
            scaffoldBackgroundColor: colors.background,
            sliderTheme: SliderThemeData(
              activeTrackColor: colors.accent,
              thumbColor: colors.accent,
              inactiveTrackColor: colors.divider,
              overlayColor: colors.accent.withValues(alpha: 0.12),
            ),
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutCubic,
            color: colors.background,
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final wide = constraints.maxWidth >= 940;
                    final horizontalPadding = constraints.maxWidth < 600
                        ? 20.0
                        : 32.0;
                    return Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1120),
                        child: CustomScrollView(
                          slivers: [
                            SliverPadding(
                              padding: EdgeInsets.fromLTRB(
                                horizontalPadding,
                                12,
                                horizontalPadding,
                                48,
                              ),
                              sliver: SliverList.list(
                                children: [
                                  _buildTopBar(colors),
                                  const SizedBox(height: 32),
                                  _buildHeading(colors),
                                  const SizedBox(height: 28),
                                  _buildThemeSection(
                                    colors,
                                    isDark,
                                    appearance.mode,
                                  ),
                                  const SizedBox(height: 28),
                                  if (wide)
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: 340,
                                          child: _buildFontSettings(colors),
                                        ),
                                        const SizedBox(width: 20),
                                        Expanded(
                                          child: _buildSpecimen(
                                            colors,
                                            compact: true,
                                          ),
                                        ),
                                      ],
                                    )
                                  else ...[
                                    _buildFontSettings(colors),
                                    const SizedBox(height: 24),
                                    _buildSpecimen(colors),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopBar(_SettingsColors colors) => ClipRRect(
    borderRadius: BorderRadius.circular(18),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: colors.surface.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: colors.divider),
        ),
        child: Row(
          children: [
            _Pressable(
              onPressed: () => Navigator.of(context).maybePop(),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: colors.divider),
                ),
                child: Icon(
                  Icons.arrow_back_rounded,
                  color: colors.text,
                  size: 19,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'SETTINGS',
              style: TextStyle(
                color: colors.secondaryText,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.8,
              ),
            ),
            const Spacer(),
            Icon(Icons.tune_rounded, color: colors.secondaryText, size: 19),
          ],
        ),
      ),
    ),
  );

  Widget _buildHeading(_SettingsColors colors) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Appearance',
        style: TextStyle(
          color: colors.text,
          fontSize: 38,
          height: 1.1,
          fontWeight: FontWeight.w700,
          letterSpacing: -1.5,
        ),
      ),
      const SizedBox(height: 8),
      Text(
        'Make this space feel like yours.',
        style: TextStyle(color: colors.secondaryText, fontSize: 15),
      ),
    ],
  );

  Widget _buildThemeSection(
    _SettingsColors colors,
    bool isDark,
    AppAppearanceMode mode,
  ) => _SettingsCard(
    colors: colors,
    padding: const EdgeInsets.all(22),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          colors: colors,
          title: 'Theme',
          subtitle: 'Choose how the interface looks.',
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colors.divider),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) => SizedBox(
              height: 40,
              child: Stack(
                children: [
                  AnimatedAlign(
                    alignment: switch (mode) {
                      AppAppearanceMode.light => Alignment.centerLeft,
                      AppAppearanceMode.dark => Alignment.center,
                      AppAppearanceMode.system => Alignment.centerRight,
                    },
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOutCubic,
                    child: Container(
                      width: constraints.maxWidth / 3,
                      height: 34,
                      decoration: BoxDecoration(
                        color: colors.accent,
                        borderRadius: BorderRadius.circular(11),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      for (final option in AppAppearanceMode.values)
                        Expanded(
                          child: _ModeButton(
                            colors: colors,
                            mode: option,
                            selected: mode == option,
                            onTap: () => _selectMode(option),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 17),
        LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = (constraints.maxWidth - 12) / 2;
            return Row(
              children: [
                SizedBox(
                  width: cardWidth,
                  child: _ThemePreviewCard(
                    isDark: false,
                    selected: !isDark,
                    onTap: () => _selectMode(AppAppearanceMode.light),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: cardWidth,
                  child: _ThemePreviewCard(
                    isDark: true,
                    selected: isDark,
                    onTap: () => _selectMode(AppAppearanceMode.dark),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    ),
  );

  Widget _buildFontSettings(_SettingsColors colors) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _SettingsCard(
        colors: colors,
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle(
              colors: colors,
              title: 'Typography',
              subtitle: 'Upload a font and fine-tune its appearance.',
            ),
            const SizedBox(height: 18),
            _buildUploadZone(colors),
            if (_fontFileName != null) ...[
              const SizedBox(height: 14),
              _buildUploadedFont(colors),
            ],
            if (_isUploading) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _uploadProgress,
                  minHeight: 4,
                  backgroundColor: colors.divider,
                  color: colors.accent,
                ),
              ),
            ],
            const SizedBox(height: 22),
            _SliderSetting(
              colors: colors,
              label: 'Font size',
              valueLabel: '${_fontSize.round()} px',
              value: _fontSize,
              min: 12,
              max: 48,
              divisions: 36,
              onChanged: (value) => setState(() => _fontSize = value),
            ),
            _SliderSetting(
              colors: colors,
              label: 'Font weight',
              valueLabel: '${(_fontWeight / 100).round() * 100}',
              value: _fontWeight,
              min: 100,
              max: 900,
              divisions: 8,
              onChanged: (value) => setState(() => _fontWeight = value),
            ),
            _SliderSetting(
              colors: colors,
              label: 'Letter spacing',
              valueLabel: '${_letterSpacing.toStringAsFixed(1)} px',
              value: _letterSpacing,
              min: -1,
              max: 3,
              divisions: 40,
              onChanged: (value) => setState(() => _letterSpacing = value),
            ),
            const SizedBox(height: 2),
            _Pressable(
              onPressed: _resetFont,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(
                  color: colors.background,
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(color: colors.divider),
                ),
                child: Text(
                  'Reset to Apple System Font (SF Pro / Inter)',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colors.text,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );

  Widget _buildUploadZone(_SettingsColors colors) => DragTarget<PlatformFile>(
    onWillAcceptWithDetails: (details) {
      setState(() => _isDragHovering = true);
      return true;
    },
    onLeave: (_) => setState(() => _isDragHovering = false),
    onAcceptWithDetails: (details) {
      setState(() => _isDragHovering = false);
      _handlePlatformDrop(details.data);
    },
    builder: (context, candidateData, rejectedData) => MouseRegion(
      onEnter: (_) => setState(() => _isDragHovering = true),
      onExit: (_) => setState(() => _isDragHovering = false),
      child: Stack(
        children: [
          if (kIsWeb)
            Positioned.fill(
              child: DropzoneView(
                onCreated: (controller) => _dropzoneController = controller,
                onHover: () => setState(() => _isDragHovering = true),
                onLeave: () => setState(() => _isDragHovering = false),
                onDropFile: _handleWebDrop,
                onDropInvalid: (_) {
                  setState(() => _isDragHovering = false);
                  _showMessage(
                    'Choose a .ttf, .otf, .woff, or .woff2 font file.',
                  );
                },
                onError: (message) => _showMessage(
                  'The browser font drop area failed: ${message ?? 'unknown error'}',
                ),
              ),
            ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _isUploading ? null : _selectFont,
            child: IgnorePointer(
              child: AnimatedScale(
                scale: _isDragHovering ? 1.015 : 1,
                duration: const Duration(milliseconds: 180),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 22,
                  ),
                  decoration: BoxDecoration(
                    color: _isDragHovering
                        ? colors.accent.withValues(alpha: 0.07)
                        : colors.background,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _isDragHovering ? colors.accent : colors.divider,
                      width: _isDragHovering ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: colors.accent.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Icon(
                          _fontFileName == null
                              ? Icons.upload_file_rounded
                              : Icons.check_rounded,
                          color: colors.accent,
                          size: 22,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _fontFileName == null
                            ? 'Drop your font here'
                            : 'Font ready to use',
                        style: TextStyle(
                          color: colors.text,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'or browse files · TTF, OTF, WOFF, WOFF2',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: colors.secondaryText,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildUploadedFont(_SettingsColors colors) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
    decoration: BoxDecoration(
      color: colors.background,
      borderRadius: BorderRadius.circular(13),
      border: Border.all(color: colors.divider),
    ),
    child: Row(
      children: [
        Icon(Icons.text_fields_rounded, color: colors.secondaryText, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            _fontFileName!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colors.text,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            _fontExtension ?? '',
            style: TextStyle(
              color: colors.secondaryText,
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Icon(Icons.check_circle_rounded, color: colors.success, size: 17),
      ],
    ),
  );

  Widget _buildSpecimen(_SettingsColors colors, {bool compact = false}) {
    final family = _fontFamily;
    final weight = FontWeight
        .values[((_fontWeight / 100).round() - 1).clamp(0, 8).toInt()];
    TextStyle specimenStyle({
      required double size,
      FontWeight? fontWeight,
      double? height,
    }) => TextStyle(
      fontFamily: family,
      fontSize: size,
      fontWeight: fontWeight ?? weight,
      letterSpacing: _letterSpacing,
      height: height,
      color: colors.text,
    );

    return _SettingsCard(
      colors: colors,
      padding: EdgeInsets.all(compact ? 24 : 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _SectionTitle(
                  colors: colors,
                  title: 'Live preview',
                  subtitle: _fontFileName ?? 'Apple system font',
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                decoration: BoxDecoration(
                  color: colors.accent.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text(
                  'Aa',
                  style: TextStyle(
                    color: colors.accent,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'The quick brown fox jumps over the lazy dog',
            style: specimenStyle(
              size: compact ? _fontSize + 10 : _fontSize + 8,
              height: 1.12,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Good typography makes every moment easier to read. Explore your favorite typeface across headings, body copy, and the details in between.',
            style: specimenStyle(
              size: compact ? 14 : 13,
              height: 1.65,
            ).copyWith(color: colors.secondaryText),
          ),
          const SizedBox(height: 22),
          Divider(height: 1, color: colors.divider),
          const SizedBox(height: 18),
          Text(
            'Aa Bb Cc Dd Ee Ff Gg Hh Ii Jj Kk Ll Mm Nn Oo Pp Qq Rr Ss Tt Uu Vv Ww Xx Yy Zz',
            style: specimenStyle(size: compact ? 17 : 15, height: 1.7),
          ),
          const SizedBox(height: 9),
          Text(
            '0123456789  ·  !?@#&%*',
            style: specimenStyle(
              size: 16,
            ).copyWith(color: colors.secondaryText),
          ),
          const SizedBox(height: 22),
          Text(
            'TRY YOUR OWN TEXT',
            style: TextStyle(
              color: colors.secondaryText,
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.3,
            ),
          ),
          const SizedBox(height: 9),
          TextField(
            controller: _sampleController,
            minLines: 2,
            maxLines: 4,
            style: specimenStyle(size: _fontSize, height: 1.4),
            decoration: InputDecoration(
              hintText: 'Type something to preview your font…',
              hintStyle: TextStyle(color: colors.secondaryText),
              filled: true,
              fillColor: colors.background,
              contentPadding: const EdgeInsets.all(14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: colors.divider),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: colors.divider),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: colors.accent),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _SpecimenTag(colors: colors, label: '${_fontSize.round()} px'),
              _SpecimenTag(
                colors: colors,
                label: 'Weight ${(_fontWeight / 100).round() * 100}',
              ),
              _SpecimenTag(
                colors: colors,
                label: family == null ? 'System' : 'Custom font',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingsColors {
  const _SettingsColors(this.isDark);

  final bool isDark;

  Color get background =>
      isDark ? const Color(0xFF000000) : const Color(0xFFF5F5F7);
  Color get surface =>
      isDark ? const Color(0xFF1C1C1E) : const Color(0xFFFFFFFF);
  Color get text => isDark ? const Color(0xFFFFFFFF) : const Color(0xFF000000);
  Color get secondaryText =>
      isDark ? const Color(0xFF8E8E93) : const Color(0xFF6E6E73);
  Color get divider =>
      isDark ? const Color(0x1FFFFFFF) : const Color(0x14000000);
  Color get accent => isDark ? Colors.white : Colors.black;
  Color get accentText => isDark ? Colors.black : Colors.white;
  Color get success => const Color(0xFF30D158);
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.colors,
    required this.child,
    this.padding = const EdgeInsets.all(20),
  });

  final _SettingsColors colors;
  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeInOutCubic,
    padding: padding,
    decoration: BoxDecoration(
      color: colors.surface,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: colors.divider),
      boxShadow: [
        if (!colors.isDark)
          const BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 24,
            offset: Offset(0, 4),
          ),
      ],
    ),
    child: child,
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.colors,
    required this.title,
    required this.subtitle,
  });

  final _SettingsColors colors;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: TextStyle(
          color: colors.text,
          fontSize: 17,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        subtitle,
        style: TextStyle(color: colors.secondaryText, fontSize: 12),
      ),
    ],
  );
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.colors,
    required this.mode,
    required this.selected,
    required this.onTap,
  });

  final _SettingsColors colors;
  final AppAppearanceMode mode;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => _Pressable(
    onPressed: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
        style: TextStyle(
          color: selected ? colors.accentText : colors.secondaryText,
          fontSize: 12,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
        ),
        textAlign: TextAlign.center,
        child: switch (mode) {
          AppAppearanceMode.light => const Text('Light'),
          AppAppearanceMode.dark => const Text('Dark'),
          AppAppearanceMode.system => const Text('System'),
        },
      ),
    ),
  );
}

class _ThemePreviewCard extends StatelessWidget {
  const _ThemePreviewCard({
    required this.isDark,
    required this.selected,
    required this.onTap,
  });

  final bool isDark;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final background = isDark
        ? const Color(0xFF000000)
        : const Color(0xFFF5F5F7);
    final surface = isDark ? const Color(0xFF1C1C1E) : const Color(0xFFFFFFFF);
    final text = isDark ? Colors.white : Colors.black;
    return _Pressable(
      onPressed: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: selected
                ? (isDark ? Colors.white : Colors.black)
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 58,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 38,
                    height: 5,
                    decoration: BoxDecoration(
                      color: text,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 72,
                    height: 4,
                    decoration: BoxDecoration(
                      color: text.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 13,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white : Colors.black,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Container(
                        width: 34,
                        height: 13,
                        decoration: BoxDecoration(
                          color: background,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  isDark ? 'Dark' : 'Light',
                  style: TextStyle(
                    color: text,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (selected)
                  Icon(Icons.check_circle_rounded, color: text, size: 14),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SliderSetting extends StatelessWidget {
  const _SliderSetting({
    required this.colors,
    required this.label,
    required this.valueLabel,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });

  final _SettingsColors colors;
  final String label;
  final String valueLabel;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: colors.text,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              valueLabel,
              style: TextStyle(color: colors.secondaryText, fontSize: 11),
            ),
          ],
        ),
        Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          divisions: divisions,
          onChanged: onChanged,
        ),
      ],
    ),
  );
}

class _SpecimenTag extends StatelessWidget {
  const _SpecimenTag({required this.colors, required this.label});

  final _SettingsColors colors;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
    decoration: BoxDecoration(
      color: colors.background,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: colors.divider),
    ),
    child: Text(
      label,
      style: TextStyle(color: colors.secondaryText, fontSize: 10),
    ),
  );
}

class _Pressable extends StatefulWidget {
  const _Pressable({required this.onPressed, required this.child});

  final VoidCallback? onPressed;
  final Widget child;

  @override
  State<_Pressable> createState() => _PressableState();
}

class _PressableState extends State<_Pressable> {
  bool _pressed = false;
  bool _hovering = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => _hovering = true),
    onExit: (_) => setState(() {
      _hovering = false;
      _pressed = false;
    }),
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onPressed,
      onTapDown: widget.onPressed == null
          ? null
          : (_) => setState(() => _pressed = true),
      onTapUp: widget.onPressed == null
          ? null
          : (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1,
        duration: const Duration(milliseconds: 120),
        child: AnimatedOpacity(
          opacity: _hovering ? 0.88 : 1,
          duration: const Duration(milliseconds: 150),
          child: widget.child,
        ),
      ),
    ),
  );
}
