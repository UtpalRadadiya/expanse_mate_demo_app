import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  final String name;
  final String iconUrl;
  final String categoryID;

  CategoryModel({required this.name, required this.iconUrl, required this.categoryID});

  factory CategoryModel.fromFireStore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CategoryModel(
      name: data['name'] ?? '',
      iconUrl: data['icon'] ?? '',
      categoryID: doc.id ?? '',
    );
  }

  // Convert a CategoryModel to a Map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'icon': iconUrl,
    };
  }
}
