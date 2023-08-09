import 'package:carpool_app/main/auth_pages/signup_widgets/shared_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:checkbox_formfield/checkbox_formfield.dart';
import '../../utils/terms_as_str.dart';

class TermAgreement extends StatefulWidget {
  /// FormState Key used to Verify the User has agreed to App Terms
  GlobalKey<FormState> formKey;

  /// Class to house User Information as it is obtained during signup process
  UserData user;

  TermAgreement({super.key, required this.user, required this.formKey});

  @override
  State<TermAgreement> createState() => _TermAgreementState();
}

class _TermAgreementState extends State<TermAgreement> {
  /// Controller for the Scrollable User Terms
  final ScrollController _controller = ScrollController();

  /// All terms section titles, used as headers in terms view
  final List<String> sectionTitles = TermsOfService.getTermSectionTitles();

  /// All terms section contents, used as paragraphs in terms view
  final List<String> sectionsContents = TermsOfService.getTermSectionContents();

  @override
  Widget build(BuildContext context) {
    /// Height double obtained via MediaQuery, used in dyanmic sizing
    double height = MediaQuery.of(context).size.height;

    /// Width double obtained via MediaQuery, used in dyanmic sizing
    double width = MediaQuery.of(context).size.width;
    return Container(
      padding: EdgeInsets.all(width * 0.04),
      child: Center(
        child: SingleChildScrollView(
          child: Column(children: [
            // Formatted title/subtitle widget, defined in shared widgets file
            const SignupTitle('Welcome to HuskyExpress',
                'Please read and accept our User Agreement'),
            SizedBox(height: height * 0.0036),
            Container(
              height: height * 0.6,
              decoration: BoxDecoration(
                  border: Border.all(
                color: Colors.red,
                width: 1.5,
              )),
              // Custom scrollview for nested box scrollability of terms
              child: CustomScrollView(
                controller: _controller,
                slivers: [
                  // SliverList to build the Terms and Conditions
                  SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                    return Padding(
                      padding: EdgeInsets.all(width * 0.02),
                      child: Container(
                        alignment: Alignment.center,
                        // Static method from helper class to format Term Sections
                        child: TermsOfService.getFormattedTermSection(
                            sectionTitles[index], sectionsContents[index]),
                      ),
                    );
                  }, childCount: sectionTitles.length))
                ],
              ),
            ),
            SizedBox(height: height * 0.00032),
            // Form with checkbox form field [from dependency] to verify Term Agreement
            Form(
              key: widget.formKey,
              child: CheckboxListTileFormField(
                title: Text(
                  ' I Agree to these Terms of Service',
                  style: TextStyle(fontSize: width * 0.04),
                ),
                // Initially set to false in UserData
                initialValue: widget.user.agreedToTerms,
                autovalidateMode: AutovalidateMode.always,
                checkColor: Colors.white,
                dense: true,
                // Updates to true if box checked
                onChanged: (value) {
                  widget.user.agreedToTerms = value;
                },
                // Validator for use with key in parent SignUp Page to control
                // sign-up navigation iteratively
                validator: (bool? value) {
                  if (value == false) {
                    return 'Must Agree to Terms of Service to Continue';
                  }
                  return null;
                },
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
