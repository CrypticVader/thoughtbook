import 'package:flutter/foundation.dart';

enum GroupParameter { dateModified, dateCreated, tag, none }

enum TagGroupLogic { separateCombinations, showInAll, showInOne }

enum GroupOrder { descending, ascending }

@immutable
class GroupProps {
  final GroupParameter groupParameter;
  final TagGroupLogic tagGroupLogic;
  final GroupOrder  groupOrder;

  const GroupProps({
    required this.groupParameter,
    required this.tagGroupLogic,
    required this.groupOrder,
  });
}
