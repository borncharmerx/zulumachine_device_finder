import 'package:flutter/material.dart';
import '../About Me/AboutMe.dart';
import '../DeviceScanner/DeviceScanner.dart';
import '../constant/text_constants.dart';
import 'HomeScreen.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  State<HomePage> createState() => HomePageState();
}
class HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  List<Widget> tabBody = [HomeScreen(), DeviceScannerScreen(), AboutMeScreen()];

  @override
  void initState() {
    tabController = TabController(length: 3, vsync: this);
    tabController.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(tabController.index == 0
              ? TextConstants.titleTab_1
              : tabController.index == 1
              ? TextConstants.titleTab_2
              : TextConstants.titleTab_3),
          bottom: TabBar(controller: tabController, tabs: [
            Tab(
              text: TextConstants.titleTab_1,
              icon: Icon(
                Icons.home,
                color: Colors.deepPurple,
              ),
            ),
            Tab(
                text: TextConstants.titleTab_2,
                icon: Icon(
                  Icons.device_hub,
                  color: Colors.deepPurple,
                )),
            Tab(
                text: TextConstants.titleTab_3,
                icon: Icon(
                  Icons.person,
                  color: Colors.deepPurple,
                ))
          ]),
        ),
        body: TabBarView(controller: tabController, children: tabBody));
  }
}