import 'package:assisti_fy/taskapp/core/utils/extensions.dart';
import 'package:assisti_fy/taskapp/core/values/colors.dart';
import 'package:assisti_fy/taskapp/data/models/task.dart';
import 'package:assisti_fy/taskapp/modules/home/controller.dart';
import 'package:assisti_fy/taskapp/widgets/icons.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

class AddCard extends StatelessWidget {
  final homeCtrl = Get.find<HomeController>();
  AddCard({super.key});

  @override
  Widget build(BuildContext context) {
    final icons = getIcons();
    var squareWidth = Get.width - 12.0.wp;
    return Container(
      width: squareWidth / 2,
      height: squareWidth / 2,
      margin: EdgeInsets.all(3.0.wp),
      child: InkWell(
        onTap: () async {
          await Get.defaultDialog(
            titlePadding: EdgeInsets.symmetric(horizontal: 3.0.wp),
            radius: 5,
            title: 'Task Type',
            content: Form(
              key: homeCtrl.formKey,
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 5.0.wp),
                  child: TextFormField(
                    controller: homeCtrl.editCtrl,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Title',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty){
                        return 'Please enter your task title';
                      }
                      return null;
                    },
                  ),
                  ),
                  Padding(
                    padding:  EdgeInsets.symmetric(vertical: 5.0.wp),
                    child: Wrap(
                      spacing: 2.0.wp,
                      children: icons
                      .map((e) => Obx((){
                          final index = icons.indexOf(e);
                          return ChoiceChip(
                            selectedColor: Colors.grey.shade200,
                            pressElevation: 0,
                            backgroundColor: Colors.white,
                            label: e,
                            selected: homeCtrl.chipIndex.value == index,
                            onSelected: (bool selected){
                              homeCtrl.chipIndex.value =
                              selected ? index : 0;
                            },
                          );
                        }
                      )).toList(),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)
                      ),
                      minimumSize: const Size(150, 40),
                    ),
                    onPressed: (){
                      if (homeCtrl.formKey.currentState!.validate()){
                        int icon = icons[homeCtrl.chipIndex.value].icon!.codePoint;
                        String color = icons[homeCtrl.chipIndex.value].color!.toHex();
                        var task = Task(
                          icon: icon,
                          title: homeCtrl.editCtrl.text,
                          color: color,
                        );
                        Get.back();
                        homeCtrl.addTask(task) ?
                        EasyLoading.showSuccess('Create success') :
                        EasyLoading.showError('Duplicated Task');
                      }
                    }, 
                    child: const Text('Confirm'))
                ],
              
            ),
            ),
          );
          homeCtrl.editCtrl.clear();
          homeCtrl.chipIndex(0);
        },
        child: DottedBorder(
          color: Colors.grey[400]!,
          dashPattern: const[8,4],
          child: Center(
            child: Icon(
             Icons.add,
             size: 10.0.wp,
             color: Colors.grey)
          ),
        )
      ),
    );
  }
}