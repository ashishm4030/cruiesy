import 'dart:async';
import 'dart:io';

import 'package:cruisy/Constant/constant.dart';
import 'package:cruisy/Screens/ProfileSetting_Screen.dart';
import 'package:cruisy/Screens/SeeAllFeature_Screen.dart';
import 'package:cruisy/Widgets/BottomBar_Widget.dart';
import 'package:cruisy/Widgets/Button_Widget.dart';
import 'package:cruisy/Widgets/Text_Widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';

int isbusiness = 0;
int isbusinessUnlimited = 0;

class StoreScreen extends StatefulWidget {
  const StoreScreen({Key? key}) : super(key: key);

  @override
  _StoreScreenState createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> with SingleTickerProviderStateMixin {
  TabController? _tabController;
  List<IAPItem> _items = [];
  List<PurchasedItem> _purchases = [];
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _platformVersion = 'Unknown';
  StreamSubscription? _purchaseUpdatedSubscription;
  StreamSubscription? _purchaseErrorSubscription;
  StreamSubscription? _conectionSubscription;
  bool _loading = false;
  int _pageSelected = 0;
  bool Selected = false;
  PageController _pageController = PageController(initialPage: 0);

  List<String> Month = ['1 Month, 7 Day Trial', '3 Months', '12 Months'];
  List<String> Month1 = ['\$15.99 after 1 week', 'Save 46%', 'Save 66% - Best Deal'];
  List<String> Money = ['\$15.99', '\$25.99', '\$64.99'];
  List<String> PerDay = ['\$0.54 / day', '\$8.67 / mth', '\$5.42 / mth'];
  List<String> UMonth = ['1 Month', '3 Months', '12 Months'];
  List<String> UMoney = ['\$31.99', '\$51.99', '\$154.99'];
  List<String> UPerDay = ['£1.07 / day', '\$17.34 / mth', '\$12.92 / mth'];

  final List<String> _productLists = [
    "1.99_p1m",
    '10.99_p6m',
    '19.99_p1yr',
  ];

  getToken() async {
    var user_token = await getPrefData(key: 'UserToken');
    setState(() {
      userToken = user_token;
    });
  }

  getUserId() async {
    var user_id = await getPrefData(key: 'UserId');
    setState(() {
      userId = user_id;
    });
  }

  Future _getProduct() async {

    List<IAPItem> items = await FlutterInappPurchase.instance.getProducts(_productLists);
    print('========items======');
    print("items: $items");
    for (var item in items) {
      print('${item.toString()}');
      this._items.add(item);
    }
    setState(() {
      this._items = items;
      this._purchases = [];
    });
  }

  Future<void> initPlatformState() async {
    String platformVersion;

    try {
      platformVersion = (await FlutterInappPurchase.instance.platformVersion)!;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    var result = await FlutterInappPurchase.instance.initConnection;
    print('result: $result');

    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });

    try {
      String msg = await FlutterInappPurchase.instance.consumeAllItems;
      print('consumeAllItems: $msg');
    } catch (err) {
      print('consumeAllItems error: $err');
    }

    _purchaseUpdatedSubscription = FlutterInappPurchase.purchaseUpdated.listen((productItem) {
      if (Platform.isAndroid) {
        print('Purchased');
        print(productItem);
      } else {
        print('this is a ios platform subscription!');
        print('purchase Item: $productItem');
        if (productItem!.transactionId != null) {
          // sendReceiptToServer();
          print('sdbfh dhfj dshf sdfhfs:${productItem.transactionId}');
        } else {
          print('transactionId: ${productItem.transactionId}');
        }
      }
    });

    _purchaseErrorSubscription = FlutterInappPurchase.purchaseError.listen((purchaseError) {
      print('purchase-error: $purchaseError');
      setState(() {
        _loading = false;
      });
    });
  }

