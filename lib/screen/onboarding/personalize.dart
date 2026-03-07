import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lifeos/screen/onboarding/complete.dart';
import 'package:lifeos/screen/onboarding/welcome.dart';

class Personalize extends StatefulWidget {
  const Personalize({super.key});

  @override
  State<Personalize> createState() => _PersonalizeState();
}

class _PersonalizeState extends State<Personalize> {
  List<int> selected = [];
  List categories = [
    {
      "label": "Health & Fitness",
      "icon": Icons.monitor_heart,
      "bg": Color(0xFFFFEBEE),
      "text": Color(0xFFE53935),
    },
    {
      "label": "Finance",
      "icon": Icons.attach_money,
      "bg": Color(0xFFE8F5E9),
      "text": Color(0xFF43A047),
    },
    {
      "label": "Career & Skills",
      "icon": Icons.work,
      "bg": Color(0xFFE3F2FD),
      "text": Color(0xFF1E88E5),
    },
    {
      "label": "Education",
      "icon": Icons.school,
      "bg": Color(0xFFF3E5F5),
      "text": Color(0xFF8E24AA),
    },
    {
      "label": "Productivity",
      "icon": Icons.track_changes,
      "bg": Color(0xFFFFF3E0),
      "text": Color(0xFFFB8C00),
    },
    {
      "label": "Mental Wellness",
      "icon": Icons.favorite,
      "bg": Color(0xFFFCE4EC),
      "text": Color(0xFFD81B60),
    },
  ];
 TextEditingController nameController = TextEditingController();



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFf3f4f6),
      body: SingleChildScrollView(child: Container(
        padding: EdgeInsets.fromLTRB(25, 50, 25, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Let's personalize your experience",
              style: GoogleFonts.rubik(
                fontSize: 30,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Help us tailor LifeOS to your needs",
              textAlign: TextAlign.start,
              style: GoogleFonts.rubik(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Icon(
                  Icons.person_outline_rounded,
                  size: 18,
                  color: Color(0xFF1E3A8A),
                ),
                SizedBox(width: 8),
                Text(
                  "What should we call you?",
                  style: GoogleFonts.rubik(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hint: Text(
                  "Enter your name",
                  style: GoogleFonts.rubik(color: Colors.grey),
                ),
                contentPadding: EdgeInsets.all(15),
                border: InputBorder.none,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.transparent),
                ),
                fillColor: Color(0xFFE5E7EB),
                filled: true,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Color(0xFF1E3A8A)),
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Icon(Icons.album_outlined, size: 18, color: Color(0xFF1E3A8A)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "What would you like to focus on? (Select at least one)",
                    style: GoogleFonts.rubik(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 430,
              child: GridView.builder(
                itemCount: categories.length,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisExtent: 122,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemBuilder: (context, index) {
                  bool isSelected = selected.contains(index);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        isSelected
                            ? selected.remove(index)
                            : selected.add(index);
                      });
                    },
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      padding: EdgeInsets.all(16),

                      decoration: BoxDecoration(
                        color: isSelected
                            ? Color(0xFFdee2ec).withOpacity(0.1)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isSelected
                              ? Color(0xFF1E3A8A)
                              : Colors.grey.shade300,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 2,
                            offset: Offset(0, 1 ),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: categories[index]["bg"],
                            ),
                            child: Icon(
                              categories[index]["icon"],
                              size: 25,
                              color: categories[index]["text"],
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            categories[index]["label"],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 10,),
            Text("Selected: ${selected.length} areas",style: GoogleFonts.rubik(fontSize: 14,fontWeight: FontWeight.w400),),
            SizedBox(height: 20,),
            Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(color: Color(0xFFdde1eb),borderRadius: BorderRadius.circular(20),border: Border.all(color:Color(0xFF1E3A8A) )),
                child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.trending_up_rounded,color:Color(0xFF1E3A8A) ,),
                    SizedBox(width: 10,),
                    Expanded(child: Text("We'll customize your dashboard and recommendations based on your selections. You can always change these later in Settings."))
                  ],
                )
            )
,
            SizedBox(height: 20,),
Center(child:             TextButton.icon(label: Text("Continue",style: GoogleFonts.rubik(color:nameController.text.isEmpty?Colors.black:Colors.white,),),onPressed: (){
  Navigator.push(context, MaterialPageRoute(builder: (context)=>Complete()));
},iconAlignment: IconAlignment.end,icon: Icon(Icons.arrow_forward,color:nameController.text.isEmpty?Colors.black:Colors.white,),style: TextButton.styleFrom(backgroundColor: nameController.text.isEmpty?Color(0xFFe5e7eb):Color(0xFF1e3a8a),minimumSize: Size(250, 60),),)
  ,),
            SizedBox(height: 40,),
          ],
        ),
      ),)
    );
  }
}
