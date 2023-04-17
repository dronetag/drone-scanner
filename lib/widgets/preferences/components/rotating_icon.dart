import 'package:flutter/widgets.dart';

class RotatingIcon extends StatefulWidget {
  final Widget icon;
  final bool rotating;
  const RotatingIcon({
    Key? key,
    required this.icon,
    required this.rotating,
  }) : super(key: key);

  @override
  State<RotatingIcon> createState() => _RotatingIconState();
}

class _RotatingIconState extends State<RotatingIcon>
    with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 2),
    vsync: this,
  )..repeat(reverse: false);

  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.linear,
  );
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.rotating) {
      _controller.reset();
    } else {
      _controller.repeat();
    }
    return RotationTransition(turns: _animation, child: widget.icon);
  }
}
