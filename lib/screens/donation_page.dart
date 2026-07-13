import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:temple/models/donation_model.dart';
import 'package:temple/screens/donation_status_page.dart';
import 'package:temple/utils/secret.dart';
import 'package:temple/utils/colors.dart';
import 'package:temple/utils/async_utils.dart';
import 'package:temple/utils/constant.dart' as CustomConstant;
import 'package:temple/utils/dimensions.dart';
import 'package:temple/widget/big_text.dart';
import 'package:temple/widget/show_custom_snakbar.dart';
import 'package:temple/widget/small_text.dart';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';

class DontaionPage extends StatefulWidget {
  const DontaionPage({Key? key}) : super(key: key);

  @override
  State<DontaionPage> createState() => _DontaionPageState();
}

class _DontaionPageState extends State<DontaionPage> {
  final _formKey = GlobalKey<FormState>();
  
  late final TextEditingController fullNameController;
  late final TextEditingController emailAddressController;
  late final TextEditingController phoneNumberController;
  late final TextEditingController addressController;
  late final TextEditingController countryController;
  late final TextEditingController donationAmountController;
  late final TextEditingController donationCommentsController;

  bool isAnonymous = false;
  bool _isLoading = false;

  final Razorpay _razorpay = Razorpay();

  void _openCheckout() {
    var options = {
      'key': SECRET.RAZORPAY_SECRED_ID,
      'amount': num.parse(donationAmountController.text) * 100, // Converts Rupees to Paisa
      'name': 'Jagannath Mandir',
      'description': 'Payment for Your Temple Donation',
      'prefill': {
        'contact': phoneNumberController.text.trim(), 
        'email': emailAddressController.text.trim()
      },
      "theme": {"color": "#FF9800"}, // Syncs Razorpay loader color accent with your orange theme
    };
    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint("Razorpay display error: ${e.toString()}");
    }
  }

  Future<int> sendMail() async {
    final url = Uri.parse("https://emailjs.com");
    try {
      final response = await http.post(
        url,
        headers: {'Content-type': 'application/json'},
        body: json.encode(
          {
            'service_id': SECRET.DONATION_SERVICE_ID,
            'template_id': SECRET.DONATION_TEMPLATE_ID,
            'user_id': SECRET.DONATION_USER_ID,
            'template_params': {
              'full_name': isAnonymous ? "Anonymous Devotee" : fullNameController.text,
              'address': addressController.text,
              'country': countryController.text,
              'donation_amount': donationAmountController.text,
              'donation_message': donationCommentsController.text,
              'email_address': emailAddressController.text,
              'phone_number': phoneNumberController.text,
              'is_anonymous': isAnonymous,
            },
            'accessToken': "6xctMol37DLDtlHVif-W7"
          },
        ),
      );
      return response.statusCode;
    } catch (e) {
      debugPrint("Background receipt email dispatch failure: $e");
      return 500;
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    setState(() => _isLoading = true);
    try {
      await addDonationForm();
      await sendMail();
      
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DonationStatusPage(status: 1)),
      );

      fullNameController.clear();
      emailAddressController.clear();
      phoneNumberController.clear();
      addressController.clear();
      countryController.clear();
      donationAmountController.clear();
      donationCommentsController.clear();
    } catch (e) {
      debugPrint("Success callback execution exception: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint("Razorpay Gateway Error: ${response.code} -- ${response.message}");
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DonationStatusPage(status: 0)),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print("RazorWallet Target Selection: " + response.walletName!);
  }

  @override
  void initState() {
    super.initState();
    fullNameController = TextEditingController();
    emailAddressController = TextEditingController();
    phoneNumberController = TextEditingController();
    addressController = TextEditingController();
    countryController = TextEditingController();
    donationAmountController = TextEditingController();
    donationCommentsController = TextEditingController();

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    fullNameController.dispose();
    emailAddressController.dispose();
    phoneNumberController.dispose();
    addressController.dispose();
    countryController.dispose();
    donationAmountController.dispose();
    donationCommentsController.dispose();
    super.dispose();
  }

  CollectionReference donation = FirebaseFirestore.instance.collection('donation');

  Future<void> addDonationForm() async {
    final form = DonationModel(
      fullName: isAnonymous ? "Anonymous" : fullNameController.text,
      emailAddress: emailAddressController.text,
      phoneNumber: phoneNumberController.text,
      message: donationCommentsController.text,
      submitedAt: DateTime.now(),
      amount: double.parse(donationAmountController.text),
      address: addressController.text,
      country: countryController.text,
      isAnonymous: isAnonymous,
    );

    try {
      await runWithTimeout(
        donation.add(form.toJson()),
        timeout: const Duration(seconds: 12),
      );
    } catch (error) {
      debugPrint('Donation: submission failed: $error');
      if (mounted) {
        showCustomSnakBar('Database write timed out. Data will sync once network returns.', title: 'Network Notice');
      }
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.orange,
          elevation: 0,
          title: const Text(
            "Donation",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: !_isLoading
            ? Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Container(
                  padding: EdgeInsets.all(Dimensions.width10),
                  child: SingleChildScrollView(
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Dynamic Alert Information Banner
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                "Support Your Mandir",
                                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 6),
                              Text(
                                "Your contributions support daily sewa, prasad distribution, and temple maintenance operations.",
                                style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.orange.shade100),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.orange.withOpacity(0.04),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ]),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              BigText(text: "Your Information", size: Dimensions.font20),
                              const SizedBox(height: 20),
                              
                              buildUsername(),
                              const SizedBox(height: 16),
                              
                              buildEmail(),
                              const SizedBox(height: 16),
                              
                              buildPhone(),
                              const SizedBox(height: 16),
                              
                              buildAddress(),
                              const SizedBox(height: 16),
                              
                              buildCountry(),
                              const SizedBox(height: 24),
                              
                              // Anonymous Option Interactive Checkbox Layer
                              Row(
                                children: [
                                  Checkbox(
                                    value: isAnonymous,
                                    activeColor: Colors.orange,
                                    onChanged: (value) {
                                      setState(() {
                                        isAnonymous = value ?? false;
                                      });
                                    },
                                  ),
                                  const Expanded(
                                    child: Text(
                                      "Keep my donation anonymous",
                                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
                                    ),
                                  ),
                                ],
                              ),
                              
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Divider(color: Colors.black12, thickness: 1),
                              ),
                              
                              BigText(text: "Contribution Parameters", size: Dimensions.font20),
                              const SizedBox(height: 20),
                              
                              buildDonation(),
                              const SizedBox(height: 16),
                              
                              buildDonationComments(),
                              const SizedBox(height: 12),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // 🟢 BOTTOM OVERLAP FIXED: Safe padding pushes buttons above hardware swipe indicators
                        SafeArea(
                          top: false,
                          left: false,
                          right: false,
                          bottom: true,
                          child: SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                              onPressed: () async {
                                var connectivityResult = await Connectivity().checkConnectivity();
                                if (connectivityResult != ConnectivityResult.none) {
                                  final isValid = _formKey.currentState!.validate();
                                  FocusScope.of(context).unfocus(); // Drops keyboard smoothly
                                  
                                  if (isValid) {
                                    _formKey.currentState!.save();
                                    
                                    // Security Validation: Ensure transaction token contains legal numeric layout values
                                    final rawAmount = donationAmountController.text.trim();
                                    if (num.tryParse(rawAmount) != null && num.parse(rawAmount) > 0) {
                                      _openCheckout(); // Launches Razorpay overlay view panel
                                    } else {
                                      showCustomSnakBar("Please specify a valid financial amount block.", title: "Input Error");
                                    }
                                  }
                                } else {
                                  showCustomSnakBar("Please Turn on Your Internet", title: "Attention");
                                }
                              },
                              child: const Text(
                                "Confirm & Pay",
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              )
            : const Center(child: CircularProgressIndicator(color: Colors.orange)));
  }

  Widget buildUsername() {
    return TextFormField(
      controller: fullNameController,
      textCapitalization: TextCapitalization.words,
      enabled: !isAnonymous,
      decoration: InputDecoration(
        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(width: 2.0, color: Colors.orange)),
        prefixIcon: const Icon(Icons.person_outline, color: Colors.orange),
        labelText: 'Full Name',
        labelStyle: TextStyle(color: isAnonymous ? Colors.grey : Colors.black54),
        hintText: "Name with Surname",
        border: const OutlineInputBorder(),
      ),
      cursorColor: Colors.orange,
      validator: (value) {
        if (!isAnonymous) {
          if (value == null || value.trim().isEmpty) return 'Please enter your name';
          if (value.trim().length < 6) return 'Please write your full name';
        }
        return null;
      },
      onSaved: (value) => setState(() => fullNameController.text = value!),
    );
  }

  Widget buildEmail() {
    return TextFormField(
      controller: emailAddressController,
      keyboardType: TextInputType.emailAddress,
      enabled: !isAnonymous,
      decoration: InputDecoration(
        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(width: 2.0, color: Colors.orange)),
        labelText: 'Email Address',
        labelStyle: TextStyle(color: isAnonymous ? Colors.grey : Colors.black54),
        hintText: "name@example.com",
        helperText: "Used exclusively to transmit transaction receipt documents.",
        helperStyle: const TextStyle(fontSize: 11),
        prefixIcon: const Icon(Icons.mail_outlined, color: Colors.orange),
        border: const OutlineInputBorder(),
      ),
      cursorColor: Colors.orange,
      validator: (value) {
        if (!isAnonymous) {
          if (value == null || value.trim().isEmpty) return 'Please enter your email';
          if (!GetUtils.isEmail(value.trim())) return 'Please enter a valid email address';
        }
        return null;
      },
      onSaved: (value) => setState(() => emailAddressController.text = value!),
    );
  }

  Widget buildPhone() {
    return TextFormField(
      keyboardType: TextInputType.phone,
      controller: phoneNumberController,
      enabled: !isAnonymous,
      decoration: InputDecoration(
        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(width: 2.0, color: Colors.orange)),
        labelText: 'Phone Number',
        labelStyle: TextStyle(color: isAnonymous ? Colors.grey : Colors.black54),
        hintText: "Enter Mobile Number",
        prefixIcon: const Icon(Icons.call_outlined, color: Colors.orange),
        border: const OutlineInputBorder(),
      ),
      cursorColor: Colors.orange,
      validator: (value) {
        if (!isAnonymous) {
          if (value == null || value.trim().isEmpty) return 'Enter a phone number';
          if (!GetUtils.isPhoneNumber(value.trim())) return 'Enter a valid phone number';
        }
        return null;
      },
      onSaved: (value) => setState(() => phoneNumberController.text = value!),
    );
  }

  Widget buildAddress() {
    return TextFormField(
      controller: addressController,
      maxLines: 2,
      enabled: !isAnonymous,
      decoration: InputDecoration(
        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(width: 2.0, color: Colors.orange)),
        labelText: 'Address',
        labelStyle: TextStyle(color: isAnonymous ? Colors.grey : Colors.black54),
        hintText: "Home Address",
        prefixIcon: Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Icon(Icons.location_on_outlined, color: isAnonymous ? Colors.grey : Colors.orange),
        ),
        border: const OutlineInputBorder(),
      ),
      cursorColor: Colors.orange,
      validator: (value) {
        if (!isAnonymous && (value == null || value.trim().isEmpty)) {
          return 'Please specify your address';
        }
        return null;
      },
      onSaved: (value) => setState(() => addressController.text = value!),
    );
  }

  Widget buildCountry() {
    return TextFormField(
      controller: countryController,
      textCapitalization: TextCapitalization.words,
      enabled: !isAnonymous,
      decoration: InputDecoration(
        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(width: 2.0, color: Colors.orange)),
        labelText: 'Country',
        labelStyle: TextStyle(color: isAnonymous ? Colors.grey : Colors.black54),
        hintText: "Your Country",
        prefixIcon: Icon(Icons.location_city_outlined, color: isAnonymous ? Colors.grey : Colors.orange),
        border: const OutlineInputBorder(),
      ),
      cursorColor: Colors.orange,
      validator: (value) {
        if (!isAnonymous && (value == null || value.trim().isEmpty)) {
          return 'Please specify your country';
        }
        return null;
      },
      onSaved: (value) => setState(() => countryController.text = value!),
    );
  }

  Widget buildDonation() {
    return TextFormField(
      controller: donationAmountController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: const InputDecoration(
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(width: 2.0, color: Colors.orange)),
        labelText: 'Amount',
        labelStyle: TextStyle(color: Colors.black54),
        hintText: "Amount In INR (₹)",
        prefixIcon: Icon(Icons.currency_rupee_outlined, color: Colors.orange),
        border: OutlineInputBorder(),
      ),
      cursorColor: Colors.orange,
      validator: (value) {
        if (value == null || value.trim().isEmpty) return "Enter an Amount for your donation";
        final parsed = num.tryParse(value.trim());
        if (parsed == null || parsed <= 0) return 'Please enter a valid numeric transaction amount';
        return null;
      },
      onSaved: (value) => setState(() => donationAmountController.text = value!),
    );
  }

  Widget buildDonationComments() {
    return TextFormField(
      controller: donationCommentsController,
      maxLines: 3,
      decoration: const InputDecoration(
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(width: 2.0, color: Colors.orange)),
        labelText: 'Comments',
        labelStyle: TextStyle(color: Colors.black54),
        hintText: "Extra Message For Your Donation (Optional)",
        prefixIcon: Padding(
          padding: EdgeInsets.only(bottom: 40),
          child: Icon(Icons.info_outline, color: Colors.orange),
        ),
        border: OutlineInputBorder(),
      ),
      cursorColor: Colors.orange,
      onSaved: (value) => setState(() => donationCommentsController.text = value!),
    );
  }
} // Final closing bracket for the entire class state
