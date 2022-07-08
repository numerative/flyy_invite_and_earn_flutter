import 'package:flutter/material.dart';
import 'package:flyy_flutter_plugin/flyy_flutter_plugin.dart';
import 'package:flyy_invite_earn_flutter/sign_up_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SetupPage extends StatefulWidget {
  const SetupPage({Key? key}) : super(key: key);

  @override
  State<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  final TextEditingController _packageNameController = TextEditingController();
  final TextEditingController _partnerIdController = TextEditingController();
  String packageName = "", partnerId = "";

  String packageNameError = "", partnerIdError = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SDK Setup"),
      ),
      body: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 96),
                Image.asset(
                  "images/flyy_logo.png",
                  height: 50,
                ),
                const SizedBox(height: 48),
                TextField(
                  controller: _packageNameController,
                  decoration: InputDecoration(
                      hintText: "Package Name",
                      helperText: "from Settings > Connect SDK",
                      errorText:
                          packageNameError.isEmpty ? null : packageNameError),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _partnerIdController,
                  decoration: InputDecoration(
                      hintText: "Partner Id",
                      helperText: "from Settings > SDK Keys",
                      errorText:
                          partnerIdError.isEmpty ? null : partnerIdError),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                    onPressed: () async {
                      ValueNotifier<String> referralCode = ValueNotifier("");
                      bool isValid = validate();
                      setState(() {});
                      if (isValid) {
                        //Init SDK
                        FlyyFlutterPlugin.setPackageName(packageName);
                        FlyyFlutterPlugin.initFlyySDKWithReferralCallback(
                                partnerId, FlyyFlutterPlugin.STAGE)
                            .then((value) {
                          referralCode.value = value[0];
                          setState(() {});
                        });
                        storeCreds(packageName, partnerId);

                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) =>
                                SignUpPage(referralCode: referralCode)));
                      }
                    },
                    child: const Text("Next")),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    checkStoredSDKCreds();
  }

  void checkStoredSDKCreds() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    packageName = preferences.getString("package_name") ?? "";
    partnerId = preferences.getString("partner_id") ?? "";
    setState(() {
      _packageNameController.text = packageName;
      _partnerIdController.text = partnerId;
    });
  }

  bool validate() {
    bool isValid = false;
    if (_partnerIdController.text.isEmpty) {
      partnerIdError = "Partner Id cannot be Empty";

      isValid = false;
    } else {
      partnerIdError = "";
    }
    if (_packageNameController.text.isEmpty) {
      packageNameError = "Package Name cannot be Empty";
      isValid = false;
    } else {
      packageNameError = "";
    }
    if (_partnerIdController.text.isNotEmpty &&
        _packageNameController.text.isNotEmpty) {
      packageName = _packageNameController.text;
      partnerId = _partnerIdController.text;
      isValid = true;
    }
    return isValid;
  }

  void storeCreds(String packageName, String partnerId) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString("package_name", packageName);
    preferences.setString("partner_id", partnerId);
  }
}
