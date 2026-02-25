class SettingsData {
  int teamCount = 2; // How many teams to make
  int division = 2; // Split by skill levels
  int proportion = 6; // How many players in one team
  int gameVenues = 1; // Number of play areas
  int gameRounds = 1; // Number of games

  bool preferExtraTeam = false; // Add more teams for extra players

  GEN_OPTION o = GEN_OPTION.even_gender; // Best balance settings

  @override
  String toString() {
    return 'SettingsData{teamCount: $teamCount, o: $o, division: $division, preferExtraTeam: $preferExtraTeam}';
  }

  SettingsData() {
    teamCount = 2;
    division = 2;
    gameVenues = 1;
    gameRounds = 1;
    proportion = 6;
    o = GEN_OPTION.even_gender;
    preferExtraTeam = false;
  }
}

class Game {
  String team;
  String venue;
  int? scoreTeam1;
  int? scoreTeam2;

  Game(this.team, this.venue, {this.scoreTeam1, this.scoreTeam2});

  @override
  String toString() {
    return 'Game{teams: $team, venue: $venue, score: $scoreTeam1 - $scoreTeam2}';
  }
}

class Round {
  List<Game> matches;
  String roundName;

  Round(this.matches, this.roundName);

  @override
  String toString() {
    return 'Round{matches: $matches, roundName: $roundName}';
  }
}

enum GEN_OPTION { distribute, division, random, even_gender }
