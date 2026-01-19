import 'package:flutter/material.dart';
import 'package:flutter_application_2/widgets/custom_bg_scaffold.dart';
import 'package:flutter_application_2/widgets/glass_morph_content.dart';

class EntryScreen extends StatelessWidget {
  const EntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomBgScaffold(
      child: Column(
        children: [
          // Increased flex from 2 to 4 to give the logo more vertical space
          Flexible(
            flex: 4,
            child: Center(
              child: Container(
                // The Decoration handles the border and rounding
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    30.0,
                  ), // Adjust for more/less rounding
                  border: Border.all(
                    // ignore: deprecated_member_use
                    color: Colors.white.withOpacity(
                      0.5,
                    ), // Semi-transparent white border
                    width: 4.0, // Thickness of the border
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                    26.0,
                  ), // Slightly less than container to fit inside
                  child: Image.asset(
                    'assets/ddd.gif',
                    height: 180, // Increased size as requested
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),

          // Kept flex 7 for your glass content
          Flexible(flex: 8, child: GlassContent()),
          const SizedBox(height: 80),

          // Lower flex for the footer to keep it compact at the bottom
          Flexible(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/govt_assam_white__.png', height: 40),
                const SizedBox(width: 12),
                const Text(
                  'Government of Assam',
                  style: TextStyle(
                    fontSize: 20,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
