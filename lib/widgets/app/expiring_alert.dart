import 'package:flutter/material.dart';
import '../../bloc/proximity_alerts_cubit.dart';

class ExpiringWidget extends StatefulWidget {
  final Widget child;

  const ExpiringWidget({Key? key, required this.child}) : super(key: key);

  @override
  State<ExpiringWidget> createState() => _ExpiringWidgetState();
}

class _ExpiringWidgetState extends State<ExpiringWidget> {
  bool _visible = true;

  @override
  void initState() {
    super.initState(); //when this route starts, it will execute this code
    // TODO: finish impl / swap for other solution
    /*Future.delayed(
        const Duration(seconds: ProximityAlertsCubit.expirationTimeSec), () {
      if (mounted) {
        //checks if widget is still active and not disposed
        setState(() {
          //tells the widget builder to rebuild again because ui has updated
          _visible = false;
        });
      }
    });*/
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: _visible,
      child: widget.child,
    );
  }
}
