import 'package:flutter/material.dart';

import '../../core/services/api_service.dart';
import '../../core/utils/responsive.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

enum _AdminUserFilter { all, highRisk }

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final ApiService _apiService = ApiService();

  bool _loading = true;
  _AdminUserFilter _filter = _AdminUserFilter.all;

  Map<String, dynamic> _metrics = {
    'total_users': 0,
    'high_risk_users': 0,
    'recent_threats': 0,
    'average_cyber_score': 0,
  };

  List<_AdminUser> _users = [];

  @override
  void initState() {
    super.initState();
    _loadAdminData();
  }

  Future<void> _loadAdminData() async {
    try {
      final metrics = await _apiService.getAdminMetrics();
      final users = await _apiService.getAdminUsers();

      if (!mounted) return;
      setState(() {
        _metrics = metrics;
        _users = users.map(_AdminUser.fromJson).toList();
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  String _scoreLabel(num value) {
    if (value >= 85) return 'Strong';
    if (value >= 70) return 'Stable';
    if (value >= 50) return 'Moderate';
    return 'Needs Attention';
  }

  List<_AdminUser> get _filteredUsers {
    if (_filter == _AdminUserFilter.highRisk) {
      return _users.where((user) => user.riskLevel == 'high').toList();
    }
    return _users;
  }

  void _showInfoSheet(String title, String message) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF342E2C),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 26),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                style: const TextStyle(
                  color: Color(0xFFD3C3BC),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showUserDetails(_AdminUser user) {
    final badgeColor = switch (user.riskLevel) {
      'high' => const Color(0xFFFFA49C),
      'medium' => const Color(0xFFFFD4A6),
      _ => const Color(0xFFFFCEB6),
    };

    final scoreText =
        user.cyberScore != null ? user.cyberScore.toString() : 'Not available';

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF342E2C),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final compact = Responsive.isCompact(context);

        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            18,
            20,
            MediaQuery.of(context).viewInsets.bottom + 28,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: compact ? 22 : 24,
                    backgroundColor: const Color(0xFF554640),
                    child: Text(
                      user.initials,
                      style: TextStyle(
                        color: const Color(0xFFFFE6D9),
                        fontWeight: FontWeight.w800,
                        fontSize: compact ? 14 : 15,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      user.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: compact ? 17 : 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _DetailRow(label: 'Email', value: user.email, compact: compact),
              _DetailRow(label: 'Role', value: user.role.toUpperCase(), compact: compact),
              _DetailRow(label: 'Joined', value: user.createdAt, compact: compact),
              _DetailRow(label: 'Cyber Score', value: scoreText, compact: compact),
              const SizedBox(height: 14),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: compact ? 10 : 12,
                  vertical: compact ? 7 : 8,
                ),
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: badgeColor.withOpacity(0.40)),
                ),
                child: Text(
                  user.statusLabel,
                  style: TextStyle(
                    color: badgeColor,
                    fontSize: compact ? 12 : 12.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final compact = Responsive.isCompact(context);

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final averageScore = (_metrics['average_cyber_score'] ?? 0) as num;
    final totalUsers = (_metrics['total_users'] ?? 0).toString();
    final highRisk = (_metrics['high_risk_users'] ?? 0).toString();
    final recentThreats = (_metrics['recent_threats'] ?? 0).toString();

    return RefreshIndicator(
      onRefresh: _loadAdminData,
      color: const Color(0xFFF2A47F),
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          Responsive.horizontalPadding(context),
          compact ? 6 : 8,
          Responsive.horizontalPadding(context),
          18,
        ),
        children: [
          GestureDetector(
            onTap: () => _showInfoSheet(
              'Organization Cyber Score',
              'This is the overall cyber score summary based on the recent scan and monitoring activity available in the system.',
            ),
            child: Container(
              padding: EdgeInsets.all(compact ? 16 : 18),
              decoration: BoxDecoration(
                color: const Color(0xFF5B4740),
                borderRadius: BorderRadius.circular(compact ? 20 : 22),
                border: Border.all(color: const Color(0xAAEAA27F), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF2A47F).withOpacity(0.18),
                    blurRadius: 22,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'Organization Cyber Score',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFFFFE6D9),
                      fontSize: compact ? 14 : 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${averageScore.toInt()} - ${_scoreLabel(averageScore).toUpperCase()}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFFFFCDB6),
                      fontSize: compact ? 18 : 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  compact: compact,
                  title: 'Users',
                  value: totalUsers,
                  color: const Color(0xFFFFCEB6),
                  selected: _filter == _AdminUserFilter.all,
                  onTap: () => setState(() => _filter = _AdminUserFilter.all),
                ),
              ),
              SizedBox(width: compact ? 10 : 12),
              Expanded(
                child: _MetricCard(
                  compact: compact,
                  title: 'High Risk',
                  value: highRisk,
                  color: const Color(0xFFFFA49C),
                  selected: _filter == _AdminUserFilter.highRisk,
                  onTap: () => setState(() => _filter = _AdminUserFilter.highRisk),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () => _showInfoSheet(
              'Recent Threats',
              'This reflects dangerous scan activity detected during the recent monitoring window.',
            ),
            child: _InfoStrip(
              compact: compact,
              title: 'Recent Threats',
              value: recentThreats,
              valueColor: const Color(0xFFFFD4A6),
              icon: Icons.warning_amber_rounded,
            ),
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () => _showInfoSheet(
              'Monitoring State',
              averageScore >= 70
                  ? 'The current system state looks relatively stable.'
                  : 'The current system state needs closer review and follow-up.',
            ),
            child: _InfoStrip(
              compact: compact,
              title: 'Monitoring State',
              value: averageScore >= 70 ? 'Stable' : 'Needs Review',
              valueColor: averageScore >= 70
                  ? const Color(0xFFFFCEB6)
                  : const Color(0xFFFFA49C),
              icon: averageScore >= 70
                  ? Icons.verified_rounded
                  : Icons.priority_high_rounded,
            ),
          ),
          SizedBox(height: compact ? 16 : 18),
          Row(
            children: [
              Expanded(
                child: Text(
                  'User Records',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: compact ? 16 : 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                _filter == _AdminUserFilter.highRisk ? 'High Risk Only' : 'All Users',
                style: TextStyle(
                  color: const Color(0xFFD3C3BC),
                  fontSize: compact ? 11.8 : 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_filteredUsers.isEmpty)
            Container(
              padding: EdgeInsets.all(compact ? 16 : 18),
              decoration: BoxDecoration(
                color: const Color(0xFF3A3431),
                borderRadius: BorderRadius.circular(compact ? 20 : 22),
                border: Border.all(color: const Color(0xFF7C6F6A)),
              ),
              child: Text(
                'No users found for the selected filter.',
                style: TextStyle(
                  color: const Color(0xFFD3C3BC),
                  fontSize: compact ? 13.2 : 14,
                ),
              ),
            )
          else
            ..._filteredUsers.map(
              (user) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _UserTile(
                  compact: compact,
                  user: user,
                  onTap: () => _showUserDetails(user),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AdminUser {
  const _AdminUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.createdAt,
    required this.statusLabel,
    required this.riskLevel,
    this.cyberScore,
  });

  final String id;
  final String name;
  final String email;
  final String role;
  final String createdAt;
  final String statusLabel;
  final String riskLevel;
  final int? cyberScore;

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  factory _AdminUser.fromJson(Map<String, dynamic> json) {
    return _AdminUser(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? 'Unnamed User').toString(),
      email: (json['email'] ?? '').toString(),
      role: (json['role'] ?? 'user').toString(),
      createdAt: (json['created_at'] ?? 'Not available').toString(),
      statusLabel: (json['status_label'] ?? 'Monitor').toString(),
      riskLevel: (json['risk_level'] ?? 'medium').toString(),
      cyberScore: json['cyber_score'] is num
          ? (json['cyber_score'] as num).toInt()
          : null,
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.color,
    required this.selected,
    required this.onTap,
    required this.compact,
  });

  final String title;
  final String value;
  final Color color;
  final bool selected;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: compact ? 100 : 112,
        padding: EdgeInsets.all(compact ? 14 : 16),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF4A3B36) : const Color(0xFF3A3431),
          borderRadius: BorderRadius.circular(compact ? 20 : 22),
          border: Border.all(
            color: selected ? const Color(0xAAF2A47F) : const Color(0xFF7C6F6A),
            width: selected ? 1.2 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFF2A47F).withOpacity(selected ? 0.14 : 0.06),
              blurRadius: 12,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: compact ? 13.2 : 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: compact ? 20 : 24,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoStrip extends StatelessWidget {
  const _InfoStrip({
    required this.title,
    required this.value,
    required this.valueColor,
    required this.icon,
    required this.compact,
  });

  final String title;
  final String value;
  final Color valueColor;
  final IconData icon;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(compact ? 14 : 16),
      decoration: BoxDecoration(
        color: const Color(0xFF3A3431),
        borderRadius: BorderRadius.circular(compact ? 20 : 22),
        border: Border.all(color: const Color(0xFF7C6F6A)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF2A47F).withOpacity(0.06),
            blurRadius: 12,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: compact ? 14 : 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  value,
                  style: TextStyle(
                    color: valueColor,
                    fontSize: compact ? 16 : 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: compact ? 40 : 44,
            height: compact ? 40 : 44,
            decoration: BoxDecoration(
              color: valueColor.withOpacity(0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: valueColor, size: compact ? 20 : 22),
          ),
        ],
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  const _UserTile({
    required this.user,
    required this.onTap,
    required this.compact,
  });

  final _AdminUser user;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final badgeColor = switch (user.riskLevel) {
      'high' => const Color(0xFFFFA49C),
      'medium' => const Color(0xFFFFD4A6),
      _ => const Color(0xFFFFCEB6),
    };

    final scoreText = user.cyberScore != null ? 'Score ${user.cyberScore}' : 'Score N/A';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(compact ? 12 : 14),
        decoration: BoxDecoration(
          color: const Color(0xFF3A3431),
          borderRadius: BorderRadius.circular(compact ? 18 : 20),
          border: Border.all(color: const Color(0xFF7C6F6A)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFF2A47F).withOpacity(0.06),
              blurRadius: 12,
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: compact ? 20 : 22,
              backgroundColor: const Color(0xFF554640),
              child: Text(
                user.initials,
                style: TextStyle(
                  color: const Color(0xFFFFE6D9),
                  fontWeight: FontWeight.w800,
                  fontSize: compact ? 12.5 : 13.5,
                ),
              ),
            ),
            SizedBox(width: compact ? 10 : 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: compact ? 14.2 : 15.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: const Color(0xFFD3C3BC),
                      fontSize: compact ? 12 : 12.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${user.statusLabel} - $scoreText',
                    style: TextStyle(
                      color: badgeColor,
                      fontSize: compact ? 11.6 : 12.4,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: compact ? 8 : 10),
            Icon(
              Icons.chevron_right_rounded,
              color: const Color(0xFFFFCEB6),
              size: compact ? 20 : 24,
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    required this.compact,
  });

  final String label;
  final String value;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: compact ? 82 : 92,
            child: Text(
              label,
              style: TextStyle(
                color: const Color(0xFFD3C3BC),
                fontSize: compact ? 12.8 : 13.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: compact ? 13.5 : 14.2,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
