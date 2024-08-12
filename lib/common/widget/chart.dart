import 'package:expanse_mate_demo_app/common/item_list/graph_items_list.dart';
import 'package:expanse_mate_demo_app/profile/bloc/home_page_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomChart extends StatefulWidget {
  CustomChart({super.key, this.showIncome, this.homePageBloc});
  bool? showIncome;
  HomePageBloc? homePageBloc;

  @override
  State<CustomChart> createState() => _CustomChartState();
}

class _CustomChartState extends State<CustomChart> {
  double interval = 0;
  GraphList graphList = GraphList();

  @override
  void initState() {
    fetchData();
    setInterval();
    super.initState();
  }

  Future<void> fetchData() async {
    await graphList.fetchDataFromFirebase();
    setState(() {});
  }

  void setInterval() {
    if (graphList.maxAmount < 1000) {
      interval = 100;
    } else {
      interval = ((graphList.maxAmount / 1000).ceil()) * 100;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: MediaQuery.sizeOf(context).width,
        child: ClipRRect(
          child: graphList.expenseDateAndAmountList.isNotEmpty ||
                  graphList.incomeDateAndAmountList.isNotEmpty
              ? StreamBuilder<List<FlSpot>>(
                  stream: widget.homePageBloc?.lineChartData,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: CircularProgressIndicator(color: Color(0xff4EBDA4)));
                    }

                    return LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: true,
                          horizontalInterval: (widget.homePageBloc?.maxPayment.value ?? 0) / 10,
                          getDrawingHorizontalLine: (value) {
                            return const FlLine(
                              color: Colors.grey,
                              strokeWidth: 1,
                            );
                          },
                          getDrawingVerticalLine: (value) {
                            return const FlLine(
                              color: Colors.grey,
                              strokeWidth: 1,
                            );
                          },
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              getTitlesWidget: (value, meta) {
                                DateTime date = DateTime.now()
                                    .subtract(Duration(days: (DateTime.now().day - 1) - value.toInt()));
                                return SideTitleWidget(
                                  space: 10,
                                  axisSide: meta.axisSide,
                                  child: Text(
                                    DateFormat('dd MMM').format(date),
                                    style: const TextStyle(fontSize: 8),
                                  ),
                                );
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: (widget.homePageBloc?.maxPayment.value ?? 0) / 5,
                              getTitlesWidget: (value, meta) {
                                return Text(value.toInt().toString());
                              },
                              reservedSize: 42,
                            ),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: false,
                            ),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: true, reservedSize: 10),
                          ),
                        ),
                        borderData: FlBorderData(
                          border: const Border(
                              bottom: BorderSide.none,
                              left: BorderSide.none,
                              top: BorderSide.none,
                              right: BorderSide(width: 1, color: Colors.grey)),
                          show: true,
                        ),
                        minX: 0,
                        maxX: snapshot.data!.length.toDouble(),
                        minY: 0,
                        maxY: widget.homePageBloc!.maxPayment.value.toDouble(),
                        lineBarsData: [
                          LineChartBarData(
                            spots: snapshot.data!
                                .map((spot) => FlSpot(spot.x, spot.y < 0 ? 0 : spot.y))
                                .toList(),
                            isCurved: true,
                            color: (widget.homePageBloc?.showIncome.value ?? false)
                                ? const Color(0xff4EBDA4)
                                : Colors.red,
                            barWidth: 2,
                            dotData: FlDotData(
                              getDotPainter: (p0, p1, p2, p3) {
                                return FlDotCirclePainter(
                                  radius: 4,
                                  color: (widget.homePageBloc?.showIncome.value ?? false)
                                      ? const Color(0xff4EBDA4)
                                      : Colors.red,
                                  strokeWidth: 2,
                                  strokeColor: Colors.white,
                                );
                              },
                              show: true,
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              color: (widget.homePageBloc?.showIncome.value ?? false)
                                  ? const Color(0xff4EBDA4).withOpacity(0.3)
                                  : Colors.red.withOpacity(0.3),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                )
              : const Center(
                  child: CircularProgressIndicator(
                  color: Color(0xff4EBDA4),
                )),
        ),
      ),
    );
  }
}
