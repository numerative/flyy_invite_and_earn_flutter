import 'package:flutter/material.dart';
import 'package:flyy_flutter_plugin/flyy_flutter_plugin.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late SharedPreferences preferences;
  final TextEditingController eventController = TextEditingController();
  String eventId = "";
  String eventIdError = "";
  final double verticalWidth = 250;

  @override
  void initState() {
    super.initState();
    initializeEventId();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 48),
            Row(
              children: [
                Expanded(
                  flex: 5,
                  child: TextField(
                    controller: eventController,
                    decoration: InputDecoration(
                        hintText: "Enter Event Id",
                        errorText: eventIdError.isEmpty ? null : eventIdError),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 3,
                  child: ElevatedButton(
                    onPressed: () {
                      bool isValid = validateEventId();
                      setState(() {});
                      if (isValid) sendEvent(eventController.text);
                      preferences.setString("event_id", eventController.text);
                    },
                    child: const Text("Send Event"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: verticalWidth,
              child: ElevatedButton(
                onPressed: () {
                  FlyyFlutterPlugin.openFlyyOffersPage();
                },
                child: const Text("Offers"),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: verticalWidth,
              child: ElevatedButton(
                onPressed: () {
                  FlyyFlutterPlugin.openFlyyReferralsPage();
                },
                child: const Text("Referral History"),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: verticalWidth,
              child: ElevatedButton(
                child: const Text("Referral Count"),
                onPressed: () async {
                  int count = await FlyyFlutterPlugin.getReferralCount();
                  final snackBar =
                      SnackBar(content: Text("$count Successful Referrals"));
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool validateEventId() {
    eventId = eventController.text;
    bool isValid = false;

    if (eventId.isEmpty) {
      eventIdError = "Event Id cannot be Empty";
      isValid = false;
    } else {
      eventIdError = "";
      isValid = true;
    }

    return isValid;
  }

  void sendEvent(String text) {
    //Note: Only use the sendEvent method in Staging. For production, make
    //an API call from your backend.
    //See: https://docs.theflyy.com/docs/create-and-track-your-first-offer#send-event-on-checkout
    FlyyFlutterPlugin.sendEvent(eventId, "true");
  }

  void initializeEventId() async {
    preferences = await SharedPreferences.getInstance();
    eventId = preferences.getString("event_id") ?? "kyc_done";

    if (eventId.isNotEmpty) {
      setState(() {
        eventController.text = eventId;
      });
    }
  }
}
