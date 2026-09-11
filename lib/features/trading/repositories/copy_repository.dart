import '../../../core/constants/copy_constants.dart';
import '../../../core/errors/data_error.dart';
import '../data_providers/copy_data_provider.dart';
import '../models/copy_model.dart';

class CopyRepository {
  CopyRepository({required CopyDataProviderInterface dataProvider})
      : _dataProvider = dataProvider;

  final CopyDataProviderInterface _dataProvider;

  Future<CopyStatus> getStatus() async {
    final dto = await _dataProvider.getStatus();
    return CopyStatus.fromDto(dto);
  }

  Future<CopyStatus> enable({
    required num amountRsv,
    required bool acceptDisclaimer,
  }) async {
    final dto = await _dataProvider.enable(
      amountRsv: amountRsv,
      acceptDisclaimer: acceptDisclaimer,
    );
    return CopyStatus.fromDto(dto);
  }

  Future<CopyStatus> topup({required num amountRsv}) async {
    final dto = await _dataProvider.topup(amountRsv: amountRsv);
    return CopyStatus.fromDto(dto);
  }

  Future<CopyStatus> exit() async {
    final dto = await _dataProvider.exit();
    return CopyStatus.fromDto(dto);
  }

  Future<CopyStatus> complete() async {
    final dto = await _dataProvider.complete();
    return CopyStatus.fromDto(dto);
  }

  Future<List<CopyHistoryItem>> getHistory({int limit = 50}) async {
    final dtos = await _dataProvider.getHistory(limit: limit);
    return dtos.map(CopyHistoryItem.fromDto).toList(growable: false);
  }

  static String mapError(Object error) {
    if (error is DataError) {
      switch (error.apiError) {
        case 'plan_required':
          return CopyConstants.errorPlanRequired;
        case 'disclaimer_required':
          return CopyConstants.errorDisclaimer;
        case 'min_stake':
          return CopyConstants.errorMinStake;
        case 'insufficient_earned':
          return CopyConstants.errorInsufficient;
        case 'already_active':
          return CopyConstants.errorAlreadyActive;
        case 'no_active_stake':
          return CopyConstants.errorNoStake;
        case 'lock_active':
          return CopyConstants.errorLockActive;
      }
      return error.displayMessage;
    }
    return error.toString();
  }
}
