# Flutter Architecture Guide: Best Practices

## Enterprise-Grade Architecture Pattern for Backend-to-UI Data Flow

> **Цей документ описує архітектурний підхід, який забезпечує чистий, масштабований та підтримуваний код для Flutter додатків з інтеграцією Backend API.**

---

## 📋 Зміст

1. [Огляд архітектури](#1-огляд-архітектури)
2. [Структура проекту](#2-структура-проекту)
3. [Data Flow: Backend → UI](#3-data-flow-backend--ui)
4. [MWWM Pattern](#4-mwwm-pattern)
5. [Dependency Injection](#5-dependency-injection)
6. [State Management](#6-state-management)
7. [Navigation Pattern](#7-navigation-pattern)
8. [Error Handling](#8-error-handling)
9. [Localization](#9-localization)
10. [Best Practices](#10-best-practices)
11. [Приклади реалізації](#11-приклади-реалізації)

---

## 1. Огляд архітектури

### 1.1 Основні принципи

Архітектура базується на **MWWM (Model-Widget-WidgetModel)** pattern з додатковими шарами для забезпечення чистої сепарації відповідальностей:

```
┌─────────────────────────────────────────────────────────┐
│                        UI Layer                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │   Widget     │  │  Component   │  │   Page       │  │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘  │
│         │                 │                  │          │
│         └─────────────────┼──────────────────┘          │
│                           │                              │
│                    ┌──────▼───────┐                      │
│                    │ WidgetModel  │                      │
│                    │  (Business   │                      │
│                    │   Logic)     │                      │
│                    └──────┬───────┘                      │
└───────────────────────────┼──────────────────────────────┘
                            │
┌───────────────────────────┼──────────────────────────────┐
│                    ┌──────▼───────┐                      │
│                    │  Repository   │                      │
│                    │  (Data Layer) │                      │
│                    └──────┬───────┘                      │
│                           │                              │
│                    ┌──────▼───────┐                      │
│                    │ DataProvider │                      │
│                    │  (API Calls) │                      │
│                    └──────┬───────┘                      │
│                           │                              │
│                    ┌──────▼───────┐                      │
│                    │ NetworkClient │                      │
│                    │   (Dio/HTTP) │                      │
│                    └──────────────┘                      │
│                                                           │
│                    ┌──────────────┐                      │
│                    │  Interactor  │                      │
│                    │ (Cross-Cutting│                      │
│                    │   Concerns)  │                      │
│                    └──────────────┘                      │
└───────────────────────────────────────────────────────────┘
```

### 1.2 Ключові компоненти

- **Widget** - UI компоненти (StatelessWidget або CoreMwwmWidget)
- **WidgetModel** - Бізнес-логіка та стан UI
- **Repository** - Абстракція над DataProvider, трансформація DTO → Model
- **DataProvider** - Прямі виклики API через NetworkClient
- **DTO (Data Transfer Object)** - Структури даних з Backend
- **Model** - Доменні моделі для використання в UI
- **Interactor** - Бізнес-логіка, що не залежить від UI (Analytics, Permissions, etc.)
- **Navigator** - Абстракція навігації

---

## 2. Структура проекту

### 2.1 Feature-Based Organization

Проект організований за **feature-based** підходом, де кожна функціональність має свою папку з повним циклом від API до UI:

```
lib/
├── features/                          # Feature modules
│   └── feature_name/
│       ├── data_providers/            # API calls
│       │   ├── feature_data_provider_interface.dart
│       │   └── feature_data_provider.dart
│       ├── dto/                       # Data Transfer Objects
│       │   └── feature_dto.dart
│       ├── models/                    # Domain models
│       │   └── feature_model.dart
│       ├── repositories/              # Data layer abstraction
│       │   └── feature_repository.dart
│       ├── pages/                     # UI pages
│       │   └── feature_page/
│       │       ├── feature_page.dart
│       │       ├── feature_wm.dart
│       │       ├── feature_i18n.dart
│       │       ├── di/                # Dependency Injection
│       │       │   └── feature_wm_builder.dart
│       │       ├── navigation/        # Navigation
│       │       │   ├── feature_navigator.dart
│       │       │   └── feature_route.dart
│       │       └── components/        # UI components
│       │           └── feature_component.dart
│       └── components/                # Shared feature components
│           └── feature_widget.dart
│
├── data_management/                   # Core data layer
│   ├── common/                        # Network, errors, etc.
│   ├── providers/                     # Base data providers
│   ├── repositories/                 # Base repositories
│   └── models/                        # Common models
│
├── interactors/                       # Cross-cutting concerns
│   ├── analytics/
│   ├── permission/
│   └── geolocation/
│
├── components/                        # Shared UI components
├── pages/                             # Standalone pages
└── main.dart                          # App entry point
```

### 2.2 Переваги feature-based структури

- ✅ **Модульність** - кожна feature ізольована
- ✅ **Масштабованість** - легко додавати нові features
- ✅ **Тестованість** - можна тестувати feature окремо
- ✅ **Командна робота** - різні команди можуть працювати паралельно
- ✅ **Підтримуваність** - легко знайти код, пов'язаний з feature

---

## 3. Data Flow: Backend → UI

### 3.1 Потік даних

```
Backend API
    ↓
NetworkClient (Dio)
    ↓
DataProvider (API calls, parsing JSON)
    ↓
DTO (Data Transfer Object)
    ↓
Repository (DTO → Model transformation)
    ↓
WidgetModel (Business logic, state management)
    ↓
Widget (UI rendering)
```

### 3.2 Детальний опис шарів

#### 3.2.1 NetworkClient

**Призначення:** Низькорівневий HTTP клієнт на базі Dio

**Відповідальність:**

- HTTP запити (GET, POST, PUT, DELETE)
- Управління токенами авторизації
- Обробка cookies
- Логування запитів/відповідей
- Обробка помилок мережі
- Налаштування таймаутів

**Приклад:**

```dart
class NetworkClient {
  final Dio _dio;
  final PreferencesRepository _preferencesRepository;

  NetworkClient({
    required String apiEndpoint,
    required PreferencesRepository preferencesRepository,
  }) : _preferencesRepository = preferencesRepository {
    initDio(apiEndpoint);
  }

  Future<DataRequestResult> api({
    required String path,
    Map<String, dynamic>? payload,
    String? authToken,
  }) async {
    // Implementation
  }
}
```

#### 3.2.2 DataProvider

**Призначення:** Шар для викликів API та парсингу JSON

**Відповідальність:**

- Виклики конкретних API endpoints
- Парсинг JSON відповідей
- Створення DTO об'єктів
- Обробка помилок API

**Базові класи:**

- `DataProvider` - базовий клас
- `ProtectedIntraDataProvider` - для захищених API
- `PublicDataProvider` - для публічних API

**Приклад:**

```dart
class FeatureDataProvider extends ProtectedIntraDataProvider
    implements FeatureDataProviderInterface {

  FeatureDataProvider({
    required super.networkClient,
    required super.tokensDataProvider,
    required super.confirmationDataProvider,
  });

  @override
  Future<List<FeatureDto>> getFeatures() async {
    final response = await getIntraApiAccessor('api/features/list')();
    final list = _extractList(response, 'features');
    return list.map((e) => FeatureDto.fromJson(e as Map<String, dynamic>)).toList();
  }

  List<dynamic> _extractList(Map<String, dynamic> json, String key) {
    final value = json[key];
    return value is List ? value : <dynamic>[];
  }
}
```

#### 3.2.3 DTO (Data Transfer Object)

**Призначення:** Структури даних, що точно відповідають Backend API

**Відповідальність:**

- Парсинг JSON з Backend
- Валідація даних
- Серіалізація/десеріалізація

**Приклад:**

```dart
class FeatureDto {
  final int id;
  final String title;
  final String? description;
  final List<FeatureItemDto> items;

  const FeatureDto({
    required this.id,
    required this.title,
    this.description,
    required this.items,
  });

  factory FeatureDto.fromJson(Map<String, dynamic> json) {
    return FeatureDto(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      items: (json['items'] as List)
          .map((e) => FeatureItemDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'items': items.map((e) => e.toJson()).toList(),
    };
  }
}
```

#### 3.2.4 Repository

**Призначення:** Абстракція над DataProvider, трансформація DTO → Model

**Відповідальність:**

- Виклики DataProvider
- Трансформація DTO в Model
- Кешування (за потреби)
- Агрегація даних з різних джерел

**Приклад:**

```dart
class FeatureRepository {
  final FeatureDataProviderInterface _dataProvider;

  FeatureRepository({
    required FeatureDataProviderInterface dataProvider,
  }) : _dataProvider = dataProvider;

  Future<List<Feature>> getFeatures() async {
    final dtos = await _dataProvider.getFeatures();
    return dtos.map((dto) => Feature.fromDto(dto)).toList();
  }

  Future<Feature> getFeatureDetails(int id) async {
    final dto = await _dataProvider.getFeatureDetails(id);
    return Feature.fromDto(dto);
  }
}
```

#### 3.2.5 Model

**Призначення:** Доменні моделі для використання в UI

**Відповідальність:**

- Бізнес-логіка домену
- Computed properties
- Валідація стану
- Helper методи

**Приклад:**

```dart
class Feature {
  final int id;
  final String title;
  final String? description;
  final List<FeatureItem> items;

  const Feature({
    required this.id,
    required this.title,
    this.description,
    required this.items,
  });

  factory Feature.fromDto(FeatureDto dto) {
    return Feature(
      id: dto.id,
      title: dto.title,
      description: dto.description,
      items: dto.items.map((item) => FeatureItem.fromDto(item)).toList(),
    );
  }

  // Computed properties
  bool get hasItems => items.isNotEmpty;
  String get displayTitle => description ?? title;

  // Business logic
  FeatureItem? findItemById(int itemId) {
    try {
      return items.firstWhere((item) => item.id == itemId);
    } catch (e) {
      return null;
    }
  }
}
```

---

## 4. MWWM Pattern

### 4.1 Огляд

**MWWM (Model-Widget-WidgetModel)** - це архітектурний pattern, що розділяє UI (Widget) та бізнес-логіку (WidgetModel).

### 4.2 Компоненти

#### 4.2.1 Widget (UI)

**Призначення:** Декларативний UI код

**Типи:**

- `CoreMwwmWidget` - для складних екранів з бізнес-логікою
- `StatelessWidget` - для простих UI компонентів

**Приклад:**

```dart
class FeaturePage extends CoreMwwmWidget {
  final FeaturePageWidgetModel Function(BuildContext) widgetModelBuilder;

  FeaturePage({
    super.key,
    required this.widgetModelBuilder,
  }) : super(widgetModelBuilder: widgetModelBuilder);

  @override
  State<StatefulWidget> createState() => _FeaturePageState();
}

class _FeaturePageState extends MwwmWidgetState<FeaturePageWidgetModel> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(wm.i18n.pageTitle)),
      body: StreamBuilder<List<Feature>>(
        stream: wm.featuresStream,
        builder: (context, snapshot) {
          final features = snapshot.data ?? [];
          if (features.isEmpty) {
            return Center(child: Text(wm.i18n.emptyMessage));
          }
          return ListView.builder(
            itemCount: features.length,
            itemBuilder: (context, index) {
              return FeatureItemWidget(
                feature: features[index],
                onTap: () => wm.onFeatureTap(features[index].id),
              );
            },
          );
        },
      ),
    );
  }
}
```

#### 4.2.2 WidgetModel

**Призначення:** Бізнес-логіка та стан UI

**Відповідальність:**

- Управління станом через Streams
- Обробка user actions
- Виклики Repository
- Навігація
- Error handling

**Приклад:**

```dart
class FeaturePageWidgetModel extends WidgetModel {
  final FeatureRepository _repository;
  final FeatureNavigator _navigator;
  final FeatureI18n i18n;

  // State streams
  final BehaviorSubject<List<Feature>> featuresStream = BehaviorSubject.seeded([]);
  final BehaviorSubject<bool> isLoadingStream = BehaviorSubject.seeded(false);

  FeaturePageWidgetModel(
    this._repository,
    this._navigator,
    this.i18n,
  ) : super(const WidgetModelDependencies());

  @override
  void onLoad() {
    super.onLoad();
    _loadFeatures();
  }

  Future<void> _loadFeatures() async {
    isLoadingStream.add(true);
    try {
      final features = await _repository.getFeatures();
      featuresStream.add(features);
    } catch (e) {
      handleError(e);
    } finally {
      isLoadingStream.add(false);
    }
  }

  void onFeatureTap(int featureId) {
    _navigator.goToFeatureDetails(featureId);
  }

  @override
  void dispose() {
    featuresStream.close();
    isLoadingStream.close();
    super.dispose();
  }
}
```

#### 4.2.3 Model (Optional)

**Призначення:** Складні бізнес-сценарії з Change/Performer pattern

**Використання:** Для складних flows з багатьма взаємодіями

---

## 5. Dependency Injection

### 5.1 Підхід

Проект використовує **комбінацію Provider та GetIt**:

- **Provider** - для UI-рівня залежностей (DataManager, Repositories, Interactors)
- **GetIt** - для сервісів (Analytics, Crash Reporting, etc.)

### 5.2 Ініціалізація в main.dart

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize GetIt for services
  await sl.init(deviceType);

  // Initialize repositories
  final preferencesRepository = PreferencesRepository(...);

  runApp(
    MultiProvider(
      providers: [
        // Core dependencies
        Provider<DataManager>(
          create: (_) => DataManager(
            networkClient: NetworkClient(
              apiEndpoint: preferencesRepository.getBaseUrl(),
              preferencesRepository: preferencesRepository,
            ),
          ),
        ),
        Provider<InteractorsStorage>(
          create: (_) => InteractorsStorage(...),
        ),
      ],
      child: MyApp(),
    ),
  );
}
```

### 5.3 WidgetModel Builder Pattern

**Призначення:** Централізоване створення WidgetModel з усіма залежностями

**Структура:**

```
lib/features/feature_name/pages/feature_page/
├── di/
│   └── feature_wm_builder.dart
```

**Приклад:**

```dart
// di/feature_wm_builder.dart
FeaturePageWidgetModel createFeaturePageWidgetModel(BuildContext context) {
  final dataManager = context.read<DataManager>();
  final dataProvider = dataManager.featureDataProvider;
  final translate = context.read<TranslatorFunction>();

  final repository = FeatureRepository(dataProvider: dataProvider);
  final navigator = FeatureNavigator(context, repository);
  final i18n = FeatureI18n(translate);
  final analytics = context.read<InteractorsStorage>().analyticsInteractor;

  return FeaturePageWidgetModel(
    repository,
    navigator,
    i18n,
    analytics,
  );
}
```

**Використання:**

```dart
class FeaturePage extends CoreMwwmWidget {
  FeaturePage({super.key})
      : super(widgetModelBuilder: createFeaturePageWidgetModel);
}
```

### 5.4 Repository Provider Pattern

Для репозиторіїв, які використовуються в кількох місцях:

```dart
MultiRepositoryProvider(
  providers: [
    RepositoryProvider<FeatureRepository>(
      create: (context) {
        final dataManager = context.read<DataManager>();
        return FeatureRepository(
          dataProvider: dataManager.featureDataProvider,
        );
      },
    ),
  ],
  child: FeaturePage(),
)
```

---

## 6. State Management

### 6.1 Підхід

Використовується **RxDart BehaviorSubject** для reactive state management.

### 6.2 Streams в WidgetModel

```dart
class FeaturePageWidgetModel extends WidgetModel {
  // State streams
  final BehaviorSubject<List<Feature>> featuresStream = BehaviorSubject.seeded([]);
  final BehaviorSubject<bool> isLoadingStream = BehaviorSubject.seeded(false);
  final BehaviorSubject<String?> selectedFeatureId = BehaviorSubject.seeded(null);

  // Computed streams
  Stream<bool> get hasFeatures => featuresStream.map((features) => features.isNotEmpty);
}
```

### 6.3 Використання в UI

```dart
StreamBuilder<List<Feature>>(
  stream: wm.featuresStream,
  initialData: wm.featuresStream.value,
  builder: (context, snapshot) {
    final features = snapshot.data ?? [];
    return ListView.builder(...);
  },
)
```

### 6.4 Best Practices

- ✅ Використовуйте `BehaviorSubject.seeded()` для початкових значень
- ✅ Завжди закривайте streams в `dispose()`
- ✅ Використовуйте `initialData` в StreamBuilder для миттєвого відображення
- ✅ Комбінуйте streams через `combineLatest`, `merge`, `switchMap` за потреби

---

## 7. Navigation Pattern

### 7.1 Navigator Class Pattern

**Призначення:** Абстракція навігації для тестування та ізоляції

**Структура:**

```
lib/features/feature_name/pages/feature_page/navigation/
├── feature_navigator.dart
└── feature_route.dart
```

**Приклад:**

```dart
// feature_navigator.dart
class FeatureNavigator {
  final NavigatorState _navigator;
  final FeatureRepository _repository;

  FeatureNavigator(BuildContext context, this._repository)
      : _navigator = Navigator.of(context);

  void goBack() {
    _navigator.pop();
  }

  void goToFeatureDetails(int featureId) {
    _navigator.push(
      MaterialPageRoute(
        builder: (_) => FeatureDetailPage(featureId: featureId),
      ),
    );
  }

  void goToFeatureSettings(Feature feature) {
    _navigator.push(FeatureSettingsRoute(feature: feature));
  }
}
```

**Приклад Route:**

```dart
// feature_route.dart
class FeatureDetailRoute extends MaterialPageRoute<void> {
  FeatureDetailRoute({required int featureId})
      : super(
          builder: (context) => FeatureDetailPage(featureId: featureId),
        );
}
```

### 7.2 Використання в WidgetModel

```dart
class FeaturePageWidgetModel extends WidgetModel {
  final FeatureNavigator _navigator;

  void onFeatureTap(int featureId) {
    _navigator.goToFeatureDetails(featureId);
  }
}
```

---

## 8. Error Handling

### 8.1 DataError Pattern

```dart
class DataError {
  final ErrorCode errorCode;
  final String? message;
  final Map<String, dynamic>? data;

  const DataError({
    required this.errorCode,
    this.message,
    this.data,
  });
}
```

### 8.2 Error Handling в WidgetModel

```dart
class FeaturePageWidgetModel extends WidgetModel
    with ShowToastOnDataErrorMixin {

  Future<void> _loadFeatures() async {
    try {
      final features = await _repository.getFeatures();
      featuresStream.add(features);
    } catch (e) {
      Logger.e('Error loading features: $e');
      showToastOnDataError(
        DataError(
          errorCode: ErrorCode.unhandled_error,
          message: e.toString(),
        ),
      );
    }
  }
}
```

### 8.3 Error Handling в DataProvider

```dart
@protected
Future<void> handleResponse(
  DataRequestResult? dataRequestResult,
  Completer<Map<String, dynamic>> requestCompleter,
) async {
  if (dataRequestResult is DataRequestSuccess) {
    requestCompleter.complete(dataRequestResult.data.cast<String, Object>());
  } else if (dataRequestResult is DataRequestFail) {
    requestCompleter.completeError(dataRequestResult.error);
    _serverErrors.addIfNotClosed(dataRequestResult.error);
  } else {
    requestCompleter.completeError(
      DataError(errorCode: ErrorCode.unhandled_error),
    );
  }
}
```

---

## 9. Localization

### 9.1 I18n Class Pattern

**Структура:**

```
lib/features/feature_name/pages/feature_page/
└── feature_i18n.dart
```

**Приклад:**

```dart
class FeatureI18n extends TranslateBase {
  FeatureI18n(TranslatorFunction translate) : super(translate);

  String get pageTitle => translate('widget.feature.pageTitle');
  String get emptyMessage => translate('widget.feature.emptyMessage');
  String get errorMessage => translate('widget.feature.errorMessage');

  String featureItemTitle(int index) =>
      translate('widget.feature.itemTitle', {'index': index});
}
```

### 9.2 Використання

```dart
class FeaturePageWidgetModel extends WidgetModel {
  final FeatureI18n i18n;

  // Use i18n.pageTitle, i18n.emptyMessage, etc.
}
```

---

## 10. Best Practices

### 10.1 Створення нової Feature

**Крок 1: Створіть структуру папок**

```
lib/features/new_feature/
├── data_providers/
├── dto/
├── models/
├── repositories/
└── pages/
    └── new_feature_page/
        ├── di/
        ├── navigation/
        └── components/
```

**Крок 2: Створіть DataProvider Interface**

```dart
// data_providers/new_feature_data_provider_interface.dart
abstract class NewFeatureDataProviderInterface {
  Future<List<NewFeatureDto>> getFeatures();
  Future<NewFeatureDto> getFeatureDetails(int id);
}
```

**Крок 3: Реалізуйте DataProvider**

```dart
// data_providers/new_feature_data_provider.dart
class NewFeatureDataProvider extends ProtectedIntraDataProvider
    implements NewFeatureDataProviderInterface {

  NewFeatureDataProvider({
    required super.networkClient,
    required super.tokensDataProvider,
    required super.confirmationDataProvider,
  });

  @override
  Future<List<NewFeatureDto>> getFeatures() async {
    final response = await getIntraApiAccessor('api/new-feature/list')();
    final list = _extractList(response, 'features');
    return list.map((e) => NewFeatureDto.fromJson(e as Map<String, dynamic>)).toList();
  }
}
```

**Крок 4: Створіть DTO**

```dart
// dto/new_feature_dto.dart
class NewFeatureDto {
  final int id;
  final String title;

  const NewFeatureDto({required this.id, required this.title});

  factory NewFeatureDto.fromJson(Map<String, dynamic> json) {
    return NewFeatureDto(
      id: json['id'] as int,
      title: json['title'] as String,
    );
  }
}
```

**Крок 5: Створіть Model**

```dart
// models/new_feature_model.dart
class NewFeature {
  final int id;
  final String title;

  const NewFeature({required this.id, required this.title});

  factory NewFeature.fromDto(NewFeatureDto dto) {
    return NewFeature(id: dto.id, title: dto.title);
  }
}
```

**Крок 6: Створіть Repository**

```dart
// repositories/new_feature_repository.dart
class NewFeatureRepository {
  final NewFeatureDataProviderInterface _dataProvider;

  NewFeatureRepository({required NewFeatureDataProviderInterface dataProvider})
      : _dataProvider = dataProvider;

  Future<List<NewFeature>> getFeatures() async {
    final dtos = await _dataProvider.getFeatures();
    return dtos.map((dto) => NewFeature.fromDto(dto)).toList();
  }
}
```

**Крок 7: Додайте DataProvider в DataManager**

```dart
// data_management/data_manager.dart
case DataProviderType.newFeature:
  dataProvider = NewFeatureDataProvider(
    networkClient: _networkClient,
    tokensDataProvider: _tokensDataProvider,
    confirmationDataProvider: _confirmationDataProvider,
  );
  break;

// Add getter
NewFeatureDataProvider get newFeature =>
    getOrCreateProvider(DataProviderType.newFeature) as NewFeatureDataProvider;
```

**Крок 8: Створіть WidgetModel**

```dart
// pages/new_feature_page/new_feature_wm.dart
class NewFeaturePageWidgetModel extends WidgetModel {
  final NewFeatureRepository _repository;
  final NewFeatureNavigator _navigator;
  final NewFeatureI18n i18n;

  final BehaviorSubject<List<NewFeature>> featuresStream =
      BehaviorSubject.seeded([]);

  NewFeaturePageWidgetModel(
    this._repository,
    this._navigator,
    this.i18n,
  ) : super(const WidgetModelDependencies());

  @override
  void onLoad() {
    super.onLoad();
    _loadFeatures();
  }

  Future<void> _loadFeatures() async {
    try {
      final features = await _repository.getFeatures();
      featuresStream.add(features);
    } catch (e) {
      handleError(e);
    }
  }

  @override
  void dispose() {
    featuresStream.close();
    super.dispose();
  }
}
```

**Крок 9: Створіть WidgetModel Builder**

```dart
// pages/new_feature_page/di/new_feature_wm_builder.dart
NewFeaturePageWidgetModel createNewFeaturePageWidgetModel(BuildContext context) {
  final dataManager = context.read<DataManager>();
  final dataProvider = dataManager.newFeature;
  final translate = context.read<TranslatorFunction>();

  final repository = NewFeatureRepository(dataProvider: dataProvider);
  final navigator = NewFeatureNavigator(context, repository);
  final i18n = NewFeatureI18n(translate);

  return NewFeaturePageWidgetModel(repository, navigator, i18n);
}
```

**Крок 10: Створіть Page Widget**

```dart
// pages/new_feature_page/new_feature_page.dart
class NewFeaturePage extends CoreMwwmWidget {
  NewFeaturePage({super.key})
      : super(widgetModelBuilder: createNewFeaturePageWidgetModel);

  @override
  State<StatefulWidget> createState() => _NewFeaturePageState();
}

class _NewFeaturePageState extends MwwmWidgetState<NewFeaturePageWidgetModel> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(wm.i18n.pageTitle)),
      body: StreamBuilder<List<NewFeature>>(
        stream: wm.featuresStream,
        initialData: wm.featuresStream.value,
        builder: (context, snapshot) {
          final features = snapshot.data ?? [];
          return ListView.builder(
            itemCount: features.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(features[index].title),
                onTap: () => wm.onFeatureTap(features[index].id),
              );
            },
          );
        },
      ),
    );
  }
}
```

**Крок 11: Створіть Navigator**

```dart
// pages/new_feature_page/navigation/new_feature_navigator.dart
class NewFeatureNavigator {
  final NavigatorState _navigator;
  final NewFeatureRepository _repository;

  NewFeatureNavigator(BuildContext context, this._repository)
      : _navigator = Navigator.of(context);

  void goToFeatureDetails(int featureId) {
    _navigator.push(
      MaterialPageRoute(
        builder: (_) => NewFeatureDetailPage(featureId: featureId),
      ),
    );
  }
}
```

**Крок 12: Створіть I18n**

```dart
// pages/new_feature_page/new_feature_i18n.dart
class NewFeatureI18n extends TranslateBase {
  NewFeatureI18n(TranslatorFunction translate) : super(translate);

  String get pageTitle => translate('widget.newFeature.pageTitle');
  String get emptyMessage => translate('widget.newFeature.emptyMessage');
}
```

### 10.2 Правила іменування

- **DTO**: `FeatureDto`, `FeatureItemDto`
- **Model**: `Feature`, `FeatureItem`
- **DataProvider**: `FeatureDataProvider`
- **Repository**: `FeatureRepository`
- **WidgetModel**: `FeaturePageWidgetModel`
- **Widget**: `FeaturePage`, `FeatureItemWidget`
- **Navigator**: `FeatureNavigator`
- **I18n**: `FeatureI18n`

### 10.3 Обробка помилок

- ✅ Завжди обгортайте API виклики в try-catch
- ✅ Використовуйте `Logger` для логування помилок
- ✅ Показуйте user-friendly повідомлення через `ShowToastOnDataErrorMixin`
- ✅ Обробляйте специфічні помилки окремо

### 10.4 Тестування

- ✅ Тестуйте DataProvider з mock NetworkClient
- ✅ Тестуйте Repository з mock DataProvider
- ✅ Тестуйте WidgetModel з mock Repository та Navigator
- ✅ Тестуйте Widget з mock WidgetModel

---

## 11. Приклади реалізації

### 11.1 Повний приклад Feature

Дивіться реалізацію в `lib/features/additional_privileges/` як референс.

### 11.2 Checklist для нової Feature

- [ ] Створено структуру папок
- [ ] Створено DataProvider Interface
- [ ] Реалізовано DataProvider
- [ ] Створено DTO класи
- [ ] Створено Model класи
- [ ] Створено Repository
- [ ] Додано DataProvider в DataManager
- [ ] Створено WidgetModel
- [ ] Створено WidgetModel Builder
- [ ] Створено Page Widget
- [ ] Створено Navigator
- [ ] Створено I18n
- [ ] Додано локалізаційні ключі
- [ ] Оброблено помилки
- [ ] Додано логування

---

## 12. Ключові пакети

### 12.1 Обов'язкові залежності

```yaml
dependencies:
  # State Management & Architecture
  mwwm: # MWWM pattern
  rxdart: # Reactive streams
  provider: # Dependency Injection

  # Network
  dio: # HTTP client

  # UI
  flutter_screenutil: # Responsive design

  # Utilities
  get_it: # Service locator
  surf_logger: # Logging
```

### 12.2 Рекомендовані залежності

```yaml
dependencies:
  # State Management
  flutter_bloc: # For complex state (optional)

  # Network
  cached_network_image: # Image caching

  # Localization
  intl: # Internationalization
```

---

## 13. Висновок

Ця архітектура забезпечує:

- ✅ **Чистий код** - чітке розділення відповідальностей
- ✅ **Масштабованість** - легко додавати нові features
- ✅ **Тестованість** - кожен шар можна тестувати окремо
- ✅ **Підтримуваність** - легко знайти та змінити код
- ✅ **Продуктивність** - оптимізований data flow
- ✅ **Типобезпека** - використання типів на всіх рівнях

---

## 14. Додаткові ресурси

- MWWM документація: `plugins/mwwm/README.md`
- Приклади в проекті: `lib/features/additional_privileges/`
- NetworkClient: `lib/data_management/common/network_client.dart`
- DataManager: `lib/data_management/data_manager.dart`

---

**Версія:** 1.0  
**Дата:** 2025-12-19  
**Автор:** Architecture Analysis
