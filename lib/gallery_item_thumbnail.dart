import 'package:flutter/material.dart';
import 'package:galleryimage/app_cached_network_image.dart';

import 'gallery_item_model.dart';

// to show image in Row
class GalleryItemThumbnail extends StatelessWidget {
  final GalleryItemModel galleryItem;
  final GestureTapCallback? onTap;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final double radius;
  final Function(GalleryItemModel galleryItem)? onLongPress;

  const GalleryItemThumbnail({
    super.key,
    required this.galleryItem,
    required this.onTap,
    required this.radius,
    required this.loadingWidget,
    required this.errorWidget,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: () {
        if (onLongPress != null) onLongPress!(galleryItem);
      },
      child: Hero(
        tag: galleryItem.id,
        child: AppCachedNetworkImage(
          fit: BoxFit.cover,
          imageUrl: galleryItem.imageUrl,
          loadingWidget: loadingWidget,
          errorWidget: errorWidget,
          radius: radius,
        ),
      ),
    );
  }
}
