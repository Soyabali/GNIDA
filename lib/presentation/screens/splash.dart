
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/verifyAppVersion.dart';
import '../complaints/complaintHomePage.dart';
import '../login/loginScreen_2.dart';
import '../resources/app_text_style.dart';
import '../resources/assets_manager.dart';

class SplashView extends StatefulWidget {

  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplaceState();
}

class _SplaceState extends State<SplashView> {

  bool activeConnection = false;
  String T = "";
  var result,msg;
  var iVersion;
  Future checkUserConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        setState(() {
          activeConnection = true;
          T = "Turn off the data and repress again";
          versionAliCall();
          //displayToast(T);
        });
      }
    } on SocketException catch (_) {
      setState(() {
        activeConnection = false;
        T = "Turn On the data and repress again";
        displayToast(T);
      });
    }
  }

  String? _appVersion ;

  // get app Version

  //url
  void _launchGooglePlayStore() async {
    const url = 'https://play.google.com/store/apps/details?id=com.instagram.android&hl=en_IN&gl=US'; // Replace <YOUR_APP_ID> with your app's package name
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
  //
  void displayToast(String msg){
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }

  @override
  void initState() {
    // TODO: implement initState

    Future.delayed(const Duration(seconds: 1), () {
      checkUserConnection();
    });

    // versionAliCall();
    //getlocalDataBaseValue();
    print('---------xx--xxxxxx-------');
    super.initState();
  }
  // getlocalDataBaseValue() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String? token = prefs.getString('sToken');
  //   print('----TOKEN---87---$token');
  //   if(token!=null){
  //     print('-----89---HomeScreen');
  //     Navigator.push(
  //       context,
  //       MaterialPageRoute(builder: (context) => ComplaintHomePage()),
  //     );
  //   }else{
  //     print('-----91----LoginScreen');
  //     Navigator.push(
  //       context,
  //       MaterialPageRoute(builder: (context) => LoginScreen_2()),
  //     );
  //   }
  // }
  Future<void> versionAliCall() async {
    try {
      // Call the API to check the app version
      var loginMap = await VerifyAppVersionRepo().verifyAppVersion(context, "1");
      print("-----109---$loginMap");
      result = "${loginMap['Result']}";
      msg = "${loginMap['Msg']}";
      iVersion = "${loginMap['iVersion']}";

      print("------114---$loginMap");

      // Check result and navigate or show dialog
      if (iVersion == "1") {
        // Navigate to LoginScreen if version matches
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? sToken = prefs.getString('sToken');

        print("--sToken----120----$sToken");
        if(sToken!=null){
          print('-----122---HomeScreen');
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ComplaintHomePage()),
          );
        }else {
          print("-----118---HomeScreen");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen_2()),
          );
        }
      } else {
        // Show dialog for mismatched version
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('New Version Available'),
              content: const Text(
                'Please download the latest version of the app from the Play Store.',
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    _launchGooglePlayStore();
                  },
                  child: const Text('Download'),
                ),
              ],
            );
          },
        );
        //displayToast(msg ?? "Version mismatch. Please update the app.");
      }
    } catch (e) {
      // Handle potential errors
      print("Error in versionAliCall: $e");
      displayToast("Failed to verify app version.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplaceScreen(),
    );
  }
}

class SplaceScreen extends StatelessWidget {
  const SplaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home:Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.hardEdge,
        alignment: Alignment.bottomRight,
          children: [
            // Container(
            //     decoration: const BoxDecoration(
            //       image: DecorationImage(
            //         image: AssetImage(ImageAssets.templepuri4), // Replace 'background_image.jpg' with your image path
            //         fit: BoxFit.cover, // Cover the entire container
            //       ),
            //     ),
            //   ),
            Container(
              child: Stack(
                alignment: Alignment.center,
                children: [
                     Container(
                       child: Image.asset("assets/icon/icon.png",
                         height: 200,
                         width: 300,),
                     ),
                     Positioned(
                         child: Text('',
                           style:AppTextStyle.font30penSansExtraboldWhiteTextStyle,
                         ),
                     )
                ],
              )
            )

          ],
      )
    );
  }

}

