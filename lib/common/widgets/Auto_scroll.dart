import 'dart:async';
import 'package:flutter/material.dart';



class ContinuousImageScroller extends StatefulWidget {
  final List<String> assetImages;
  final double itemWidth;
  final double itemHeight;
  final Duration interval;
  final Duration animationDuration;

  const ContinuousImageScroller({
    super.key,
    required this.assetImages,
    required this.itemWidth,
    required this.itemHeight,
    this.interval = const Duration(seconds: 2),
    this.animationDuration = const Duration(milliseconds: 600),
  });

  @override
  State<ContinuousImageScroller> createState() =>
      _ContinuousImageScrollerState();
}

class _ContinuousImageScrollerState extends State<ContinuousImageScroller> {
  final ScrollController _scrollController = ScrollController();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoScroll();
    });
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(widget.interval, (_) {
      if (!_scrollController.hasClients) return;

      final maxScrollExtent = _scrollController.position.maxScrollExtent;
      final currentOffset = _scrollController.offset;

      // When reached end → jump instantly to start (no animation)
      if (currentOffset >= maxScrollExtent) {
        _scrollController.jumpTo(0);
      }

      // Smoothly scroll forward
      _scrollController.animateTo(
        _scrollController.offset + widget.itemWidth + 12, // include padding space
        duration: widget.animationDuration,
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 🔁 Duplicate the list once to ensure continuous look
    final List<String> infiniteList = [...widget.assetImages, ...widget.assetImages];

    return SizedBox(
      height: widget.itemHeight,
      child: ListView.builder(
        controller: _scrollController,
        primary: false,
        // physics: const ClampingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: infiniteList.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                infiniteList[index % widget.assetImages.length],
                width: widget.itemWidth,
                height: widget.itemHeight,
                fit: BoxFit.fill,
              ),
            ),
          );
        },
      ),
    );
  }
}

