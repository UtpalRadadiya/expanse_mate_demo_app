import 'package:expanse_mate_demo_app/common/consts/app_image.dart';
import 'package:expanse_mate_demo_app/common/widget/chart_widget.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff4EBDA4),
        centerTitle: false,
        title: const Text(
          'Hello Hitesh✌️',
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
      ),
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
                      //BoxShadow
                    ],
                  ),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xffF0F0F0),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Text(
                            'Mar 2023',
                            style: TextStyle(
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
                                  const Text(
                                    '₹{4800}',
                                    style: TextStyle(
                                      fontSize: 24,
                                      color: Color(0xff4EBDA4),
                                    ),
                                  ),
                                  const SizedBox(width: 3),
                                  InkWell(
                                    onTap: () {},
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
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Expenses',
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 3),
                              Text(
                                '₹{4900}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    margin: const EdgeInsets.symmetric(horizontal: 16),
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
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Balance Trend',
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                            InkWell(
                              onTap: () {},
                              child: Image.asset(
                                AppImage.icMenu.pathPNG(),
                                height: 24,
                              ),
                            )
                          ],
                        ),
                        const Divider(
                          color: Colors.grey,
                        ),
                        LineChartSample(),
                      ],
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget getAppBottomView() {
    return Container(
      padding: const EdgeInsets.only(left: 30, bottom: 20),
      child: Row(
        children: [
          getProfileView(),
          Container(
            margin: const EdgeInsets.only(left: 20),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hubert Wong',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white),
                ),
                Text(
                  'hubert.wong@mail.com',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '+1 1254 251 241',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

Widget getProfileView() {
  return Stack(
    children: [
      const CircleAvatar(
        radius: 32,
        backgroundColor: Colors.white,
        child: Icon(Icons.person_outline_rounded),
      ),
      Positioned(
          bottom: 1,
          right: 1,
          child: Container(
            height: 30,
            width: 30,
            decoration: const BoxDecoration(
                color: Colors.amber, borderRadius: BorderRadius.all(Radius.circular(20))),
            child: const Icon(
              Icons.edit,
              color: Colors.deepPurple,
              size: 20,
            ),
          ))
    ],
  );
}
