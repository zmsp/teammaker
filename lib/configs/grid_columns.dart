import 'package:pluto_grid/pluto_grid.dart';

class GridColumns {
  static List<PlutoColumn> getColumns() {
    return [
      PlutoColumn(
        enableRowDrag: true,
        enableHideColumnMenuItem: false,
        enableRowChecked: true,
        title: "name",
        field: "name_field",
        frozen: PlutoColumnFrozen.start,
        width: 150,
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'team',
        field: 'team_field',
        textAlign: PlutoColumnTextAlign.center,
        width: 80,
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'gender',
        field: 'gender_field',
        width: 80,
        type: PlutoColumnType.select(["MALE", "FEMALE", "X"]),
      ),
      PlutoColumn(
        title: 'Level',
        field: 'skill_level_field',
        type: PlutoColumnType.select([1, 2, 3, 4, 5]),
        width: 80,
        textAlign: PlutoColumnTextAlign.right,
      ),
    ];
  }
}
