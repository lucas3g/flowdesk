import 'package:flowdesk/features/rules/domain/entities/rule.dart';
import 'package:flutter_test/flutter_test.dart';

Rule _regionRule(String targetValue) => Rule(
  bundleId: 'com.slack',
  appName: 'Slack',
  actionType: RuleActionType.applyRegion,
  targetValue: targetValue,
);

void main() {
  group('Rule.regionTarget', () {
    test('regra antiga (layoutId:índice) parseia sem monitorKey', () {
      expect(_regionRule('9:1').regionTarget, (9, 1, null));
    });

    test('regra nova inclui o monitorKey', () {
      expect(
        _regionRule('9:1:Dell 4K:2000x1600').regionTarget,
        (9, 1, 'Dell 4K:2000x1600'),
      );
    });

    test('monitorKey com nome contendo dois-pontos é preservado', () {
      expect(
        _regionRule('9:0:LG: HDR 4K:3840x2160').regionTarget,
        (9, 0, 'LG: HDR 4K:3840x2160'),
      );
    });

    test('alvo inválido retorna null', () {
      expect(_regionRule('9').regionTarget, isNull);
      expect(_regionRule('a:b').regionTarget, isNull);
      expect(_regionRule('').regionTarget, isNull);
    });
  });
}
