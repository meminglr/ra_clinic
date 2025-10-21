import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ra_clinic/model/costumer_model.dart';
import 'package:ra_clinic/model/seans_model.dart';

class AddCostumerPage extends StatefulWidget {
  const AddCostumerPage({super.key});

  @override
  State<AddCostumerPage> createState() => _AddCostumerPageState();
}

class _AddCostumerPageState extends State<AddCostumerPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _telNoController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  int _seansCount = 0;
  final List<SeansModel> _seansList = [];

  final _formKey = GlobalKey<FormState>();
  String kayitTarihi = "";

  void seansEkle() {
    _seansCount = _seansCount + 1;
    setState(() {});
    _seansList.add(
      SeansModel(
        "description",
        id: 1,
        name: "name",
        startDate: "",
        endDate: "endDate",
        seansCount: _seansCount,
      ),
    );
    setState(() {});
  }

  void tarihVeSaatAl() {
    DateTime now = DateTime.now();
    kayitTarihi = DateFormat('dd/MM/yyyy HH:mm').format(now);
  }

  void saveAndReturn() {
    if (_nameController.text.isNotEmpty || _formKey.currentState!.validate()) {
      final CostumerModel newCostumer = CostumerModel(
        id: "1",
        name: _nameController.text,
        phone: _telNoController.text,
        startDate: kayitTarihi,
        notes: _noteController.text,
        seansList: _seansList,
      );
      Navigator.pop(context, newCostumer);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gerekli alanları doldurunuz")));
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tarihVeSaatAl();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Müşteri Ekle")),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          saveAndReturn();
          //  Navigator.pop(context);
        },
        label: const Text("Kaydet"),
        icon: const Icon(Icons.save_outlined),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              spacing: 16,
              children: [
                TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen müşteri ismini giriniz';
                    }
                    return null;
                  },
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: "Müşteri ismini giriniz",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                TextFormField(
                  controller: _telNoController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: "Telefon No",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                ),
                TextFormField(
                  controller: _noteController,
                  decoration: InputDecoration(
                    hintText: "Not",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.note_outlined),
                  ),
                ),
                Text("Kayıt Tarihi: $kayitTarihi"),
                FilledButton(
                  onPressed: () {
                    seansEkle();
                    setState(() {});
                  },
                  child: Text("Seans Ekle"),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _seansList.length,
                    itemBuilder: (context, index) {
                      SeansModel seans = _seansList[index];
                      return Column(
                        children: [
                          Card.filled(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("${seans.seansCount}. Seans"),
                                  TextFormField(
                                    controller: seans.noteController,
                                    decoration: InputDecoration(
                                      hintText: "Not",
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.note_outlined),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
