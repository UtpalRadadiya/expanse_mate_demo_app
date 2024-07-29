import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expanse_mate_demo_app/common/consts/app_image.dart';
import 'package:expanse_mate_demo_app/firebase_services/firebase_services.dart';
import 'package:expanse_mate_demo_app/model/category_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';

class ExpanseItemPage extends StatefulWidget {
  ExpanseItemPage({super.key, this.currentIndex});

  int? currentIndex;

  @override
  State<ExpanseItemPage> createState() => _ExpanseItemPageState();
}

class _ExpanseItemPageState extends State<ExpanseItemPage> {
  final BehaviorSubject<DateTime> selectedDate = BehaviorSubject<DateTime>.seeded(DateTime.now());
  final BehaviorSubject<String?> noteSubject = BehaviorSubject<String?>.seeded(null);
  final BehaviorSubject<String?> previousNote = BehaviorSubject<String?>();
  final _firebaseService = FirebaseServices();
  final _fireStore = FirebaseFirestore.instance;
  final BehaviorSubject<List<CategoryModel>?> _categories = BehaviorSubject<List<CategoryModel>?>();
  final BehaviorSubject<CategoryModel?> _selectedCategory = BehaviorSubject<CategoryModel?>();
  TextEditingController expenseController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // _firebaseService.getCategories();
    _fetchCategories();
  }

  void _fetchCategories() async {
    try {
      List<CategoryModel> categories = await _firebaseService.getCategories();
      _categories.value = categories;
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }

  @override
  void dispose() {
    selectedDate.close();
    noteSubject.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const SizedBox(height: 28),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xffDDDDDD),
                  borderRadius: BorderRadius.circular(18),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                child: const Text('₹ INR'),
              ),
              SizedBox(width: MediaQuery.sizeOf(context).width / 2.2),
              Expanded(
                child: TextFormField(
                  controller: expenseController,
                  decoration: const InputDecoration(
                    hintText: 'Add Expense',
                    hintStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  style: TextStyle(
                    fontSize: 36,
                    color: widget.currentIndex == 0 ? const Color(0xffDB1A2B) : const Color(0xff4EBDA4),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Divider(
          height: 1,
          color: Colors.black,
        ),
        const SizedBox(height: 16),
        customRow(
          icon: AppImage.category.path(),
          text: 'Category',
          onTap: () {
            if (_categories.value?.isNotEmpty ?? false) {
              _showCategoryDropdown(context);
            }
          },
          child: _selectedCategory.valueOrNull == null
              ? const Icon(Icons.keyboard_arrow_right)
              : Row(
                  children: [
                    Image.network(
                      _selectedCategory.valueOrNull?.iconUrl ?? '',
                      height: 18,
                    ),
                    const SizedBox(width: 10),
                    Text(_selectedCategory.valueOrNull?.name ?? ''),
                  ],
                ),
        ),
        commonDivider(),
        customRow(
          icon: AppImage.icCalender.path(),
          text: 'Date & Time',
          onTap: () {
            _selectDate(context);
          },
          child: StreamBuilder<DateTime>(
            stream: selectedDate,
            builder: (context, snapshot) {
              final date = snapshot.data ?? DateTime.now();
              final isToday = DateFormat('yyyy-MM-dd').format(date) ==
                  DateFormat('yyyy-MM-dd').format(DateTime.now());
              final formattedDate = isToday
                  ? 'Today, ${DateFormat('hh:mm a').format(date)}'
                  : DateFormat('EEE, MMM d, hh:mm a').format(date);
              return Text(formattedDate);
            },
          ),
        ),
        commonDivider(),
        customRow(
          icon: AppImage.category.path(),
          text: 'Note',
          onTap: () {
            _showNoteDialog(context);
          },
          child: StreamBuilder<String?>(
            stream: noteSubject.stream,
            builder: (context, snapshot) {
              final note = snapshot.data;
              return note == null ? const Icon(Icons.keyboard_arrow_right) : Text(note);
            },
          ),
        ),
        commonDivider(),
        const Spacer(),
        GestureDetector(
          onTap: () {
            _saveData();
          },
          child: Container(
            height: 48,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.center,
            width: double.maxFinite,
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Save',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget customRow({String? icon, String? text, Function()? onTap, Widget? child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          children: [
            SvgPicture.asset(icon ?? ''),
            const SizedBox(width: 10),
            Text(text ?? ''),
            const Spacer(),
            child ?? const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  void _showCategoryDropdown(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Category'),
          content: DropdownButton<CategoryModel>(
            value: _selectedCategory.valueOrNull,
            items: _categories.valueOrNull?.map((category) {
              return DropdownMenuItem<CategoryModel>(
                value: category,
                child: Row(
                  children: [
                    Image.network(
                      category.iconUrl,
                      height: 18,
                    ),
                    const SizedBox(width: 10),
                    Text(category.name),
                  ],
                ),
              );
            }).toList(),
            onChanged: (CategoryModel? newValue) {
              setState(() {
                _selectedCategory.value = newValue;
              });
              Navigator.of(context).pop();
            },
          ),
        );
      },
    );
  }

  void _saveData() async {
    if (_selectedCategory.valueOrNull == null ||
        selectedDate.valueOrNull == null ||
        expenseController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please fill all required fields.'),
      ));
      return;
    }

    /// Determine collection name and type
    String collectionName = 'expanse_income';
    String type = widget.currentIndex == 0 ? 'expense' : 'income';

    ///Get selected category id
    String categoryId = _selectedCategory.value!.categoryID;

    /// Prepare data to save
    Map<String, dynamic> data = {
      'category': categoryId,
      'note': noteSubject.valueOrNull ?? '',
      'date': selectedDate.value.toIso8601String(),
      'payment': int.tryParse(expenseController.text) ?? 0,
      'type': type,
    };

    try {
      /// Add data to Firestore
      await _fireStore.collection(collectionName).add(data);

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Data saved successfully.'),
      ));
    } catch (e) {
      print('Error saving data: $e');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Error saving data. Please try again'),
      ));
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate.value) {
      selectedDate.add(picked);
    }
  }

  Future<void> _showNoteDialog(BuildContext context) async {
    final TextEditingController controller = TextEditingController(text: noteSubject.value);
    previousNote.value = noteSubject.value;
    final result = await showDialog<String?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Note'),
          content: TextFormField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Enter your note here'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog without saving
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                Navigator.of(context).pop(controller.text); // Close the dialog and return the text
              },
            ),
          ],
        );
      },
    );

    if (result != null && result.isNotEmpty) {
      noteSubject.add(result);
    } else {
      noteSubject.add(null);
    }
  }

  Widget commonDivider() {
    return const Column(
      children: [
        SizedBox(height: 16),
        Divider(
          height: 1,
          color: Colors.black,
        ),
        SizedBox(height: 16),
      ],
    );
  }
}
