part of 'history_detail_bloc.dart';

@freezed
class HistoryDetailState with _$HistoryDetailState {
  const factory HistoryDetailState.initial() = _Initial;
  const factory HistoryDetailState.loading() = _Loading;
  const factory HistoryDetailState.success(
      List<OrderItemModel> data, List<OrderItem> orders) = _Success;
  const factory HistoryDetailState.error(String message) = _Error;
}
