import 'package:dri_receiver/dri_receiver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/dri_receiver_cubit.dart';
import 'receiver_page_detail_content.dart';
import 'receiver_page_list_content.dart';

class ReceiverPage extends StatelessWidget {
  const ReceiverPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DriReceiverProvider(
      child: Builder(builder: (context) {
        final connectedSerialNumber =
            context.select<DriReceiversCubit, String?>(
                (cubit) => cubit.state.connectedReceiverId);
        if (connectedSerialNumber == null) {
          return const ReceiverPageListContent();
        } else {
          return ReceiverPageDetailContent(serialNumber: connectedSerialNumber);
        }
      }),
    );
  }
}
