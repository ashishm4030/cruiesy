import 'package:cruisy/Constant/constant.dart';
import 'package:cruisy/Widgets/Appbar_Widget.dart';
import 'package:cruisy/Widgets/Text_Widget.dart';
import 'package:flutter/material.dart';

class SeeAllFeatureScreen extends StatefulWidget {
  const SeeAllFeatureScreen({Key? key}) : super(key: key);

  @override
  _SeeAllFeatureScreenState createState() => _SeeAllFeatureScreenState();
}

class _SeeAllFeatureScreenState extends State<SeeAllFeatureScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kbackgroundColor,
      appBar: CostumeAppBar(
        text: 'Unlimited Features',
        bool: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Feature(
              text: '	• 	Unlimited profiles (Scroll forever)',
            ),
            Feature(
              text: '	• 	Unlimited profiles (Scroll forever)',
            ),
            Feature(
              text: '	• 	Profiles search box',
            ),
            Feature(
              text: '	• 	Unlimited favorites and blocks',
            ),
            Feature(
              text: '	• 	Show me people near (Google Maps Integration)',
            ),
            Feature(
              text: '	• 	See who’s online right now',
            ),
            Feature(
              text: '	• 	Viewed Me. Last 24 hours of views',
            ),
            Feature(
              text: '	• 	Incognito Mode. Go off the grid',
            ),
            Feature(
              text: '	• 	Unlimited chat and video chat',
            ),
            Feature(
              text: '	• 	Typing Status: See when they’re typing',
            ),
            Feature(
              text: '	• 		Unsend: Undo sent messages & photos',
            ),
            Feature(
              text: '	• 	Expiring Photos: no screenshot available',
            ),
            Feature(
              text: '	• 	Chat Translate: speak the same language',
            ),
            Feature(
              text: '	• 	Create chat group',
            ),
            Feature(
              text: '	• 	Save your favorite phrases for easier chat',
            ),
            Feature(
              text: '	• 	Send multiple photos at once (webserver auto delete)*',
            ),
            Feature(
              text: '	• 	Show read receipts',
            ),
            Feature(
              text: '	• 	Mark who I have chatted with',
            ),
            Feature(
              text: '	• 	Search Messages box',
            ),
          ],
        ),
      ),
    );
  }
}

class Feature extends StatelessWidget {
  final String text;
  Feature({
    Key? key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
      child: RegularText(
        text,
        color: Colors.white,
        fontSize: 12,
      ),
    );
  }
}
