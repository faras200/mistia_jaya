import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pos_app/data/dataoutputs/print_invoice.dart';
import 'package:flutter_pos_app/presentation/setting/pages/manage_printer_page.dart';
import 'package:intl/intl.dart';
import 'package:flutter_pos_app/core/assets/assets.gen.dart';
import 'package:flutter_pos_app/core/components/buttons.dart';
import 'package:flutter_pos_app/core/components/spaces.dart';
import 'package:flutter_pos_app/core/constants/colors.dart';
import 'package:flutter_pos_app/core/extensions/build_context_ext.dart';
import 'package:flutter_pos_app/core/extensions/date_time_ext.dart';
import 'package:flutter_pos_app/core/extensions/int_ext.dart';
import 'package:flutter_pos_app/data/dataoutputs/cwb_print.dart';
import 'package:flutter_pos_app/presentation/history/bloc/history_detail/history_detail_bloc.dart';
import 'package:flutter_pos_app/presentation/history/widgets/item_product_card.dart';
import 'package:flutter_pos_app/presentation/order/models/order_model.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TransactionDetailDialoge extends StatefulWidget {
  final OrderModel dataDetail;
  const TransactionDetailDialoge({
    super.key,
    required this.dataDetail,
  });

  @override
  State<TransactionDetailDialoge> createState() =>
      _TransactionDetailDialogeState();
}

class _TransactionDetailDialogeState extends State<TransactionDetailDialoge> {
  late SharedPreferences prefs;
  late String? macName = '';

  Future<void> loadPreferences() async {
    prefs = await SharedPreferences.getInstance();
    macName = prefs.getString("mac_print_name") ?? '';
  }

  @override
  void initState() {
    super.initState();
    context
        .read<HistoryDetailBloc>()
        .add(HistoryDetailEvent.fetchDetail(widget.dataDetail.id ?? 0));

    loadPreferences();
  }

  @override
  Widget build(BuildContext context) {
    DateTime parseDate = DateFormat("yyyy-MM-ddTHH:mm:ss")
        .parse(widget.dataDetail.transactionTime!);
    var inputDate = DateTime.parse(parseDate.toString());
    var outputDate = inputDate.toFormattedTime();

    return AlertDialog(
      scrollable: true,
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SpaceHeight(24.0),
          const Text(
            'Detail Order',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
            ),
          ),
          Text(
            widget.dataDetail.id!.toString(),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _LabelValue(
            label: 'TOTAL PEMBELIAN',
            value:
                '${widget.dataDetail.totalPrice!.currencyFormatRp}   ( ${widget.dataDetail.paymentMethod} )',
          ),
          const Divider(height: 26.0),
          _LabelValue(
            label: 'NOMINAL BAYAR',
            value: widget.dataDetail.nominalBayar!.currencyFormatRp,
          ),
          const Divider(height: 26.0),
          _LabelValue(
            label: 'WAKTU PEMBAYARAN',
            value: outputDate,
          ),
          const SpaceHeight(26.0),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'DETAIL ITEM PEMBELIAN',
                style: TextStyle(),
              ),
              SpaceHeight(5.0),
            ],
          ),
          BlocBuilder<HistoryDetailBloc, HistoryDetailState>(
            builder: (context, state) {
              return state.maybeWhen(
                orElse: () {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
                success: (data, orders) {
                  return Column(
                    children: [
                      SizedBox(
                        width: double.maxFinite,
                        height: 200,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          itemCount: orders.length,
                          separatorBuilder: (context, index) =>
                              const SpaceHeight(10.0),
                          itemBuilder: (context, index) => ItemProductCard(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4.0),
                            data: data[index],
                            dataproduct: orders[index],
                          ),
                        ),
                      ),
                      const SpaceHeight(30.0),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Button.filled(
                              onPressed: () {
                                context.pop();
                              },
                              label: 'Kembali',
                              fontSize: 13,
                            ),
                          ),
                          const SpaceWidth(10.0),
                          Flexible(
                            child: Button.outlined(
                              onPressed: () async {
                                if (macName == '') {
                                  setState(() {
                                    macName = '0';
                                  });
                                  return AwesomeDialog(
                                          context: context,
                                          dialogType: DialogType.error,
                                          headerAnimationLoop: false,
                                          animType: AnimType.bottomSlide,
                                          title: 'Error!',
                                          desc: 'Printer tidak terdeteksi',
                                          buttonsTextStyle: const TextStyle(
                                              color: Colors.white),
                                          showCloseIcon: true,
                                          btnOkText: 'Setting Printer',
                                          btnOkOnPress: () {
                                            // context.pop();
                                            // ignore: use_build_context_synchronously
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        const ManagePrinterPage()));
                                          },
                                          btnOkColor: AppColors.primary)
                                      .show();
                                }
                                final printValue =
                                    await PrintInvoice.instance.printOrder(
                                  orders,
                                  widget.dataDetail.totalQuantity!,
                                  widget.dataDetail.totalPrice!,
                                  widget.dataDetail.paymentMethod!,
                                  widget.dataDetail.nominalBayar!,
                                  widget.dataDetail.namaKasir!,
                                  widget.dataDetail.namaKasir!,
                                  widget.dataDetail.transactionTime!,
                                );
                                await PrintBluetoothThermal.writeBytes(
                                    printValue);
                              },
                              label: 'Print',
                              icon: Assets.icons.print
                                  // ignore: deprecated_member_use_from_same_package
                                  .svg(color: AppColors.primary),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _LabelValue extends StatelessWidget {
  final String label;
  final String value;

  const _LabelValue({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(),
        ),
        const SpaceHeight(5.0),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
