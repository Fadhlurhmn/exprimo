// education/presentation/widgets/expression_card.dart
import 'package:flutter/material.dart';
import '../../domain/models/expression.dart';

class ExpressionCard extends StatelessWidget {
  final Expression expression;
  final VoidCallback onTap;

  const ExpressionCard({
    Key? key,
    required this.expression,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: expression.backgroundColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  expression.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Image.asset(
                expression.iconPath,
                height: 40,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
