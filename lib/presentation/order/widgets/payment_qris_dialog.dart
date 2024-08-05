import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pos_app/core/components/buttons.dart';

import 'package:flutter_pos_app/core/extensions/build_context_ext.dart';
import 'package:flutter_pos_app/presentation/order/bloc/qris/qris_bloc.dart';
import 'package:flutter_pos_app/presentation/order/widgets/payment_success_dialog.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

import '../../../core/components/spaces.dart';
import '../../../core/constants/colors.dart';
import '../../../data/datasources/product_local_datasource.dart';
import '../bloc/order/order_bloc.dart';
import '../models/order_model.dart';

class PaymentQrisDialog extends StatefulWidget {
  final int price;
  const PaymentQrisDialog({
    Key? key,
    required this.price,
  }) : super(key: key);

  @override
  State<PaymentQrisDialog> createState() => _PaymentQrisDialogState();
}

class _PaymentQrisDialogState extends State<PaymentQrisDialog> {
  String orderId = '';
  Timer? timer;
  @override
  void initState() {
    orderId = DateTime.now().millisecondsSinceEpoch.toString();
    context.read<QrisBloc>().add(QrisEvent.generateQRCode(
          orderId,
          widget.price,
        ));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      contentPadding: const EdgeInsets.all(0),
      backgroundColor: AppColors.primary,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(12.0),
            child: Text(
              'Pembayaran QRIS',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'Quicksand',
                fontWeight: FontWeight.w700,
                height: 0,
              ),
            ),
          ),
          const SpaceHeight(6.0),
          BlocBuilder<OrderBloc, OrderState>(
            builder: (context, state) {
              return state.maybeWhen(orElse: () {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }, success: (data, qty, total, paymentMethod, nominal, idKasir,
                  namaKasir) {
                return Container(
                  width: context.deviceWidth,
                  padding: const EdgeInsets.all(14.0),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    color: AppColors.white,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      BlocListener<QrisBloc, QrisState>(
                        listener: (context, state) {
                          state.maybeWhen(orElse: () {
                            return;
                          }, qrisResponse: (data) {
                            const onSec = Duration(seconds: 5);
                            timer = Timer.periodic(onSec, (timer) {
                              context
                                  .read<QrisBloc>()
                                  .add(QrisEvent.checkPaymentStatus(
                                    orderId,
                                  ));
                            });
                          }, success: (message) {
                            timer?.cancel();
                            final orderModel = OrderModel(
                                paymentMethod: paymentMethod,
                                nominalBayar: total,
                                orders: data,
                                totalQuantity: qty,
                                totalPrice: total,
                                idKasir: idKasir,
                                namaKasir: namaKasir,
                                transactionTime:
                                    DateFormat('yyyy-MM-ddTHH:mm:ss')
                                        .format(DateTime.now()),
                                isSync: false);
                            ProductLocalDatasource.instance
                                .saveOrder(orderModel);
                            context.pop();
                            showDialog(
                              context: context,
                              builder: (context) =>
                                  const PaymentSuccessDialog(),
                            );
                          });
                        },
                        child: BlocBuilder<QrisBloc, QrisState>(
                          builder: (context, state) {
                            return state.maybeWhen(
                              orElse: () {
                                return const SizedBox();
                              },
                              qrisResponse: (data) {
                                Logger().d(data.statusMessage);
                                return Container(
                                  width: 256.0,
                                  height: 256.0,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20.0),
                                    color: Colors.white,
                                  ),
                                  child: Center(
                                    child: Image.network(
                                        'https://api.midtrans.com/v2/qris/7e2a129c-9dc3-4119-a586-36fd50dcd7c1/qr-code'
                                        // data.actions!.first.url!,
                                        ),
                                  ),
                                );
                              },
                              loading: () {
                                return Container(
                                  width: 256.0,
                                  height: 256.0,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20.0),
                                    color: Colors.white,
                                  ),
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                      const SpaceHeight(5.0),
                      const Text(
                        'Scan QRIS untuk melakukan pembayaran',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      const SpaceHeight(15.0),
                      BlocConsumer<OrderBloc, OrderState>(
                        listener: (context, state) {
                          state.maybeWhen(
                            orElse: () {},
                            success: (data, qty, total, payment, nominal,
                                idKasir, namaKasir) {
                              final orderModel = OrderModel(
                                  paymentMethod: payment,
                                  nominalBayar: nominal,
                                  orders: data,
                                  totalQuantity: qty,
                                  totalPrice: total,
                                  idKasir: idKasir,
                                  namaKasir: namaKasir,
                                  //tranction time format 2024-01-03T22:12:22
                                  transactionTime:
                                      DateFormat('yyyy-MM-ddTHH:mm:ss')
                                          .format(DateTime.now()),
                                  isSync: false);
                              ProductLocalDatasource.instance
                                  .saveOrder(orderModel);
                              context.pop();
                              showDialog(
                                context: context,
                                builder: (context) =>
                                    const PaymentSuccessDialog(),
                              );
                            },
                          );
                        },
                        builder: (context, state) {
                          return state.maybeWhen(orElse: () {
                            return const SizedBox();
                          }, success: (data, qty, total, payment, _, idKasir,
                              mameKasir) {
                            return Button.filled(
                              onPressed: () {
                                context
                                    .read<OrderBloc>()
                                    .add(OrderEvent.addNominalBayar(
                                      widget.price,
                                    ));
                                // context.pop();
                                // showDialog(
                                //   context: context,
                                //   builder: (context) => const PaymentSuccessDialog(),
                                // );
                              },
                              label: 'Selesai',
                            );
                          }, error: (message) {
                            return const SizedBox();
                          });
                        },
                      ),
                    ],
                  ),
                );
              });
            },
          ),
        ],
      ),
    );
  }
}
