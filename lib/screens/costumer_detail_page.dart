import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ra_clinic/model/costumer_model.dart';
import 'package:ra_clinic/model/seans_model.dart';

class CostumerDetail extends StatefulWidget {
  CostumerModel costumer;
  CostumerDetail({required this.costumer, super.key});

  @override
  State<CostumerDetail> createState() => _CostumerDetailState();
}

class _CostumerDetailState extends State<CostumerDetail> {
  List<SeansModel> _seansList = [];

  DateTime now = DateTime.now();

  String kayitTarihi = "";

  void removeSeans(int index) {
    if (_seansList.isNotEmpty) {
      _seansList[index].isDeleted = !_seansList[index].isDeleted;
      setState(() {});
    }
  }

  void seansEkle() {
    _seansList.add(
      SeansModel(
        "description",
        id: 1,
        name: "name",
        startDate: now,
        seansCount: _seansList.length + 1,
      ),
    );
    setState(() {});
  }

  void tarihVeSaatAl() {
    kayitTarihi =
        "${now.day}/${now.month}/${now.year} - ${now.hour}:${now.minute}";
    setState(() {});
  }

  Future<void> _tarihSec(BuildContext context) async {
    final DateTime? secilenTarih = await showDatePicker(
      context: context,
      initialDate: now, // İlk gösterilecek tarih
      firstDate: DateTime(2000), // Seçilebilecek en erken tarih
      lastDate: DateTime(2030), // Seçilebilecek en geç tarih
    );

    if (secilenTarih != null && secilenTarih != now) {
      setState(() {
        now = secilenTarih; // State'i güncelle
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _seansList = widget.costumer.seansList ?? [];
    tarihVeSaatAl();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        label: const Text("Düzenle"),
        icon: const Icon(Icons.edit_outlined),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage("assets/avatar.png"),
                  ),
                  Text(
                    " ${widget.costumer.name} ",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  if (widget.costumer.phone!.isNotEmpty)
                    Text(
                      "No: ${widget.costumer.phone}",
                      style: TextStyle(fontSize: 18),
                    ),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: Card.filled(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.circular(16),
                ),
                child: Column(
                  children: [
                    Text(" ${widget.costumer.startDateString} "),
                    if (widget.costumer.notes!.isNotEmpty)
                      Text(
                        "Not: ${widget.costumer.notes} ",
                        style: TextStyle(fontSize: 16),
                      ),
                  ],
                ),
              ),
            ),
            SliverList.builder(
              itemCount: _seansList.length,
              itemBuilder: (context, index) {
                SeansModel seans = _seansList[index];
                return Column(
                  children: [
                    seans.isDeleted
                        ? FilledButton.tonal(
                            onPressed: () {},
                            child: Text("${seans.seansCount}. seans yok"),
                          )
                        : Card.filled(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            color: Colors.green.shade100,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: 16,
                                right: 16,
                                top: 16,
                                bottom: 16,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,

                                    children: [
                                      Text(
                                        "${seans.seansCount}. Seans",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),

                                  _seansList[index].seansNote != null
                                      ? Text("${_seansList[index].seansNote}")
                                      : SizedBox(),
                                ],
                              ),
                            ),
                          ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