  _requestPurchase(String KeyOfPremium) async {
    setState(() {
      _loading = true;
    });
    try {
      await FlutterInappPurchase.instance.requestPurchase(KeyOfPremium);
      var data = await FlutterInappPurchase.instance.requestPurchase(KeyOfPremium);
      print(data);
      print('data');
    } on Exception catch (e) {
      print(e.toString());
    }
  }

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    // _getProduct();
    // initPlatformState();
    // getToken();
    // getUserId();
    print("isbusiness");
    print(isbusiness);
    super.initState();
  }

  @override
  void dispose() async {
    super.dispose();
    if (_conectionSubscription != null) {
      _conectionSubscription!.cancel();
      _conectionSubscription = null;
      _purchaseUpdatedSubscription!.cancel();
      _purchaseUpdatedSubscription = null;
      _purchaseErrorSubscription!.cancel();
      _purchaseErrorSubscription = null;
    }
    await FlutterInappPurchase.instance.endConnection;
  }

  List<String> TabText = ['Premium', 'Unlimited'];

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: kbackgroundColor,
      appBar: PreferredSize(
        preferredSize: Size(width, 50),
        child: SafeArea(
          child: Column(
            children: [
              TabBar(
                labelPadding: EdgeInsets.only(top: 20, bottom: 8),
                indicatorColor: Colors.white,
                unselectedLabelColor: klightGrey,
                labelColor: kGreyColor,
                controller: _tabController,
                tabs: List.generate(
                  TabText.length,
                  (index) => Text(
                    TabText[index],
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              Container(
                height: 1,
                color: klightGrey.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: height * 0.45,
                  width: width,
                  child: Stack(
                    children: [
                      PageView(
                        onPageChanged: (value) {
                          setState(() {
                            _pageSelected = value;
                          });
                        },
                        controller: _pageController,
                        children: <Widget>[
                          Container(
                            height: height,
                            width: width,
                            decoration: BoxDecoration(image: DecorationImage(image: AssetImage('assets/images/p2.JPEG'), fit: BoxFit.cover)),
                          ),
                          Container(
                            height: height,
                            width: width,
                            decoration: BoxDecoration(image: DecorationImage(image: AssetImage('assets/images/p4.JPEG'), fit: BoxFit.cover)),
                          ),
                          Container(
                            height: height,
                            width: width,
                            decoration: BoxDecoration(image: DecorationImage(image: AssetImage('assets/images/p3.JPEG'), fit: BoxFit.cover)),
                          ),
                          Container(
                            height: height,
                            width: width,
                            decoration: BoxDecoration(image: DecorationImage(image: AssetImage('assets/images/p6.JPEG'), fit: BoxFit.cover)),
                          ),
                          Container(
                            height: height,
                            width: width,
                            decoration: BoxDecoration(image: DecorationImage(image: AssetImage('assets/images/p8.JPEG'), fit: BoxFit.cover)),
                          ),
                          Container(
                            height: height,
                            width: width,
                            decoration: BoxDecoration(image: DecorationImage(image: AssetImage('assets/images/p2.JPEG'), fit: BoxFit.cover)),
                          ),
                          Container(
                            height: height,
                            width: width,
                            decoration: BoxDecoration(image: DecorationImage(image: AssetImage('assets/images/p4.JPEG'), fit: BoxFit.cover)),
                          ),
                          Container(
                            height: height,
                            width: width,
                            decoration: BoxDecoration(image: DecorationImage(image: AssetImage('assets/images/p3.JPEG'), fit: BoxFit.cover)),
                          ),
                          Container(
                            height: height,
                            width: width,
                            decoration: BoxDecoration(image: DecorationImage(image: AssetImage('assets/images/p6.JPEG'), fit: BoxFit.cover)),
                          ),
                        ],
                      ),
                      Positioned(
                        bottom: 15,
                        left: width * 0.32,
                        child: Row(
                          children: List.generate(
                            9,
                            (index) => Container(
                              margin: EdgeInsets.only(right: 5),
                              height: 10,
                              width: 10,
                              decoration: BoxDecoration(color: _pageSelected == index ? kPrimaryColor : Colors.white, shape: BoxShape.circle),
                            ),
                          ),
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IgnorePointer(
                            ignoring: true,
                            ignoringSemantics: true,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Column(
                                  children: [
                                    RegularText(
                                      'Join Premium',
                                      color: kPrimaryColor,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ],
                                ),
                                RegularText(
                                  ' and chat',
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                ),
                              ],
                            ),
                          ),
                          RegularText(
                            'with 600 Users',
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  children: List.generate(
                    Month.length,
                    (index) => Column(
                      children: [
                        Container(
                          height: 0.9,
                          color: klightGrey,
                        ),
                        Container(
                          width: width,
                          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                          child: Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RegularText(
                                    Month[index],
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                  RegularText(
                                    Month1[index],
                                    fontSize: 14,
                                    color: index == 0 ? klightGrey : Color(0xff5bfa8d),
                                  ),
                                ],
                              ),
                              Spacer(),
                              Container(
                                width: width * 0.3,
                                padding: EdgeInsets.symmetric(
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(color: kPrimaryColor, borderRadius: BorderRadius.circular(8)),
                                child: Column(
                                  children: [
                                    RegularText(
                                      Money[index],
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                    RegularText(
                                      PerDay[index],
                                      color: Colors.white,
                                      fontSize: 10,
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        Container(
                          height: 0.9,
                          color: klightGrey,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 25,
                ),
                isbusiness == 1 || isbusinessUnlimited == 1
                    ? DisableButton(text: 'Continue')
                    : CostumeButton(
                        onTap: () {
                          setState(() {
                            isbusiness = 1;
                            print("isbusiness");
                            print(isbusiness);
                          });
                          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => BottomBar()), (route) => false);
                          Toasty.showtoast("Your Subscription Successfully");
                          // if (Selected == 0) {
                          //   _requestPurchase(_productLists[0]);
                          // } else if (Selected == 1) {
                          //   _requestPurchase(_productLists[1]);
                          // } else {
                          //   _requestPurchase(_productLists[2]);
                          // }
                        },
                        text: 'Continue',
                      ),
                SizedBox(
                  height: isbusiness == 1 || isbusinessUnlimited == 1 ? 100 : 150,
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: height * 0.035,
                ),
                Image.asset(
                  'assets/images/Unlimited.png',
                  scale: 4,
                ),
                SizedBox(
                  height: height * 0.02,
                ),
                Center(
                  child: RegularText(
                    '      Unlimited Profiles\nViewed Me Typing Status\n              Incognito\n                Unsend\n        All Xtra Features',
                    color: Colors.white,
                    fontSize: 22,
                  ),
                ),
                SizedBox(
                  height: height * 0.02,
                ),
                Column(
                  children: List.generate(
                    3,
                    (index) => Column(
                      children: [
                        Container(
                          height: 0.9,
                          color: klightGrey,
                        ),
                        Container(
                          width: width,
                          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                          child: Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RegularText(
                                    UMonth[index],
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                  index == 1
                                      ? RegularText(
                                          'Save 46%',
                                          color: Color(0xff5bfa8d),
                                        )
                                      : Container(),
                                  index == 2
                                      ? RegularText(
                                          'Save 60%',
                                          color: Color(0xff5bfa8d),
                                        )
                                      : Container(),
                                ],
                              ),
                              Spacer(),
                              Container(
                                width: width * 0.3,
                                padding: EdgeInsets.symmetric(
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(color: kPrimaryColor, borderRadius: BorderRadius.circular(8)),
                                child: Column(
                                  children: [
                                    RegularText(
                                      UMoney[index],
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                    RegularText(
                                      UPerDay[index],
                                      color: Colors.white,
                                      fontSize: 10,
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        Container(
                          height: 0.9,
                          color: klightGrey,
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 15),
                  child: LogoutButton(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => SeeAllFeatureScreen()));
                    },
                    text: 'See All Features',
                  ),
                ),
                SizedBox(
                  height: 25,
                ),
                isbusiness == 1 || isbusinessUnlimited == 1
                    ? DisableButton(text: 'Continue')
                    : CostumeButton(
                        onTap: () {
                          setState(() {
                            isbusinessUnlimited = 1;
                            print("isbusinessUnlimited");
                            print(isbusinessUnlimited);
                          });
                          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => BottomBar()), (route) => false);
                          Toasty.showtoast("Your Unlimited Subscription Successfully");
                          // if (Selected == 0) {
                          //   _requestPurchase(_productLists[0]);
                          // } else if (Selected == 1) {
                          //   _requestPurchase(_productLists[1]);
                          // } else {
                          //   _requestPurchase(_productLists[2]);
                          // }
                        },
                        text: 'Continue',
                      ),
                SizedBox(
                  height: isbusiness == 1 || isbusinessUnlimited == 1 ? 100 : 150,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
