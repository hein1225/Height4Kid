import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/growth_chart.dart';
import '../widgets/character_display.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        final isPink = appProvider.currentTheme == 'pink';
        final kid = appProvider.currentKid;

        return Column(
          children: [
            // Hero Section with Character
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Hero gradient background area
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: isPink
                              ? [
                                  AppTheme.pinkHeroGradientStart,
                                  AppTheme.pinkHeroGradientEnd,
                                  Colors.white
                                ]
                              : [
                                  AppTheme.blueHeroGradientStart,
                                  AppTheme.blueHeroGradientEnd,
                                  Colors.white
                                ],
                        ),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(40),
                          bottomRight: Radius.circular(40),
                        ),
                      ),
                      child: Column(
                        children: [
                          // Avatar, kid name and settings row
                          if (kid != null)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: () => appProvider.setPage('kids'),
                                    child: Stack(
                                      children: [
                                        Container(
                                          width: 48,
                                          height: 48,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(24),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withValues(alpha: 0.1),
                                                blurRadius: 8,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 2,
                                            ),
                                          ),
                                          child: kid.avatar != null
                                              ? ClipOval(
                                                  child: _buildAvatarImage(kid.avatar!, isPink),
                                                )
                                              : _defaultAvatar(isPink),
                                        ),
                                        // 切换标识
                                        Positioned(
                                          right: 0,
                                          bottom: 0,
                                          child: Container(
                                            width: 16,
                                            height: 16,
                                            decoration: BoxDecoration(
                                              color: isPink ? AppTheme.pinkPrimary : AppTheme.bluePrimary,
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(color: Colors.white, width: 2),
                                            ),
                                            child: const Icon(
                                              Icons.swap_horiz,
                                              size: 10,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    kid.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textDark,
                                    ),
                                  ),
                                  const Spacer(),
                                  _HeaderButton(
                                    icon: Icons.settings,
                                    onTap: () => appProvider.setPage('settings'),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 10),
                          // Character display with data tags
                          const CharacterDisplay(),
                        ],
                      ),
                    ),
                    // Chart Section
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: SizedBox(
                        width: double.infinity,
                        child: GrowthChart(
                          onTapFullscreen: () => appProvider.toggleFullscreenChart(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAvatarImage(String avatarUrl, bool isPink) {
    if (avatarUrl.startsWith('data:image')) {
      final bytes = base64Decode(avatarUrl.split(',')[1]);
      return Image.memory(
        bytes,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _defaultAvatar(isPink),
      );
    }
    return Image.network(
      avatarUrl,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _defaultAvatar(isPink),
    );
  }

  Widget _defaultAvatar(bool isPink) {
    return Center(
      child: Icon(
        Icons.child_care,
        color: isPink ? AppTheme.pinkPrimary : AppTheme.bluePrimary,
        size: 28,
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Center(
          child: Icon(
            icon,
            color: AppTheme.textDark,
            size: 20,
          ),
        ),
      ),
    );
  }
}
