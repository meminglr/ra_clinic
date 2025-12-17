import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ra_clinic/model/costumer_model.dart';
import 'package:ra_clinic/model/seans_model.dart';
import 'package:ra_clinic/presentation/costumer_detail/widgets/no_seans_warning_view.dart';
import 'package:ra_clinic/presentation/costumer_detail/widgets/add_seans_sheet.dart';
import 'package:ra_clinic/providers/customer_provider.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:ra_clinic/constants/app_constants.dart';

class SeansManagerView extends StatefulWidget {
  final CustomerModel customer;

  const SeansManagerView({super.key, required this.customer});

  @override
  State<SeansManagerView> createState() => _SeansManagerViewState();
}

class _SeansManagerViewState extends State<SeansManagerView> {
  void removeSeans(int seansIndex) {
    List<SeansModel> seansList = List.from(widget.customer.seansList);
    if (seansList.isNotEmpty) {
      if (seansList[seansIndex].isDeleted) {
        // Restore
        seansList[seansIndex].isDeleted = false;
      } else {
        // Delete
        if (seansIndex == seansList.length - 1) {
          // If it's the last session, remove it completely
          seansList.removeAt(seansIndex);
        } else {
          // Otherwise, soft delete
          seansList[seansIndex].isDeleted = true;
        }
      }

      CustomerModel updatedCustomer = widget.customer.copyWith(
        seansList: seansList,
      );
      context.read<CustomerProvider>().updateCustomerAfterSeansChange(
        updatedCustomer,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      key: const PageStorageKey<String>('seanslar'),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Seans Listesi",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton.filledTonal(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) =>
                          AddSeansSheet(customer: widget.customer),
                    );
                  },
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ),
        ),
        if (widget.customer.seansList.isEmpty)
          const NoSeansWarning()
        else
          SliverList.builder(
            itemCount: widget.customer.seansList.length,
            itemBuilder: (context, index) {
              SeansModel seans = widget.customer.seansList[index];

              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 6.0,
                ),
                child: seans.isDeleted
                    ? _buildDeletedSeansCard(context, seans, index)
                    : _buildSeansCard(context, seans, index),
              );
            },
          ),

        // FAB butonunun altında içerik kalmasın diye boşluk
        const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
      ],
    );
  }

  Widget _buildSeansCard(BuildContext context, SeansModel seans, int index) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      "${seans.seansCount}.",
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "Seans",
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        "${seans.startDate.day}.${seans.startDate.month}.${seans.startDate.year}",
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
                PullDownButton(
                  routeTheme: PullDownMenuRouteTheme(
                    backgroundColor: AppConstants.dropDownButtonsColor(context),
                  ),
                  itemBuilder: (context) => [
                    PullDownMenuItem(
                      title: 'Düzenle',
                      icon: Icons.edit_outlined,
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (context) => AddSeansSheet(
                            customer: widget.customer,
                            editingSeans: seans,
                          ),
                        );
                      },
                    ),
                    PullDownMenuItem(
                      title: 'Sil',
                      icon: Icons.delete_outline,
                      isDestructive: true,
                      onTap: () => removeSeans(index),
                    ),
                  ],
                  buttonBuilder: (context, showMenu) => IconButton(
                    onPressed: showMenu,
                    icon: const Icon(Icons.more_vert),
                  ),
                ),
              ],
            ),
          ),
          if (seans.seansNote != null && seans.seansNote!.isNotEmpty) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: Text(
                seans.seansNote!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDeletedSeansCard(
    BuildContext context,
    SeansModel seans,
    int index,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          Icons.delete_sweep_outlined,
          color: Theme.of(context).disabledColor,
        ),
        title: Text(
          "${seans.seansCount}. Seans (Silindi)",
          style: TextStyle(
            decoration: TextDecoration.lineThrough,
            color: Theme.of(context).disabledColor,
          ),
        ),
        trailing: FilledButton.icon(
          onPressed: () => removeSeans(index),
          icon: const Icon(Icons.restore, size: 18),
          label: const Text("Geri Al"),
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
            foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(horizontal: 12),
          ),
        ),
      ),
    );
  }
}
