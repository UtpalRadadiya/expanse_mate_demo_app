import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expanse_mate_demo_app/base/base_bloc.dart';
import 'package:expanse_mate_demo_app/firebase_services/firebase_services.dart';
import 'package:expanse_mate_demo_app/model/category_model.dart';
import 'package:expanse_mate_demo_app/model/expanse_income_model.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

enum Selection { sort, filter }

class ActivityBloc extends BaseBloc {
  final _firebaseService = FirebaseServices();
  final expensesSubject = BehaviorSubject<List<ExpanseIncomeModel>>();
  final datesSubject = BehaviorSubject<List<DateTime>>();
  final selectedDateSubject = BehaviorSubject<DateTime?>();
  final selectionSubject = BehaviorSubject<Selection>();
  final selectedCategorySubject = BehaviorSubject<String?>();
  final amountRangeSubject = BehaviorSubject<RangeValues>();
  final dateRangeSubject = BehaviorSubject<DateTimeRange>();
  final selectedDateExpensesSubject = BehaviorSubject<List<ExpanseIncomeModel>>();

  final categoryDetails = <String, Map<String, String>>{};
  final categorySubject = BehaviorSubject<String?>();

  final BehaviorSubject<List<CategoryModel>?> category = BehaviorSubject<List<CategoryModel>?>();
  final BehaviorSubject<CategoryModel?> selectedCategory = BehaviorSubject<CategoryModel?>();

  ActivityBloc() {
    fetchCategoryDetails();
    _fetchCategories();
  }

  void fetchExpenses() async {
    final snapshot = await FirebaseFirestore.instance.collection('expanse_income').get();
    final expenses = snapshot.docs.map((doc) => ExpanseIncomeModel.fromDocument(doc)).toList();
    expensesSubject.add(expenses);
    applyFilters();
  }

  void _fetchCategories() async {
    try {
      List<CategoryModel> categories = await _firebaseService.getCategories();
      category.add(categories);
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }

  void applyFilters() {
    List<ExpanseIncomeModel> expenses = expensesSubject.value;

    final amountRange = amountRangeSubject.valueOrNull;
    final dateRange = dateRangeSubject.valueOrNull;
    final category = selectedCategory.valueOrNull?.name;
    final selectedDate = selectedDateSubject.valueOrNull;

    expenses = expenses.where((expense) {
      bool matchesAmountRange = true;
      bool matchesDateRange = true;
      bool matchesCategory = true;

      if (amountRange != null) {
        matchesAmountRange = expense.payment >= amountRange.start && expense.payment <= amountRange.end;
      }

      if (dateRange != null) {
        DateTime expenseDate = DateTime.parse(expense.date);
        matchesDateRange = expenseDate.isAfter(dateRange.start.subtract(const Duration(days: 1))) &&
            expenseDate.isBefore(dateRange.end.add(const Duration(days: 1)));
      }

      if (category != null) {
        String categoryID = expense.categoryId;
        matchesCategory = categoryDetails[categoryID]?['name'] == category;
      }

      // if (selectedDate != null) {
      //   DateTime expenseDate = DateTime.parse(expense.date);
      //   matchesDateRange = expenseDate.year == selectedDate.year &&
      //       expenseDate.month == selectedDate.month &&
      //       expenseDate.day == selectedDate.day;
      // }

      return matchesAmountRange && matchesDateRange && matchesCategory;
    }).toList();

    if (selectedDate != null) {
      selectedDateExpensesSubject.add(expenses);
    } else {
      expensesSubject.add(expenses);
    }
  }

  // void clearFiltersAndSorts() {
  //   amountRangeSubject.add(const RangeValues(0, 100000));
  //   dateRangeSubject.add(DateTimeRange(start: DateTime(1900), end: DateTime.now()));
  //   selectedCategory.add(null);
  //   selectedDateSubject.add(null);
  //   fetchExpenses();
  // }

  void fetchCategoryDetails() async {
    final snapshot = await FirebaseFirestore.instance.collection('categories').get();
    for (var doc in snapshot.docs) {
      categoryDetails[doc.id] = {
        'name': doc['name'],
        'icon': doc['icon'],
      };
    }
  }

  void generateDatesForCurrentMonth() {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

    final dates = List<DateTime>.generate(
      lastDayOfMonth.day,
      (index) => firstDayOfMonth.add(Duration(days: index)),
    );

    datesSubject.add(dates);
  }

  void selectDate(DateTime? date) {
    selectedDateSubject.add(date);
    // if (date == null) {
    //   fetchExpenses();
    // } else {
    //   fetchExpensesForDate(date);
    // }
  }

  void selectCategory(String? categoryId) {
    selectedCategorySubject.add(categoryId);
    fetchExpenses();
  }

  void setAmountRange(RangeValues rangeValues) {
    amountRangeSubject.add(rangeValues);
  }

  void setDateRange(DateTimeRange dateRange) {
    dateRangeSubject.add(dateRange);
  }

  @override
  void dispose() {
    expensesSubject.close();
    datesSubject.close();
    selectedDateSubject.close();
    selectionSubject.close();
    selectedCategorySubject.close();
    amountRangeSubject.close();
    dateRangeSubject.close();
  }
}
