// lib/features/expressions/presentation/pages/expressions_page.dart
import 'package:flutter/material.dart';
import '../widgets/expression_card.dart';
import '../widgets/expression_detail.dart';
import '../../domain/models/expression.dart';

class ExpressionsPage extends StatelessWidget {
  const ExpressionsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Apakah Anda tahu makna di balik setiap ekspresi?',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Temukan penjelasannya di sini! 😄',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 20),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: expressions.length,
                itemBuilder: (context, index) {
                  return ExpressionCard(
                    expression: expressions[index],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ExpressionDetail(
                            expression: expressions[index],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
