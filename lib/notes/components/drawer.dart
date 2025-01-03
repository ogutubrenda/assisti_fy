import 'package:assisti_fy/habbittracker/pages/home_page.dart';
import 'package:assisti_fy/notes/pages/notes_page.dart';
import 'package:assisti_fy/taskapp/modules/home/view.dart';
import 'package:assisti_fy/voiceassist/home_view.dart';
import 'package:flutter/material.dart';

import '../settings_page.dart';
import 'drawer_tile.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build (BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.background,
      child: Column(
        children: [
          //header
          const DrawerHeader(
            child: Icon(Icons.home),
          ),

          DrawerTile(
            title: "Voice Assistant",
            leading: const Icon(Icons.settings),
            onTap: (){
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => VoicePage(),));
            },
          ),

          DrawerTile(
            title: "Task Manager",
            leading: const Icon(Icons.task),
            onTap: () { 
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage(),));
            }
          ),


          DrawerTile(
            title: "Habbit tracker",
            leading: const Icon(Icons.track_changes_rounded),
            onTap: () { 
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context) => HabitPage(),));
            }
          ),

          //notes tile
          DrawerTile(
            title: "Notes",
            leading: const Icon(Icons.note),
            onTap: () { 
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context) => NotesPage(),));
            }
          ),

          DrawerTile(
            title: "Settings",
            leading: const Icon(Icons.settings),
            onTap: (){
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsPage(),));
            },
          ),
        ],
      ),
      );
    
  }
  
 
  
}