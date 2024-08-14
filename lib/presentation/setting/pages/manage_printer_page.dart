import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pos_app/core/components/loading.dart';
import 'package:flutter_pos_app/core/extensions/build_context_ext.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/components/spaces.dart';
import '../../../core/constants/colors.dart';
import '../models/printer_model.dart';
import '../widgets/menu_printer_button.dart';
import '../widgets/menu_printer_content.dart';

class ManagePrinterPage extends StatefulWidget {
  const ManagePrinterPage({super.key});

  @override
  State<ManagePrinterPage> createState() => _ManagePrinterPageState();
}

class _ManagePrinterPageState extends State<ManagePrinterPage> {
  int selectedIndex = 0;
  // final List<PrinterModel> datas = [
  //   PrinterModel(
  //     name: 'Galaxy A30',
  //     address: 12324567412,
  //   ),
  //   PrinterModel(
  //     name: 'Galaxy A30',
  //     address: 12324567412,
  //   ),
  //   PrinterModel(
  //     name: 'Galaxy A30',
  //     address: 12324567412,
  //   ),
  // ];

  String macName = '';

  String _info = "";
  String _msj = '';
  bool connected = false;
  List<BluetoothInfo> items = [];
  final List<String> _options = [
    "permission bluetooth granted",
    "bluetooth enabled",
    "connection status",
    "update info"
  ];

  String _selectSize = "2";
  final _txtText = TextEditingController(text: "Hello developer");
  bool _progress = false;
  String _msjprogress = "";

