import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'dart:typed_data';

void main() {
  runApp(const IdCardApp());
}

class IdCardApp extends StatelessWidget {
  const IdCardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Student ID Card',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF23403C)),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const IdCardGenerator(),
    );
  }
}

class IdCardGenerator extends StatefulWidget {
  const IdCardGenerator({super.key});

  @override
  State<IdCardGenerator> createState() => _IdCardGeneratorState();
}

class _IdCardGeneratorState extends State<IdCardGenerator> {
  // Form state
  bool _showCard = false;
  final _formKey = GlobalKey<FormState>();

  // Input controllers
  final _studentIdController = TextEditingController();
  final _nameController = TextEditingController();
  final _programController = TextEditingController();
  final _departmentController = TextEditingController();
  final _nationalityController = TextEditingController();

  // Photo state
  File? _selectedPhoto;
  Uint8List? _selectedPhotoBytes;

  // Card customization state
  Color _selectedColor = const Color(0xFF23403C);
  String _selectedFont = 'Roboto';

  // Color pool
  final List<Color> _colorPool = [
    const Color(0xFF23403C), // Original green
    const Color(0xFF1565C0), // Blue
    const Color(0xFF7B1FA2), // Purple
    const Color(0xFFD32F2F), // Red
    const Color(0xFF388E3C), // Green
    const Color(0xFFE64A19), // Orange
    const Color(0xFF5D4037), // Brown
    const Color(0xFF455A64), // Blue Grey
    const Color(0xFF0097A7), // Cyan
    const Color(0xFFAD1457), // Pink
  ];

  // Font pool
  final List<String> _fontPool = [
    'Roboto',
    'Open Sans',
    'Lato',
    'Montserrat',
    'Oswald',
    'Source Sans Pro',
    'Raleway',
    'PT Sans',
    'Ubuntu',
    'Nunito',
  ];

  @override
  void dispose() {
    _studentIdController.dispose();
    _nameController.dispose();
    _programController.dispose();
    _departmentController.dispose();
    _nationalityController.dispose();
    super.dispose();
  }

