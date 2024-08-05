part of 'history_detail_bloc.dart';

@freezed
class HistoryDetailEvent with _$HistoryDetailEvent {
  const factory HistoryDetailEvent.started() = _Started;
  const factory HistoryDetailEvent.fetchDetail(int idOrder) = _FetchDetail;
}
