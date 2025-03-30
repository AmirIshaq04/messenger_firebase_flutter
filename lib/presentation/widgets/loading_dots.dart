import 'package:flutter/material.dart';

class LoadingDots extends StatefulWidget {
  const LoadingDots({super.key});

  @override
  State<LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<LoadingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          3,
          (index) {
            return AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final animation = Tween(
                  begin: 0.0,
                  end: 0.1,
                ).animate(
                  CurvedAnimation(
                    parent: _controller,
                    curve: Interval(index * 0.2, index * 0.2 + 0.5,
                        curve: Curves.easeInOut),
                  ),
                );
                return Container(
                  width: 4,
                  height: 4,
                  margin: EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(
                          0.3 + (0.7 * animation.value),
                        ),
                    shape: BoxShape.circle,
                  ),
                );
              },
            );
          },
        ));
  }
}
