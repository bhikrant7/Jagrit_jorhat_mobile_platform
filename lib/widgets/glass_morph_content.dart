import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/screens/authentication/login_screen.dart';
import 'package:flutter_application_2/screens/authentication/register_screen.dart';
import 'package:flutter_application_2/widgets/welcome_button.dart';

class GlassContent extends StatelessWidget {
  const GlassContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha((0.15 * 255).toInt()),
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
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: "Welcome User!",
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      WidgetSpan(child: SizedBox(height: 12)),
                      TextSpan(
                        text:
                            "\nPlease register or login to proceed submission of form",
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    const Expanded(
                      child: WelcomeButton(
                        buttonText: 'Log-in\n(লগ-ইন)',
                        onTap: LoginScreen(),
                        color: Color.fromARGB(0, 36, 47, 148),
                        textColor: Colors.white,
                        borderColor: Colors.white,
                        bRadius: BorderRadius.only(
                          topLeft: Radius.circular(5),
                          bottomLeft: Radius.circular(5),
                        ),
                      ),
                    ),
                    Expanded(
                      child: WelcomeButton(
                        buttonText: 'Register\n(পঞ্জীয়ন)',
                        onTap: RegisterScreen(),
                        color: Colors.white,
                        textColor: Color.fromARGB(255, 0, 89, 155),
                        borderColor: Color.fromARGB(0, 36, 47, 148),
                        bRadius: BorderRadius.only(
                          topRight: Radius.circular(5),
                          bottomRight: Radius.circular(5),
                        ),
                      ),
                    ),
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
