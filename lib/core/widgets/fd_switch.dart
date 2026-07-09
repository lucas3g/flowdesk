import 'package:flutter/cupertino.dart';

import '../theme/app_colors.dart';

/// Toggle estilo iOS/macOS (verde quando ativo), conforme o design system.
class FdSwitch extends StatelessWidget {
  const FdSwitch({super.key, required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Transform.scale(
      scale: 0.78,
      alignment: Alignment.centerRight,
      child: CupertinoSwitch(
        value: value,
        onChanged: onChanged,
        activeTrackColor: colors.green,
      ),
    );
  }
}
