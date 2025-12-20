import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ra_clinic/model/costumer_model.dart';
import 'package:ra_clinic/model/seans_model.dart';
import 'package:ra_clinic/presentation/costumer_detail/widgets/no_seans_warning_view.dart';
import 'package:ra_clinic/presentation/costumer_detail/widgets/add_seans_sheet.dart';
import 'package:ra_clinic/presentation/widgets/media_viewer_common.dart';
import 'package:ra_clinic/providers/customer_provider.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:ra_clinic/constants/app_constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ra_clinic/services/webdav_service.dart';
import 'package:ra_clinic/providers/auth_provider.dart';
import 'package:flutter/cupertino.dart';

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

  void _removeFileFromSeans(SeansModel seans, String fileName) {
    List<SeansModel> seansList = List.from(widget.customer.seansList);
    final index = seansList.indexWhere((s) => s.seansId == seans.seansId);

    if (index != -1) {
      List<String> updatedImages = List.from(seansList[index].imageUrls);
      updatedImages.remove(fileName);

      seansList[index] = seansList[index].copyWith(imageUrls: updatedImages);

      CustomerModel updatedCustomer = widget.customer.copyWith(
        seansList: seansList,
      );

      context.read<CustomerProvider>().updateCustomerAfterSeansChange(
        updatedCustomer,
      );
    }
  }

  void _viewMedia(SeansModel seans, String currentFileName) {
    if (seans.imageUrls.isEmpty) return;

    final webDavService = context.read<WebDavService>();
    final uid = context.read<FirebaseAuthProvider>().currentUser?.uid;
    final basePath =
        "$uid/customers/${widget.customer.customerId}/sessions/${seans.seansId}";

    final mediaUrls = seans.imageUrls.map((name) {
      return webDavService.getFileUrl("$basePath/$name");
    }).toList();

    final index = seans.imageUrls.indexOf(currentFileName);

    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (_) => FullScreenMediaViewer(
          mediaUrls: mediaUrls,
          fileNames: List.from(seans.imageUrls),
          basePath: basePath,
          initialIndex: index == -1 ? 0 : index,
          headers: webDavService.getAuthHeaders(),
          onFileDeleted: (name) => _removeFileFromSeans(seans, name),
        ),
      ),
    );
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
                      showDragHandle: true,
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
        color: Theme.of(context).colorScheme.surfaceContainer,
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
                          showDragHandle: true,
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
          if (seans.imageUrls.isNotEmpty) ...[
            const SizedBox(height: 8),
            SizedBox(
              height: 80,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: seans.imageUrls.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, imgIndex) {
                  final fileName = seans.imageUrls[imgIndex];
                  final webDavService = context.read<WebDavService>();
                  final path =
                      "${context.read<FirebaseAuthProvider>().currentUser?.uid}/customers/${widget.customer.customerId}/sessions/${seans.seansId}/$fileName";

                  final url = webDavService.getFileUrl(path);
                  final headers = webDavService.getAuthHeaders();

                  // Check if it's video
                  final isVideo =
                      fileName.toLowerCase().endsWith('.mp4') ||
                      fileName.toLowerCase().endsWith('.mov');

                  final isUploading = context
                      .watch<CustomerProvider>()
                      .isFileUploading(fileName);

                  if (isUploading) {
                    return Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  }

                  return GestureDetector(
                    onTap: () => _viewMedia(seans, fileName),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 80,
                        height: 80,
                        child: isVideo
                            ? VideoThumbnailWidget(url: url, headers: headers)
                            : CachedNetworkImage(
                                imageUrl: url,
                                httpHeaders: headers,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: Colors.grey[200],
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: Colors.grey[200],
                                  child: const Icon(
                                    Icons.refresh,
                                    color: Colors.grey,
                                    size: 24,
                                  ),
                                ),
                              ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
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
        color: Theme.of(context).cardColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${seans.seansCount}. Seans (Silindi)",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    decoration: TextDecoration.lineThrough,
                    color: Theme.of(context).disabledColor,
                  ),
                ),
                Text(
                  "${seans.startDate.day}.${seans.startDate.month}.${seans.startDate.year}",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).disabledColor,
                  ),
                ),
              ],
            ),
            IconButton.filledTonal(
              onPressed: () => removeSeans(index),
              icon: const Icon(Icons.restore),
              tooltip: "Geri Yükle",
            ),
          ],
        ),
      ),
    );
  }
}
