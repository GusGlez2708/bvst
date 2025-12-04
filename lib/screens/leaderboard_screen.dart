// lib/screens/leaderboard_screen.dart
import 'package:bvst/services/score_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final ScoreService _scoreService = ScoreService();
  List<Map<String, dynamic>> _leaderboard = [];
  bool _isLoading = true;
  Map<String, dynamic>? _userRank;

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    setState(() => _isLoading = true);

    try {
      final leaderboard = await _scoreService.getGlobalLeaderboard(limit: 50);
      final userRank = await _scoreService.getUserRank();

      setState(() {
        _leaderboard = leaderboard;
        _userRank = userRank;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading leaderboard: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [Color(0xFF0D1B2A), Color(0xFF000000)],
            center: Alignment.center,
            radius: 0.8,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Color(0xFF61E2FF),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        'LEADERBOARD INFINITO',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.orbitron(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF61E2FF),
                        ),
                      ),
                    ),
                    const SizedBox(width: 48), // Balance back button
                  ],
                ),
              ),

              // User Rank Card (if available)
              if (_userRank != null)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4FA0E4).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF61E2FF),
                        width: 2,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          'TU RANGO:',
                          style: GoogleFonts.orbitron(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                        Text(
                          '#${_userRank!['rank']}',
                          style: GoogleFonts.orbitron(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFFFD700),
                          ),
                        ),
                        Text(
                          'de ${_userRank!['total_players']}',
                          style: GoogleFonts.orbitron(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Leaderboard List
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF61E2FF),
                        ),
                      )
                    : _leaderboard.isEmpty
                    ? Center(
                        child: Text(
                          'No hay scores registrados aún',
                          style: GoogleFonts.orbitron(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadLeaderboard,
                        color: const Color(0xFF61E2FF),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          itemCount: _leaderboard.length,
                          itemBuilder: (context, index) {
                            final entry = _leaderboard[index];
                            final rank = index + 1;
                            final username = entry['username'] ?? 'Jugador';
                            final score = entry['score'] ?? 0;
                            final round = entry['round_reached'] ?? 0;

                            // Medal colors for top 3
                            Color? medalColor;
                            if (rank == 1)
                              medalColor = const Color(0xFFFFD700); // Gold
                            if (rank == 2)
                              medalColor = const Color(0xFFC0C0C0); // Silver
                            if (rank == 3)
                              medalColor = const Color(0xFFCD7F32); // Bronze

                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color:
                                      medalColor ??
                                      const Color(0xFF61E2FF).withOpacity(0.3),
                                  width: medalColor != null ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  // Rank
                                  SizedBox(
                                    width: 40,
                                    child: Text(
                                      '#$rank',
                                      style: GoogleFonts.orbitron(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: medalColor ?? Colors.white,
                                      ),
                                    ),
                                  ),
                                  // Username
                                  Expanded(
                                    child: Text(
                                      username,
                                      style: GoogleFonts.pressStart2p(
                                        fontSize: 12,
                                        color: Colors.white,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  // Round
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF8B00FF,
                                      ).withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'R$round',
                                      style: GoogleFonts.orbitron(
                                        fontSize: 10,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  // Score
                                  Text(
                                    '$score',
                                    style: GoogleFonts.orbitron(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFFFFD700),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
              ),

              // Refresh Button
              if (!_isLoading)
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: ElevatedButton.icon(
                    onPressed: _loadLeaderboard,
                    icon: const Icon(Icons.refresh),
                    label: Text(
                      'ACTUALIZAR',
                      style: GoogleFonts.pressStart2p(fontSize: 12),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4FA0E4),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
