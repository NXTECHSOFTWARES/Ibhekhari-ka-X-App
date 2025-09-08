enum Condition {
  HOT,
  N_A,
  SOFTEN,
  MELTED,
  WARM,
  ROOM_TEMPERATURE,

}

final conditionValues = EnumValues({
  "hot": Condition.HOT,
  "N/A": Condition.N_A,
  "soften": Condition.SOFTEN
});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}