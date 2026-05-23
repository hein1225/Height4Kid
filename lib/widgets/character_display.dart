import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../models/national_standard.dart';

class CharacterDisplay extends StatelessWidget {
  const CharacterDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        final isPink = appProvider.currentTheme == 'pink';
        final kid = appProvider.currentKid;
        final ageGroup = kid?.getAgeGroup() ?? '0-3';
        final records = appProvider.getSortedRecords();
        final latestRecord = records.isNotEmpty ? records.first : null;

        return SizedBox(
          height: 320,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Ground
              Positioned(
                bottom: 20,
                left: 50,
                right: 50,
                child: Container(
                  height: 70,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: isPink
                          ? [AppTheme.pinkGroundStart, AppTheme.pinkGroundMid, AppTheme.pinkGroundEnd]
                          : [AppTheme.blueGroundStart, AppTheme.blueGroundMid, AppTheme.blueGroundEnd],
                    ),
                    borderRadius: BorderRadius.circular(35),
                    boxShadow: [
                      BoxShadow(
                        color: (isPink ? AppTheme.pinkPrimary : AppTheme.bluePrimary).withValues(alpha: 0.4),
                        blurRadius: 20,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                ),
              ),
              // Grass blades - 更自然的分布
              Positioned(
                bottom: 48,
                left: 80,
                child: _GrassBlade(rotation: -20, delay: 0),
              ),
              Positioned(
                bottom: 42,
                left: 100,
                child: _GrassBlade(rotation: -8, delay: 1),
              ),
              Positioned(
                bottom: 50,
                left: 120,
                child: _GrassBlade(rotation: 5, delay: 2),
              ),
              Positioned(
                bottom: 48,
                right: 90,
                child: _GrassBlade(rotation: 20, delay: 3),
              ),
              Positioned(
                bottom: 42,
                right: 70,
                child: _GrassBlade(rotation: 8, delay: 4),
              ),
              Positioned(
                bottom: 50,
                right: 110,
                child: _GrassBlade(rotation: -5, delay: 5),
              ),
              // Character shadow
              Positioned(
                bottom: 40,
                child: Container(
                  width: 200,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(0, 0),
                      radius: 0.5,
                      colors: [
                        (isPink ? AppTheme.pinkPrimary : AppTheme.bluePrimary).withValues(alpha: 0.15),
                        Colors.transparent,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
              ),
              // Character image
              Positioned(
                bottom: 50,
                child: SizedBox(
                  width: 220,
                  height: 220,
                  child: Image.asset(
                    _getImagePath(ageGroup, isPink),
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildFallbackCharacter(isPink);
                    },
                    frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                      if (frame == null) {
                        return _buildFallbackCharacter(isPink);
                      }
                      return child;
                    },
                  ),
                ),
              ),
              // Height tag with evaluation
              Positioned(
                right: 20,
                top: 40,
                child: _DataTagWithEval(
                  label: '身高：',
                  value: latestRecord != null ? '${latestRecord.height}cm' : '—',
                  dotColor: isPink ? AppTheme.pinkPrimary : AppTheme.bluePrimary,
                  valueColor: isPink ? AppTheme.pinkPrimary : AppTheme.bluePrimary,
                  evalResult: latestRecord != null && kid != null
                      ? StandardData.evaluateHeight(
                          latestRecord.height,
                          kid.getAgeInMonths(latestRecord.date) / 12,
                          isPink ? 'girl' : 'boy',
                        )
                      : null,
                ),
              ),
              // Weight tag
              Positioned(
                left: 20,
                top: 140,
                child: _DataTagWithEval(
                  label: '体重：',
                  value: latestRecord != null ? '${latestRecord.weight}kg' : '—',
                  dotColor: AppTheme.weightColor,
                  valueColor: AppTheme.weightValueColor,
                  evalResult: null, // 体重不显示评估
                ),
              ),
              // BMI tag with evaluation
              Positioned(
                left: 20,
                top: 200,
                child: _BmiTagWithEval(
                  bmi: latestRecord != null && kid != null
                      ? latestRecord.weight / ((latestRecord.height / 100) * (latestRecord.height / 100))
                      : null,
                  evalResult: latestRecord != null && kid != null
                      ? StandardData.evaluateBmi(
                          latestRecord.weight / ((latestRecord.height / 100) * (latestRecord.height / 100)),
                          kid.getAgeInMonths(latestRecord.date) / 12,
                          isPink ? 'girl' : 'boy',
                        )
                      : null,
                ),
              ),
              // Age badge
              Positioned(
                top: 0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isPink
                          ? [AppTheme.pinkPrimary, AppTheme.pinkSecondary]
                          : [AppTheme.bluePrimary, AppTheme.blueSecondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Text(
                    kid?.getFormattedAge() ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getImagePath(String ageGroup, bool isPink) {
    final genderText = isPink ? '女孩' : '男孩';
    return "assets/images/Q版${genderText}成长形象生成${ageGroup}.png";
  }

  Widget _buildFallbackCharacter(bool isPink) {
    final primaryColor = isPink ? AppTheme.pinkPrimary : AppTheme.bluePrimary;
    return Center(
      child: Container(
        width: 120,
        height: 160,
        decoration: BoxDecoration(
          color: primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(60),
        ),
        child: Center(
          child: Icon(
            Icons.child_care,
            size: 60,
            color: primaryColor,
          ),
        ),
      ),
    );
  }
}

class _GrassBlade extends StatefulWidget {
  final double rotation;
  final int delay;

  const _GrassBlade({required this.rotation, required this.delay});

  @override
  State<_GrassBlade> createState() => _GrassBladeState();
}

class _GrassBladeState extends State<_GrassBlade>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _swayAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    // 摇摆动画
    _swayAnimation = Tween<double>(
      begin: widget.rotation - 3,
      end: widget.rotation + 3,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutSine,
      ),
    );
    
    // 轻微缩放动画，模拟生命力
    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
    
    // 添加延迟，使每株小草动画不同步
    Future.delayed(Duration(milliseconds: widget.delay * 300), () {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _swayAnimation.value * 3.14159 / 180,
          alignment: Alignment.bottomCenter,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            alignment: Alignment.bottomCenter,
            child: CustomPaint(
              size: const Size(20, 32),
              painter: _CuteGrassPainter(),
            ),
          ),
        );
      },
    );
  }
}

