import 'package:expanse_mate_demo_app/base/base_bloc.dart';
import 'package:expanse_mate_demo_app/base/base_stateful_widget.dart';
import 'package:expanse_mate_demo_app/common/consts/app_image.dart';
import 'package:expanse_mate_demo_app/model/category_model.dart';
import 'package:expanse_mate_demo_app/model/expanse_income_model.dart';
import 'package:expanse_mate_demo_app/profile/bloc/activity_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends BaseState<ActivityPage> {
  final ActivityBloc _activityBloc = ActivityBloc();
  String categoryName = '';
  String categoryIcon = '';
  RangeValues amountRange = const RangeValues(0, 100000);
  DateTimeRange dateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 7)),
    end: DateTime.now(),
  );

  @override
  void initState() {
    super.initState();
    _activityBloc.fetchExpenses();
    _activityBloc.fetchCategoryDetails();
    _activityBloc.generateDatesForCurrentMonth();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: StreamBuilder(
          stream: _activityBloc.selectedDateSubject,
          builder: (context, snapshot) {
            return Column(
              children: [
                dateRow(),
                const SizedBox(height: 20),
                resetButton(),
                const SizedBox(height: 20),
                sortOrFilterRow(),
                const SizedBox(height: 20),
                Expanded(child: expenseList()),
                const SizedBox(height: 20),
              ],
            );
          }),
    );
  }

  Widget resetButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(right: 16),
        child: StreamBuilder<DateTime?>(
          stream: _activityBloc.selectedDateSubject,
          builder: (context, snapshot) {
            bool isDateSelected = snapshot.data != null;
            return isDateSelected
                ? ElevatedButton(
                    onPressed: () {
                      // _activityBloc.clearFiltersAndSorts();
                      // _activityBloc.selectDate(null);
                      // _activityBloc.fetchExpenses();
                      _clearSortAndFilter();
                    },
                    child: const Text('Reset Date'),
                  )
                : const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _activityBloc.dispose();
    super.dispose();
  }

  AppBar appBar() {
    return AppBar(
      centerTitle: false,
      title: const Text(
        'Activity',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          // color: Colors.white,
          letterSpacing: 0.53,
        ),
      ),
      actions: [
        InkWell(
          onTap: () {},
          child: const Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(
              Icons.notifications,
            ),
          ),
        ),
      ],
    );
  }

  Widget dateRow() {
    return StreamBuilder<List<DateTime>>(
      stream: _activityBloc.datesSubject,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<DateTime> dates = snapshot.data!;
          DateTime today = DateTime.now();

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ColoredBox(
              color: const Color(0xffEFEFEF),
              child: Row(
                children: dates.map((date) {
                  bool isFutureDate = date.isAfter(today);
                  return StreamBuilder<DateTime?>(
                      stream: _activityBloc.selectedDateSubject,
                      builder: (context, selectedSnapshot) {
                        bool isSelected = selectedSnapshot.data == date;

                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 26, vertical: 8),
                          child: GestureDetector(
                            onTap: isFutureDate
                                ? null
                                : () {
                                    _activityBloc.selectDate(date);
                                  },
                            child: Text(
                              DateFormat('dd MMM').format(date),
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.red
                                    : isFutureDate
                                        ? Colors.grey
                                        : Colors.black,
                              ),
                            ),
                          ),
                        );
                      });
                }).toList(),
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  // Widget dateRow() {
  //   return StreamBuilder<List<DateTime>>(
  //     stream: _activityBloc.datesSubject,
  //     builder: (context, snapshot) {
  //       if (snapshot.hasData) {
  //         List<DateTime> dates = snapshot.data!;
  //         DateTime today = DateTime.now();
  //
  //         return SingleChildScrollView(
  //           scrollDirection: Axis.horizontal,
  //           child: ColoredBox(
  //             color: const Color(0xffEFEFEF),
  //             child: Row(
  //               children: [
  //                 Container(
  //                   margin: const EdgeInsets.symmetric(horizontal: 26, vertical: 8),
  //                   child: GestureDetector(
  //                     onTap: () {
  //                       _activityBloc.selectDate(null);
  //                     },
  //                     child: const Text(
  //                       'Reset Date',
  //                       style: TextStyle(
  //                         color: Colors.red,
  //                         fontWeight: FontWeight.bold,
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //                 ...dates.map((date) {
  //                   bool isFutureDate = date.isAfter(today);
  //                   return StreamBuilder<DateTime?>(
  //                     stream: _activityBloc.selectedDateSubject,
  //                     builder: (context, selectedSnapshot) {
  //                       bool isSelected = selectedSnapshot.data == date;
  //
  //                       return Container(
  //                         margin: const EdgeInsets.symmetric(horizontal: 26, vertical: 8),
  //                         child: GestureDetector(
  //                           onTap: isFutureDate
  //                               ? null
  //                               : () {
  //                                   _activityBloc.selectDate(date);
  //                                 },
  //                           child: Text(
  //                             DateFormat('dd MMM').format(date),
  //                             style: TextStyle(
  //                               color: isSelected
  //                                   ? Colors.red
  //                                   : isFutureDate
  //                                       ? Colors.grey
  //                                       : Colors.black,
  //                             ),
  //                           ),
  //                         ),
  //                       );
  //                     },
  //                   );
  //                 }),
  //               ],
  //             ),
  //           ),
  //         );
  //       } else if (snapshot.hasError) {
  //         return Center(child: Text('Error: ${snapshot.error}'));
  //       } else {
  //         return const Center(child: CircularProgressIndicator());
  //       }
  //     },
  //   );
  // }

  Widget expenseList() {
    return StreamBuilder<List<ExpanseIncomeModel>>(
      // stream: _activityBloc.expensesSubject,
      stream: _activityBloc.selectedDateSubject.hasValue
          ? _activityBloc.selectedDateExpensesSubject
          : _activityBloc.expensesSubject,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<ExpanseIncomeModel> expenses = snapshot.data!;

          DateTime? selectedDate = _activityBloc.selectedDateSubject.valueOrNull;
          if (selectedDate != null) {
            expenses = expenses.where((expense) {
              DateTime expenseDate = DateTime.parse(expense.date);
              return expenseDate.year == selectedDate.year &&
                  expenseDate.month == selectedDate.month &&
                  expenseDate.day == selectedDate.day;
            }).toList();
          }

          return ListView.builder(
            itemCount: expenses.length,
            itemBuilder: (context, index) {
              ExpanseIncomeModel expense = expenses[index];
              String categoryID = expense.categoryId;
              categoryName = _activityBloc.categoryDetails[categoryID]?['name'] ?? '';
              categoryIcon = _activityBloc.categoryDetails[categoryID]?['icon'] ?? '';
              return ListTile(
                title: Text(categoryName),
                subtitle: Text(expense.date),
                leading: Container(
                  color: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
                  child: Image.network(
                    categoryIcon,
                    height: 24,
                    width: 20,
                    fit: BoxFit.cover,
                    color: Colors.white,
                  ),
                ),
                trailing: Text('\$${expense.payment.toString()}'),
              );
            },
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget sortOrFilterRow() {
    return IntrinsicHeight(
      child: Container(
        height: 50,
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              blurRadius: 5.0,
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  _activityBloc.selectionSubject.add(Selection.sort);
                  _showSortBottomSheet();
                },
                child: StreamBuilder<Selection>(
                  stream: _activityBloc.selectionSubject,
                  builder: (context, snapshot) {
                    final isSelected = snapshot.data == Selection.sort;

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          AppImage.icSort.path(),
                          color: isSelected ? const Color(0xff4EBDA4) : Colors.black,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Sort',
                          style: TextStyle(
                            color: isSelected ? const Color(0xff4EBDA4) : Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            const VerticalDivider(
              width: 1,
              color: Colors.grey,
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  _activityBloc.selectionSubject.add(Selection.filter);
                  _showSortBottomSheet();
                },
                child: StreamBuilder<Selection>(
                  stream: _activityBloc.selectionSubject,
                  builder: (context, snapshot) {
                    final isSelected = snapshot.data == Selection.filter;

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          AppImage.icFilter.path(),
                          color: isSelected ? const Color(0xff4EBDA4) : Colors.black,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Filter',
                          style: TextStyle(
                            color: isSelected ? const Color(0xff4EBDA4) : Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSortBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              const Text('Select Amount Range'),
              StreamBuilder<RangeValues>(
                  stream: _activityBloc.amountRangeSubject,
                  builder: (context, snapshot) {
                    return RangeSlider(
                      values: amountRange,
                      min: 0,
                      max: 100000,
                      divisions: 200,
                      labels: RangeLabels(
                        amountRange.start.round().toString(),
                        amountRange.end.round().toString(),
                      ),
                      onChanged: (values) {
                        setState(() {
                          amountRange = values;
                          _activityBloc.setAmountRange(values);
                        });
                      },
                    );
                  }),
              const Text('Select Date Range'),
              const SizedBox(height: 20),
              StreamBuilder<DateTimeRange>(
                  stream: _activityBloc.dateRangeSubject,
                  builder: (context, snapshot) {
                    var data = snapshot.data;
                    return ElevatedButton(
                      onPressed: () async {
                        DateTimeRange? picked = await showDateRangePicker(
                          context: context,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                          initialDateRange: dateRange,
                        );
                        if (picked != null && picked != dateRange) {
                          setState(() {
                            dateRange = picked;
                            _activityBloc.setDateRange(picked);
                          });
                        }
                      },
                      child: Text(
                          '${DateFormat('dd MMM yyyy').format(data?.start ?? DateTime.now())} - ${DateFormat('dd MMM yyyy').format(data?.end ?? DateTime.now())}'),
                    );
                  }),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _showCategoryDropdown(context);
                },
                child: Text(
                  _activityBloc.selectedCategory.valueOrNull?.name ?? 'Select Category',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _applySorting();
                },
                child: const Text('Apply'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _clearSortAndFilter();
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.clear_all,
                      color: Colors.red,
                    ),
                    SizedBox(width: 5),
                    Text(
                      'Clear Data',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  _showCategoryDropdown(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Category'),
          content: DropdownButton<CategoryModel>(
            value: _activityBloc.selectedCategory.valueOrNull,
            items: _activityBloc.category.valueOrNull?.map((category) {
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
                _activityBloc.selectedCategory.value = newValue;
              });
              Navigator.of(context).pop();
            },
          ),
        );
      },
    );
  }

  void _applySorting() {
    _activityBloc.applyFilters();
    expenseList();
  }

  void _clearSortAndFilter() {
    _activityBloc.amountRangeSubject.add(const RangeValues(0, 100000));
    _activityBloc.dateRangeSubject.add(DateTimeRange(start: DateTime(1900), end: DateTime.now()));
    _activityBloc.selectedCategory.add(null);
    _activityBloc.selectDate(null);

    _activityBloc.fetchExpenses();
  }

  @override
  BaseBloc? getBaseBloc() {
    return null;
  }
}
