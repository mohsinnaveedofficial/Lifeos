import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Task extends StatefulWidget {
  const Task({super.key});

  @override
  State<Task> createState() => _TaskState();
}

class _TaskState extends State<Task> with TickerProviderStateMixin {
  String activeTab = "today";
  late TabController tabController;

  List<Map<String, dynamic>> tasks = [
    {
      "id": 1,
      "title": "Read 10 pages",
      "deadline": "Today 10:00 AM",
      "category": "Study",
      "priority": "High",
      "completed": false,
    },
    {
      "id": 2,
      "title": "Workout",
      "deadline": "Tomorrow 7:00 AM",
      "category": "Health",
      "priority": "Medium",
      "completed": false,
    },
    {
      "id": 3,
      "title": "Buy groceries",
      "deadline": "Today 5:00 PM",
      "category": "Personal",
      "priority": "Low",
      "completed": true,
    },
  ];

  void toggleTask(int id) {
    setState(() {
      final task = tasks.firstWhere((t) => t["id"] == id);
      task["completed"] = !task["completed"];
    });
  }

  Color getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case "high":
        return Colors.red;
      case "medium":
        return Colors.orange;
      case "low":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  List<Map<String, dynamic>> get filteredTasks {
    return tasks.where((t) {
      if (activeTab == "completed") return t["completed"] == true;
      if (activeTab == "today")
        return t["completed"] == false && t["deadline"].contains("Today");
      if (activeTab == "upcoming")
        return t["completed"] == false && !t["deadline"].contains("Today");
      return true;
    }).toList();
  }

