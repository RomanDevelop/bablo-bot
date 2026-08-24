import 'package:rxdart/rxdart.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/daily_constants.dart';
import '../../../../core/errors/data_error.dart';
import '../../../../core/mwwm/widget_model.dart';
import '../../models/daily_article.dart';
import '../../repositories/daily_repository.dart';

class DailyArticleState {
  const DailyArticleState({
    this.article,
    this.isLoading = true,
    this.error,
    this.reacting = false,
    this.myReaction,
  });

  final DailyArticle? article;
  final bool isLoading;
  final String? error;
  final bool reacting;
  final String? myReaction;

  DailyArticleState copyWith({
    DailyArticle? article,
    bool? isLoading,
    String? error,
    bool? reacting,
    String? myReaction,
    bool clearError = false,
  }) {
    return DailyArticleState(
      article: article ?? this.article,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      reacting: reacting ?? this.reacting,
      myReaction: myReaction ?? this.myReaction,
    );
  }
}

class DailyArticleWidgetModel extends WidgetModel {
  DailyArticleWidgetModel({
    required DailyRepository repository,
    required this.articleId,
    DailyArticle? preview,
  })  : _repository = repository,
        super(const WidgetModelDependencies()) {
    stateStream = BehaviorSubject.seeded(
      DailyArticleState(
        article: preview ?? repository.cachedById(articleId),
        isLoading: true,
      ),
    );
  }

  final DailyRepository _repository;
  final String articleId;
  late final BehaviorSubject<DailyArticleState> stateStream;

  @override
  void onLoad() {
    super.onLoad();
    refresh();
  }

  Future<void> refresh() async {
    final current = stateStream.value;
    stateStream.add(
      current.copyWith(
        isLoading: current.article?.hasBody != true,
        clearError: true,
      ),
    );
    try {
      final article = await _repository.getArticle(articleId);
      stateStream.add(
        current.copyWith(
          article: article,
          isLoading: false,
          clearError: true,
        ),
      );
    } catch (e, st) {
      handleError(e, st);
      final message = e is DataError ? e.displayMessage : e.toString();
      stateStream.add(current.copyWith(isLoading: false, error: message));
    }
  }

  Future<void> react(String type) async {
    final current = stateStream.value;
    if (current.reacting || current.article == null || current.myReaction != null) {
      return;
    }
    stateStream.add(current.copyWith(reacting: true));
    try {
      final updated = await _repository.postReaction(id: articleId, type: type);
      stateStream.add(
        current.copyWith(
          article: updated,
          reacting: false,
          myReaction: type,
        ),
      );
    } catch (e, st) {
      handleError(e, st);
      final local = current.article!.copyWith(
        reactions: current.article!.reactions.incremented(type),
      );
      stateStream.add(
        current.copyWith(
          article: local,
          reacting: false,
          myReaction: type,
        ),
      );
    }
  }

  Future<void> share() async {
    final article = stateStream.value.article;
    if (article == null) return;
    final url = DailyConstants.shareUrl(article.id);
    await SharePlus.instance.share(
      ShareParams(
        text: '${article.title}\n$url',
        subject: article.title,
        title: article.title,
      ),
    );
  }

  @override
  void dispose() {
    stateStream.close();
    super.dispose();
  }
}
