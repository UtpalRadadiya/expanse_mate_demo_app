import 'package:expanse_mate_demo_app/base/base_bloc.dart';
import 'package:expanse_mate_demo_app/base/base_stateful_widget.dart';
import 'package:expanse_mate_demo_app/common/consts/app_image.dart';
import 'package:expanse_mate_demo_app/common/consts/app_routes.dart';
import 'package:expanse_mate_demo_app/common/helper/route/route_manager.dart';
import 'package:expanse_mate_demo_app/common/item_list/route_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends BaseState<Dashboard> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
        ),
        child: Stack(children: [
          Scaffold(
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              backgroundColor: const Color(0xff4EBDA4),
              selectedItemColor: Colors.white,
              unselectedItemColor: const Color(0xffCBF3F0),
              currentIndex: index,
              onTap: (value) {
                setState(() {
                  if (value == 2) {
                    return;
                  }
                  index = value;
                });
              },
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  activeIcon: SvgPicture.asset(
                    AppImage.activeHome.path(),
                    color: Colors.white,
                  ),
                  icon: SvgPicture.asset(AppImage.inActiveHome.path()),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  activeIcon: SvgPicture.asset(
                    AppImage.activeGroup.path(),
                    color: Colors.white,
                  ),
                  icon: SvgPicture.asset(AppImage.inActiveGroup.path()),
                  label: 'Group',
                ),
                const BottomNavigationBarItem(
                  icon: SizedBox(),
                  label: '',
                ),
                BottomNavigationBarItem(
                  activeIcon: SvgPicture.asset(
                    AppImage.activeActivity.path(),
                    color: Colors.white,
                  ),
                  icon: SvgPicture.asset(AppImage.inActiveActivity.path()),
                  label: 'Activity',
                ),
                BottomNavigationBarItem(
                  activeIcon: SvgPicture.asset(
                    AppImage.activeProfile.path(),
                    color: Colors.white,
                  ),
                  icon: SvgPicture.asset(AppImage.inActiveProfile.path()),
                  label: 'Profile',
                ),
              ],
            ),
            body: RouteList().list[index],
          ),
          Positioned(
            // right: 8,
            bottom: 0,
            left: MediaQuery.of(context).size.width * .5 - 40,

            child: Container(
              decoration: const BoxDecoration(
                  borderRadius:
                      BorderRadius.only(topLeft: Radius.circular(70), topRight: Radius.circular(70)),
                  color: Colors.transparent),
              alignment: Alignment.topCenter,
              height: 83,
              width: 80,
              child: GestureDetector(
                onTap: () {
                  AppRouteManager.pushNamed(AppRoutes.expanseProfilePage);
                },
                child: Container(
                    height: 56,
                    width: 56,
                    decoration: BoxDecoration(
                        border: Border.all(width: 4, color: Colors.white),
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(100)),
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 32,
                    )),
              ),
            ),
          ),
        ]));
  }

  @override
  BaseBloc? getBaseBloc() {
    return null;
  }
}
