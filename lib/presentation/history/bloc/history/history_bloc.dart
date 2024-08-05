import 'package:bloc/bloc.dart';
import 'package:flutter_pos_app/data/datasources/order_local_datasource.dart';
import 'package:flutter_pos_app/data/datasources/order_remote_datasource.dart';
import 'package:flutter_pos_app/data/datasources/product_local_datasource.dart';
import 'package:flutter_pos_app/presentation/home/models/order_item.dart';
import 'package:flutter_pos_app/presentation/order/models/order_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logger/logger.dart';

part 'history_event.dart';
part 'history_state.dart';
part 'history_bloc.freezed.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  HistoryBloc() : super(const _Initial()) {
    // on<_Fetch>((event, emit) async {
    //   emit(const HistoryState.loading());
    //   final data = await ProductLocalDatasource.instance.getAllOrder();
    //   emit(HistoryState.success(data));
    // });

    on<_Fetch>((event, emit) async {
      emit(const HistoryState.loading());
      final data = await OrderLocalDatasource.instance.getAllOrder();
      int keynumb = 0;
      for (var dataOrder in data) {
        final dataOrders = await OrderLocalDatasource.instance
            .getOrderItemByOrderIdLocal(dataOrder.id!);

        List<OrderItem> orderItems = [];
        for (var dataproduct in dataOrders) {
          final product = await ProductLocalDatasource.instance
              .getProductById(dataproduct.productId);

          orderItems.add(OrderItem(
              product: product.first, quantity: dataproduct.quantity));
        }
        Logger().d(orderItems[0].product.category);

        data[keynumb].orders = orderItems;
        keynumb++;
      }
      emit(HistoryState.success(data));
    });

    on<_FetchByDate>((event, emit) async {
      emit(const HistoryState.loading());
      final fromDate = DateTime.parse(event.fromDate).toIso8601String();
      final toDate = DateTime.parse(event.toDate)
          .add(const Duration(hours: 23, minutes: 59, seconds: 59))
          .toIso8601String();
      final data =
          await OrderLocalDatasource.instance.getByDate(fromDate, toDate);
      int keynumb = 0;
      for (var dataOrder in data) {
        final dataOrders = await OrderLocalDatasource.instance
            .getOrderItemByOrderIdLocal(dataOrder.id!);

        List<OrderItem> orderItems = [];
        for (var dataproduct in dataOrders) {
          final product = await ProductLocalDatasource.instance
              .getProductById(dataproduct.productId);

          orderItems.add(OrderItem(
              product: product.first, quantity: dataproduct.quantity));
        }

        data[keynumb].orders = orderItems;
        keynumb++;
      }
      emit(HistoryState.success(data));
    });

    on<_Delete>((event, emit) async {
      emit(const HistoryState.loading());
      final histories = event.histories;
      Logger().d(histories);
      List<String> ids =
          histories.map<String>((item) => item.id.toString()).toList();
      Logger().d(ids);
      final deleteLocal =
          await OrderLocalDatasource.instance.deleteOrderById(ids);

      if (deleteLocal > 0) {
        final deleteRemote =
            await OrderRemoteDatasource.instance.deleteOrder(ids);
        // final data = await OrderLocalDatasource.instance.getAllOrder();
        if (deleteRemote) {
          Logger().d('delete success');
          emit(const HistoryState.successDelete(true));
          // emit(HistoryState.success(data));
        } else {
          // emit(HistoryState.success(data));
          emit(const HistoryState.successDelete(true));
        }
      } else {
        final data = await OrderLocalDatasource.instance.getAllOrder();
        // emit(HistoryState.success(data));
        emit(const HistoryState.successDelete(false));
      }
    });
  }
}
