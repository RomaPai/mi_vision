import 'package:flutter/cupertino.dart';

class ClipWave extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(0, size.height * 0.3);
    path.quadraticBezierTo(size.width * 0.04, size.height * 0.22,
        size.width * 0.4, size.height * 0.25);
    path.quadraticBezierTo(size.width * 0.9, size.height * 0.29,
        size.width * 1.0, size.height * 0.1);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}
