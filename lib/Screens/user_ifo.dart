import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mi_vision/Utils/Authentication.dart';
import 'package:mi_vision/Utils/ClipWave.dart';
import 'package:mi_vision/Utils/custom%20colors.dart';
import 'package:mi_vision/Utils/db%20utils.dart';
import 'package:google_fonts/google_fonts.dart';

import 'SignInScreen.dart';
import 'TabItemBuilder.dart';

class UserInfoScreen extends StatefulWidget {
  const UserInfoScreen({Key? key, required User user})
      : _user = user,
        super(key: key);

  final User _user;

  @override
  _UserInfoScreenState createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen>
    with SingleTickerProviderStateMixin {
  late User _user;
  bool _isSigningOut = false;

  Route _routeToSignInScreen() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => SignInScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(-1.0, 0.0);
        var end = Offset.zero;
        var curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  @override
  void initState() {
    _user = widget._user;
    _controllerTab = TabController(length: 2, vsync: this);
    super.initState();
  }

  File? _image;
  String imagePath = "";
  String _text = '';
  ImagePicker picker = ImagePicker();
  bool isImageShown = false;
  AnimationController? _controllerAnimation;
  double? _scale;

  void _onTapDown(TapDownDetails details) {
    _controllerAnimation!.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controllerAnimation!.reverse();
  }

  Future getImage() async {
    final pickedFile =
        await picker.getImage(source: ImageSource.camera, imageQuality: 70);

    if (_controllerTab.index == 0) {
      setState(() {
        if (pickedFile != null) {
          _image = File(pickedFile.path);
          imagePath = pickedFile.path;
          detectLabels(imagePath, _user.uid);
        } else {
          print('No image selected.');
        }
      });
    } else if (_controllerTab.index == 1) {
      setState(() {
        if (pickedFile != null) {
          _image = File(pickedFile.path);
          imagePath = pickedFile.path;
          readImage(_image!);
        } else {
          print('No image selected.');
        }
      });
    }
  }

  Future<void> readImage(File imageFile) async {
    final textDetector = GoogleMlKit.vision.textDetector();
    final RecognisedText recognisedText =
        await textDetector.processImage(InputImage.fromFile(imageFile));

    Future.sync(() async {
      await textDetector.close();

      debugPrint(recognisedText.text);
      setState(() {
        _text = recognisedText.text;
      });
    });
  }

  late TabController _controllerTab;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Container(
        color: Color(0xffdbfcff),
        child: Stack(
          children: [
            Positioned(
              top: 30,
              right: 16,
              child: _isSigningOut
                  ? CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : GestureDetector(
                      onTap: () async {
                        setState(() {
                          _isSigningOut = true;
                        });
                        await Authentication.signOut(context: context);
                        setState(() {
                          _isSigningOut = false;
                        });
                        Navigator.of(context)
                            .pushReplacement(_routeToSignInScreen());
                      },
                      child: Padding(
                        padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                        child: Text(
                          'Sign Out',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xff231942),
                          ),
                        ),
                      ),
                    ),
            ),
            Positioned(
              top: 75,
              child: Container(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _user.photoURL != null
                        ? ClipOval(
                            child: Material(
                              color: CustomColors.firebaseGrey.withOpacity(0.3),
                              child: Image.network(
                                _user.photoURL!,
                                fit: BoxFit.fitHeight,
                                height: 50,
                              ),
                            ),
                          )
                        : ClipOval(
                            child: Material(
                              color: CustomColors.firebaseGrey.withOpacity(0.3),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Icon(
                                  Icons.person,
                                  size: 60,
                                  color: CustomColors.firebaseGrey,
                                ),
                              ),
                            ),
                          ),
                    Text(
                      'Hi, ${_user.displayName!}',
                      style: GoogleFonts.nunitoSans(
                          fontSize: 32,
                          color: Color(0xff231942),
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.4),
                    ),
                    // Text(
                    //   'lorem ipsum lorem ipsum',
                    //   style: GoogleFonts.nunitoSans(
                    //     fontSize: 20,
                    //     color: Color(0xff231942),
                    //     fontWeight: FontWeight.w500,
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
            Positioned(
              child: ClipPath(
                clipper: ClipWave(),
                child: Container(
                    color: Color(0xffffffff),
                    // color: Color(0xffdbfcff),
                    child: Container(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.265),
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal:
                                    MediaQuery.of(context).size.width * 0.15),
                            child: TabBar(
                              unselectedLabelColor: Colors.black38,
                              labelColor: Color(0xff231942),
                              indicatorColor: Color(0xff857e61),
                              indicatorWeight: 4,
                              labelStyle: GoogleFonts.nunitoSans(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.4),
                              indicatorSize: TabBarIndicatorSize.label,
                              controller: _controllerTab,
                              tabs: [
                                Tab(
                                  text: 'My Items',
                                ),
                                Tab(
                                  text: 'Read it',
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: TabBarView(
                              physics: BouncingScrollPhysics(),
                              controller: _controllerTab,
                              children: [
                                TabItemCardBuilder(
                                  userId: _user.uid,
                                ),
                                tabReadImage(),
                              ],
                            ),
                          )
                        ],
                      ),
                    )),
              ),
            )
          ],
        ),
      ),
      floatingActionButton: GestureDetector(
        // onTapDown: _onTapDown,
        // onTapUp: _onTapUp,
        onTap: getImage,
        child: Container(
          padding: EdgeInsets.all(18),
          decoration: ShapeDecoration(
            color: Color(0xff231942),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15.0))),
          ),
          child: Icon(
            Icons.camera_alt_rounded,
            color: Colors.white,
            size: 26,
          ),
        ),
      ),
    );
  }

  Widget tabReadImage() {
    return Container(
      padding: const EdgeInsets.only(left: 24, right: 16, top: 18),
      margin: EdgeInsets.only(bottom: 22),
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            GestureDetector(
              onLongPress: () {
                Clipboard.setData(ClipboardData(text: _text));
                showSnackBar('Copied to the clipboard!', context);
              },
              child: Text(
                '$_text',
                textAlign: TextAlign.left,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.nunitoSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Color(0xff231942)),
              ),
            ),
            SizedBox(
              height: 16,
            ),
            Row(
              mainAxisAlignment: _image == null
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.spaceBetween,
              children: [
                _image == null
                    ? Padding(
                        padding: const EdgeInsets.only(top: 100),
                        child: Text('Click a picture to read the image',
                            style: GoogleFonts.nunitoSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Color(0xff231942))),
                      )
                    : isImageShown
                        ? TextButton(
                            onPressed: () {
                              setState(() {
                                isImageShown = !isImageShown;
                              });
                            },
                            child: Text('Hide Image'))
                        : TextButton(
                            onPressed: () {
                              setState(() {
                                isImageShown = !isImageShown;
                              });
                            },
                            child: Text('Show Image')),
                _image != null
                    ? IconButton(
                        icon: Icon(
                          Icons.copy,
                          color: Colors.black26,
                        ),
                        onPressed: () {
                          showSnackBar('Copied to the clipboard!', context);
                        })
                    : Container(),
              ],
            ),
            isImageShown
                ? Center(
                    child: Container(
                      height: 200,
                      width: MediaQuery.of(context).size.width - 52,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.file(
                          _image!,
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // _controllerAnimation!.dispose();
    super.dispose();
  }
}