  String optionprinttype = "58 mm";
  List<String> options = ["58 mm", "80 mm"];
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    initPlatformState();
    checkPremission();
    loadPreferences();
  }

  Future<void> checkPremission() async {
    bool granted = !(await Future.wait([
      // Check Permissions
      Permission.bluetooth.isGranted,
      Permission.bluetoothAdvertise.isGranted,
      Permission.bluetoothConnect.isGranted,
      Permission.bluetoothScan.isGranted,
    ]))
        .any((element) => false);
    [
      // Ask Permissions
      Permission.bluetooth,
      Permission.bluetoothAdvertise,
      Permission.bluetoothConnect,
      Permission.bluetoothScan
    ].request();
  }

  Future<void> loadPreferences() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      macName = prefs.getString("mac_print_name") ?? '';
    });
  }

  Future<void> initPlatformState() async {
    String platformVersion;
    int porcentbatery = 0;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await PrintBluetoothThermal.platformVersion;
      print("patformversion: $platformVersion");
      porcentbatery = await PrintBluetoothThermal.batteryLevel;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    final bool result = await PrintBluetoothThermal.bluetoothEnabled;
    print("bluetooth enabled: $result");
    if (result) {
      _msj = "Bluetooth enabled, please search and connect";
      getBluetoots();
    } else {
      _msj = "Bluetooth not enabled";
      // ignore: use_build_context_synchronously
      return AwesomeDialog(
              context: context,
              dialogType: DialogType.warning,
              headerAnimationLoop: false,
              animType: AnimType.bottomSlide,
              title: 'Peringatan!',
              desc: 'Hidupkan bluetooth ponsel anda!!',
              buttonsTextStyle: const TextStyle(color: Colors.white),
              showCloseIcon: true,
              btnOkOnPress: () {},
              btnOkColor: AppColors.primary)
          .show();
    }

    setState(() {
      _info = "$platformVersion ($porcentbatery% battery)";
    });
  }

  Future<void> getBluetoots() async {
    checkPremission();
    setState(() {
      _progress = true;
      _msjprogress = "Wait";
      items = [];
    });
    final List<BluetoothInfo> listResult =
        await PrintBluetoothThermal.pairedBluetooths;

    setState(() {
      _progress = false;
    });

    if (listResult.isEmpty) {
      _msj =
          "There are no bluetoohs linked, go to settings and link the printer";
    } else {
      _msj = "Touch an item in the list to connect";
    }

    setState(() {
      items = listResult;
    });
  }

  Future<void> connect(String mac) async {
    setState(() {
      _progress = true;
      _msjprogress = "Connecting...";
      connected = false;
    });
    disconnect();
    MyLoading().loading(context);
    final bool result =
        await PrintBluetoothThermal.connect(macPrinterAddress: mac);
    print("state conected $result");
    MyLoading().dismiss();
    setState(() {
      _progress = false;
    });
    if (result) {
      connected = true;
      prefs.setString("mac_print_name", mac);
      // ignore: use_build_context_synchronously
      AwesomeDialog(
              context: context,
              dialogType: DialogType.success,
              headerAnimationLoop: false,
              animType: AnimType.bottomSlide,
              title: 'Success!',
              desc: 'Koneksi printer berhasil!!',
              buttonsTextStyle: const TextStyle(color: Colors.white),
              showCloseIcon: true,
              btnOkOnPress: () {
                context.pop();
                // ignore: use_build_context_synchronously
                // Navigator.pushReplacement(
                //     context,
                //     MaterialPageRoute(
                //         builder: (context) => const ManageMenuPage()));
              },
              btnOkColor: AppColors.primary)
          .show();

      // ignore: use_build_context_synchronously
    } else {
      macName = '';
      // ignore: use_build_context_synchronously
      AwesomeDialog(
              context: context,
              dialogType: DialogType.error,
              headerAnimationLoop: false,
              animType: AnimType.bottomSlide,
              title: 'Peringatan!',
              desc: 'Koneksi printer gagal!!',
              buttonsTextStyle: const TextStyle(color: Colors.white),
              showCloseIcon: true,
              btnOkOnPress: () {},
              btnOkColor: AppColors.primary)
          .show();
    }
  }

  Future<void> disconnect() async {
    final bool status = await PrintBluetoothThermal.disconnect;
    setState(() {
      connected = false;
    });
    prefs.setString("mac_print_name", '');
    print("status disconnect $status");
  }

  Future<void> printTest() async {
    bool conexionStatus = await PrintBluetoothThermal.connectionStatus;
    //print("connection status: $conexionStatus");
    if (conexionStatus) {
      List<int> ticket = await testTicket();
      final result = await PrintBluetoothThermal.writeBytes(ticket);
      print("print test result:  $result");
    } else {
      //no conectado, reconecte
    }
  }

  Future<List<int>> testTicket() async {
    List<int> bytes = [];
    // Using default profile
    final profile = await CapabilityProfile.load();
    final generator = Generator(
        optionprinttype == "58 mm" ? PaperSize.mm58 : PaperSize.mm80, profile);
    //bytes += generator.setGlobalFont(PosFontType.fontA);
    bytes += generator.reset();

    bytes += generator.text('Hoki Distribusi Niaga',
        styles: const PosStyles(bold: true));
    bytes +=
        generator.text('Reverse text', styles: const PosStyles(reverse: true));
    bytes += generator.text('Underlined text',
        styles: const PosStyles(underline: true), linesAfter: 1);
    bytes += generator.text('Align left',
        styles: const PosStyles(align: PosAlign.left));
    bytes += generator.text('Align center',
        styles: const PosStyles(align: PosAlign.center));
    bytes += generator.text('Align right',
        styles: const PosStyles(align: PosAlign.right), linesAfter: 1);

    bytes += generator.text(
      'HOKI HDN',
      styles: const PosStyles(
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    );

    bytes += generator.feed(2);
    //bytes += generator.cut();
    return bytes;
  }

  Future<void> printWithoutPackage() async {
    //impresion sin paquete solo de PrintBluetoothTermal
    bool connectionStatus = await PrintBluetoothThermal.connectionStatus;
    if (connectionStatus) {
      String text = "${_txtText.text}\n";
      bool result = await PrintBluetoothThermal.writeString(
          printText: PrintTextSize(size: int.parse(_selectSize), text: text));
      print("status print result: $result");
      setState(() {
        _msj = "printed status: $result";
      });
    } else {
      //no conectado, reconecte
      setState(() {
        _msj = "no connected device";
      });
      print("no conectado");
    }
  }

  Future<void> printString() async {
    bool conexionStatus = await PrintBluetoothThermal.connectionStatus;
    if (conexionStatus) {
      String enter = '\n';
      await PrintBluetoothThermal.writeBytes(enter.codeUnits);
      //size of 1-5
      String text = "Hello";
      await PrintBluetoothThermal.writeString(
          printText: PrintTextSize(size: 1, text: text));
      await PrintBluetoothThermal.writeString(
          printText: PrintTextSize(size: 2, text: "$text size 2"));
      await PrintBluetoothThermal.writeString(
          printText: PrintTextSize(size: 3, text: "$text size 3"));
    } else {
      //desconectado
      print("desconectado bluetooth $conexionStatus");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Printer'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          Container(
            width: context.deviceWidth / 2,
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                MenuPrinterButton(
                  label: 'Search',
                  onPressed: () {
                    getBluetoots();
                    selectedIndex = 0;
                    setState(() {});
                  },
                  isActive: selectedIndex == 0,
                ),
                MenuPrinterButton(
                  label: 'Disconnect',
                  onPressed: () {
                    selectedIndex = 1;
                    disconnect();
                    setState(() {
                      macName = '';
                    });
                  },
                  isActive: selectedIndex == 1,
                ),
                MenuPrinterButton(
                  label: 'Test',
                  onPressed: () {
                    selectedIndex = 2;
                    printTest();
                    setState(() {});
                  },
                  isActive: selectedIndex == 2,
                ),
              ],
            ),
          ),
          const SpaceHeight(34.0),
          _Body(
            // selectedIndex: selectedIndex,
            macName: macName,
            datas: items,
            clickHandler: (mac) async {
              macName = mac;
              await connect(mac);
              setState(() {});
            },
          ),
        ],
      ),
    );
  }
}

