import 'package:flutter/material.dart';
import 'package:flutter_pos_app/core/extensions/int_ext.dart';
import 'package:flutter_pos_app/presentation/history/widgets/transction_detail_dialoge.dart';
import 'package:flutter_pos_app/presentation/order/models/order_model.dart';

import '../../../core/assets/assets.gen.dart';
import '../../../core/constants/colors.dart';
import '../models/history_transaction_model.dart';

class HistoryTransactionCard extends StatefulWidget {
  final OrderModel data;
  final EdgeInsetsGeometry? padding;

  const HistoryTransactionCard({
    super.key,
    required this.data,
    this.padding,
  });

  @override
  State<HistoryTransactionCard> createState() => _HistoryTransactionCardState();
}

class _HistoryTransactionCardState extends State<HistoryTransactionCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.padding,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 2),
            blurRadius: 48.0,
            blurStyle: BlurStyle.outer,
            spreadRadius: 0,
            color: AppColors.black.withOpacity(0.06),
          ),
        ],
      ),
      child: ListTile(
        onTap: () {
          // if (widget.isSelectItem) {
          //   setState(() {
          //     selectedItem[widget.index] = !isSelectedData;
          //     Logger().d(selectedItem);
          //     widget.updateSelectItem(selectedItem.containsValue(true));
          //     // widget.isSelectItem = selectedItem.containsValue(true);
          //   });
          // } else {
          showDialog(
            context: context,
            builder: (context) =>
                TransactionDetailDialoge(dataDetail: widget.data),
          );
          // }
        },
        leading: Assets.icons.payments.svg(),
        title: Text(widget.data.paymentMethod),
        subtitle: Text('${widget.data.totalQuantity} items'),
        trailing: Text(
          widget.data.totalPrice.currencyFormatRp,
          style: const TextStyle(
            color: AppColors.green,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
