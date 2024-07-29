import 'package:expanse_mate_demo_app/base/base_ui_state.dart';
import 'package:expanse_mate_demo_app/model/category_model.dart';

class CategoryItemsState extends BaseUiState<List<CategoryModel>> {
  CategoryItemsState.loading() : super.loading();

  CategoryItemsState.completed(List<CategoryModel> data) : super.completed(data: data);

  CategoryItemsState.error(super.error) : super.error();
}
