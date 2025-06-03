import 'package:airspothealth/i18n/strings.g.dart';
import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(t.appSetup.privacyPolicyTitle),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Text(
          '''
AirSpot Pty Ltd ACN 668 699 278\n\n
This Privacy Policy describes how your personal information is collected, used, and shared when you visit or make a purchase from https://airspothealth.com/ (the "Site") or download, install and use the AirSpot Health App (the "App") for mobile devices.\n
PERSONAL INFORMATION WE COLLECT\n
When you visit the Site, or install the App, we automatically collect certain information about your device, including information about your web browser, IP address, time zone, and some of the cookies that are installed on your device. Additionally, as you browse the Site, we collect information about the individual web pages or products that you view, what websites or search terms referred you to the Site, and information about how you interact with the Site. We refer to this automatically-collected information as "Device Information.\n
The Site collects Device Information using the following technologies:\n
-\t"Cookies" are data files that are placed on your device or computer and often include an anonymous unique identifier. For more information about cookies, and how to disable cookies, visit http://www.allaboutcookies.org.
-\t"Log files" track actions occurring on the Site, and collect data including your IP address, browser type, Internet service provider, referring/exit pages, and date/time stamps.
-\t"Web beacons," "tags," and "pixels" are electronic files used to record information about how you browse the Site.
\n
Additionally when you make a purchase or attempt to make a purchase through the Site, or install the App, we collect certain information from you, including your name, billing address, shipping address, payment information (such as credit card numbers), email address, and phone number. We refer to this information as "Order Information.
\n
When we talk about "Personal Information" in this Privacy Policy, we are talking both about Device Information and Order Information.
\n
HOW DO WE USE YOUR PERSONAL INFORMATION?\n
We use the Order Information that we collect generally to fulfill any orders placed through the Site (including processing your payment information, arranging for shipping, and providing you with invoices and/or order confirmations). Additionally, we use this Order Information to:
-\tCommunicate with you
-\tScreen our orders for potential risk or fraud
-\tWhen in line with the preferences you have shared with us, provide you with information or advertising relating to our products or services.
\n
We use the Device Information that we collect to help us screen for potential risk and fraud (in particular, your IP address), and more generally to improve and optimize our Site (for example, by generating analytics about how our customers browse and interact with the Site, and to assess the success of our marketing and advertising campaigns).\n
SHARING YOUR PERSONAL INFORMATION
\n
We limit the use of your Personal Information to essential sharing with third parties, as described above. For example, we may use Shopify to power our online store – you can read more about how Shopify uses your Personal Information here: https://www.shopify.com/legal/privacy. We also use Google Analytics to help us understand how our customers use the Site – you can read more about how Google uses your Personal Information here: https://www.google.com/intl/en/policies/privacy/. You can also opt-out of Google Analytics here: https://tools.google.com/dlpage/gaoptout. If you make a purchase through Kickstarter, refer to this page for their privacy policy: https://legal.kickstarter.com/policies?name=privacy-policy
\n
Finally, we may also share your Personal Information to comply with applicable laws and regulations, to respond to a subpoena, search warrant or other lawful request for information we receive, or to otherwise protect our rights.
\n
BEHAVIOURAL ADVERTISING\n
As described above, we use your Personal Information to provide you with targeted advertisements or marketing communications we believe may be of interest to you. For more information about how targeted advertising works, you can visit the Network Advertising Initiative's ("NAI") educational page at http://www.networkadvertising.org/understanding-online-advertising/how-does-it-work.
\n
DO NOT TRACK\n
Please note that we do not alter our Site's data collection and use practices when we see a Do Not Track signal from your browser.\n
YOUR RIGHTS\n
If you are a European resident, you have the right to access personal information we hold about you and to ask that your personal information be corrected, updated, or deleted. If you would like to exercise this right, please contact us through the contact information below. Additionally, if you are a European resident we note that we are processing your information in order to fulfill contracts we might have with you (for example if you make an order through the Site), or otherwise to pursue our legitimate business interests listed above. Additionally, please note that your information will be transferred outside of Europe, including to Canada and the United States.
\n
DATA RETENTION\n
When you place an order through the Site, we will maintain your Order Information for our records unless and until you ask us to delete this information.
\n
MINORS\n
The Site is not intended for individuals under the age of 14 years.\n
CHANGES\n
We may update this privacy policy from time to time in order to reflect, for example, changes to our practices or for other operational, legal or regulatory reasons.\n
CONTACT US\n
For more information about our privacy practices, if you have questions, or if you would like to make a complaint, please contact us by e-mail at support@airspothealth.com
''',
          textAlign: TextAlign.justify,
        ),
      ),
    );
  }
}
