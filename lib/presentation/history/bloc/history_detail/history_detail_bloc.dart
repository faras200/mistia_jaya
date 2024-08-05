import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_pos_app/data/datasources/order_local_datasource.dart';
import 'package:flutter_pos_app/data/datasources/product_local_datasource.dart';
import 'package:flutter_pos_app/data/models/request/order_request_model.dart';
import 'package:flutter_pos_app/data/models/response/product_response_model.dart';
import 'package:flutter_pos_app/presentation/home/models/order_item.dart';
import 'package:logger/logger.dart';

part 'history_detail_event.dart';
part 'history_detail_state.dart';
part 'history_detail_bloc.freezed.dart';

class HistoryDetailBloc extends Bloc<HistoryDetailEvent, HistoryDetailState> {
  HistoryDetailBloc() : super(const _Success([], [])) {
    on<_FetchDetail>((event, emit) async {
      emit(const HistoryDetailState.loading());
      final data = await OrderLocalDatasource.instance
          .getOrderItemByOrderIdLocal(event.idOrder);
      List<OrderItem> orderItems = [];

      for (var dataproduct in data) {
        final product = await ProductLocalDatasource.instance
            .getProductById(dataproduct.productId);

        orderItems.add(
            OrderItem(product: product.first, quantity: dataproduct.quantity));
      }

      Logger().d(event.idOrder);
      Logger().d(orderItems);
      Logger().d(data);

      emit(HistoryDetailState.success(data, orderItems));
    });
  }
}
