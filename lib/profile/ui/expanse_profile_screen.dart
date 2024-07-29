import 'package:expanse_mate_demo_app/profile/ui/expanse_item_page.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class ExpanseProfilePage extends StatefulWidget {
  const ExpanseProfilePage({Key? key}) : super(key: key);

  @override
  State<ExpanseProfilePage> createState() => _ExpanseProfilePageState();
}

class _ExpanseProfilePageState extends State<ExpanseProfilePage> {
  late BehaviorSubject<int> tabChangeStreamSubject;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    tabChangeStreamSubject = BehaviorSubject<int>.seeded(currentIndex);
  }

  @override
  void dispose() {
    tabChangeStreamSubject.close();
    super.dispose();
  }

  void changeTab(int index) {
    setState(() {
      currentIndex = index;
      tabChangeStreamSubject.add(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Flutter Custom TabBar',
          style: TextStyle(fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 40,
            padding: const EdgeInsets.all(3),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey.withOpacity(.2),
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => changeTab(0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: currentIndex == 0 ? Colors.red : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          'Expense',
                          style: TextStyle(
                            color: currentIndex == 0 ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => changeTab(1),
                    child: Container(
                      decoration: BoxDecoration(
                        color: currentIndex == 1 ? Colors.green : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          'Income',
                          style: TextStyle(
                            color: currentIndex == 1 ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: IndexedStack(
              index: currentIndex,
              children: [
                ExpanseItemPage(currentIndex: currentIndex),
                ExpanseItemPage(currentIndex: currentIndex),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
