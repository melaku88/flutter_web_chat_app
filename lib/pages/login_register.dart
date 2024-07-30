import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_web_chat_app/colors/default_colors.dart';
import 'package:flutter_web_chat_app/models/user_model.dart';

class LoginRegisterPage extends StatefulWidget {
  const LoginRegisterPage({Key? key}) : super(key: key);

  @override
  State<LoginRegisterPage> createState() => _LoginRegisterPageState();
}

class _LoginRegisterPageState extends State<LoginRegisterPage> {
  //=========================================================================
  double screenWidth = 0;
  double screenHeight = 0;
  Uint8List? selectedImage;
  bool doesUserWantToLogin = true;
  bool doesUserWantToSignup = false;
  bool loadingOn = false;
  String? uid;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  chooseProfilePick()async{
    FilePickerResult? pickImage = await FilePicker.platform.pickFiles(type: FileType.image);
    setState(() {
      selectedImage = pickImage!.files.single.bytes;
    });
  }

  registerValidation()async{
    setState(() {
      loadingOn = true;
    });
    String nameInput = _nameController.text.trim();
    String emailInput = _emailController.text.trim();
    String passwordInput = _passwordController.text.trim();

    try {
      if(selectedImage != null && nameInput.isNotEmpty && emailInput.isNotEmpty && passwordInput.isNotEmpty){
        if(emailInput.contains('@')){
          if(passwordInput.length >= 6){
            // create user
            UserCredential createUser = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: emailInput, password: passwordInput);
            var uid = createUser.user!.uid;

            // upload profile picture
            Reference imageRef = await FirebaseStorage.instance.ref('images/${uid}.jpg');
            UploadTask task = imageRef.putData(selectedImage!);
            var dounloadURL = await(await task).ref.getDownloadURL();

            final userData = await UserModel(uid, nameInput, emailInput, passwordInput, dounloadURL);

            await FirebaseAuth.instance.currentUser!.updateDisplayName(userData.name);
            await FirebaseAuth.instance.currentUser!.updatePhotoURL(userData.profilePic);

            await FirebaseFirestore.instance
              .collection('Users')
              .doc(uid)
              .set(userData.toJson()).then((value){
                setState(() { loadingOn = false; });
                Navigator.pushReplacementNamed(context, '/home');
              });

          }else{
          snackbarError('The length of your password must be atleast 6 character!');
          setState(() { loadingOn = false;});
          }
        }else{
        snackbarError('Please enter a valid email!');
        setState(() { loadingOn = false;});
        }
      }else{
        snackbarError('Please check to fill all the provided fields and profile picture!');
        setState(() { loadingOn = false;});
      }
    }on FirebaseAuthException catch (e) {
      snackbarError(e.code);
      setState(() { loadingOn = false;});
    }
  }

