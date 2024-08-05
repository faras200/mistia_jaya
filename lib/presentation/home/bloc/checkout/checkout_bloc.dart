import 'package:bloc/bloc.dart';
import 'package:flutter_pos_app/data/models/response/product_response_model.dart';
import 'package:flutter_pos_app/presentation/home/models/order_item.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'checkout_event.dart';
part 'checkout_state.dart';
part 'checkout_bloc.freezed.dart';

class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  CheckoutBloc() : super(const _Success([], 0, 0)) {
    on<_AddCheckout>((event, emit) {
      var currentStates = state as _Success;
      List<OrderItem> newCheckout = [...currentStates.products];
      emit(const _Loading());
      if (newCheckout.any((element) => element.product == event.product)) {
        var index = newCheckout
            .indexWhere((element) => element.product == event.product);

        newCheckout[index].quantity++;
      } else {
        newCheckout.add(OrderItem(product: event.product, quantity: 1));
      }

      final hitung = calculate(newCheckout);

      emit(_Success(newCheckout, hitung.totalQuantity, hitung.totalPrice));
    });

    on<_RemoveCheckout>((event, emit) {
      var currentStates = state as _Success;
      List<OrderItem> newCheckout = [...currentStates.products];
      emit(const _Loading());
      if (newCheckout.any((element) => element.product == event.product)) {
        var index = newCheckout
            .indexWhere((element) => element.product == event.product);

        if (newCheckout[index].quantity > 1) {
          newCheckout[index].quantity--;
        } else {
          newCheckout.removeAt(index);
        }
      }

      final hitung = calculate(newCheckout);

      emit(_Success(newCheckout, hitung.totalQuantity, hitung.totalPrice));
    });

    on<_RemoveItemCheckout>((event, emit) {
      var currentState = state as _Success;
      List<OrderItem> newCheckout = [...currentState.products];
      emit(const _Loading());
      if (newCheckout.any((element) => element.product == event.product)) {
        var index = newCheckout
            .indexWhere((element) => element.product == event.product);

        newCheckout.removeAt(index);
      }

      final hitung = calculate(newCheckout);

      emit(_Success(newCheckout, hitung.totalQuantity, hitung.totalPrice));
    });

    on<_Started>((event, emit) {
      emit(const _Loading());
      emit(const _Success([], 0, 0));
    });
  }
}

CalculateResult calculate(List<OrderItem> newCheckout) {
  int totalQuantity = 0;
  int totalPrice = 0;

  newCheckout.forEach((element) {
    totalQuantity += element.quantity;

    totalPrice += element.product.price * element.quantity;
  });

  return CalculateResult(
    totalQuantity: totalQuantity,
    totalPrice: totalPrice,
  );
}

class CalculateResult {
  int totalQuantity;
  int totalPrice;

  CalculateResult({required this.totalQuantity, required this.totalPrice});
}
