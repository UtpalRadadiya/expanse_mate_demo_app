import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expanse_mate_demo_app/base/base_bloc.dart';
import 'package:expanse_mate_demo_app/model/expanse_income_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';

class HomePageBloc extends BaseBloc {
  var showIncome = BehaviorSubject<bool>.seeded(false);
  var seeMore = BehaviorSubject<bool>.seeded(false);

  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  var expenses = BehaviorSubject<List<ExpanseIncomeModel>>.seeded([]);
  Map<String, Map<String, String>> categoryDetails = {};

  var categoryWiseData = BehaviorSubject<List<BarChartGroupData>>.seeded([]);
  var maxExpenseIncomeValue = BehaviorSubject<num>.seeded(0);
  var maxPayment = BehaviorSubject<num>.seeded(1);
  var lineChartData = BehaviorSubject<List<FlSpot>>.seeded([]);
  // var barChartData = BehaviorSubject<List<BarChartGroupData>>.seeded([]);

  void toggleSeeMore() {
    seeMore.add(!seeMore.value);
    fetchExpenses(limit: seeMore.value ? null : 3);
  }

  Future<void> fetchMonthlyData() async {
    try {
      DateTime now = DateTime.now();
      DateTime firstDayOfCurrentMonth = DateTime(now.year, now.month, 1);

      QuerySnapshot snapshot = await _fireStore
          .collection('expanse_income')
          .where('date', isGreaterThanOrEqualTo: firstDayOfCurrentMonth.toIso8601String())
          .where('date', isLessThanOrEqualTo: now.toIso8601String())
          .get();

      List<ExpanseIncomeModel> fetchedData =
          snapshot.docs.map((doc) => ExpanseIncomeModel.fromDocument(doc)).toList();

      Map<String, double> dailyTotals = {};
      double maxPaymentValue = 0;

      // Initialize daily totals for each day in the month
      for (int i = 0; i <= now.day - 1; i++) {
        String dateKey = DateFormat('yyyy-MM-dd').format(firstDayOfCurrentMonth.add(Duration(days: i)));
        dailyTotals[dateKey] = 0;
      }

      // Calculate totals
      for (var data in fetchedData) {
        String type = data.type;
        double payment = data.payment.toDouble();

        if (showIncome.value && type != 'income') continue;
        if (!showIncome.value && type != 'expense') continue;

        String dateKey = DateFormat('yyyy-MM-dd').format(DateTime.parse(data.date));
        dailyTotals[dateKey] = dailyTotals[dateKey]! + payment;

        if (dailyTotals[dateKey]! > maxPaymentValue) {
          maxPaymentValue = dailyTotals[dateKey]!;
        }
      }

      // Create FlSpot list for LineChart
      List<FlSpot> spots = [];
      int index = 0;
      dailyTotals.forEach((date, total) {
        spots.add(FlSpot(index.toDouble(), total));
        index++;
      });

      maxPayment.add(maxPaymentValue);
      lineChartData.add(spots);
    } catch (e) {
      print('Error fetching monthly data: $e');
    }
  }

  Future<void> fetchExpenses({int? limit}) async {
    try {
      Query query = _fireStore.collection('expanse_income').where('type', isEqualTo: 'expense');

      // Fetch all expenses
      QuerySnapshot querySnapshot = await query.get();
      List<ExpanseIncomeModel> allExpenses =
          querySnapshot.docs.map((doc) => ExpanseIncomeModel.fromDocument(doc)).toList();

      // Get the current month's expenses
      DateTime now = DateTime.now();
      DateTime startOfMonth = DateTime(now.year, now.month, 1);
      DateTime endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

      List<ExpanseIncomeModel> currentMonthExpenses = allExpenses.where((expense) {
        DateTime expenseDate = DateTime.parse(expense.date);
        return expenseDate.isAfter(startOfMonth) && expenseDate.isBefore(endOfMonth);
      }).toList();

      // Sort expenses in ascending order by date
      currentMonthExpenses.sort((a, b) => DateTime.parse(b.date).compareTo(DateTime.parse(a.date)));

      if (limit != null && currentMonthExpenses.length > limit) {
        expenses.add(currentMonthExpenses.take(limit).toList());
      } else {
        expenses.add(currentMonthExpenses);
      }
    } catch (e) {
      print('Error fetching expenses: $e');
    }
  }

