import 'package:cloud_firestore/cloud_firestore.dart';

class ExpanseIncomeModel {
  final String categoryId;
  final String date;
  final String note;
  final String type;
  final num payment;

  ExpanseIncomeModel({
    required this.categoryId,
    required this.date,
    required this.note,
    required this.type,
    required this.payment,
  });

  factory ExpanseIncomeModel.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ExpanseIncomeModel(
      categoryId: data['category'] ?? '',
      date: data['date'] ?? '',
      note: data['note'] ?? '',
      type: data['type'] ?? '',
      payment: data['payment'] ?? 0,
    );
  }
}
