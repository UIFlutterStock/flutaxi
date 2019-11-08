import 'package:flutter/material.dart';
import 'package:pk_skeleton/pk_skeleton.dart';

class Skeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Center(
          child: PKCardSkeleton(
        isCircularImage: true,
        isBottomLinesActive: true,
      )),
    );
  }
}
