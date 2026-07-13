import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:temple/utils/secret.dart';
import 'package:temple/utils/colors.dart';
import 'package:temple/utils/constant.dart';
import 'package:temple/utils/dimensions.dart';
import 'package:temple/widget/big_text.dart';
import 'package:temple/widget/show_custom_snakbar.dart';
import 'package:http/http.dart' as http;

class SlotBookingPage extends StatefulWidget {
  const SlotBookingPage({Key? key}) : super(key: key);

  @override
  State<SlotBookingPage> createState() => _SlotBookingPageState();
}

class _SlotBookingPageState extends State<SlotBookingPage> {
  StreamController<String> selectedPujariController = StreamController();
  final _formKey = GlobalKey<FormState>();
  
  var pickDateController = TextEditingController();
  var pickTimeController = TextEditingController();
  var descriptionController = TextEditingController();
  var poojnameController = TextEditingController();
  var phoneNumberController = TextEditingController();
  var fullNameController = TextEditingController();

  @override
  void dispose() {
    pickDateController.dispose();
    pickTimeController.dispose();
    descriptionController.dispose();
    poojnameController.dispose();
    phoneNumberController.dispose();
    fullNameController.dispose();
    selectedPujariController.close();
    super.dispose();
  }

  var isLoading = false;

  @override
  Widget build(BuildContext context) {
    return isLoading == false
        ? Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.orange,
              elevation: 0,
              title: const Text(
                "Book A Slot",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
              ),
              iconTheme: const IconThemeData(color: Colors.white),
            ),
            body: Form(
              key: _formKey,
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: Dimensions.width20,
                    vertical: Dimensions.height10),
                child: SingleChildScrollView(
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Alert Banner block
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              "Book a Pooja Slot",
                              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 6),
                            Text(
                              "Fill in your details to reserve your preferred time slot.",
                              style: TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      BigText(text: "Your Name"),
                      const SizedBox(height: 8),
                      buildUsername(),
                      
                      const SizedBox(height: 16),
                      BigText(text: "Your Phone Number"),
                      const SizedBox(height: 8),
                      buildPhone(),
                      
                      const SizedBox(height: 16),
                      BigText(text: "Select Date"),
                      const SizedBox(height: 8),
                      buildDateTextField(),
                      
                      const SizedBox(height: 16),
                      BigText(text: "Select Time"),
                      const SizedBox(height: 8),
                      buildTimeTextField(),
                      
                      const SizedBox(height: 16),
                      BigText(text: "Name Of Pooja"),
                      const SizedBox(height: 8),
                      buildNameOfPooja(),
                      
                      const SizedBox(height: 16),
                      BigText(text: "Description of Pooja"),
                      const SizedBox(height: 8),
                      buildDescription(),

                      const SizedBox(height: 32),

                      // 🟢 BOTTOM OVERLAP FIXED: Safe structural spacing protection
                      SafeArea(
                        top: false,
                        left: false,
                        right: false,
                        bottom: true,
                        child: SizedBox(
                          height: 52,
                          width: double.infinity,
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
                                FocusScope.of(context).unfocus();
                                
                                if (isValid) {
                                  _formKey.currentState!.save();
                                  setState(() {
                                    isLoading = true;
                                  });
                                  
                                  await sendMail();
                                  
                                  pickDateController.clear();
                                  pickTimeController.clear();
                                  phoneNumberController.clear();
                                  fullNameController.clear();
                                  poojnameController.clear();
                                  descriptionController.clear();
                                  
                                  setState(() {
                                    isLoading = false;
                                  });
                                  
                                  Get.snackbar(
                                    "Booking Confirmed",
                                    "We have received your request successfully!",
                                    backgroundColor: Colors.orangeAccent,
                                    colorText: Colors.white,
                                  );
                                  Get.back(); // Redirect back to Home
                                }
                              } else {
                                showCustomSnakBar("Please Turn on Your Internet", title: "Attention");
                              }
                            },
                            child: const Text(
                              "Submit Booking",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        : const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Colors.orange),
            ),
          );
  }
  Widget buildDateTextField() {
    return TextFormField(
      readOnly: true,
      controller: pickDateController,
      decoration: InputDecoration(
        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(width: 2.0, color: Colors.orange)),
        labelText: 'Pick Date',
        labelStyle: const TextStyle(color: Colors.black54),
        suffixIcon: CircleAvatar(
          radius: Dimensions.radius20 * 5 / 4,
          backgroundColor: Colors.orange.withOpacity(0.1),
          child: IconButton(
            onPressed: () async {
              DateTime? newDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 180)),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(primary: Colors.orange),
                    ),
                    child: child!,
                  );
                },
              );
              if (newDate == null) return;
              setState(() {
                pickDateController.text = DateFormat('dd/MM/yyyy').format(newDate);
              });
            },
            icon: const Icon(Icons.date_range, color: Colors.orange),
          ),
        ),
        hintText: "DD/MM/YYYY",
        border: const OutlineInputBorder(),
      ),
      cursorColor: Colors.orange,
      validator: (value) {
        if (value!.isEmpty) return 'Please choose a date';
        if (!value.contains("/")) return 'Please select a valid date';
        return null;
      },
      onSaved: (value) => setState(() => pickDateController.text = value!),
    );
  }

  Widget buildTimeTextField() {
    return TextFormField(
      readOnly: true,
      controller: pickTimeController,
      decoration: InputDecoration(
        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(width: 2.0, color: Colors.orange)),
        labelText: 'Pick Time',
        labelStyle: const TextStyle(color: Colors.black54),
        suffixIcon: CircleAvatar(
          radius: Dimensions.radius20 * 5 / 4,
          backgroundColor: Colors.orange.withOpacity(0.1),
          child: IconButton(
            onPressed: () async {
              TimeOfDay? newTime = await showTimePicker(
                context: context, 
                initialTime: const TimeOfDay(hour: 9, minute: 0),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(primary: Colors.orange),
                    ),
                    child: child!,
                  );
                },
              );
              if (newTime == null) return;
              setState(() {
                pickTimeController.text = MaterialLocalizations.of(context).formatTimeOfDay(newTime);
              });
            },
            icon: const Icon(Icons.timer, color: Colors.orange),
          ),
        ),
        hintText: "HH:MM AM/PM",
        border: const OutlineInputBorder(),
      ),
      cursorColor: Colors.orange,
      validator: (value) => value!.isEmpty ? 'Please choose a time' : null,
      onSaved: (value) => setState(() => pickTimeController.text = value!),
    );
  }

  Widget buildPhone() {
    return TextFormField(
      keyboardType: TextInputType.phone,
      controller: phoneNumberController,
      decoration: const InputDecoration(
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(width: 2.0, color: Colors.orange)),
        labelText: 'Phone Number',
        labelStyle: TextStyle(color: Colors.black54),
        prefixIcon: Icon(Icons.call, color: Colors.orange),
        hintText: "Enter Mobile Number",
        border: OutlineInputBorder(),
      ),
      cursorColor: Colors.orange,
      validator: (value) {
        if (value!.isEmpty) return 'Enter a phone number';
        if (!GetUtils.isPhoneNumber(value)) return 'Enter a valid phone number';
        return null;
      },
    );
  }

  Widget buildUsername() {
    return TextFormField(
      controller: fullNameController,
      textCapitalization: TextCapitalization.words,
      decoration: const InputDecoration(
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(width: 2.0, color: Colors.orange)),
        prefixIcon: Icon(Icons.person, color: Colors.orange),
        labelText: 'Full Name',
        labelStyle: TextStyle(color: Colors.black54),
        hintText: "Name with Surname",
        border: OutlineInputBorder(),
      ),
      cursorColor: Colors.orange,
      validator: (value) {
        if (value!.isEmpty) return 'Please enter your name';
        if (value.length < 6) return 'Please write your full name';
        return null;
      },
    );
  }

  Widget buildNameOfPooja() {
    return TextFormField(
      controller: poojnameController,
      decoration: const InputDecoration(
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(width: 2.0, color: Colors.orange)),
        prefixIcon: Icon(Icons.fireplace, color: Colors.orange),
        labelText: 'Pooja',
        labelStyle: TextStyle(color: Colors.black54),
        hintText: "Name of Pooja",
        border: OutlineInputBorder(),
      ),
      cursorColor: Colors.orange,
      validator: (value) => value!.isEmpty ? 'Please enter a pooja name' : null,
    );
  }

  Widget buildDescription() {
    return TextFormField(
      maxLines: 3,
      controller: descriptionController,
      decoration: const InputDecoration(
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(width: 2.0, color: Colors.orange)),
        prefixIcon: Padding(
          padding: EdgeInsets.only(bottom: 40),
          child: Icon(Icons.info, color: Colors.orange),
        ),
        labelText: 'Description',
        labelStyle: TextStyle(color: Colors.black54),
        hintText: "Description about pooja setup instructions",
        border: OutlineInputBorder(),
      ),
      cursorColor: Colors.orange,
    );
  }

  Future sendMail() async {
    final url = Uri.parse("https://emailjs.com");
    final response = await http.post(
      url,
      headers: {'Content-type': 'application/json'},
      body: json.encode(
        {
          'service_id': SECRET.SLOT_BOOKING_SERVICE_ID,
          'template_id': SECRET.SLOT_BOOKING_TEMPLATE_ID,
          'user_id': SECRET.SLOT_BOOKING_USER_ID,
          'template_params': {
            'full_name': fullNameController.text,
            'message': descriptionController.text,
            'pooja_name': poojnameController.text,
            'pooja_time': pickTimeController.text,
            'pooja_date': pickDateController.text,
            'phone_number': phoneNumberController.text,
          }
        },
      ),
    );
    // print("EmailJS Status: ${response.statusCode}");
    // print("EmailJS Body: ${response.body}");
    return response;
  }
} // Final closing bracket for the entire class state
