import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expanse_mate_demo_app/base/base_bloc.dart';
import 'package:expanse_mate_demo_app/firebase_services/firebase_services.dart';
import 'package:expanse_mate_demo_app/model/category_model.dart';
import 'package:expanse_mate_demo_app/model/expanse_income_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';

enum Selection { sort, filter }

enum SortCriteria { none, amount, dateRange, category }

class ActivityBloc extends BaseBloc {
  final _firebaseService = FirebaseServices();
  final expensesSubject = BehaviorSubject<List<ExpanseIncomeModel>>();
  final datesSubject = BehaviorSubject<List<DateTime>>();
  final selectedDateSubject = BehaviorSubject<DateTime?>();
  final selectionSubject = BehaviorSubject<Selection>();
  final amountRangeSubject = BehaviorSubject<RangeValues>();
  final dateRangeSubject = BehaviorSubject<DateTimeRange>();
  final selectedDateExpensesSubject = BehaviorSubject<List<ExpanseIncomeModel>>();

  final categoryDetails = <String, Map<String, String>>{};

  final BehaviorSubject<List<CategoryModel>?> category = BehaviorSubject<List<CategoryModel>?>();

  final sortCriteriaController = BehaviorSubject<SortCriteria>();
  final BehaviorSubject<CategoryModel?> selectedCategorySubject = BehaviorSubject.seeded(null);

  ActivityBloc() {
    fetchCategoryDetails();
    _fetchCategories();
  }

  void setSortCriteria(SortCriteria criteria) {
    sortCriteriaController.add(criteria);
  }

  void fetchSortedItems() {
    final currentCriteria = sortCriteriaController.valueOrNull;
    List<ExpanseIncomeModel> items = expensesSubject.value;

    switch (currentCriteria) {
      case SortCriteria.amount:
        items.sort((a, b) => a.payment.compareTo(b.payment));
        break;
      case SortCriteria.dateRange:
        items.sort((a, b) => a.date.compareTo(b.date));
        break;
      case SortCriteria.category:
        items.sort((a, b) => b.categoryId.compareTo(a.categoryId));
        break;
      default:
        break;
    }

    expensesSubject.add(items);
  }

  Future<void> fetchExpenses() async {
    final snapshot = await FirebaseFirestore.instance.collection('expanse_income').get();
    final expenses = snapshot.docs.map((doc) => ExpanseIncomeModel.fromDocument(doc)).toList();
    expensesSubject.add(expenses);
  }

