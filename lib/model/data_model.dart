class SettingsData {
  int teamCount = 2;
  int division = 2;
  int proportion = 6; // Standard Volleyball team size
  int gameVenues = 1; // Default to 1 court/venue
  int gameRounds = 1; // Default to enough rounds for everyone to play once

  bool preferExtraTeam =
      false; // Toggle for handling remainders in team generation

  GEN_OPTION o = GEN_OPTION.even_gender; // Default generation option

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

enum GEN_OPTION { distribute, division, random, proportion, even_gender }
