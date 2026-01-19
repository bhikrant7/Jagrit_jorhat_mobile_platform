import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/screens/authentication/login_screen.dart';
// import 'package:flutter_application_2/screens/authentication/register_screen.dart';
import 'package:flutter_application_2/widgets/welcome_button.dart';

class GlassContent extends StatelessWidget {
  const GlassContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 70, sigmaY: 35),
          child: Container(
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.symmetric(horizontal: 0),
            decoration: BoxDecoration(
              // color: Colors.white.withAlpha((0.15 * 255).toInt()),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.white.withAlpha((0.1 * 255).toInt()),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    
                    children: [
                      
                      TextSpan(
                        text: "জাগৃত ",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                          color: Colors.white, 
                        ),
                      ),
                      
                      TextSpan(
                        text: "যোৰহাট",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                          color: Color.fromRGBO(255, 165, 0, 1), 
                        ),
                      ),
                      const WidgetSpan(child: SizedBox(height: 12)),
                      const TextSpan(
                        text:
                            "\nনাগৰিকৰ আবেদন নিষ্পত্তিকৰণ ব্য‌ৱস্থাপনা পোৰ্টেল",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white60,
                          fontWeight: FontWeight.w600,
                        ), 
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                Row(
                  children: [
                    const Expanded(
                      child: WelcomeButton(
                        buttonText: 'Login or Register\n(লগ-ইন) / (পঞ্জীয়ন)',

                        onTap: LoginScreen(),
                        color: Color.fromARGB(0, 255, 255, 255),
                        textColor:  Colors.white,
                        borderColor: Colors.white,
                        bRadius: BorderRadius.only(
                          topLeft: Radius.circular(5),
                          bottomLeft: Radius.circular(5),
                          topRight: Radius.circular(5),
                         bottomRight: Radius.circular(5),
                        ),
                      ),
                    ),
                    // Expanded(
                    //   child: WelcomeButton(
                    //     buttonText: 'Register\n(পঞ্জীয়ন)',
                    //     onTap: RegisterScreen(),
                    //     color: Colors.white,
                    //     textColor: Color.fromARGB(255, 0, 89, 155),
                    //     borderColor: Color.fromARGB(0, 36, 47, 148),
                    //     bRadius: BorderRadius.only(
                    //       topRight: Radius.circular(5),
                    //       bottomRight: Radius.circular(5),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