  void _createCard() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _showCard = true;
      });
    }
  }

  void _editCard() {
    setState(() {
      _showCard = false;
    });
  }

  void _changeColor() {
    setState(() {
      // Get a random color from the pool, but not the current one
      List<Color> availableColors = _colorPool
          .where((color) => color != _selectedColor)
          .toList();
      if (availableColors.isNotEmpty) {
        availableColors.shuffle();
        _selectedColor = availableColors.first;
      }
    });
  }

  void _changeFont() {
    setState(() {
      // Get a random font from the pool, but not the current one
      List<String> availableFonts = _fontPool
          .where((font) => font != _selectedFont)
          .toList();
      if (availableFonts.isNotEmpty) {
        availableFonts.shuffle();
        _selectedFont = availableFonts.first;
      }
    });
  }

  Widget _buildPhotoPreview() {
    if (_selectedPhotoBytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.memory(
          _selectedPhotoBytes!,
          fit: BoxFit.cover,
          width: 120,
          height: 120,
        ),
      );
    } else if (_selectedPhoto != null && !kIsWeb) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.file(
          _selectedPhoto!,
          fit: BoxFit.cover,
          width: 120,
          height: 120,
        ),
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_a_photo, size: 40, color: Colors.grey[400]),
          const SizedBox(height: 8),
          Text(
            'Tap to add photo',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      );
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Photo',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  if (!kIsWeb) // Camera is not available on web
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          Navigator.pop(context);
                          final XFile? image = await picker.pickImage(
                            source: ImageSource.camera,
                            imageQuality: 80,
                          );
                          if (image != null) {
                            if (kIsWeb) {
                              final bytes = await image.readAsBytes();
                              setState(() {
                                _selectedPhotoBytes = bytes;
                                _selectedPhoto = null;
                              });
                            } else {
                              setState(() {
                                _selectedPhoto = File(image.path);
                                _selectedPhotoBytes = null;
                              });
                            }
                          }
                        },
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Camera'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF23403C),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  if (!kIsWeb) const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        Navigator.pop(context);
                        final XFile? image = await picker.pickImage(
                          source: ImageSource.gallery,
                          imageQuality: 80,
                        );
                        if (image != null) {
                          if (kIsWeb) {
                            final bytes = await image.readAsBytes();
                            setState(() {
                              _selectedPhotoBytes = bytes;
                              _selectedPhoto = null;
                            });
                          } else {
                            setState(() {
                              _selectedPhoto = File(image.path);
                              _selectedPhotoBytes = null;
                            });
                          }
                        }
                      },
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Gallery'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF23403C),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFEFEF),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: _showCard ? _buildCardView() : _buildFormView(),
          ),
        ),
      ),
    );
  }

  Widget _buildFormView() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Create Your ID Card',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF23403C),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Fill in all the details to generate your student ID card',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Student ID Field
            TextFormField(
              controller: _studentIdController,
              decoration: const InputDecoration(
                labelText: 'Student ID',
                hintText: 'Enter your student ID',
                prefixIcon: Icon(Icons.key),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your student ID';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Name Field
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                hintText: 'Enter your full name',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your full name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Program Field
            TextFormField(
              controller: _programController,
              decoration: const InputDecoration(
                labelText: 'Program',
                hintText: 'e.g., B.Sc. in CSE',
                prefixIcon: Icon(Icons.school),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your program';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Department Field
            TextFormField(
              controller: _departmentController,
              decoration: const InputDecoration(
                labelText: 'Department',
                hintText: 'e.g., CSE',
                prefixIcon: Icon(Icons.business),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your department';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Nationality Field
            TextFormField(
              controller: _nationalityController,
              decoration: const InputDecoration(
                labelText: 'Nationality',
                hintText: 'e.g., Bangladesh',
                prefixIcon: Icon(Icons.location_on),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your nationality';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Photo Selection Section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Photo',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF23403C),
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      border: Border.all(
                        color:
                            (_selectedPhoto != null ||
                                _selectedPhotoBytes != null)
                            ? const Color(0xFF23403C)
                            : Colors.grey[300]!,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _buildPhotoPreview(),
                  ),
                ),
                if (_selectedPhoto != null || _selectedPhotoBytes != null) ...[
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _selectedPhoto = null;
                        _selectedPhotoBytes = null;
                      });
                    },
                    icon: const Icon(Icons.delete_outline, size: 16),
                    label: const Text('Remove Photo'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red[600],
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 32),

            // Create Button
            ElevatedButton.icon(
              onPressed: _createCard,
              icon: const Icon(Icons.credit_card),
              label: const Text('Create ID Card'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF23403C),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardView() {
    return Column(
      children: [
        _IdCard(
          studentId: _studentIdController.text,
          name: _nameController.text,
          program: _programController.text,
          department: _departmentController.text,
          nationality: _nationalityController.text,
          photo: _selectedPhoto,
          photoBytes: _selectedPhotoBytes,
          cardColor: _selectedColor,
          fontFamily: _selectedFont,
        ),
        const SizedBox(height: 20),
        // Button row for customization
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: _changeColor,
              icon: const Icon(Icons.palette),
              label: const Text('Change Color'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: _changeFont,
              icon: const Icon(Icons.font_download),
              label: const Text('Change Font'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _editCard,
          icon: const Icon(Icons.edit),
          label: const Text('Edit Card'),
          style: ElevatedButton.styleFrom(
            backgroundColor: _selectedColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
      ],
    );
  }
}

class _IdCard extends StatelessWidget {
  final String studentId;
  final String name;
  final String program;
  final String department;
  final String nationality;
  final File? photo;
  final Uint8List? photoBytes;
  final Color cardColor;
  final String fontFamily;

  const _IdCard({
    required this.studentId,
    required this.name,
    required this.program,
    required this.department,
    required this.nationality,
    this.photo,
    this.photoBytes,
    this.cardColor = const Color(0xFF23403C),
    this.fontFamily = 'Roboto',
  });

  // Colors based on description
  static const Color green = Color(
    0xFF23403C,
  ); // Updated institutional green (#23403C)

  TextStyle _getGoogleFontStyle({
    required double fontSize,
    required FontWeight fontWeight,
    required Color color,
    double? letterSpacing,
  }) {
    switch (fontFamily.toLowerCase().replaceAll(' ', '')) {
      case 'roboto':
        return GoogleFonts.roboto(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          letterSpacing: letterSpacing,
        );
      case 'opensans':
        return GoogleFonts.openSans(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          letterSpacing: letterSpacing,
        );
      case 'lato':
        return GoogleFonts.lato(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          letterSpacing: letterSpacing,
        );
      case 'montserrat':
        return GoogleFonts.montserrat(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          letterSpacing: letterSpacing,
        );
      case 'oswald':
        return GoogleFonts.oswald(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          letterSpacing: letterSpacing,
        );
      case 'sourcesanspro':
        return GoogleFonts.sourceSans3(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          letterSpacing: letterSpacing,
        );
      case 'raleway':
        return GoogleFonts.raleway(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          letterSpacing: letterSpacing,
        );
      case 'ptsans':
        return GoogleFonts.ptSans(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          letterSpacing: letterSpacing,
        );
      case 'ubuntu':
        return GoogleFonts.ubuntu(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          letterSpacing: letterSpacing,
        );
      case 'nunito':
        return GoogleFonts.nunito(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          letterSpacing: letterSpacing,
        );
      default:
        return GoogleFonts.roboto(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          letterSpacing: letterSpacing,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Fixed card size (shortened) width:300, height:430
    return SizedBox(
      width: 300,
      height: 480,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final height = constraints.maxHeight;
          // Adjust proportions: slightly smaller top, more middle room for content.
          final topSectionHeight = height * 0.32; // reduced from 0.34
          final middleSectionHeight =
              height * 0.58; // increased to host details after photo
          final bottomSectionHeight = height * 0.10;

          // Fixed photo size, will sit just below the university name (no overlap now)
          final photoHeight = 120.0;
          final photoWidth = 120.0;

          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Background layered sections
                Column(
                  children: [
                    Container(
                      height: topSectionHeight,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(18),
                        ),
                      ),
                      alignment: Alignment.topCenter,
                      padding: const EdgeInsets.only(top: 14),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const _UniversityLogo(),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12.0,
                            ),
                            child: Text(
                              'ISLAMIC UNIVERSITY OF TECHNOLOGY',
                              textAlign: TextAlign.center,
                              style: _getGoogleFontStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 14.2,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: middleSectionHeight,
                      width: double.infinity,
                      color: Colors.white,
                      padding: EdgeInsets.only(
                        // photo sits 4px below the top of this middle section, so add that
                        // 4 + photoHeight plus a small gap (8px) below the photo
                        top: photoHeight - 35,
                      ),
                      child: _CardDetails(
                        photoHeight: photoHeight,
                        studentId: studentId,
                        name: name,
                        program: program,
                        department: department,
                        nationality: nationality,
                        cardColor: cardColor,
                        fontFamily: fontFamily,
                      ),
                    ),
                    Container(
                      height: bottomSectionHeight,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(18),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'A subsidiary organ of OIC',
                        style: _getGoogleFontStyle(
                          color: Colors.white,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ],
                ),

                // Center photo overlapping sections
                Positioned(
                  // Place photo entirely below green section title area with small gap
                  top: topSectionHeight - 40,
                  left: (constraints.maxWidth - photoWidth) / 2,
                  width: photoWidth,
                  height: photoHeight,
                  child: _PhotoFrame(
                    height: photoHeight,
                    width: photoWidth,
                    photo: photo,
                    photoBytes: photoBytes,
                    cardColor: cardColor,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _UniversityLogo extends StatelessWidget {
  const _UniversityLogo();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      height: 72,
      child: Padding(
        padding: EdgeInsets.all(4.0),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            // ARGB from #23403c00 (alpha 0x23). Use constant for clarity.
            color: Color(0x23403C00),
          ),
          child: FittedBox(
            fit: BoxFit.contain,
            child: Image.asset(
              'assets/iutlogo.png',
              filterQuality: FilterQuality.high,
              errorBuilder: (context, error, stack) =>
                  const Icon(Icons.school, color: Colors.white, size: 32),
            ),
          ),
        ),
      ),
    );
  }
}

class _PhotoFrame extends StatelessWidget {
  final double height;
  final double width;
  final File? photo;
  final Uint8List? photoBytes;
  final Color cardColor;

  const _PhotoFrame({
    required this.height,
    required this.width,
    this.photo,
    this.photoBytes,
    this.cardColor = const Color(0xFF23403C),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0x23403C00),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: cardColor, width: 3.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.20),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: _buildPhotoWidget(),
    );
  }

  Widget _buildPhotoWidget() {
    // Priority: photoBytes (web) > photo (mobile) > asset (default)
    if (photoBytes != null) {
      return Image.memory(
        photoBytes!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stack) => const Center(
          child: Icon(Icons.person, size: 64, color: Colors.black54),
        ),
      );
    } else if (photo != null && !kIsWeb) {
      return Image.file(
        photo!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stack) => const Center(
          child: Icon(Icons.person, size: 64, color: Colors.black54),
        ),
      );
    } else {
      return Image.asset(
        'assets/stevvee.jpeg',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stack) => const Center(
          child: Icon(Icons.person, size: 64, color: Colors.black54),
        ),
      );
    }
  }
}

class _CardDetails extends StatelessWidget {
  final double photoHeight;
  final String studentId;
  final String name;
  final String program;
  final String department;
  final String nationality;
  final Color cardColor;
  final String fontFamily;

  const _CardDetails({
    required this.photoHeight,
    required this.studentId,
    required this.name,
    required this.program,
    required this.department,
    required this.nationality,
    this.cardColor = const Color(0xFF23403C),
    this.fontFamily = 'Roboto',
  });

  TextStyle get labelStyle => _getTextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: Colors.black87,
  );

  TextStyle get valueStyle => _getTextStyle(
    fontSize: 13.6,
    fontWeight: FontWeight.w700,
    color: Colors.black,
    letterSpacing: 0.3,
  );

  TextStyle _getTextStyle({
    required double fontSize,
    required FontWeight fontWeight,
    required Color color,
    double? letterSpacing,
  }) {
    switch (fontFamily.toLowerCase().replaceAll(' ', '')) {
      case 'roboto':
        return GoogleFonts.roboto(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          letterSpacing: letterSpacing,
        );
      case 'opensans':
        return GoogleFonts.openSans(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          letterSpacing: letterSpacing,
        );
      case 'lato':
        return GoogleFonts.lato(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          letterSpacing: letterSpacing,
        );
      case 'montserrat':
        return GoogleFonts.montserrat(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          letterSpacing: letterSpacing,
        );
      case 'oswald':
        return GoogleFonts.oswald(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          letterSpacing: letterSpacing,
        );
      case 'sourcesanspro':
        return GoogleFonts.sourceSans3(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          letterSpacing: letterSpacing,
        );
      case 'raleway':
        return GoogleFonts.raleway(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          letterSpacing: letterSpacing,
        );
      case 'ptsans':
        return GoogleFonts.ptSans(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          letterSpacing: letterSpacing,
        );
      case 'ubuntu':
        return GoogleFonts.ubuntu(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          letterSpacing: letterSpacing,
        );
      case 'nunito':
        return GoogleFonts.nunito(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          letterSpacing: letterSpacing,
        );
      default:
        return GoogleFonts.roboto(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          letterSpacing: letterSpacing,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    const gap = SizedBox(height: 6);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // Student ID Row with pill background
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.key, size: 15, color: Colors.black54),
            const SizedBox(width: 4),
            Text(
              'Student ID',
              style: _getTextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Small blue status dot
              const SizedBox(width: 6),
              const DecoratedBox(
                decoration: BoxDecoration(
                  color: Color(0xFF2196F3), // Blue dot
                  shape: BoxShape.circle,
                ),
                child: SizedBox(width: 12, height: 12),
              ),
              const SizedBox(width: 10),
              Text(
                studentId.isNotEmpty ? studentId : '210041254',
                style: _getTextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14.2,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(width: 6),
            ],
          ),
        ),
        gap,
        _InfoLine(
          icon: Icons.person, // filled person icon
          label: 'Student Name',
          value: name.isNotEmpty ? name.toUpperCase() : 'ASIF OR RASHID ALIF',
          cardColor: cardColor,
          fontFamily: fontFamily,
        ),
        gap,
        _InfoLine(
          icon: Icons.school, // filled school cap
          label: 'Program',
          value: program.isNotEmpty ? program : 'B.Sc. in CSE',
          inline: true,
          cardColor: cardColor,
          fontFamily: fontFamily,
        ),
        gap,
        _InfoLine(
          icon: Icons.business, // building icon
          label: 'Department',
          value: department.isNotEmpty ? department : 'CSE',
          inline: true,
          cardColor: cardColor,
          fontFamily: fontFamily,
        ),
        gap,
        _InfoLine(
          icon: Icons.location_on, // location pin for nationality
          label: 'Nationality',
          value: nationality.isNotEmpty ? nationality : 'Bangladesh',
          inline: true,
          cardColor: cardColor,
          fontFamily: fontFamily,
        ),
      ],
    );
  }
}

class _InfoLine extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool inline;
  final Color cardColor;
  final String fontFamily;

  const _InfoLine({
    required this.icon,
    required this.label,
    required this.value,
    this.inline = false,
    this.cardColor = const Color(0xFF23403C),
    this.fontFamily = 'Roboto',
  });

  TextStyle _getGoogleFontStyle({
    required double fontSize,
    required FontWeight fontWeight,
    required Color color,
    double? letterSpacing,
  }) {
    switch (fontFamily.toLowerCase().replaceAll(' ', '')) {
      case 'roboto':
        return GoogleFonts.roboto(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          letterSpacing: letterSpacing,
        );
      case 'opensans':
        return GoogleFonts.openSans(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          letterSpacing: letterSpacing,
        );
      case 'lato':
        return GoogleFonts.lato(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          letterSpacing: letterSpacing,
        );
      case 'montserrat':
        return GoogleFonts.montserrat(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          letterSpacing: letterSpacing,
        );
      case 'oswald':
        return GoogleFonts.oswald(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          letterSpacing: letterSpacing,
        );
      case 'sourcesanspro':
        return GoogleFonts.sourceSans3(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          letterSpacing: letterSpacing,
        );
      case 'raleway':
        return GoogleFonts.raleway(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          letterSpacing: letterSpacing,
        );
      case 'ptsans':
        return GoogleFonts.ptSans(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          letterSpacing: letterSpacing,
        );
      case 'ubuntu':
        return GoogleFonts.ubuntu(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          letterSpacing: letterSpacing,
        );
      case 'nunito':
        return GoogleFonts.nunito(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          letterSpacing: letterSpacing,
        );
      default:
        return GoogleFonts.roboto(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          letterSpacing: letterSpacing,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (inline) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: cardColor),
          const SizedBox(width: 6),
          Text(
            '$label: ',
            style: _getGoogleFontStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: _getGoogleFontStyle(
                fontSize: 12.8,
                fontWeight: FontWeight.w700,
                color: Colors.black,
                letterSpacing: 0.2,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: cardColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: _getGoogleFontStyle(
                fontSize: 11.2,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          textAlign: TextAlign.center,
          style: _getGoogleFontStyle(
            fontSize: 13.2,
            fontWeight: FontWeight.w700,
            color: Colors.black,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}
