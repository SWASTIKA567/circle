import 'package:get/get.dart';

class SocietiesController extends GetxController {
  final RxString selectedCategory = 'All'.obs;
  final RxList<Map<String, dynamic>> societies = <Map<String, dynamic>>[].obs;

  final List<String> categories = ['All', 'Technical', 'Cultural', 'Literary', 'Sports'];

  List<Map<String, dynamic>> get filteredSocieties {
    if (selectedCategory.value == 'All') return societies;
    return societies.where((s) => s['category'] == selectedCategory.value).toList();
  }

  void selectCategory(String category) => selectedCategory.value = category;

  void toggleJoin(int index) {
    final soc = filteredSocieties[index];
    final realIndex = societies.indexOf(soc);
    if (realIndex != -1) {
      societies[realIndex] = {...soc, 'isJoined': !(soc['isJoined'] as bool)};
    }
  }
}
