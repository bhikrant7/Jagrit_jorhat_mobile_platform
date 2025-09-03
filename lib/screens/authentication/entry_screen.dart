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
          Flexible(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/logo.png', height: 80),
                const SizedBox(width: 12),
                // const Text(
                //   'Government of Assam',
                //   style: TextStyle(
                //     fontSize: 20,
                //     fontWeight: FontWeight.w500,
                //     color: Color.fromARGB(221, 194, 194, 194),
                //   ),
                // ),
              ],
            ),
          ),
          Flexible(flex: 7, child: GlassContent()),
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
                    fontWeight: FontWeight.w500,
                    color: Color.fromARGB(221, 194, 194, 194),
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
