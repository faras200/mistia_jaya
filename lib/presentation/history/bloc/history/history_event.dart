part of 'history_bloc.dart';

@freezed
class HistoryEvent with _$HistoryEvent {
  const factory HistoryEvent.started() = _Started;
  const factory HistoryEvent.fetch() = _Fetch;
  const factory HistoryEvent.fetchbydate(String fromDate, String toDate) =
      _FetchByDate;
  const factory HistoryEvent.delete(List<OrderModel> histories) = _Delete;
}
