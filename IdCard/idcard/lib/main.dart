import 'package:flutter/material.dart';

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
      home: const Scaffold(
        backgroundColor: Color(0xFFEFEFEF),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: _IdCard(),
            ),
          ),
        ),
      ),
    );
  }
}

class _IdCard extends StatelessWidget {
  const _IdCard();

  // Colors based on description
  static const Color green = Color(
    0xFF23403C,
  ); // Updated institutional green (#23403C)

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
                      decoration: const BoxDecoration(
                        color: green,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(18),
                        ),
                      ),
                      alignment: Alignment.topCenter,
                      padding: const EdgeInsets.only(top: 14),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          _UniversityLogo(),
                          SizedBox(height: 8),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12.0),
                            child: Text(
                              'ISLAMIC UNIVERSITY OF TECHNOLOGY',
                              textAlign: TextAlign.center,
                              style: TextStyle(
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
                      child: _CardDetails(photoHeight: photoHeight),
                    ),
                    Container(
                      height: bottomSectionHeight,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: green,
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(18),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'A subsidiary organ of OIC',
                        style: TextStyle(
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
                  child: _PhotoFrame(height: photoHeight, width: photoWidth),
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
  const _PhotoFrame({required this.height, required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0x23403C00),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _IdCard.green, width: 3.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.20),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        'assets/stevvee.jpeg',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stack) => const Center(
          child: Icon(Icons.person, size: 64, color: Colors.black54),
        ),
      ),
    );
  }
}

class _CardDetails extends StatelessWidget {
  final double photoHeight;
  const _CardDetails({required this.photoHeight});

  TextStyle get labelStyle => const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: Colors.black87,
  );
  TextStyle get valueStyle => const TextStyle(
    fontSize: 13.6,
    fontWeight: FontWeight.w700,
    color: Colors.black,
    letterSpacing: 0.3,
  );

  @override
  Widget build(BuildContext context) {
    const gap = SizedBox(height: 6);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // Student ID Row with pill background
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.key, size: 15, color: Colors.black54),
            SizedBox(width: 4),
            Text(
              'Student ID',
              style: TextStyle(
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
            color: _IdCard.green,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              // Small blue status dot
              SizedBox(width: 6),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: Color(0xFF2196F3), // Blue dot
                  shape: BoxShape.circle,
                ),
                child: SizedBox(width: 12, height: 12),
              ),
              SizedBox(width: 10),
              Text(
                '210041254',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14.2,
                  letterSpacing: 0.4,
                ),
              ),
              SizedBox(width: 6),
            ],
          ),
        ),
        gap,
        _InfoLine(
          icon: Icons.person, // filled person icon
          label: 'Student Name',
          value: 'ASIF OR RASHID ALIF',
        ),
        gap,
        _InfoLine(
          icon: Icons.school, // filled school cap
          label: 'Program',
          value: 'B.Sc. in CSE',
          inline: true,
        ),
        gap,
        _InfoLine(
          icon: Icons.business, // building icon
          label: 'Department',
          value: 'CSE',
          inline: true,
        ),
        gap,
        _InfoLine(
          icon: Icons.location_on, // location pin for nationality
          label: 'Nationality',
          value: 'Bangladesh',
          inline: true,
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
  const _InfoLine({
    required this.icon,
    required this.label,
    required this.value,
    this.inline = false,
  });

  @override
  Widget build(BuildContext context) {
    if (inline) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: _IdCard.green),
          const SizedBox(width: 6),
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12.8,
                fontWeight: FontWeight.w700,
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
            Icon(icon, size: 16, color: _IdCard.green),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
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
          style: const TextStyle(
            fontSize: 13.2,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}
