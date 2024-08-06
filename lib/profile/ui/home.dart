import 'package:expanse_mate_demo_app/common/consts/app_image.dart';
import 'package:expanse_mate_demo_app/common/consts/app_routes.dart';
import 'package:expanse_mate_demo_app/common/helper/route/route_manager.dart';
import 'package:expanse_mate_demo_app/common/item_list/graph_items_list.dart';
import 'package:expanse_mate_demo_app/common/widget/chart.dart';
import 'package:expanse_mate_demo_app/model/expanse_income_model.dart';
import 'package:expanse_mate_demo_app/profile/bloc/home_page_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomePageBloc _homePageBloc = HomePageBloc();
  GraphList graphList = GraphList();

  @override
  void initState() {
    super.initState();
    _homePageBloc.fetchExpenses(limit: 3);
    _homePageBloc.fetchCategoryDetails();
    _homePageBloc.fetchCategoryWiseData();
  }

  @override
  void dispose() {
    _homePageBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Column(
              children: [
                Container(
                  height: 50,
                  color: const Color(0xff4EBDA4),
                ),
              ],
            ),
            Column(
              children: [
                Container(
                  height: 100,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white,
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.grey,
                        blurRadius: 10.0,
                      ), //BoxShadow
                    ],
                  ),
                  child: FutureBuilder<Map<String, num>>(
                      future: _homePageBloc.fetchMonthlyTotals(),
                      builder: (context, monthlySnapshot) {
                        Map<String, num> totals = monthlySnapshot.data ?? {'income': 0, 'expense': 0};
                        num incomeTotal = totals['income']!;
                        num expenseTotal = totals['expense']!;

                        return Column(
                          children: [
                            Align(
                              alignment: Alignment.centerRight,
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 5),
                                decoration: BoxDecoration(
                                  color: const Color(0xffF0F0F0),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  _homePageBloc.formattedDate(DateTime.now()),
                                  style: const TextStyle(
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Available Fund',
                                      style: TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(width: 3),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '₹$incomeTotal',
                                          style: const TextStyle(
                                            fontSize: 24,
                                            color: Color(0xff4EBDA4),
                                          ),
                                        ),
                                        const SizedBox(width: 3),
                                        InkWell(
                                          onTap: () {
                                            AppRouteManager.pushNamed(AppRoutes.expanseProfilePage,
                                                arguments: {
                                                  'index': 1,
                                                });
                                          },
                                          child: Image.asset(
                                            AppImage.icEdit.pathPNG(),
                                            color: const Color(0xff4EBDA4),
                                            height: 16.73,
                                            width: 16.73,
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Total Expenses',
                                      style: TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      '₹${expenseTotal.toString()}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        );
                      }),
                ),
                const SizedBox(height: 16),
                Container(
                    height: 300,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.white,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.grey,
                          blurRadius: 10.0,
                        ),
                      ],
                    ),
                    child: StreamBuilder<bool>(
                        stream: _homePageBloc.showIncome,
                        // initialData: _homePageBloc.showIncome.value,
                        builder: (context, snapshot) {
                          return Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Balance Trend',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Switch(
                                    splashRadius: 0,
                                    value: _homePageBloc.showIncome.value,
                                    onChanged: (value) {
                                      _homePageBloc.showIncome.add(value);
                                    },
                                    activeColor: const Color(0xff4EBDA4),
                                    activeThumbImage: const NetworkImage(
                                      'https://e7.pngegg.com/pngimages/703/8/png-clipart-businessperson-income-text-service.png',
                                    ),
                                    inactiveThumbImage: const NetworkImage(
                                      'https://media.istockphoto.com/id/1447102380/vector/down-arrow-button-icon-on-red-background-with-shadow.jpg?s=612x612&w=0&k=20&c=tBx_7laKLrrMM7T0T4VAdYjmAuRArJJY07GdfY39apA=',
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 10),
                              Expanded(
                                  child: CustomChart(
                                showIncome: _homePageBloc.showIncome.value,
                              )),
                            ],
                          );
                        })),
                const SizedBox(height: 16),
                StreamBuilder<List<BarChartGroupData>>(
                  stream: _homePageBloc.categoryWiseData,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No data available.'));
                    }

                    return Container(
                      height: 300,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.white,
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.grey,
                            blurRadius: 10.0,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Category wise chart',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Expanded(
                            child: StreamBuilder<num>(
                                stream: _homePageBloc.maxExpenseIncomeValue,
                                builder: (context, maxSnapshot) {
                                  var maxY = maxSnapshot.data?.toDouble() ?? 0.0;

                                  return BarChart(
                                    BarChartData(
                                      barGroups: snapshot.data!,
                                      borderData: FlBorderData(
                                        show: false,
                                      ),
                                      alignment: BarChartAlignment.spaceBetween,
                                      gridData: const FlGridData(drawVerticalLine: false),
                                      barTouchData: BarTouchData(),
                                      minY: 0,
                                      maxY: maxY,
                                      titlesData: FlTitlesData(
                                        bottomTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            reservedSize: 30,
                                            getTitlesWidget: (double value, meta) {
                                              String categoryId = _homePageBloc.categoryDetails.keys
                                                  .elementAt(value.toInt());
                                              return SizedBox(
                                                width: 60,
                                                child: Padding(
                                                  padding: const EdgeInsets.only(right: 10),
                                                  child: Text(
                                                    _homePageBloc.categoryDetails[categoryId]!['name']!,
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(fontSize: 10),
                                                    maxLines: 2,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        leftTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            reservedSize: 40,
                                            getTitlesWidget: (double value, TitleMeta meta) {
                                              return Text(
                                                value.toInt().toString(),
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 10,
                                                ),
                                              );
                                            },
                                            interval: maxY / 5,
                                          ),
                                        ),
                                        topTitles: const AxisTitles(
                                          sideTitles: SideTitles(showTitles: false),
                                        ),
                                        show: true,
                                        rightTitles: const AxisTitles(
                                          sideTitles: SideTitles(showTitles: false),
                                        ),
                                      ),
                                      // gridData: const FlGridData(show: false),
                                    ),
                                  );
                                }),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                StreamBuilder(
                  stream: _homePageBloc.seeMore,
                  builder: (context, snapshot) {
                    return StreamBuilder<List<ExpanseIncomeModel>>(
                        stream: _homePageBloc.expenses,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(child: Text('Error: ${snapshot.error}'));
                          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Center(child: Text('No expenses found.'));
                          }
                          List<ExpanseIncomeModel> expenses = snapshot.data!;

                          return Container(
                            margin: const EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 50),
                            height: _homePageBloc.seeMore.value ? 372 : 272,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Colors.white,
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.grey,
                                  blurRadius: 10.0,
                                ), //BoxShadow
                                //BoxShadow
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(children: [
                                const Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Expenses',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    Icon(Icons.menu)
                                  ],
                                ),
                                const SizedBox(height: 8),
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8),
                                  child: Divider(
                                    height: 0,
                                    color: Colors.grey,
                                    thickness: 0,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        'This Month',
                                        style: TextStyle(fontSize: 12, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  height: _homePageBloc.seeMore.value ? 250 : 150,
                                  child: ListView.builder(
                                    physics: _homePageBloc.seeMore.value
                                        ? const BouncingScrollPhysics()
                                        : const NeverScrollableScrollPhysics(),
                                    itemCount: expenses.length,
                                    padding: EdgeInsets.zero,
                                    itemBuilder: (context, index) {
                                      var expense = expenses[index];
                                      String categoryID = expense.categoryId;
                                      String categoryName =
                                          _homePageBloc.categoryDetails[categoryID]?['name'] ?? '';
                                      String categoryIcon =
                                          _homePageBloc.categoryDetails[categoryID]?['icon'] ?? '';

                                      return Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            color: Colors.red,
                                            padding:
                                                const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
                                            child: Image.network(
                                              categoryIcon,
                                              height: 24,
                                              width: 20,
                                              fit: BoxFit.cover,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                categoryName,
                                                style: const TextStyle(fontSize: 12),
                                              ),
                                              const Text(
                                                'Cash',
                                                style: TextStyle(fontSize: 12, color: Colors.grey),
                                              ),
                                              if (expenses.isNotEmpty)
                                                Text(
                                                  expenses[index].note,
                                                  style:
                                                      const TextStyle(fontSize: 12, color: Colors.grey),
                                                ),
                                            ],
                                          ),
                                          const Spacer(),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Text('₹${expense.payment}',
                                                  style:
                                                      const TextStyle(fontSize: 16, color: Colors.red)),
                                              Text(
                                                _homePageBloc.formatDate(expense.date),
                                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                                              ),
                                            ],
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 8),
                                StreamBuilder<bool>(
                                  stream: _homePageBloc.seeMore,
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) return const SizedBox.shrink();
                                    bool showAll = snapshot.data!;
                                    return Align(
                                      alignment: Alignment.centerRight,
                                      child: GestureDetector(
                                        onTap: () {
                                          _homePageBloc.toggleSeeMore();
                                        },
                                        child: Text(
                                          showAll ? 'See less' : 'See more',
                                          style: const TextStyle(color: Color(0xff4EBDA4)),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ]),
                            ),
                          );
                        });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  AppBar appBar() {
    return AppBar(
      backgroundColor: const Color(0xff4EBDA4),
      centerTitle: false,
      title: const Text(
        'Hello Pals✌️',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          letterSpacing: 0.53,
        ),
      ),
      actions: [
        InkWell(
          onTap: () {},
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(
              Icons.notifications,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
