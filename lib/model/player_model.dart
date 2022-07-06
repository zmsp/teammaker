class PlayerModel {
  int level = 3;
  String name = "";
  String team = "";
  String gender = "MALE";

  PlayerModel(this.level, this.name, this.team, this.gender);

  String getGenderString() {
    return gender[0].toUpperCase();
  }
}
