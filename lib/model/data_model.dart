class SettingsData{
  int teamCount = 4;
  int division = 2;
  int proportion = 2;

  GEN_OPTION o = GEN_OPTION.distribute;

  @override
  String toString() {
    return 'SettingsData{teamCount: $teamCount, o: $o, division: $division}';
  }
}
enum GEN_OPTION{distribute, division, random, proportion}