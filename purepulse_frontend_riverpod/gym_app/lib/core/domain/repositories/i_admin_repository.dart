abstract interface class IAdminRepository {
  bool get hasNewAnnouncements;
  set hasNewAnnouncements(bool value);
  void trackLogout();
  Future<void> fetchCategories();
  Future<void> deleteAccount();
  String getExerciseCategoryId(String category);
  Future<void> addCategory(String category);
  Future<void> removeCategory(String category);
  Future<void> addProductCategory(String category);
  Future<void> removeProductCategory(String category);
  String getProductCategoryId(String category);
}
