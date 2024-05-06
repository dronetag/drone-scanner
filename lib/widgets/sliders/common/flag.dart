import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../constants/sizes.dart';
import 'small_circular_progress_indicator.dart';

class Flag extends StatefulWidget {
  final String countryCode;
  final Color? color;
  final EdgeInsets? margin;

  const Flag({super.key, required this.countryCode, this.color, this.margin});

  @override
  State<Flag> createState() => _FlagState();
}

class _FlagState extends State<Flag> {
  Widget? image;

  @override
  void initState() {
    super.initState();
    _fetchImage();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.margin,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.transparent,
      ),
      width: Sizes.flagSize,
      height: Sizes.flagSize,
      child: image ??
          SmallCircularProgressIndicator(
            size: Sizes.standard / 10,
            color: widget.color,
            margin: const EdgeInsets.all(
              Sizes.standard / 3,
            ),
          ),
    );
  }

  Future<void> _fetchImage() async {
    final response = await http.get(Uri.parse(
        'https://flagcdn.com/h20/${widget.countryCode.toLowerCase()}.png'));
    if (response.statusCode == 200) {
      setState(() {
        image = CircleAvatar(
            backgroundImage: Image.memory(response.bodyBytes).image);
      });
    } else {
      setState(() {
        image = Icon(
          Icons.cancel,
          size: Sizes.flagSize,
          color: widget.color,
        );
      });
    }
  }
}
