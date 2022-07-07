import 'package:flutter/material.dart';
import 'package:flyy_flutter_plugin/flyy_flutter_plugin.dart';
import 'package:flyy_invite_earn_flutter/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  late SharedPreferences preferences;
  TextEditingController refCodeController = TextEditingController();
  TextEditingController userIdController = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  String referralCode = "", userId = "", userName = "";
  String refCodeError = "", userIdError = "";
  final double verticalWidth = 250;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sign Up"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 48),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: refCodeController,
                    decoration: InputDecoration(
                        hintText: "Enter Referral Code",
                        errorText: refCodeError.isEmpty ? null : refCodeError),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: ElevatedButton(
                    onPressed: () {
                      bool isValid = validateReferralCode();
                      setState(() {});
                      if (isValid) applyReferral(refCodeController.text);
                    },
                    child: const Text("Set"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: verticalWidth,
              child: TextField(
                controller: userIdController,
                decoration: const InputDecoration(hintText: "User Id"),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: verticalWidth,
              child: TextField(
                controller: userNameController,
                decoration:
                    const InputDecoration(hintText: "User Name (Optional)"),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: verticalWidth,
              child: ElevatedButton(
                child: const Text("Sign Up"),
                onPressed: () {
                  bool isValid = validateUserId();
                  setState(() {});
                  if (isValid) {
                    preferences.setString("user_id", userId);
                    FlyyFlutterPlugin.setFlyyNewUser(userId);
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const HomePage()));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    initialize();
  }

  bool validateReferralCode() {
    bool isValid = false;
    if (refCodeController.text.isEmpty) {
      refCodeError = "Referral Code Empty";
      isValid = false;
    } else {
      refCodeError = "";
      isValid = true;
    }
    return isValid;
  }

  void applyReferral(String referralCode) async {
    Map<String, dynamic> response =
        await FlyyFlutterPlugin.verifyReferralCode(referralCode);
    bool isValid = response["is_valid"];

    if (isValid) {
      FlyyFlutterPlugin.setFlyyReferralCode(referralCode);
      if (!mounted) return;
      const snackBar = SnackBar(content: Text("Referral Code Applied"));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      if (!mounted) return;
      const snackBar = SnackBar(content: Text("Invalid Referral Code"));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }

    FlyyFlutterPlugin.setFlyyReferralCode(referralCode);
  }

  bool validateUserId() {
    bool isValid = false;
    userId = userIdController.text;
    if (userId.isEmpty) {
      isValid = false;
      userIdError = "User Id Required";
    } else {
      isValid = true;
    }
    return isValid;
  }

  void initialize() async {
    preferences = await SharedPreferences.getInstance();
    String userId = preferences.getString("user_id") ?? "";
    if (userId.isNotEmpty) {
      setState(() {
        userIdController.text = userId;
      });
    }
  }
}
