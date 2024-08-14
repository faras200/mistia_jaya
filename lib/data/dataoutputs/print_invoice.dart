import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';

import 'package:intl/intl.dart';
import 'package:flutter_pos_app/core/extensions/date_time_ext.dart';
import 'package:flutter_pos_app/core/extensions/int_ext.dart';
import 'package:flutter_pos_app/presentation/home/models/order_item.dart';

class PrintInvoice {
  PrintInvoice._init();

  static final PrintInvoice instance = PrintInvoice._init();

  Future<List<int>> printOrder(
    List<OrderItem> products,
    int totalQuantity,
    int totalPrice,
    String paymentMethod,
    int nominalBayar,
    String namaKasir,
    String uuid,
    String transactionTime,
  ) async {
    List<int> bytes = [];

    DateTime parseDate =
        DateFormat("yyyy-MM-ddTHH:mm:ss").parse(transactionTime);
    var inputDate = DateTime.parse(parseDate.toString());
    var outputDate = inputDate.toFormattedTime();

    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);

    String payment = paymentMethod == 'Tunai'
        ? 'Tunai'
        : paymentMethod == 'QRIS'
            ? 'QRIS'
            : 'QRIS AP';

    bytes += generator.reset();
    bytes += generator.text('RM Mistia Jaya',
        styles: const PosStyles(
          bold: true,
          align: PosAlign.center,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
        ));
    // bytes += generator.text('Code with Bahri',
    //     styles: const PosStyles(
    //       bold: true,
    //       align: PosAlign.center,
    //       height: PosTextSize.size1,
    //       width: PosTextSize.size1,
    //     ));

    bytes += generator.text(
        'Griya Merpati Mas Blok C41A No.13, Kota Tangerang, Banten 15133',
        styles: const PosStyles(bold: true, align: PosAlign.center));
    bytes += generator.hr();

    bytes += generator.row(
      [
        PosColumn(
          text: 'Date:',
          width: 3,
          styles: const PosStyles(align: PosAlign.left, underline: true),
        ),
        PosColumn(
          text: outputDate,
          width: 9,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ],
    );

    bytes += generator.row(
      [
        PosColumn(
          text: 'Nama Kasir: ',
          width: 4,
          styles: const PosStyles(align: PosAlign.left, underline: true),
        ),
        PosColumn(
          text: uuid,
          width: 8,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ],
    );

    bytes += generator.hr();
    bytes += generator.text('Pesanan:',
        styles: const PosStyles(bold: false, align: PosAlign.center));
    //for from data
    for (final product in products) {
      // bytes += generator.text(product.product.name,
      //     maxCharsPerLine: 25, styles: const PosStyles(align: PosAlign.left));

      bytes += generator.row(
        [
          PosColumn(
            text: product.product.name,
            width: 12,
            styles: const PosStyles(align: PosAlign.left, underline: true),
          ),
        ],
      );

      bytes += generator.row([
        PosColumn(
          text:
              '${product.quantity} x  @${product.product.price.currencyFormat}',
          width: 8,
          styles: const PosStyles(align: PosAlign.left),
        ),
        PosColumn(
          text: (product.product.price * product.quantity).currencyFormat,
          width: 4,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
    }

    bytes += generator.hr();

    bytes += generator.row([
      PosColumn(
        text: 'Total',
        width: 6,
        styles: const PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: totalPrice.currencyFormatRp,
        width: 6,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);

    bytes += generator.row([
      PosColumn(
        text: 'Bayar $payment',
        width: 6,
        styles: const PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: nominalBayar.currencyFormatRp,
        width: 6,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);

    if ((nominalBayar - totalPrice) > 0) {
      bytes += generator.row([
        PosColumn(
          text: 'Kembalian',
          width: 8,
          styles: const PosStyles(align: PosAlign.left),
        ),
        PosColumn(
          text: (nominalBayar - totalPrice).currencyFormatRp,
          width: 4,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
    }

    bytes += generator.hr();

    bytes += generator.text('Terima kasih',
        styles: const PosStyles(bold: false, align: PosAlign.center));
    bytes += generator.feed(3);

    return bytes;
  }
}
