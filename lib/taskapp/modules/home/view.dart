import 'package:assisti_fy/notes/components/drawer.dart';
import 'package:assisti_fy/taskapp/core/utils/extensions.dart';
import 'package:assisti_fy/taskapp/core/values/colors.dart';
import 'package:assisti_fy/taskapp/data/models/task.dart';
import 'package:assisti_fy/taskapp/modules/home/controller.dart';
import 'package:assisti_fy/taskapp/modules/home/widgets/add_card.dart';
import 'package:assisti_fy/taskapp/modules/home/widgets/add_dialog.dart';
import 'package:assisti_fy/taskapp/modules/home/widgets/task_card.dart';
import 'package:assisti_fy/taskapp/modules/report/view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
//import 'package:dotted_border/dotted_border.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Add the Drawer here
      drawer: MyDrawer(),

      // Add the AppBar here
      appBar: AppBar(
        title: Text(
          'Assistify',
          style: GoogleFonts.dmSerifText(
            fontSize: 20.0.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Obx(
        () => IndexedStack(
          index: controller.tabIndex.value,
          children: [
            SafeArea(
              child: ListView(
                children: [
                  Padding(
                    padding: EdgeInsets.all(4.0.wp),
                    child: Text(
                      'My Tasks',
                      style: TextStyle(
                        fontSize: 24.0.sp,
                        fontWeight: FontWeight.bold,
                        fontFamily: GoogleFonts.dmSerifText().fontFamily,
                      ),
                    ),
                  ),
                  Obx(
                    () => GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      children: [
                        ...controller.tasks
                            .map((element) => LongPressDraggable(
                                  data: element,
                                  onDragStarted: () => controller.changeDeleting(true),
                                  onDraggableCanceled: (_, __) => controller.changeDeleting(false),
                                  onDragEnd: (_) => controller.changeDeleting(false),
                                  feedback: Opacity(
                                      opacity: 0.8,
                                      child: TaskCard(task: element)),
                                  child: TaskCard(task: element),
                                ))
                            .toList(),
                        AddCard(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            ReportPage(),
          ],
        ),
      ),
      floatingActionButton: DragTarget<Task>(
        builder: (_, __, ___) {
          return Obx(
            () => FloatingActionButton(
              backgroundColor: controller.deleting.value ? Colors.red : blue,
              onPressed: () {
                if (controller.tasks.isNotEmpty) {
                  Get.to(() => AddDialog(), transition: Transition.downToUp);
                } else {
                  EasyLoading.showInfo('Please create a task type');
                }
              },
              child: Icon(controller.deleting.value ? Icons.delete : Icons.add),
            ),
          );
        },
        onAccept: (Task task) {
          controller.deleteTask(task);
          EasyLoading.showSuccess('Deleted Successfully');
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Theme(
        data: ThemeData(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: Obx(
          () => BottomNavigationBar(
            onTap: (int index) => controller.changeTabIndex(index),
            currentIndex: controller.tabIndex.value,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            items: [
              BottomNavigationBarItem(
                label: 'Home',
                icon: Padding(
                  padding: EdgeInsets.only(right: 15.0.wp),
                  child: const Icon(
                    Icons.apps,
                  ),
                ),
              ),
              BottomNavigationBarItem(
                label: 'Report',
                icon: Padding(
                  padding: EdgeInsets.only(left: 15.0.wp),
                  child: const Icon(
                    Icons.data_usage,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
