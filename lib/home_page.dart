import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import 'login_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _logout(BuildContext context) {
    var box = Hive.box('authBox');
    box.put('isLoggedIn', false); // Clear login state

    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const LoginPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Enquiries', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _logout(context),
          )
        ],
        backgroundColor: Colors.black,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('contacts')
            .orderBy("createdAt", descending: true)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No contacts found',
                  style: TextStyle(color: Colors.white)),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var contact = snapshot.data!.docs[index];
              return StatefulBuilder(
                builder: (context, setState) {
                  return ContactTile(contact: contact);
                },
              );
            },
          );
        },
      ),
    );
  }
}

class ContactTile extends StatefulWidget {
  final QueryDocumentSnapshot contact;
  const ContactTile({Key? key, required this.contact}) : super(key: key);

  @override
  _ContactTileState createState() => _ContactTileState();
}

class _ContactTileState extends State<ContactTile> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => isExpanded = !isExpanded),
      child: Card(
        color: Colors.grey[900],
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Name: ${widget.contact['name']}',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              Text('Subject: ${widget.contact['subject']}',
                  style: TextStyle(color: Colors.white70, fontSize: 16)),
              if (isExpanded) ...[
                const SizedBox(height: 10),
                Text('Email: ${widget.contact['email']}',
                    style: TextStyle(color: Colors.white70)),
                Text('Mobile: ${widget.contact['mobile']}',
                    style: TextStyle(color: Colors.white70)),
                Text('Message: ${widget.contact['message']}',
                    style: TextStyle(color: Colors.white70)),
                // Text('Read: ${widget.contact['isRead'] ? "Yes" : "No"}',
                //     style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 10),
              ],
              Align(
                alignment: Alignment.centerRight,
                child: Text(isExpanded ? 'Show Less' : 'Show More',
                    style: TextStyle(color: Colors.blue, fontSize: 14)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