  Future<void> fetchCategoryDetails() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('categories').get();
      Map<String, Map<String, String>> categoryMap = {};
      for (var doc in snapshot.docs) {
        categoryMap[doc.id] = {
          'name': doc['name'],
          'icon': doc['icon'],
        };
      }
      categoryDetails = categoryMap;
    } catch (e) {
      print("Error fetching categories: $e");
    }
  }

  Future<Map<String, num>> fetchMonthlyTotals() async {
    Map<String, num> totals = {'income': 0, 'expense': 0};

    try {
      DateTime now = DateTime.now();
      DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('expanse_income')
          .where('date', isGreaterThanOrEqualTo: firstDayOfMonth.toIso8601String())
          .get();

      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        String type = data['type'];
        num payment = data['payment'];

        if (type == 'income') {
          totals['income'] = totals['income']! + payment;
        } else if (type == 'expense') {
          totals['expense'] = totals['expense']! + payment;
        }
      }
    } catch (e) {
      print("Error fetching monthly totals: $e");
    }

    return totals;
  }

  ///Working
  // Future<void> fetchCategoryWiseData() async {
  //   try {
  //     // Fetch all categories first to ensure all are included
  //     QuerySnapshot categorySnapshot = await _fireStore.collection('categories').get();
  //     List<String> categoryIds = categorySnapshot.docs.map((doc) => doc.id).toList();
  //
  //     QuerySnapshot snapshot = await _fireStore.collection('expanse_income').get();
  //     Map<String, Map<String, num>> aggregatedData = {
  //       for (var id in categoryIds) id: {'income': 0, 'expense': 0}
  //     };
  //
  //     num maxValue = 0;
  //
  //     for (var doc in snapshot.docs) {
  //       var data = doc.data() as Map<String, dynamic>;
  //       String categoryId = data['category'];
  //       String type = data['type'];
  //       num payment = data['payment'];
  //
  //       if (!aggregatedData.containsKey(categoryId)) {
  //         aggregatedData[categoryId] = {'income': 0, 'expense': 0};
  //       }
  //       if (type == 'income') {
  //         aggregatedData[categoryId]!['income'] = aggregatedData[categoryId]!['income']! + payment;
  //       } else if (type == 'expense') {
  //         aggregatedData[categoryId]!['expense'] = aggregatedData[categoryId]!['expense']! + payment;
  //       }
  //
  //       if (payment > maxValue) {
  //         maxValue = payment;
  //       }
  //     }
  //
  //     maxExpenseIncomeValue.add(maxValue);
  //
  //     List<BarChartGroupData> barGroups = [];
  //     aggregatedData.forEach((categoryId, amounts) {
  //       int categoryIndex = barGroups.length;
  //       barGroups.add(
  //         BarChartGroupData(
  //           x: categoryIndex,
  //           barRods: [
  //             BarChartRodData(
  //               toY: amounts['income']?.toDouble() ?? 0.0,
  //               color: Colors.green,
  //               width: 5,
  //             ),
  //             BarChartRodData(
  //               toY: amounts['expense']?.toDouble() ?? 0.0,
  //               color: Colors.red,
  //               width: 5,
  //             ),
  //           ],
  //         ),
  //       );
  //     });
  //
  //     categoryWiseData.add(barGroups);
  //   } catch (e) {
  //     print("Error fetching category-wise data: $e");
  //   }
  // }

  Future<void> fetchCategoryWiseData() async {
    try {
      // Fetch all categories first to ensure all are included
      QuerySnapshot categorySnapshot = await _fireStore.collection('categories').get();
      List<String> categoryIds = categorySnapshot.docs.map((doc) => doc.id).toList();

      QuerySnapshot snapshot = await _fireStore.collection('expanse_income').get();
      Map<String, Map<String, num>> aggregatedData = {
        for (var id in categoryIds) id: {'income': 0, 'expense': 0}
      };

      num totalIncome = 0;
      num totalExpense = 0;

      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        String categoryId = data['category'];
        String type = data['type'];
        num payment = data['payment'];

        if (!aggregatedData.containsKey(categoryId)) {
          aggregatedData[categoryId] = {'income': 0, 'expense': 0};
        }
        if (type == 'income') {
          aggregatedData[categoryId]!['income'] = aggregatedData[categoryId]!['income']! + payment;
          totalIncome += payment;
        } else if (type == 'expense') {
          aggregatedData[categoryId]!['expense'] = aggregatedData[categoryId]!['expense']! + payment;
          totalExpense += payment;
        }
      }

      num maxValue = totalIncome > totalExpense ? totalIncome : totalExpense;
      maxExpenseIncomeValue.add(maxValue);

      List<BarChartGroupData> barGroups = [];
      aggregatedData.forEach((categoryId, amounts) {
        int categoryIndex = barGroups.length;
        barGroups.add(
          BarChartGroupData(
            x: categoryIndex,
            barRods: [
              BarChartRodData(
                toY: amounts['income']?.toDouble() ?? 0.0,
                color: Colors.green,
                width: 5,
              ),
              BarChartRodData(
                toY: amounts['expense']?.toDouble() ?? 0.0,
                color: Colors.red,
                width: 5,
              ),
            ],
          ),
        );
      });

      categoryWiseData.add(barGroups);
    } catch (e) {
      print("Error fetching category-wise data: $e");
    }
  }

  String formatDate(String transactionDate) {
    DateTime date = DateTime.parse(transactionDate);
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime yesterday = today.subtract(const Duration(days: 1));

    if (date.isAtSameMomentAs(today)) {
      return 'Today';
    } else if (date.isAtSameMomentAs(yesterday)) {
      return 'Yesterday';
    } else {
      return DateFormat('dd MMM, yyyy').format(date);
    }
  }

  String formattedDate(DateTime dateTime) {
    return DateFormat('MMM, yyyy').format(dateTime);
  }

  @override
  void dispose() {
    seeMore.close();
    expenses.close();
    categoryWiseData.close();
    maxExpenseIncomeValue.close();
    super.dispose();
  }
}
