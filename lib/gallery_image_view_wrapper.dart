import 'package:flutter/material.dart';
import 'package:galleryimage/app_cached_network_image.dart';

import 'gallery_item_model.dart';

// to view image in full screen
class GalleryImageViewWrapper extends StatefulWidget {
  final Color? backgroundColor;
  final int? initialIndex;
  final String? titleGallery;
  final List<GalleryItemModel> galleryItems;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final double minScale;
  final double maxScale;
  final double radius;
  final bool reverse;
  final bool showListInGalley;
  final bool showAppBar;
  final bool closeWhenSwipeUp;
  final bool closeWhenSwipeDown;
  final Icon? appBarMoreActionsIcon;
  final Function(GalleryItemModel galleryItem)? onAppBarMoreActionsPressed;
  final bool hideEverythingElseOnImagePressed;

  const GalleryImageViewWrapper({
    super.key,
    required this.titleGallery,
    required this.backgroundColor,
    required this.initialIndex,
    required this.galleryItems,
    required this.loadingWidget,
    required this.errorWidget,
    required this.minScale,
    required this.maxScale,
    required this.radius,
    required this.reverse,
    required this.showListInGalley,
    required this.showAppBar,
    required this.closeWhenSwipeUp,
    required this.closeWhenSwipeDown,
    this.appBarMoreActionsIcon,
    this.onAppBarMoreActionsPressed,
    required this.hideEverythingElseOnImagePressed,
  });

  @override
  State<StatefulWidget> createState() {
    return _GalleryImageViewWrapperState();
  }
}

class _GalleryImageViewWrapperState extends State<GalleryImageViewWrapper> {
  late final PageController _controller =
      PageController(initialPage: widget.initialIndex ?? 0);
  int _currentPage = 0;
  late bool _showListInGalley;
  bool _showDescription = true;
  late bool _hideAppBar;

  @override
  void initState() {
    _currentPage = 0;
    _controller.addListener(() {
      setState(() {
        _currentPage = _controller.page?.toInt() ?? 0;
      });
    });
    _showListInGalley = widget.showListInGalley;
    _hideAppBar = widget.showAppBar;
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _hideAppBar
          ? AppBar(
              title: Text(widget.titleGallery ?? "Gallery"),
              actions: _addAppBarMoreActions(),
            )
          : null,
      backgroundColor: widget.backgroundColor,
      body: SafeArea(
        child: Container(
          constraints:
              BoxConstraints.expand(height: MediaQuery.of(context).size.height),
          child: Column(
            children: [
              Expanded(
                child: GestureDetector(
                  onVerticalDragEnd: (details) {
                    if (widget.closeWhenSwipeUp &&
                        details.primaryVelocity! < 0) {
                      //'up'
                      Navigator.of(context).pop();
                    }
                    if (widget.closeWhenSwipeDown &&
                        details.primaryVelocity! > 0) {
                      // 'down'
                      Navigator.of(context).pop();
                    }
                  },
                  child: PageView.builder(
                    reverse: widget.reverse,
                    controller: _controller,
                    itemCount: widget.galleryItems.length,
                    itemBuilder: (context, index) {
                      GalleryItemModel galleryItem = widget.galleryItems[index];
                      return Stack(
                        children: [
                          _buildImage(galleryItem),
                          if (galleryItem.imageDescription != null &&
                              _showDescription)
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: galleryItem.imageDescription!,
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              if (_showListInGalley)
                SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.galleryItems.length,
                      itemBuilder: (BuildContext context, int index) {
                        final e = widget.galleryItems[index];
                        return _buildLitImage(e);
                      },
                    )
                ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _addAppBarMoreActions() {
    if (widget.appBarMoreActionsIcon != null &&
        widget.onAppBarMoreActionsPressed != null) {
      return [
        IconButton(
          icon: widget.appBarMoreActionsIcon!,
          onPressed: () => widget.onAppBarMoreActionsPressed!(
              widget.galleryItems[
                  _controller.page?.toInt() ?? widget.initialIndex ?? 0]),
        ),
      ];
    }
    return [];
  }

// build image with zooming
  Widget _buildImage(GalleryItemModel item) {
    return Hero(
      tag: item.id,
      child: InteractiveViewer(
        minScale: widget.minScale,
        maxScale: widget.maxScale,
        child: GestureDetector(
          onTap: () {
            if (widget.hideEverythingElseOnImagePressed) {
              setState(() {
                _showDescription = !_showDescription;
                _showListInGalley = !_showListInGalley;
                _hideAppBar = !_hideAppBar;
              });
            }
          },
          child: Center(
            child: AppCachedNetworkImage(
              imageUrl: item.imageUrl,
              loadingWidget: widget.loadingWidget,
              errorWidget: widget.errorWidget,
              radius: widget.radius,
            ),
          ),
        ),
      ),
    );
  }

// build image with zooming
  Widget _buildLitImage(GalleryItemModel item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _controller.jumpToPage(item.index);
          });
        },
        child: AppCachedNetworkImage(
          height: _currentPage == item.index ? 70 : 60,
          width: _currentPage == item.index ? 70 : 60,
          fit: BoxFit.cover,
          imageUrl: item.imageUrl,
          errorWidget: widget.errorWidget,
          radius: widget.radius,
          loadingWidget: widget.loadingWidget,
        ),
      ),
    );
  }
}
