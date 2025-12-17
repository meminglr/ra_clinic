import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ra_clinic/model/costumer_model.dart';
import 'package:ra_clinic/model/seans_model.dart';
import 'package:ra_clinic/providers/customer_provider.dart';

import 'package:cupertino_calendar_picker/cupertino_calendar_picker.dart';
import 'package:ra_clinic/constants/app_constants.dart';
import 'package:uuid/uuid.dart';

class AddSeansSheet extends StatefulWidget {
  final CustomerModel customer;

  final SeansModel? editingSeans;

  const AddSeansSheet({super.key, required this.customer, this.editingSeans});

  @override
  State<AddSeansSheet> createState() => _AddSeansSheetState();
}

class _AddSeansSheetState extends State<AddSeansSheet> {
  late DateTime _selectedDate;
  late TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.editingSeans?.startDate ?? DateTime.now();
    _noteController = TextEditingController(
      text: widget.editingSeans?.seansNote ?? '',
    );
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _saveSeans() {
    List<SeansModel> updatedList = List.from(widget.customer.seansList);

    if (widget.editingSeans != null) {
      // Edit mode
      final index = updatedList.indexWhere(
        (s) => s.seansId == widget.editingSeans!.seansId,
      );
      if (index != -1) {
        updatedList[index] = widget.editingSeans!.copyWith(
          startDate: _selectedDate,
          seansNote: _noteController.text,
        );
      }
    } else {
      // Add mode
      String newSeansId = const Uuid().v4();
      final newSeans = SeansModel(
        seansId: newSeansId,
        startDate: _selectedDate,
        seansCount: widget.customer.seansList.length + 1,
        seansNote: _noteController.text,
      );
      updatedList.add(newSeans);
    }

    CustomerModel updatedCustomer = widget.customer.copyWith(
      seansList: updatedList,
    );

    context.read<CustomerProvider>().updateCustomerAfterSeansChange(
      updatedCustomer,
    );
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.editingSeans != null
              ? "Seans güncellendi"
              : "Yeni seans eklendi",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Klavye açıldığında yukarı kayması için bottom inse
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.editingSeans != null
                    ? "Seansı Düzenle"
                    : "Yeni Seans Ekle",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 15),
          TextField(
            controller: _noteController,
            decoration: const InputDecoration(
              labelText: "Seans Notu",
              prefixIcon: Icon(Icons.note_alt_outlined),
            ),
            textCapitalization: TextCapitalization.sentences,
            maxLines: 3,
            minLines: 1,
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.calendar_month_outlined,
                      size: 20,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    CupertinoCalendarPickerButton(
                      buttonDecoration: PickerButtonDecoration(
                        textStyle: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                        backgroundColor: Colors.transparent,
                      ),
                      minimumDateTime: DateTime(2000, 1, 1),
                      maximumDateTime: DateTime(2050, 12, 31),
                      initialDateTime: _selectedDate,
                      barrierColor: Colors.transparent,
                      containerDecoration: PickerContainerDecoration(
                        backgroundColor: AppConstants.dropDownButtonsColor(
                          context,
                        ),
                        backgroundType: PickerBackgroundType.plainColor,
                      ),
                      mode: CupertinoCalendarMode.date,
                      timeLabel: 'Saat',
                      onDateTimeChanged: (date) {
                        setState(() {
                          _selectedDate = DateTime(
                            date.year,
                            date.month,
                            date.day,
                            _selectedDate.hour,
                            _selectedDate.minute,
                          );
                        });
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
                      Icons.access_time,
                      size: 20,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    CupertinoTimePickerButton(
                      buttonDecoration: PickerButtonDecoration(
                        textStyle: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                        backgroundColor: Colors.transparent,
                      ),
                      initialTime: TimeOfDay.fromDateTime(_selectedDate),
                      barrierColor: Colors.transparent,
                      containerDecoration: PickerContainerDecoration(
                        backgroundColor: AppConstants.dropDownButtonsColor(
                          context,
                        ),
                        backgroundType: PickerBackgroundType.plainColor,
                      ),
                      onTimeChanged: (time) {
                        setState(() {
                          _selectedDate = DateTime(
                            _selectedDate.year,
                            _selectedDate.month,
                            _selectedDate.day,
                            time.hour,
                            time.minute,
                          );
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Not Alanı
          const SizedBox(height: 20),
          const SizedBox(height: 20),

          // Kaydet Butonu
          FilledButton.icon(
            onPressed: _saveSeans,
            icon: Icon(widget.editingSeans != null ? Icons.save : Icons.add),
            label: Text(widget.editingSeans != null ? "Kaydet" : "Seans Ekle"),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
