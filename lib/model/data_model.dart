class SettingsData {
  int teamCount = 1;
  int division = 2;
  int proportion = 6; // Set default 6 players per team
  int gameVenues = 2;
  int gameRounds = 2;

  GEN_OPTION o = GEN_OPTION.proportion; // Default generation option

  @override
  String toString() {
    return 'SettingsData{teamCount: $teamCount, o: $o, division: $division}';
  }

  SettingsData() {
    teamCount = 1;
    division = 2;
    proportion = 6;
    o = GEN_OPTION.proportion;
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

enum GEN_OPTION { distribute, division, random, proportion, even_gender }
