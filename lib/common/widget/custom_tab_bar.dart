import 'package:flutter/material.dart';

class CustomTabBar extends StatelessWidget {
  final TabController tabController;
  final List<String> titleList;

  const CustomTabBar({super.key, required this.tabController, required this.titleList});

  @override
  Widget build(BuildContext context) {
    final List<Widget> sizedBoxList = [];
    for (String text in titleList) {
      sizedBoxList.add(
        SizedBox(width: double.infinity, child: Center(child: Text(text))),
      );
    }
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      height: 44,
      decoration:
          BoxDecoration(borderRadius: BorderRadius.circular(40), border: Border.all(color: Colors.grey)),
      child: TabBar(
          dividerColor: Colors.transparent,
          splashBorderRadius: BorderRadius.circular(40),
          labelPadding: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          labelColor: Colors.white,
          labelStyle: const TextStyle(fontSize: 14),
          unselectedLabelStyle: const TextStyle(fontSize: 14),
          unselectedLabelColor: Colors.black.withOpacity(0.5),
          indicatorColor: const Color(0xff4EBDA4),
          indicator:
              BoxDecoration(borderRadius: BorderRadius.circular(40), color: const Color(0xff4EBDA4)),
          controller: tabController,
          tabs: sizedBoxList),
    );
  }
}