class _Body extends StatelessWidget {
  // final int selectedIndex;
  final String macName;
  final List<BluetoothInfo> datas;

  //clickHandler
  final Function(String) clickHandler;

  const _Body({
    Key? key,
    required this.macName,
    required this.datas,
    required this.clickHandler,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (datas.isEmpty) {
      return const Text('No data available');
    } else {
      return Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.card, width: 2),
          borderRadius: BorderRadius.circular(6),
        ),
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: datas.length,
          separatorBuilder: (context, index) => const SpaceHeight(16.0),
          itemBuilder: (context, index) => InkWell(
            onTap: () {
              clickHandler(datas[index].macAdress);
            },
            child: MenuPrinterContent(
              isSelected: macName == datas[index].macAdress,
              data: datas[index],
            ),
          ),
        ),
      );
    }
    // return const Placeholder();
  }
}

// class _ManagePrinterPageState extends State<ManagePrinterPage> {
//   int selectedIndex = 0;
//   // final List<PrinterModel> datas = [
//   //   PrinterModel(
//   //     name: 'Galaxy A30',
//   //     address: 12324567412,
//   //   ),
//   //   PrinterModel(
//   //     name: 'Galaxy A30',
//   //     address: 12324567412,
//   //   ),
//   //   PrinterModel(
//   //     name: 'Galaxy A30',
//   //     address: 12324567412,
//   //   ),
//   // ];

//   String macName = '';

//   String _info = "";
//   String _msj = '';
//   bool connected = false;
//   List<BluetoothInfo> items = [];
//   final List<String> _options = [
//     "permission bluetooth granted",
//     "bluetooth enabled",
//     "connection status",
//     "update info"
//   ];

//   String _selectSize = "2";
//   final _txtText = TextEditingController(text: "Hello developer");
//   bool _progress = false;
//   String _msjprogress = "";

//   String optionprinttype = "58 mm";
//   List<String> options = ["58 mm", "80 mm"];

