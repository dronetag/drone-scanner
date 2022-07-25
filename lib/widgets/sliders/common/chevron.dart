import 'package:flutter/material.dart';

enum ChevronDirection { upwards, downwards, none, notset }

class Chevron extends CustomPainter {
  BuildContext? _context;
  ChevronDirection? _dir;
  Color? _color;

  @override
  void paint(Canvas canvas, Size size) {
    if (_context == null || _dir == null) return;
    final paint = Paint();
    paint.color = _color ?? Colors.white;

    var path = Path();
    if (_dir == ChevronDirection.upwards) {
      createUpwardPath(path, size);
    } else if (_dir == ChevronDirection.downwards) {
      createDownwardPath(path, size);
    } else {
      createRectPath(path, size);
    }
    canvas.drawPath(path, paint);
  }

  void setDirection(ChevronDirection dir) {
    _dir = dir;
  }

  void setColor(Color color) {
    _color = color;
  }

  void setContext(BuildContext context) {
    _context = context;
  }

  ChevronDirection getDirection() {
    if (_dir == null) return ChevronDirection.notset;
    return _dir!;
  }

  void createUpwardPath(Path path, Size size) {
    path.moveTo(0, size.height / 3 * 2);
    path.lineTo(size.height / 3, size.height);
    path.lineTo(size.width / 2, size.height / 3 + 2);
    path.lineTo(size.width - size.height / 3, size.height);
    path.lineTo(size.width, size.height / 3 * 2);
    path.lineTo(size.width / 2, 0);
    path.lineTo(0, size.height / 3 * 2);
    path.close();
  }

  void createDownwardPath(Path path, Size size) {
    path.moveTo(0, size.height / 3);
    path.lineTo(size.width / 2, size.height);
    path.lineTo(size.width, size.height / 3);
    path.lineTo(size.width - size.height / 3, 0);
    path.lineTo(size.width / 2, size.height / 3 * 2 - 2);
    path.lineTo(size.height / 3, 0);
    path.close();
  }

  void createRectPath(Path path, Size size) {
    path.moveTo(0, size.height / 3);
    path.lineTo(0, size.height / 3 * 2);
    path.lineTo(size.width, size.height / 3 * 2);
    path.lineTo(size.width, size.height / 3);
    path.close();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
