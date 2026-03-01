class PlayerModel {
  int level = 3;
  String name = "";
  String team = "";
  String gender = "MALE";
  String role = "Any";

  PlayerModel(this.level, this.name, this.team, this.gender,
      [this.role = "Any"]);

  String getGenderString() {
    return gender[0].toUpperCase();
  }
}