//   @override
//   void initState() {
//     super.initState();
//     initPlatformState();
//   }

//   Future<void> initPlatformState() async {
//     String platformVersion;
//     int porcentbatery = 0;
//     // Platform messages may fail, so we use a try/catch PlatformException.
//     try {
//       platformVersion = await PrintBluetoothThermal.platformVersion;
//       print("patformversion: $platformVersion");
//       porcentbatery = await PrintBluetoothThermal.batteryLevel;
//     } on PlatformException {
//       platformVersion = 'Failed to get platform version.';
//     }

//     // If the widget was removed from the tree while the asynchronous platform
//     // message was in flight, we want to discard the reply rather than calling
//     // setState to update our non-existent appearance.
//     if (!mounted) return;

//     final bool result = await PrintBluetoothThermal.bluetoothEnabled;
//     print("bluetooth enabled: $result");
//     if (result) {
//       _msj = "Bluetooth enabled, please search and connect";
//     } else {
//       _msj = "Bluetooth not enabled";
//     }

//     setState(() {
//       _info = "$platformVersion ($porcentbatery% battery)";
//     });
//   }

//   Future<void> getBluetoots() async {
//     setState(() {
//       _progress = true;
//       _msjprogress = "Wait";
//       items = [];
//     });
//     final List<BluetoothInfo> listResult =
//         await PrintBluetoothThermal.pairedBluetooths;

//     setState(() {
//       _progress = false;
//     });

//     if (listResult.isEmpty) {
//       _msj =
//           "There are no bluetoohs linked, go to settings and link the printer";
//     } else {
//       _msj = "Touch an item in the list to connect";
//     }

//     setState(() {
//       items = listResult;
//     });
//   }

//   Future<void> connect(String mac) async {
//     setState(() {
//       _progress = true;
//       _msjprogress = "Connecting...";
//       connected = false;
//     });
//     final bool result =
//         await PrintBluetoothThermal.connect(macPrinterAddress: mac);
//     print("state conected $result");
//     if (result) connected = true;
//     setState(() {
//       _progress = false;
//     });
//   }

//   Future<void> disconnect() async {
//     final bool status = await PrintBluetoothThermal.disconnect;
//     setState(() {
//       connected = false;
//     });
//     print("status disconnect $status");
//   }

//   Future<void> printTest() async {
//     bool conexionStatus = await PrintBluetoothThermal.connectionStatus;
//     //print("connection status: $conexionStatus");
//     if (conexionStatus) {
//       List<int> ticket = await testTicket();
//       final result = await PrintBluetoothThermal.writeBytes(ticket);
//       print("print test result:  $result");
//     } else {
//       //no conectado, reconecte
//     }
//   }

//   Future<List<int>> testTicket() async {
//     List<int> bytes = [];
//     // Using default profile
//     final profile = await CapabilityProfile.load();
//     final generator = Generator(
//         optionprinttype == "58 mm" ? PaperSize.mm58 : PaperSize.mm80, profile);
//     //bytes += generator.setGlobalFont(PosFontType.fontA);
//     bytes += generator.reset();

//     bytes +=
//         generator.text('Code with Bahri', styles: const PosStyles(bold: true));
//     bytes +=
//         generator.text('Reverse text', styles: const PosStyles(reverse: true));
//     bytes += generator.text('Underlined text',
//         styles: const PosStyles(underline: true), linesAfter: 1);
//     bytes += generator.text('Align left',
//         styles: const PosStyles(align: PosAlign.left));
//     bytes += generator.text('Align center',
//         styles: const PosStyles(align: PosAlign.center));
//     bytes += generator.text('Align right',
//         styles: const PosStyles(align: PosAlign.right), linesAfter: 1);

//     bytes += generator.text(
//       'FIC Batch 11',
//       styles: const PosStyles(
//         height: PosTextSize.size2,
//         width: PosTextSize.size2,
//       ),
//     );

