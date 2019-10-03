import 'package:businesslibrary/data/user.dart';
import 'package:businesslibrary/util/page_util/data.dart';
import 'package:businesslibrary/util/page_util/intro_page_item.dart';
import 'package:businesslibrary/util/page_util/page_transformer.dart';
import 'package:businesslibrary/util/support/chat_page.dart';
import 'package:businesslibrary/util/support/contact_us.dart';
import 'package:businesslibrary/util/support_email.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class IntroPageView extends StatelessWidget implements IntroPageListener{
  final List<IntroItem> items;
  final User user;

  IntroPageView({this.items, this.user});
  BuildContext context;
  @override
  Widget build(BuildContext context) {
    this.context = context;
    return Scaffold(
      appBar: AppBar(
        title: Text('BFN'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.phone),
            onPressed: _onPhoneTapped,
          ),
          IconButton(
            icon: Icon(Icons.email),
            onPressed: _onEmailTapped,
          ),
          user == null? Container(): IconButton(
            icon: Icon(Icons.chat),
            onPressed: _onChatTapped,
          ),
        ],
      ),
      backgroundColor: Colors.brown.shade100,
      body: Center(
        child: SizedBox.fromSize(
          size: const Size.fromHeight(double.infinity),
          child: PageTransformer(
            pageViewBuilder: (context, visibilityResolver) {
              return PageView.builder(
                controller: PageController(viewportFraction: 0.90), pageSnapping: true,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final pageVisibility =
                      visibilityResolver.resolvePageVisibility(index);

                  return IntroPageItem(
                    item: item,
                    pageVisibility: pageVisibility,
                    listener: this,
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  onContactRequested() async{
    Navigator.pop(context);
    await Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new ContactUs()),
    );
  }

  void _onPhoneTapped() {
    print('IntroPageView._onPhoneTapped ...........');
    print('_ContactUsState._onPhoneTapped ............');
    launch("tel:0710441887");
  }
  String userType = 'Unknown';
  void _onEmailTapped() {
    print('_ContactUsState._onEmailTapped ............');
    print('_ContactUsState._onEmailTapped userType; $userType');
    assert(userType != null);
    Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => SupportEmail(userType)),
    );
  }

  void _onChatTapped() async{
    print('_ContactUsState._onChatTapped ............');
    var user =
    Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => ChatPage()),
    );
  }
}
