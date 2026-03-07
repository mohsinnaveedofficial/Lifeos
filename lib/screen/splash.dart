import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lifeos/screen/onboarding/welcome.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {

  @override
  void initState(){
    super.initState();
    _navigate();
    }

    void _navigate()async{
      await Future.delayed(Duration(seconds: 2));
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Welcome()));

    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1E3A8A),
              Colors.blue[600]!,
              Colors.indigo[900]!,
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                SizedBox(height: 100, width: 70),
                Positioned(
                  bottom: 10,
                  child: Image.asset('assets/icons/brain-organ.png',color: Colors.white,height: 70,width: 70,fit: BoxFit.cover,),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    height: 30,
                    width: 30,
                    decoration: BoxDecoration(
                      color: Color(0xFF3B82F6),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Icon(Icons.dashboard_outlined,color: Colors.green,size: 20,),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10,),

      Text("LifeOS",style: GoogleFonts.raleway(color: Colors.white,fontSize: 36,fontWeight: FontWeight.w800)),
            SizedBox(height: 5  ),
            Text("Manage Your Entire Life in One Place",style: GoogleFonts.raleway(color: Color(0xFFB6CDFB),fontSize: 14,fontWeight: FontWeight.w600),)
          ],
        ),
      ),
    );
  }
}