  void _fetchCategories() async {
    try {
      List<CategoryModel> categories = await _firebaseService.getCategories();
      category.add(categories);
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }

  // void applyFilters() {
  //   List<ExpanseIncomeModel> expenses = expensesSubject.value;
  //
  //   final amountRange = amountRangeSubject.valueOrNull;
  //   final dateRange = dateRangeSubject.valueOrNull;
  //   final category = selectedCategory.valueOrNull?.name;
  //
  //   expenses = expenses.where((expense) {
  //     bool matchesAmountRange = true;
  //     bool matchesDateRange = true;
  //     bool matchesCategory = true;
  //
  //     if (amountRange != null) {
  //       matchesAmountRange = expense.payment >= amountRange.start && expense.payment <= amountRange.end;
  //     }
  //
  //     if (dateRange != null) {
  //       DateTime expenseDate = DateTime.parse(expense.date);
  //       matchesDateRange = expenseDate.isAfter(dateRange.start.subtract(const Duration(days: 1))) &&
  //           expenseDate.isBefore(dateRange.end.add(const Duration(days: 1)));
  //     }
  //
  //     if (category != null) {
  //       String categoryID = expense.categoryId;
  //       matchesCategory = categoryDetails[categoryID]?['name'] == category;
  //     }
  //
  //     return matchesAmountRange && matchesDateRange && matchesCategory;
  //   }).toList();
  //
  //   expensesSubject.add(expenses);
  // }

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

  void generateDatesForPreviousYears() {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year - 1, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
    var date = lastDayOfMonth.difference(firstDayOfMonth).inDays;

    final dates = List<DateTime>.generate(
      date,
      (index) => firstDayOfMonth.add(Duration(days: index)),
    );

    datesSubject.add(dates);
  }

  void selectDate(DateTime? date) {
    selectedDateSubject.add(date);
    if (date != null) {
      final filteredExpenses = expensesSubject.value.where((expense) {
        final expenseDate = DateTime.parse(expense.date);
        return expenseDate.year == date.year &&
            expenseDate.month == date.month &&
            expenseDate.day == date.day;
      }).toList();
      selectedDateExpensesSubject.add(filteredExpenses);
    } else {
      selectedDateExpensesSubject.add(expensesSubject.value);
    }
  }

  void setAmountRange(RangeValues range) {
    amountRangeSubject.add(range);
    applyFilters();
  }

  void applyFilters() {
    List<ExpanseIncomeModel> expenses = expensesSubject.value;
    RangeValues? amountRange = amountRangeSubject.valueOrNull;
    DateTimeRange? dateRange = dateRangeSubject.valueOrNull;
    CategoryModel? selectedCategory = selectedCategorySubject.valueOrNull;

    List<ExpanseIncomeModel> filteredExpenses = expenses.where((expense) {
      bool matchesAmountRange = amountRange == null ||
          (expense.payment >= amountRange.start && expense.payment <= amountRange.end);

      DateTime expenseDate = DateTime.parse(expense.date);
      bool matchesDateRange = dateRange == null ||
          // (expenseDate.isAfter(dateRange.start) && expenseDate.isBefore(dateRange.end)
          (expenseDate.difference(dateRange.start).inDays >= 0 &&
              expenseDate.difference(dateRange.end).inDays <= 0);
      // );

      bool matchesCategory =
          selectedCategory == null || expense.categoryId == selectedCategory.categoryID;

      return matchesAmountRange && matchesDateRange && matchesCategory;
    }).toList();

    // If any filter is applied, show filtered data; otherwise, show all data
    List<ExpanseIncomeModel> finalExpenses = filteredExpenses.isNotEmpty ? filteredExpenses : expenses;

    expensesSubject.add(finalExpenses);
  }

  // void applyFilters() {
  //   List<ExpanseIncomeModel> expenses = expensesSubject.value;
  //   RangeValues? amountRange = amountRangeSubject.valueOrNull;
  //   DateTimeRange? dateRange = dateRangeSubject.valueOrNull;
  //   CategoryModel? selectedCategory = selectedCategorySubject.valueOrNull;
  //
  //   List<ExpanseIncomeModel> filteredExpenses = expenses.where((expense) {
  //     bool matchesAmountRange = amountRange == null ||
  //         (expense.payment >= amountRange.start && expense.payment <= amountRange.end);
  //
  //     DateTime expenseDate = DateTime.parse(expense.date);
  //     bool matchesDateRange = true;
  //
  //     if (dateRange != null) {
  //       final duration = dateRange.end.difference(dateRange.start).inDays;
  //
  //       if (duration == 1) {
  //         // Show only the first date's data if the range is exactly two days (e.g., 8th Aug to 9th Aug)
  //         matchesDateRange = expenseDate.isAtSameMomentAs(dateRange.start);
  //       } else {
  //         // Show data for both start and end dates if the range is longer
  //         matchesDateRange =
  //             (expenseDate.isAtSameMomentAs(dateRange.start) || expenseDate.isAfter(dateRange.start)) &&
  //                 (expenseDate.isAtSameMomentAs(dateRange.end) || expenseDate.isBefore(dateRange.end));
  //       }
  //     }
  //
  //     bool matchesCategory =
  //         selectedCategory == null || expense.categoryId == selectedCategory.categoryID;
  //
  //     return matchesAmountRange && matchesDateRange && matchesCategory;
  //   }).toList();
  //
  //   // If any filter is applied, show filtered data; otherwise, show all data
  //   List<ExpanseIncomeModel> finalExpenses = filteredExpenses.isNotEmpty ? filteredExpenses : expenses;
  //
  //   expensesSubject.add(finalExpenses);
  // }

  // void applyFilters() {
  //   List<ExpanseIncomeModel> expenses = expensesSubject.value;
  //   RangeValues? amountRange = amountRangeSubject.valueOrNull;
  //   DateTimeRange? dateRange = dateRangeSubject.valueOrNull;
  //   CategoryModel? selectedCategory = selectedCategorySubject.valueOrNull;
  //
  //   List<ExpanseIncomeModel> filteredExpenses = expenses.where((expense) {
  //     // Amount range check
  //     bool matchesAmountRange = amountRange == null ||
  //         (expense.payment >= amountRange.start && expense.payment <= amountRange.end);
  //
  //     // Date range check
  //     DateTime expenseDate = DateTime.parse(expense.date);
  //     bool matchesDateRange = true;
  //
  //     if (dateRange != null) {
  //       // If the date range is exactly two days (i.e., duration == 1)
  //       if (dateRange.end.difference(dateRange.start).inDays == 1) {
  //         matchesDateRange = expenseDate.isAtSameMomentAs(dateRange.start) ||
  //             expenseDate.isAtSameMomentAs(dateRange.end);
  //       } else {
  //         // For any other duration, include all dates within the range, inclusive
  //         matchesDateRange =
  //             (expenseDate.isAtSameMomentAs(dateRange.start) || expenseDate.isAfter(dateRange.start)) &&
  //                 (expenseDate.isAtSameMomentAs(dateRange.end) || expenseDate.isBefore(dateRange.end));
  //       }
  //     }
  //
  //     // Category check
  //     bool matchesCategory =
  //         selectedCategory == null || expense.categoryId == selectedCategory.categoryID;
  //
  //     return matchesAmountRange && matchesDateRange && matchesCategory;
  //   }).toList();
  //
  //   // If any filter is applied, show filtered data; otherwise, show all data
  //   List<ExpanseIncomeModel> finalExpenses = filteredExpenses.isNotEmpty ? filteredExpenses : expenses;
  //
  //   expensesSubject.add(finalExpenses);
  // }

  void setDateRange(DateTimeRange dateRange) {
    dateRangeSubject.add(dateRange);
  }

  String formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inDays == 0) {
      return DateFormat("Today, HH:mm").format(dateTime);
    } else if (diff.inDays == 1) {
      return DateFormat("Yesterday, HH:mm").format(dateTime);
    } else {
      return DateFormat("d MMM, HH:mm").format(dateTime);
    }
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
