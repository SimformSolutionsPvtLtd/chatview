import 'package:flutter/material.dart';

class PaginationLoader extends StatelessWidget {
  const PaginationLoader({
    required this.listenable,
    this.loader,
    super.key,
  });

  final ValueNotifier<bool> listenable;
  final Widget? loader;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: listenable,
      builder: (_, isLoading, child) {
        if (!isLoading) return const SizedBox.shrink();

        return SizedBox(
          height: Scaffold.of(context).appBarMaxHeight,
          child: child,
        );
      },
      child: Center(
        child: loader ?? const CircularProgressIndicator.adaptive(),
      ),
    );
  }
}
