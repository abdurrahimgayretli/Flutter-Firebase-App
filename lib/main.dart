import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Anket'),
        ),
        body: const SurveyList(),
      ),
    );
  }
}

class SurveyList extends StatefulWidget {
  const SurveyList({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return SurveyListState();
  }
}

class SurveyListState extends State {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('dilanketi').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return LinearProgressIndicator();
        } else {
          return buildBody(context, snapshot.data!.docs);
        }
      },
    );
  }

  Widget buildBody(BuildContext context,
      List<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
    return ListView(
      padding: const EdgeInsets.only(top: 20),
      children:
          snapshot.map<Widget>((data) => buildListItem(context, data)).toList(),
    );
  }

  buildListItem(context, DocumentSnapshot<Map<String, dynamic>> data) {
    final row = Anket.fromSnapshot(data);
    return Padding(
      key: ValueKey(row.isim),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(5)),
        child: ListTile(
          title: Text(row.isim),
          trailing: Text(row.oy.toString()),
          onTap: () =>
              FirebaseFirestore.instance.runTransaction((transaction) async {
            final freshSnapshot = await transaction.get(row.reference);
            final fresh = Anket.fromSnapshot(freshSnapshot);

            await transaction.update(row.reference, {'oy': fresh.oy + 1});
          }),
        ),
      ),
    );
  }
}

final sahteSnapshot = [
  {'isim': 'C#', 'oy': 3},
  {'isim': 'Java', 'oy': 5},
  {'isim': 'Dart', 'oy': 6},
  {'isim': 'Python', 'oy': 42}
];

class Anket {
  String isim;
  int oy;
  DocumentReference<Map<String, dynamic>> reference;

  Anket.fromMap(Map<String, dynamic>? map, {required this.reference})
      : assert(map!['isim'] != null),
        assert(map!['oy'] != null),
        isim = map!['isim'],
        oy = map['oy'];
  Anket.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot)
      : this.fromMap(snapshot.data(), reference: snapshot.reference);
}
