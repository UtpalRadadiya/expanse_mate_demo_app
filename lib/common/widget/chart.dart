import 'package:expanse_mate_demo_app/common/item_list/graph_items_list.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CustomChart extends StatefulWidget {
  CustomChart({super.key, this.showIncome});
  bool? showIncome;

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
    return ClipRRect(
      child:
          graphList.expenseDateAndAmountList.isNotEmpty || graphList.incomeDateAndAmountList.isNotEmpty
              ? LineChart(mainData())
              : const Center(
                  child: CircularProgressIndicator(
                  color: Color(0xff4EBDA4),
                )),
    );
  }

  LineChartData mainData() {
    Color lineColor = (widget.showIncome ?? false) ? const Color(0xff4EBDA4) : Colors.red;

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: interval,
        verticalInterval: 1,
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
            reservedSize: 20,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: graphList.maxAmount / 5,
            // getTitlesWidget: leftTitleWidgets,
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
          sideTitles: SideTitles(showTitles: false),
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
      minX: 1,
      maxX: graphList.maxDate,
      minY: 0,
      maxY: graphList.maxAmount,
      // minX: spotsToShow.first.x,
      // maxX: spotsToShow.last.x,
      // minX: 1,
      // maxX: graphList.maxDate,
      // maxX: GraphList.dateList.length.toDouble(),
      // minY: 0,
      // maxY: graphList.maxAmount.toDouble(),
      // maxY: graphList.maxAmount.toDouble(),
      // lineBarsData: [
      //   LineChartBarData(
      //     // spots: graphList.dateAndAmountList,
      //     spots: spotsToShow,
      //     isCurved: true,
      //     color: lineColor,
      //     barWidth: 2,
      //     dotData: FlDotData(
      //       getDotPainter: (p0, p1, p2, p3) {
      //         return FlDotCirclePainter(
      //           radius: 4,
      //           color: lineColor,
      //           strokeWidth: 2,
      //           strokeColor: Colors.white,
      //         );
      //       },
      //       show: true,
      //     ),
      //     belowBarData: BarAreaData(
      //       show: true,
      //       color: lineColor.withOpacity(0.3),
      //     ),
      //   ),
      // ],
      lineBarsData: [
        LineChartBarData(
          spots: graphList.expenseDateAndAmountList,
          color: lineColor,
          barWidth: 2,
          dotData: FlDotData(
            getDotPainter: (p0, p1, p2, p3) {
              return FlDotCirclePainter(
                radius: 4,
                color: lineColor,
                strokeWidth: 2,
                strokeColor: Colors.white,
              );
            },
            show: true,
          ),
          belowBarData: BarAreaData(
            show: true,
            color: lineColor.withOpacity(0.3),
          ),
        ),
        LineChartBarData(
          spots: graphList.incomeDateAndAmountList,
          color: lineColor,
          barWidth: 2,
          dotData: FlDotData(
            getDotPainter: (p0, p1, p2, p3) {
              return FlDotCirclePainter(
                radius: 4,
                color: lineColor,
                strokeWidth: 2,
                strokeColor: Colors.white,
              );
            },
            show: true,
          ),
          belowBarData: BarAreaData(
            show: true,
            color: lineColor.withOpacity(0.3),
          ),
        ),
      ],
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    int monthIndex = DateTime.now().month - 1;
    String currentMonth = GraphList.months[monthIndex];

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(
        '${value.toInt()} $currentMonth',
        style: const TextStyle(fontSize: 11),
      ),
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(
        value == 0 ? '0' : (value % 100 == 0 ? value.toInt().toString() : ""),
        // value == 0 ? '0' : (value % interval == 0 ? value.toInt().toString() : ""),
        style: const TextStyle(fontSize: 11),
      ),
    );
  }
}
