import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expanse_mate_demo_app/model/category_model.dart';

class FirebaseServices {
  final _fireStore = FirebaseFirestore.instance;

  Future<List<CategoryModel>> getCategories() async {
    final QuerySnapshot snapshot = await _fireStore.collection('categories').get();
    return snapshot.docs.map((doc) => CategoryModel.fromFireStore(doc)).toList();
  }
}
