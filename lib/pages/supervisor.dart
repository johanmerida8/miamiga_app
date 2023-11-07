import 'package:flutter/material.dart';
import 'package:miamiga_app/components/headers.dart';
import 'package:miamiga_app/components/listview.dart';
import 'package:miamiga_app/pages/evidencia.dart';

class Supervisor extends StatefulWidget {
  const Supervisor({super.key});

  @override
  State<Supervisor> createState() => _SupervisorState();
}


class _SupervisorState extends State<Supervisor> {

  final List<String> items = ["Item 1", "Item 2", "Item 3", "Item 4", "Item 5"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 25),

              const Header(
                header: 'Casos',
              ),

              const SizedBox(height: 15),

              // MyListView(
              //   items: items,
              //   onItemClick: (int index) {
              //     Navigator.of(context).push(
              //       MaterialPageRoute(
              //         builder: (context) => const CasePage(item: 'Item 1'),
              //       ),
              //     );
              //   },
              //   backgroundColor: const Color.fromRGBO(248, 181, 149, 1),
              //   borderRadius: 10.0,
              // ),
            ],
          ),
        ),
      ),
    );
  }
}