import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expanse_mate_demo_app/profile/bloc/home_page_bloc.dart';
import 'package:fl_chart/fl_chart.dart';

class GraphList {
  List<FlSpot> expenseDateAndAmountList = [];
  List<FlSpot> incomeDateAndAmountList = [];
  double maxAmount = 0;
  double maxDate = 0;
  final HomePageBloc _homePageBloc = HomePageBloc();

  // Future<void> fetchDataFromFirebase() async {
  //   try {
  //     FirebaseFirestore fireStore = FirebaseFirestore.instance;
  //     QuerySnapshot querySnapshot = await fireStore.collection('expanse_income').get();
  //
  //     Map<double, double> expenses = {};
  //     Map<double, double> incomes = {};
  //     maxAmount = 0;
  //     maxDate = 0;
  //
  //     for (var doc in querySnapshot.docs) {
  //       var data = doc.data() as Map<String, dynamic>;
  //       try {
  //         double date = DateTime.parse(data['date']).millisecondsSinceEpoch.toDouble();
  //         double payment = data['payment'].toDouble();
  //         String type = data['type'];
  //
  //         if (type == 'expense') {
  //           expenses[date] = (expenses[date] ?? 0) + payment;
  //         } else {
  //           incomes[date] = (incomes[date] ?? 0) + payment;
  //         }
  //
  //         if (payment > maxAmount) {
  //           maxAmount = payment;
  //         }
  //
  //         if (date > maxDate) {
  //           maxDate = date;
  //         }
  //       } catch (e) {
  //         print('Error parsing document: $e');
  //         print('Document data: $data');
  //       }
  //     }
  //
  //     expenseDateAndAmountList = expenses.entries.map((e) => FlSpot(e.key, e.value)).toList();
  //     incomeDateAndAmountList = incomes.entries.map((e) => FlSpot(e.key, e.value)).toList();
  //   } catch (e, s) {
  //     print('Error fetching data from Firebase: $e');
  //     print('Stack trace: $s');
  //   }
  // }

  Future<void> fetchDataFromFirebase() async {
    FirebaseFirestore fireStore = FirebaseFirestore.instance;

    QuerySnapshot expenseSnapshot =
        await fireStore.collection('expanse_income').where('type', isEqualTo: 'expense').get();

    expenseDateAndAmountList = processSnapshot(expenseSnapshot);

    // Fetch incomes
    QuerySnapshot incomeSnapshot =
        await fireStore.collection('expanse_income').where('type', isEqualTo: 'income').get();

    incomeDateAndAmountList = processSnapshot(incomeSnapshot);

    calculateMaxAmount(_homePageBloc.showIncome.value);
  }

  List<FlSpot> processSnapshot(QuerySnapshot snapshot) {
    List<FlSpot> spots = [];
    for (var doc in snapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      double date = DateTime.parse(data['date']).day.toDouble();
      double amount = data['payment'].toDouble();
      spots.add(FlSpot(date, amount));
    }
    return spots;
  }

  // void calculateMaxAmount() {
  //   List<double> allAmounts = [
  //     ...expenseDateAndAmountList.map((spot) => spot.y),
  //     ...incomeDateAndAmountList.map((spot) => spot.y)
  //   ];
  //   maxAmount = allAmounts.reduce((value, element) => value > element ? value : element);
  //
  //   List<double> allDates = [
  //     ...expenseDateAndAmountList.map((spot) => spot.x),
  //     ...incomeDateAndAmountList.map((spot) => spot.x)
  //   ];
  //
  //   maxDate =
  //       allDates.isNotEmpty ? allDates.reduce((value, element) => value > element ? value : element) : 0;
  // }

  void calculateMaxAmount(bool showIncome) {
    List<double> amounts;
    List<double> dates;

    if (showIncome) {
      amounts = incomeDateAndAmountList.map((spot) => spot.y).toList();
      dates = incomeDateAndAmountList.map((spot) => spot.x).toList();
    } else {
      amounts = expenseDateAndAmountList.map((spot) => spot.y).toList();
      dates = expenseDateAndAmountList.map((spot) => spot.x).toList();
    }

    maxAmount =
        amounts.isNotEmpty ? amounts.reduce((value, element) => value > element ? value : element) : 0;
    maxDate = dates.isNotEmpty ? dates.reduce((value, element) => value > element ? value : element) : 0;
  }

  static const List<String> months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];
}
