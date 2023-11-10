import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:miamiga_app/components/headers.dart';
import 'package:miamiga_app/index/indexes.dart';
import 'package:miamiga_app/model/datos_denunciante.dart';
import 'package:miamiga_app/model/datos_incidente.dart';

class ReadCases extends StatefulWidget {
  final User? user;
  final IncidentData incidentData;
  final DenuncianteData denuncianteData;

  const ReadCases({
    super.key,
    required this.user,
    required this.incidentData,
    required this.denuncianteData,
  });

  @override
  State<ReadCases> createState() => _ReadCasesState();
}

class _ReadCasesState extends State<ReadCases> {

  Future<List<DenuncianteData>> _fetchCases() async {

    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return [];
    }

    final QuerySnapshot casesSnapshot = 
      await FirebaseFirestore.instance.collection('cases')
      .where('supervisor', isEqualTo: widget.user!.uid)
      .get();


      final List<DenuncianteData> casesData = casesSnapshot.docs
        .map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final denuncianteData = data['denunciante'] as Map<String, dynamic>?;

          if (denuncianteData != null) {
            return DenuncianteData(
              fullName: denuncianteData['fullname'] ?? '',
              ci: denuncianteData['ci'] ?? 0,
              phone: denuncianteData['phone'] ?? 0,
              lat: denuncianteData['lat'] ?? 0.0,
              long: denuncianteData['long'] ?? 0.0,
            );
          } else {
            return DenuncianteData(
              fullName: '',
              ci: 0,
              phone: 0,
              lat: 0.0,
              long: 0.0,
            );
          }
        })
        .toList();
        return casesData;
      }

    @override
    void initState() {
      super.initState();
      _fetchCases();
    }

      

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //i want the appbar to be with no color
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Padding(
          padding: EdgeInsets.only(right: 80.0),
          child: Header(
            header: 'Casos',
          ),
        ),
      ),
      body: FutureBuilder(
        future: _fetchCases(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay casos'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data?.length,
              itemBuilder: (context, index) {
                final caseData = snapshot.data?[index];
                return GestureDetector(
                  onTap: () {
                    // Navigator.pushNamed(context, '/detalle_denuncia');
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => DetalleDenuncia(
                          user: widget.user,
                          incidentData: widget.incidentData,
                          denuncianteData: widget.denuncianteData,
                        ),
                      ),
                    );
                  },
                  child: Card(
                    color: const Color.fromRGBO(248, 181, 149, 1), // Set your desired background color
                    margin: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            caseData!.fullName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white, // Set text color
                            ),
                          ),
                          Text(
                            'CI: ${caseData.ci}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white, // Set text color
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}