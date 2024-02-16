import 'package:flutter/material.dart';
import 'package:flutter_swipe_button/flutter_swipe_button.dart';
import 'package:lottie/lottie.dart';
import 'package:project2/signup.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key, Key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.white,
        child: Column(
          children: [
            Expanded(
              child: Lottie.network(
                'https://lottie.host/de784ace-e386-4918-a654-85aadcafae00/GqwFaFp3oA.json',
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(80.0),
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'HEY, WELCOME TO ',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 25.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'M-SHOPY',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 30.0,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 177, 29, 29),
                    ),
                  ),
                  const SizedBox(height: 65),
                  SizedBox(
                    width: 170,
                    height: 30,  
                    child: Transform.scale(
                      scale: 1.5, 
                      child: SwipeButton.expand(
                        thumb: const Icon(
                          Icons.double_arrow_rounded,
                          color: Colors.white,
                        ),
                        activeThumbColor: Colors.green,
                        activeTrackColor: Colors.grey.shade300,
                        onSwipe: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SignPage ()),
                          );
                        },
                        child: const Text(
                          'GET START',
                          style: TextStyle(
                            fontSize: 10.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