// ====================== LOGIN
  loginValidation()async{
    setState(() {
      loadingOn = true;
    });
    String emailInput = _emailController.text.trim();
    String passwordInput = _passwordController.text.trim();
    try {
    if(emailInput.isNotEmpty && passwordInput.isNotEmpty){
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: emailInput, password: passwordInput).then((value){
      Navigator.pushReplacementNamed(context, '/');
      setState(() {
        loadingOn = false;
      });
  });
    }else{
      snackbarError('Please fill all the fields provided!');
      setState(() { loadingOn = false;});
    }
    }on FirebaseAuthException catch (e) {
      snackbarError(e.code);
      setState(() { loadingOn = false;});
    }
  }

  snackbarError(String message){
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.deepOrange.shade900,
        content: Center(child: Text(message, style: TextStyle(color: Colors.white),)),
      )
    );
  }

  snackbarSuccess(String message){
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green.shade900,
        content: Center(child: Text(message, style: TextStyle(color: Colors.white),)),
      )
    );
  }

  
  //=========================================================================
  @override
  Widget build(BuildContext context) {
    screenWidth= MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        color: DefaultColors.background,
        width: screenWidth,
        height: screenHeight,
        child: Stack(
          children: [
            Positioned(
                child: Container(
                  color: DefaultColors.primary,
                  width: screenWidth,
                  height: screenHeight/2,
                )
            ),
            Center(
              child: SingleChildScrollView(
                child: Card(
                  elevation: 5.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)
                  ),
                  child: Container(
                    width: 500,
                    padding: EdgeInsets.all(40.0),
                    child: Column(
                      children: [

                        Visibility(
                          visible: doesUserWantToSignup,
                          child: Column(
                            children: [
                              _buildProfilePic(),
                              _buildChoosePic(),
                              _buildTextField(_nameController, 
                               'Full Name', 'Enter your name', TextInputType.text, Icons.person_outline),
                              _buildTextField(_emailController, 
                              'Email', 'Enter your valid email', TextInputType.emailAddress, Icons.mail_outline_outlined),
                              _buildTextField(_passwordController, 
                              'Password', 'Enter atleast a 6 character password', TextInputType.text, Icons.visibility_outlined),
                            ],
                          )
                        ),
                        Visibility(
                          visible: doesUserWantToLogin,
                          child: Column(
                            children: [
                              _buildTextField(_emailController, 
                              'Email', 'Enter your valid email', TextInputType.emailAddress, Icons.mail_outline_outlined),
                              _buildTextField(_passwordController, 
                              'Password', 'Enter your valid password', TextInputType.text, Icons.visibility_outlined),
                            ],
                          )
                        ),
                        _buildButton(),
                        _buildSwitch()
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

// }}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}

Widget _buildProfilePic(){
  return ClipOval(
    child: selectedImage != null
      ? Image.memory(selectedImage!, width: 100.0, height: 100.0, fit: BoxFit.cover,) 
      : Image.asset('images/avatar.png', width: 100.0, height: 100.0, fit: BoxFit.cover,),
  );
}

Widget _buildChoosePic(){
  return GestureDetector(
    onTap: () {
      chooseProfilePick();
    },
    child: Container(
      width: 150.0,
      alignment: Alignment.center,
      margin: EdgeInsets.only(top: 3.0, bottom: 15.0),
      padding: EdgeInsets.symmetric(vertical: 4.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30.0),
        border: Border.all(color: DefaultColors.primary, width: 0.5),
      ),
      child: Text('Choose Picture', style: TextStyle(fontSize: 12.0, color: DefaultColors.primary, fontWeight: FontWeight.w600),),
    ),
  );
}
Widget _buildTextField( TextEditingController controller, String labelText, String hintText, TextInputType keyboardType, IconData icon){
  return Container(
    width: screenWidth,
    margin: EdgeInsets.only(bottom: 10.0),
    child: TextField(
      controller: controller,
      autocorrect: false,
      keyboardType: keyboardType,
      style: TextStyle(fontSize: 13.0),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(fontSize: 12.0, color: DefaultColors.primary),
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.black26, fontSize: 12.0),
        contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
        suffixIcon: Icon(icon, size: 18.0, color: DefaultColors.primary,),
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(width: 0.5, color: DefaultColors.primary)),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(width: 1.0, color: DefaultColors.primary)),
      ),
    ),
  );
}

Widget _buildButton(){
  return GestureDetector(
    onTap: () {
      if(doesUserWantToSignup == true){
        registerValidation();
      }else{
        loginValidation();
      }
    },
    child: Container(
      margin: EdgeInsets.only(top: 10.0, bottom: 20.0),
      child: Material(
        elevation: 5.0,
        borderRadius: BorderRadius.circular(5.0),
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(vertical: 10.0),
          decoration: BoxDecoration(
            color: DefaultColors.primary,
            borderRadius: BorderRadius.circular(5.0)
          ),
          child: loadingOn ? Container(
            height: 19.0,
            width: 19.0,
            child: Center(
              child: CircularProgressIndicator(color: DefaultColors.lightBarBackground,),
            ),
          ) : Text(
            doesUserWantToLogin ? 'Login' : 'Sign Up',
            style: TextStyle(color: DefaultColors.lightBarBackground),
          ),
        )
      ),
    ),
  );
}

Widget _buildSwitch(){
  return  Container(
    width: screenWidth,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Login'),
        SizedBox(width: 15.0,),
        Switch(
          value: doesUserWantToSignup, 
          onChanged:(value) {
            setState(() {
              doesUserWantToSignup = value;
              doesUserWantToLogin = !value;
            });
          },
        ),
        SizedBox(width: 15.0,),
        Text('Sign Up')
      ],
    ),
  );
}
}