  @override
  void initState() {
    super.initState();

    tabController = TabController(length: 3, vsync: this);

    tabController.addListener(() {
      setState(() {
        final tabs = ["today", "upcoming", "completed"];
        activeTab = tabs[tabController.index];
      });
    });
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tabs = ["today", "upcoming", "completed"];
    final tabLabels = ["Today", "Upcoming", "Completed"];

    tabController.addListener(() {
      setState(() {
        activeTab = tabs[tabController.index];
      });
    });

    return Scaffold(
      backgroundColor: Color(0xFFf3f4f6),

      appBar: AppBar(
        title: const Text("Tasks"),
        backgroundColor: Color(0xFFf3f4f6),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Container(
        color: Color(0xFFf3f4f6),
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            
           Padding(padding: EdgeInsets.fromLTRB(10, 0, 10, 10),child:  Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [Text("Daily Productivity",style: GoogleFonts.rubik(fontWeight: FontWeight.w500,fontSize: 13,color: Colors.black45),),
               Text("65%",style: GoogleFonts.rubik(fontWeight: FontWeight.w500,fontSize: 13,color: Colors.black87),)],
           ),),
            LinearProgressIndicator(color: Color(0xFF2C448C),minHeight:6,value: 0.65,borderRadius: BorderRadius.circular(20), backgroundColor: Colors.grey.shade300,),
            SizedBox(height: 20,),
            Container(
              height: 45,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(30),
              ),
              child: TabBar(
                splashFactory: NoSplash.splashFactory,
                controller: tabController,
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                indicator: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                indicatorPadding: const EdgeInsets.all(4),
                tabs: const [
                  Tab(text: "Today"),
                  Tab(text: "Upcoming"),
                  Tab(text: "Completed"),
                ],
              ),
            ),
            const SizedBox(height: 16),
            filteredTasks.isEmpty
                ? Center(
                    child: Text(
                      "No tasks found",
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  )
                : SizedBox(
                    height: double.maxFinite,
                    child: ListView.builder(
                      itemCount: filteredTasks.length,
                      itemBuilder: (context, index) {
                        final task = filteredTasks[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          color: Colors.white,
                          shadowColor: Colors.grey.shade100,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              color: task["completed"]
                                  ? Colors.grey
                                  : Colors.blue,
                              width: 2,

                            ),

                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: ListTile(
                            horizontalTitleGap: 0,
                            leading: Checkbox(
                              value: task["completed"],
                              onChanged: (_) => toggleTask(task["id"]),
                              shape: const CircleBorder(),
                              activeColor: Colors.green,
                            ),
                            title: Text(
                              task["title"],
                              style: TextStyle(
                                decoration: task["completed"]
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: task["completed"]
                                    ? Colors.grey
                                    : Colors.black,
                              ),
                            ),
                            subtitle: Row(
                              children: [
                                const Icon(
                                  Icons.access_time,
                                  size: 14,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  task["deadline"],
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.flag,
                                  size: 14,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  task["category"],
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: getPriorityColor(
                                  task["priority"],
                                ).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                task["priority"],
                                style: TextStyle(
                                  color: getPriorityColor(task["priority"]),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(context: context, builder: (context) => const TaskDialog());
        },
        shape: const CircleBorder(),
        backgroundColor: const Color(0xFF1E3A8A),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }


}


class TaskDialog extends StatelessWidget {
  const TaskDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Color(0XFFf3f4f6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 20),
                Text("Add New Task",style: GoogleFonts.rubik(fontSize: 18,fontWeight: FontWeight.w600),),
                IconButton(
                  icon: const Icon(Icons.close,size: 18,),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
            const SizedBox(height:  15),
            Align(
              alignment: Alignment.centerLeft,
              child:Text("Task Title",style: GoogleFonts.rubik(fontSize: 14,fontWeight: FontWeight.w500),)
            ),
            SizedBox(height: 6,),
            TextField(
            decoration: InputDecoration(
              hintText: "e.g. Read 10 pages",
              filled: true,
              fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.transparent),
              borderRadius: BorderRadius.circular(13)

            ),

            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.transparent,),
              borderRadius: BorderRadius.circular(13)
            ),
              focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF2C448C).withOpacity(0.4),width: 4),
              borderRadius: BorderRadius.circular(13)

              ),
            ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [


                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Date",
                        style: GoogleFonts.rubik(
                          fontSize: 14,
                          fontWeight: FontWeight.w500 ,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        decoration: InputDecoration(
                          hintText: "mm/dd/yyyy",
                          prefixIcon: const Icon(Icons.calendar_today),
                          filled: true,
                          fillColor: Colors.white,
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.transparent),
                            borderRadius: BorderRadius.circular(13),
                          ),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.transparent),
                            borderRadius: BorderRadius.circular(13),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: const Color(0xFF2C448C).withOpacity(0.4),
                              width: 4,
                            ),
                            borderRadius: BorderRadius.circular(13),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),


                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Time",
                        style: GoogleFonts.rubik(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        decoration: InputDecoration(
                          hintText: "--:--",
                          prefixIcon: const Icon(Icons.access_time),
                          filled: true,
                          fillColor: Colors.white,
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.transparent),
                            borderRadius: BorderRadius.circular(13),
                          ),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.transparent),
                            borderRadius: BorderRadius.circular(13),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: const Color(0xFF2C448C).withOpacity(0.4),
                              width: 4,
                            ),
                            borderRadius: BorderRadius.circular(13),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

             Align(
              alignment: Alignment.centerLeft,
              child: Text("Priority",style: GoogleFonts.rubik(fontSize: 14,fontWeight: FontWeight.w500),),
            ),

            const SizedBox(height: 6),

            DropdownButtonFormField(
              hint: const Text("Select priority"),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent),
                    borderRadius: BorderRadius.circular(13)

                ),

                border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent,),
                    borderRadius: BorderRadius.circular(13)
                ),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF2C448C).withOpacity(0.4),width: 4),
                    borderRadius: BorderRadius.circular(13)

                ),
              ),
              items: const [
                DropdownMenuItem(value: "High", child: Text("High")),
                DropdownMenuItem(value: "Medium", child: Text("Medium")),
                DropdownMenuItem(value: "Low", child: Text("Low")),
              ],
              onChanged: (value) {},
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2C448C),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {},
                child:  Text("Create Task",style: GoogleFonts.rubik(color: Colors.white,fontWeight: FontWeight.w500),),
              ),
            ),


          ],
        ),
      )
    );
  }
}

