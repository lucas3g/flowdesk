# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Sobre o projeto

FlowDesk — gerenciador de janelas e layouts de trabalho para macOS, em Flutter. O alvo principal é macOS; toda a funcionalidade nativa (janelas, monitores, atalhos globais, menu bar) vive em Swift sob `macos/Runner/`.

## Comandos

O projeto usa FVM — sempre prefixe os comandos `flutter`/`dart` com `fvm`:

```bash
fvm flutter analyze                      # lint/análise estática
fvm flutter test                         # todos os testes
fvm flutter test test/features/rules/    # testes de uma feature
fvm flutter test test/features/rules/presentation/rules_cubit_test.dart  # um arquivo

# Regenerar código (injectable + drift) após mudar anotações DI ou tabelas:
fvm dart run build_runner build --delete-conflicting-outputs

fvm flutter run -d macos                 # rodar o app
```

Para validar mudanças, `fvm flutter analyze` + `fvm flutter test` bastam. Só faça `fvm flutter build` quando houver mudança no código nativo (Swift) ou a pedido do usuário.

## Arquitetura

### Clean Architecture por feature

Cada feature em `lib/features/<nome>/` segue três camadas:

- `domain/` — entidades (Equatable), contratos de repositories e use cases. Use cases implementam `UseCase<T, Params>` ou `StreamUseCase<T, Params>` (`lib/core/usecases/usecase.dart`) e retornam `Either<Failure, T>` (fpdart). Failures são a hierarquia selada em `lib/core/errors/failures.dart` (`PlatformFailure`, `DatabaseFailure`, `PermissionFailure`, `ValidationFailure`).
- `data/` — datasources (locais via Drift, ou de plataforma via `PlatformChannel`), mappers e implementações dos repositories. Datasources lançam exceptions (`lib/core/errors/exceptions.dart`); os repositories convertem em `Failure`.
- `presentation/` — Cubits (flutter_bloc), states, pages e widgets.

### Injeção de dependência: getIt + injectable, sem BlocProvider

Tudo é registrado via anotações injectable (`@lazySingleton`, `@injectable`) e resolvido por `getIt<T>()` (`lib/core/di/injection.dart`). O código gerado fica em `injection.config.dart` — regenere com build_runner após adicionar/alterar registros. Dependências de infraestrutura não anotáveis (banco, canais nomeados) ficam em `lib/core/di/register_module.dart`.

**Convenção importante:** não use `BlocProvider`/`context.read`. Cubits são obtidos com `getIt<T>()` em campos da classe do widget e passados a `BlocBuilder`/`BlocListener` via parâmetro `bloc:`. Cubits são lazy singletons compartilhados; alguns dependem de outros cubits diretamente (ex.: `WorkspacesCubit` recebe `MonitorsCubit` e `SettingsCubit` no construtor).

### Ponte Flutter ↔ macOS

- Lado Dart: `PlatformChannel` e `PlatformEventChannel` (`lib/core/platform/`) são wrappers finos que convertem `PlatformException`/`MissingPluginException` em `PlatformDatasourceException`. Os nomes dos canais estão em `lib/core/constants/app_constants.dart` e cada canal é registrado nomeado no `RegisterModule` (ex.: `@Named('windowsChannel')`).
- Lado Swift: `macos/Runner/Channels/ChannelRouter.swift` registra todos os canais e roteia cada chamada para um manager em `macos/Runner/Managers/` (WindowManager, MonitorManager, ShortcutManager, StatusBarManager, WorkspaceManager, PermissionManager, AccessibilityManager, LaunchAtLoginManager). Ao criar um canal novo: adicionar constante em `AppConstants`, registrar no `RegisterModule`, registrar no `ChannelRouter` e implementar o manager.

### Persistência

SQLite via Drift: `lib/core/services/database/app_database.dart` + `tables.dart`. Mudanças de schema exigem incrementar `schemaVersion`, adicionar passo em `MigrationStrategy.onUpgrade` e regenerar com build_runner. Testes usam `AppDatabase.withExecutor` com banco em memória.

### Boot e serviços globais

`lib/main.dart` inicializa DI e dispara os cubits/serviços globais (settings, permissões, monitores, layouts, workspaces, atalhos, menu bar, regras, auto-restore) antes do `runApp`. Serviços transversais ficam em `lib/core/services/` (ex.: `StatusBarService` sincroniza o menu da barra de status com layouts/workspaces; `AutoRestoreService` reaplica posições).

## Testes

- Estrutura de `test/` espelha `lib/` (data/domain/presentation por feature).
- `bloc_test` + `mocktail` para cubits/use cases; fakes compartilhados em `test/helpers/fakes.dart` (inclui `FakeEventChannel` para streams de plataforma).
- Widget tests que renderizam ícones devem chamar `loadMaterialSymbolsFont()` de `test/helpers/test_fonts.dart`, senão os glifos Material Symbols viram texto e estouram o layout.
- `PlatformChannel.withChannel` permite injetar um `MethodChannel` customizado em testes de datasource.

## Convenções

- Comentários e documentação de código em português.
- Ícones via widget `MsIcon` (fonte Material Symbols Rounded em `assets/fonts/`), não `Icons.*` do Material.
