import 'package:flutter/material.dart';

class FlyToCartOverlay {
  static void animate({
    required BuildContext context,
    required GlobalKey startKey,
    required GlobalKey endKey,
    required Widget child,
    VoidCallback? onComplete,
  }) {
    final overlay = Overlay.of(context);
    final startBox = startKey.currentContext?.findRenderObject() as RenderBox?;
    final endBox = endKey.currentContext?.findRenderObject() as RenderBox?;

    if (startBox == null || endBox == null) {
      onComplete?.call();
      return;
    }

    final startPos = startBox.localToGlobal(Offset.zero);
    final endPos = endBox.localToGlobal(Offset.zero);

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _FlyingWidget(
        startPosition: startPos,
        endPosition: endPos,
        child: child,
        onComplete: () {
          entry.remove();
          onComplete?.call();
        },
      ),
    );

    overlay.insert(entry);
  }
}

class _FlyingWidget extends StatefulWidget {
  final Offset startPosition;
  final Offset endPosition;
  final Widget child;
  final VoidCallback onComplete;

  const _FlyingWidget({
    required this.startPosition,
    required this.endPosition,
    required this.child,
    required this.onComplete,
  });

  @override
  State<_FlyingWidget> createState() => _FlyingWidgetState();
}

class _FlyingWidgetState extends State<_FlyingWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _positionAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _positionAnimation = Tween<Offset>(
      begin: widget.startPosition,
      end: widget.endPosition,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.3).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward().then((_) => widget.onComplete());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          left: _positionAnimation.value.dx,
          top: _positionAnimation.value.dy,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}
