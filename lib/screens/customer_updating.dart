// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cupertino_calendar_picker/cupertino_calendar_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ra_clinic/providers/auth_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ra_clinic/services/webdav_service.dart';
import 'package:uuid/uuid.dart';

import 'package:ra_clinic/func/turkish_phone_formatter.dart';
import 'package:ra_clinic/model/costumer_model.dart';
import 'package:ra_clinic/model/seans_model.dart';
import 'package:ra_clinic/providers/customer_provider.dart';
import 'package:ra_clinic/func/utils.dart';

import '../constants/app_constants.dart';

class CostumerUpdating extends StatefulWidget {
  final CustomerModel? costumer;
  const CostumerUpdating({super.key, this.costumer});

  @override
  State<CostumerUpdating> createState() => _CostumerUpdatingState();
}

class _CostumerUpdatingState extends State<CostumerUpdating> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _telNoController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  DateTime costumerStartDate = DateTime.now();
  final _formKey = GlobalKey<FormState>();
  String kayitTarihi = "";
  String seansTarihi = "";

  String? costumerId;
  String? _profileImageUrl;
  bool _isUploadingPhoto = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.costumer == null) {
      costumerId = const Uuid().v4();
    }

    if (widget.costumer != null) {
      _nameController.text = widget.costumer!.name;
      _telNoController.text = widget.costumer!.phone ?? "";
      _noteController.text = widget.costumer!.notes ?? "";
      _noteController.text = widget.costumer!.notes ?? "";
      costumerStartDate = widget.costumer!.startDate;
      costumerId = widget.costumer!.customerId;

      _profileImageUrl = widget.costumer!.profileImageUrl;
    }
    kayitTarihiGuncelle();
  }

  Future<void> _pickAndUploadProfilePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _isUploadingPhoto = true;
        });

        final data = await image.readAsBytes();
        // Dosya uzantısını al
        final extension = image.name.split('.').last;
        // Benzersiz isim oluştur: profile_<timestamp>.<ext>
        final fileName =
            "profile_${DateTime.now().millisecondsSinceEpoch}.$extension";

        final uid = context.read<FirebaseAuthProvider>().currentUser?.uid;
        if (uid == null) throw Exception("Oturum açık değil");

        final service = context.read<WebDavService>();
        final folderPath = "$uid/customers/$costumerId";

        await service.ensurePath(folderPath);
        await service.uploadFile(folderPath, fileName, data);

        setState(() {
          _profileImageUrl = fileName;
          _isUploadingPhoto = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profil fotoğrafı yüklendi")),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploadingPhoto = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Hata: $e")));
      }
    }
  }

  void kayitTarihiGuncelle() {
    kayitTarihi = Utils.toDate(costumerStartDate);
    setState(() {});
  }

  void saveAndReturn(String id) {
    if (_nameController.text.isNotEmpty || _formKey.currentState!.validate()) {
      final CustomerModel newCostumer = CustomerModel(
        customerId: id,
        name: _nameController.text,
        phone: _telNoController.text,
        startDate: costumerStartDate,
        notes: _noteController.text,

        seansList: widget.costumer?.seansList ?? [],
        profileImageUrl: _profileImageUrl,
      );
      Navigator.pop(context, newCostumer);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gerekli alanları doldurunuz")));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _telNoController.dispose();
    _noteController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.costumer == null ? "Müşteri Ekle" : "Müşteri Düzenle",
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          saveAndReturn(costumerId!);
          //  Navigator.pop(context);
        },
        label: const Text("Kaydet"),
        icon: const Icon(Icons.save_outlined),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Form(
                key: _formKey,
                child: Column(
                  spacing: 15,
                  children: [
                    Center(
                      child: GestureDetector(
                        onTap: _pickAndUploadProfilePhoto,
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 75,
                              backgroundColor: Colors.grey[200],
                              backgroundImage: _profileImageUrl != null
                                  ? CachedNetworkImageProvider(
                                      context.read<WebDavService>().getFileUrl(
                                        "${context.read<FirebaseAuthProvider>().currentUser?.uid}/customers/$costumerId/$_profileImageUrl",
                                      ),
                                      headers: context
                                          .read<WebDavService>()
                                          .getAuthHeaders(),
                                    )
                                  : null,
                              child: _profileImageUrl == null
                                  ? const Icon(
                                      Icons.person,
                                      size: 80,
                                      color: Colors.grey,
                                    )
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                            if (_isUploadingPhoto)
                              const Positioned.fill(
                                child: CircularProgressIndicator(),
                              ),
                          ],
                        ),
                      ),
                    ),
                    TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lütfen müşteri ismini giriniz';
                        }
                        return null;
                      },
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        hintText: "Müşteri ismini giriniz",
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                    TextFormField(
                      controller: _telNoController,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        AdaptiveTurkishPhoneFormatter(),
                        // Ek güvenlik için: + veya diğer karakterlere izin vermek isterseniz buraya ekleyebilirsiniz.
                        // FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                      ],
                      decoration: InputDecoration(
                        hintText: "Telefon No",
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                    ),
                    TextFormField(
                      controller: _noteController,
                      minLines: 1,
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: "Not",
                        prefixIcon: Icon(Icons.note_outlined),
                      ),
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.calendar_month_outlined,
                                size: 25,
                                color: Colors.grey,
                              ),
                              CupertinoCalendarPickerButton(
                                buttonDecoration: PickerButtonDecoration(
                                  textStyle: TextStyle(
                                    fontSize: 17,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  backgroundColor: Colors.transparent,
                                ),
                                minimumDateTime: DateTime(2020, 1, 1),
                                maximumDateTime: DateTime(2030, 12, 31),
                                initialDateTime: costumerStartDate,
                                barrierColor: Colors.transparent,

                                containerDecoration: PickerContainerDecoration(
                                  backgroundColor:
                                      AppConstants.dropDownButtonsColor(
                                        context,
                                      ),
                                  backgroundType:
                                      PickerBackgroundType.plainColor,
                                ),
                                mode: CupertinoCalendarMode.date,
                                timeLabel: 'Saat',
                                onDateTimeChanged: (date) {
                                  costumerStartDate = date;
                                  kayitTarihiGuncelle();
                                },
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 24,
                          color: Theme.of(context).dividerColor,
                        ),

                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.access_time_outlined,
                                size: 25,
                                color: Colors.grey,
                              ),
                              CupertinoTimePickerButton(
                                buttonDecoration: PickerButtonDecoration(
                                  textStyle: TextStyle(
                                    fontSize: 17,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  backgroundColor: Colors.transparent,
                                ),
                                barrierColor: Colors.transparent,

                                containerDecoration: PickerContainerDecoration(
                                  backgroundColor:
                                      AppConstants.dropDownButtonsColor(
                                        context,
                                      ),
                                  backgroundType:
                                      PickerBackgroundType.plainColor,
                                ),
                                onTimeChanged: (value) {
                                  costumerStartDate = DateTime(
                                    costumerStartDate.year,
                                    costumerStartDate.month,
                                    costumerStartDate.day,
                                    value.hour,
                                    value.minute,
                                  );
                                  kayitTarihiGuncelle();
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
