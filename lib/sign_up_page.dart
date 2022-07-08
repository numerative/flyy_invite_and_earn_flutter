import 'package:flutter/material.dart';
import 'package:flyy_flutter_plugin/flyy_flutter_plugin.dart';
import 'package:flyy_invite_earn_flutter/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({
    Key? key,
    required this.referralCode,
  }) : super(key: key);

  final ValueNotifier<String> referralCode;

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
    widget.referralCode.addListener(() {
      prefillReferralCode();
    });
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

  Future<bool> applyReferral(String referralCode) async {
    Map<String, dynamic> response =
        await FlyyFlutterPlugin.verifyReferralCode(referralCode);
    bool isValid = response["is_valid"];

    if (isValid) {
      FlyyFlutterPlugin.setFlyyReferralCode(referralCode);
      if (!mounted) return isValid;
      const snackBar = SnackBar(content: Text("Referral Code Applied"));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      if (!mounted) return isValid;
      const snackBar = SnackBar(content: Text("Invalid Referral Code"));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }

    FlyyFlutterPlugin.setFlyyReferralCode(referralCode);
    return isValid;
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

  /// Gets called if and when the Value Notifier variable receives a Referral
  /// Code from the [initFlyySDKWithReferralCallback].
  void prefillReferralCode() async {
    if (widget.referralCode.value.isNotEmpty) {
      bool isValid = await applyReferral(widget.referralCode.value);
      if (isValid) {
        refCodeController.text = widget.referralCode.value;
      }
    }
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