//     bytes += generator.feed(2);
//     //bytes += generator.cut();
//     return bytes;
//   }

//   Future<void> printWithoutPackage() async {
//     //impresion sin paquete solo de PrintBluetoothTermal
//     bool connectionStatus = await PrintBluetoothThermal.connectionStatus;
//     if (connectionStatus) {
//       String text = "${_txtText.text}\n";
//       bool result = await PrintBluetoothThermal.writeString(
//           printText: PrintTextSize(size: int.parse(_selectSize), text: text));
//       print("status print result: $result");
//       setState(() {
//         _msj = "printed status: $result";
//       });
//     } else {
//       //no conectado, reconecte
//       setState(() {
//         _msj = "no connected device";
//       });
//       print("no conectado");
//     }
//   }

//   Future<void> printString() async {
//     bool conexionStatus = await PrintBluetoothThermal.connectionStatus;
//     if (conexionStatus) {
//       String enter = '\n';
//       await PrintBluetoothThermal.writeBytes(enter.codeUnits);
//       //size of 1-5
//       String text = "Hello";
//       await PrintBluetoothThermal.writeString(
//           printText: PrintTextSize(size: 1, text: text));
//       await PrintBluetoothThermal.writeString(
//           printText: PrintTextSize(size: 2, text: "$text size 2"));
//       await PrintBluetoothThermal.writeString(
//           printText: PrintTextSize(size: 3, text: "$text size 3"));
//     } else {
//       //desconectado
//       print("desconectado bluetooth $conexionStatus");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Kelola Printer'),
//         centerTitle: true,
//       ),
//       body: ListView(
//         padding: const EdgeInsets.all(24.0),
//         children: [
//           Container(
//             width: context.deviceWidth / 2,
//             padding: const EdgeInsets.all(8.0),
//             decoration: BoxDecoration(
//               color: AppColors.card,
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 MenuPrinterButton(
//                   label: 'Search',
//                   onPressed: () {
//                     getBluetoots();
//                     selectedIndex = 0;
//                     setState(() {});
//                   },
//                   isActive: selectedIndex == 0,
//                 ),
//                 MenuPrinterButton(
//                   label: 'Disconnect',
//                   onPressed: () {
//                     selectedIndex = 1;
//                     setState(() {});
//                   },
//                   isActive: selectedIndex == 1,
//                 ),
//                 MenuPrinterButton(
//                   label: 'Test',
//                   onPressed: () {
//                     selectedIndex = 2;
//                     setState(() {});
//                   },
//                   isActive: selectedIndex == 2,
//                 ),
//               ],
//             ),
//           ),
//           const SpaceHeight(34.0),
//           _Body(
//             // selectedIndex: selectedIndex,
//             macName: macName,
//             datas: items,
//             clickHandler: (mac) async {
//               macName = mac;
//               await connect(mac);
//               setState(() {});
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _Body extends StatelessWidget {
//   // final int selectedIndex;
//   final String macName;
//   final List<BluetoothInfo> datas;

//   //clickHandler
//   final Function(String) clickHandler;

//   const _Body({
//     Key? key,
//     required this.macName,
//     required this.datas,
//     required this.clickHandler,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     if (datas.isEmpty) {
//       return const Text('No data available');
//     } else {
//       return Container(
//         padding: const EdgeInsets.all(24.0),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           border: Border.all(color: AppColors.card, width: 2),
//           borderRadius: BorderRadius.circular(6),
//         ),
//         child: ListView.separated(
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           itemCount: datas.length,
//           separatorBuilder: (context, index) => const SpaceHeight(16.0),
//           itemBuilder: (context, index) => InkWell(
//             onTap: () {
//               clickHandler(datas[index].macAdress);
//             },
//             child: MenuPrinterContent(
//               isSelected: macName == datas[index].macAdress,
//               data: datas[index],
//             ),
//           ),
//         ),
//       );
//     }
//     // return const Placeholder();
//   }
// }