// 可爱小草绘制器
class _CuteGrassPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    
    // 主叶片 - 圆润的草叶形状
    final mainPath = Path();
    mainPath.moveTo(width * 0.5, 0);
    mainPath.quadraticBezierTo(
      width * 0.8, height * 0.3,
      width * 0.7, height * 0.8,
    );
    mainPath.quadraticBezierTo(
      width * 0.6, height * 0.95,
      width * 0.5, height,
    );
    mainPath.quadraticBezierTo(
      width * 0.4, height * 0.95,
      width * 0.3, height * 0.8,
    );
    mainPath.quadraticBezierTo(
      width * 0.2, height * 0.3,
      width * 0.5, 0,
    );
    mainPath.close();
    
    // 渐变填充
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFFB8E6B8),
        const Color(0xFF90D690),
        const Color(0xFF6BC96B),
      ],
    );
    
    final paint = Paint()
      ..shader = gradient.createShader(Rect.fromLTWH(0, 0, width, height))
      ..style = PaintingStyle.fill;
    
    canvas.drawPath(mainPath, paint);
    
    // 添加高光，让草叶更立体可爱
    final highlightPath = Path();
    highlightPath.moveTo(width * 0.45, height * 0.1);
    highlightPath.quadraticBezierTo(
      width * 0.55, height * 0.3,
      width * 0.5, height * 0.6,
    );
    highlightPath.quadraticBezierTo(
      width * 0.45, height * 0.3,
      width * 0.4, height * 0.15,
    );
    highlightPath.close();
    
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    
    canvas.drawPath(highlightPath, highlightPaint);
    
    // 中心线条
    final linePaint = Paint()
      ..color = const Color(0xFF4CAF50).withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    
    final linePath = Path();
    linePath.moveTo(width * 0.5, height * 0.15);
    linePath.quadraticBezierTo(
      width * 0.52, height * 0.5,
      width * 0.5, height * 0.85,
    );
    
    canvas.drawPath(linePath, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DataTagWithEval extends StatelessWidget {
  final String label;
  final String value;
  final Color dotColor;
  final Color valueColor;
  final String? evalResult;

  const _DataTagWithEval({
    required this.label,
    required this.value,
    required this.dotColor,
    required this.valueColor,
    this.evalResult,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.7),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 指示点
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: dotColor.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.5),
                width: 1.5,
              ),
            ),
          ),
          const SizedBox(width: 6),
          // 标签和数值
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textDark.withValues(alpha: 0.7),
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: valueColor.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
              // 评估结果 - 融入气泡内部
              if (evalResult != null) ...[
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: _getEvalColor(evalResult!).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    evalResult!,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: _getEvalColor(evalResult!),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Color _getEvalColor(String result) {
    switch (result) {
      case '矮小':
      case '偏瘦':
      case '低体重':
        return const Color(0xFFFF6B6B);
      case '偏矮':
      case '超重':
        return const Color(0xFFFFA726);
      case '标准':
      case '正常':
        return const Color(0xFF66BB6A);
      case '偏高':
        return const Color(0xFF42A5F5);
      case '超高':
      case '肥胖':
        return const Color(0xFF2196F3);
      default:
        return AppTheme.textLight;
    }
  }
}

// BMI标签组件
class _BmiTagWithEval extends StatelessWidget {
  final double? bmi;
  final String? evalResult;

  const _BmiTagWithEval({
    this.bmi,
    this.evalResult,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.7),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 指示点
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: AppTheme.weightColor.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.5),
                width: 1.5,
              ),
            ),
          ),
          const SizedBox(width: 6),
          // 标签和数值
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'BMI：',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textDark.withValues(alpha: 0.7),
                    ),
                  ),
                  Text(
                    bmi != null ? bmi!.toStringAsFixed(1) : '—',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.weightValueColor.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
              // 评估结果 - 融入气泡内部
              if (evalResult != null) ...[
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: _getBmiEvalColor(evalResult!).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    evalResult!,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: _getBmiEvalColor(evalResult!),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Color _getBmiEvalColor(String result) {
    switch (result) {
      case '低体重':
        return const Color(0xFFFF6B6B);
      case '正常':
        return const Color(0xFF66BB6A);
      case '超重':
        return const Color(0xFFFFA726);
      case '肥胖':
        return const Color(0xFF2196F3);
      default:
        return AppTheme.textLight;
    }
  }
}
