import 'package:exprimo/constants.dart';
import 'package:flutter/material.dart';

class Expression {
  final String title;
  final String description;
  final String question;
  final String example;
  final String iconPath;
  final Color backgroundColor;

  Expression({
    required this.title,
    required this.description,
    required this.question,
    required this.example,
    required this.iconPath,
    required this.backgroundColor,
  });
}

final List<Expression> expressions = [
  Expression(
    title: 'Ekspresi Senang',
    description:
        'Senang adalah ekspresi seseorang saat sedang merasa bahagian yang terlihat dari mata berkerut dan sudut bibir menarik ke atas. Selain itu, terlihat senyuman yang ditandai dengan kedua pipi terdorong naik.',
    question: 'Apa itu ekspresi senang?',
    example:
        'Ketika seseorang merasakan kebahagiaan, kepuasan, atau kegembiraan.\nContoh: Menerima kabar baik, mencapai sesuatu yang diinginkan, atau saat bersama orang yang dicintai.',
    iconPath: senangIcon,
    backgroundColor: senang,
  ),
  Expression(
    title: 'Ekspresi Marah',
    description:
        'Marah adalah ekspresi seseorang saat sedang marah yang umumnya terlihat dari kedua matanya yang tajam. Selain itu, terlihat kedua alis mengerut dan menekan area di sekitar hidung serta bibir yang menyempit.',
    question: 'Apa itu ekspresi marah?',
    example:
        'Ketika seseorang merasa frustrasi, tidak dihargai, atau mengalami ketidakadilan.\nContoh: Saat menghadapi perlakuan tidak adil, mengalami kegagalan akibat faktor eksternal, atau saat kebutuhan tidak terpenuhi.',
    iconPath: marahIcon,
    backgroundColor: marah,
  ),
  Expression(
    title: 'Ekspresi Sedih',
    description:
        'Sedih adalah ekspresi seseorang saat sedang sedih yang ditandai dengan mata bagian atas akan turun ke arah bawah. Serta, mata menjadi tidak fokus dan bagian sudut bibir sedikit turun.',
    question: 'Apa itu ekspresi sedih?',
    example:
        'Ketika seseorang merasa kehilangan, kecewa, atau terluka secara emosional.\nContoh: Kehilangan orang terkasih, gagal dalam suatu usaha, atau mendengar berita buruk.',
    iconPath: sedihIcon,
    backgroundColor: sedih,
  ),
  Expression(
    title: 'Ekspresi Takut',
    description:
        'Takut adalah ekspresi seseorang saat sedang ketakutan terhadap suatu objek tertentu. Di mana ditandai dengan kedua alis yang terangkat secara bersamaan dan mata bagian atas terangkat.',
    question: 'Apa itu ekspresi takut?',
    example:
        'Ketika seseorang merasa terancam, cemas, atau khawatir terhadap sesuatu.\nContoh: Menghadapi situasi berbahaya, berbicara di depan umum untuk pertama kali, atau melihat sesuatu yang menyeramkan.',
    iconPath: takutIcon,
    backgroundColor: takut,
  ),
];
