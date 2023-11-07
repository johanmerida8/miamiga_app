import 'package:flutter/material.dart';

class SobreScreen extends StatelessWidget {
  const SobreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //image of logo 
          Image(
            image: AssetImage('lib/images/logo.png'),
            height: 100,
          ),
          SizedBox(height: 20),
          Text(
            'Sobre del app',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 18),
            child: Text(
              'Esta app tiene como objetivo dar a conciencia sobre el feminicidio de mujeres y proporcionar recursos y apoyo a las victimas y sus familias.',
              style: TextStyle(
                fontSize: 20,  
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
