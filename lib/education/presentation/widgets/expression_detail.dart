// lib/features/expressions/presentation/widgets/expression_detail.dart
import 'package:flutter/material.dart';
import '../../domain/models/expression.dart';

class ExpressionDetail extends StatelessWidget {
  final Expression expression;

  const ExpressionDetail({
    Key? key,
    required this.expression,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(expression.title),
        backgroundColor: expression.backgroundColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: expression.backgroundColor,
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Image.asset(
                    expression.iconPath,
                    height: 60,
                  ),
                  const SizedBox(width: 20),
                  Text(
                    expression.question,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    expression.description,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    'Kapan sih kamu biasanya menunjukkan ${expression.title.toLowerCase()}? Yuk, cari tahu lebih lanjut!',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    expression.example,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
