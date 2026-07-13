import 'package:get/get.dart';
import 'package:temple/screens/contact_us_page.dart';
import 'package:temple/screens/donation_page.dart';
import 'package:temple/screens/gallery_page.dart';
import 'package:temple/screens/donation_status_page.dart';
import 'package:temple/screens/slot_booking/slot_booking_page.dart';

// Authentication Screens Imports
import 'package:temple/screens/auth/login_page.dart';
// import 'package:temple/screens/auth/verify_otp_page.dart';

import '../screens/about_us/about_us_page.dart';
import '../screens/circulars_page.dart';
import '../screens/home_page.dart';
import '../screens/splash_screen.dart';
import '../screens/books_management/books_dashboard_page.dart';
import '../screens/sewa_management/sewa_dashboard_page.dart';
import '../screens/books_management/inventory_page.dart';
import '../screens/books_management/sales_page.dart';
import '../screens/books_management/books_reports_page.dart';
import '../screens/sewa_management/sewa_programs_page.dart';
import '../screens/sewa_management/sewa_program_details_page.dart';
import 'package:temple/screens/auth/signup_page.dart';

class RouteHelper {
  static const String splashPage = '/splash-page';
  static const String loginPage = '/login';       // 🟢 Added
  static const String verifyOtpPage = '/verify-otp'; // 🟢 Added
  static const String initial = '/';
  static const String aboutUsPage = '/about-us-page';
  static const String contactUsPage = '/contact-us-page';
  static const String galleryPage = '/gallery-page';
  static const String donationPage = '/donation-page';
  static const String slotBookPage = '/slot-book-page';
  static const String dontaionSuccessPage = '/donation-success-page';
  static const String circularPage = '/circular-page';
  static const String booksDashboardPage = '/books-dashboard-page';
  static const String sewaDashboardPage = '/sewa-dashboard-page';
  static const String booksInventoryPage = '/books-inventory-page';
  static const String booksSalesPage = '/books-sales-page';
  static const String booksReportsPage = '/books-reports-page';
  static const String sewaProgramsPage = '/sewa-programs-page';
  static const String sewaProgramDetailsPage = '/sewa-program-details-page';
  static const String signupPage = '/signup';


  static String getSplashPage() => splashPage;
  static String getLoginPage() => loginPage;       // 🟢 Added
  static String getVerifyOtpPage() => verifyOtpPage; // 🟢 Added
  static String getInitial() => initial;
  static String getAboutUsPage() => aboutUsPage;
  static String getContactUsPage() => contactUsPage;
  static String getDonationPage() => donationPage;
  static String getGalleryPage() => galleryPage;
  static String getSlotBookPage() => slotBookPage;
  static String getDonationStatusPage() => dontaionSuccessPage;
  static String getCircularPage() => circularPage;
  static String getBooksDashboardPage() => booksDashboardPage;
  static String getSewaDashboardPage() => sewaDashboardPage;
  static String getBooksInventoryPage() => booksInventoryPage;
  static String getBooksSalesPage() => booksSalesPage;
  static String getBooksReportsPage() => booksReportsPage;
  static String getSewaProgramsPage() => sewaProgramsPage;
  static String getSewaProgramDetailsPage() => sewaProgramDetailsPage;

  static List<GetPage> routes = [
    GetPage(
        name: splashPage,
        page: () => const SplashScreen(),
        transition: Transition.fadeIn),
    // 1. LOGIN ROUTE CONFIGURATION
    GetPage(
        name: loginPage,
        page: () => const LoginPage(),
        transition: Transition.fade),
    GetPage(
        name: signupPage,
        page: () => const SignupPage(),
        transition: Transition.rightToLeftWithFade),
    // 2. OTP VERIFICATION ROUTE CONFIGURATION
    // GetPage(
    //     name: verifyOtpPage,
    //     page: () => const VerifyOtpPage(),
    //     transition: Transition.rightToLeftWithFade),
    GetPage(
        name: initial,
        page: () => const HomePage(),
        transition: Transition.fadeIn),
    GetPage(
      name: aboutUsPage,
      page: () => const AboutUsPage(),
    ),
    GetPage(
      name: contactUsPage,
      page: () => const ContactUsPage(), // Removed duplicated block and fixed non-const constructor formatting
    ),
    GetPage(
      name: donationPage,
      page: () => const DontaionPage(),
    ),
    GetPage(
      name: galleryPage,
      page: () => const GalleryPage(),
    ),
    GetPage(
      name: slotBookPage,
      page: () => SlotBookingPage(),
    ),
    GetPage(
      name: dontaionSuccessPage,
      page: () => DonationStatusPage(status: 1),
    ),
    GetPage(
      name: circularPage,
      page: () => CircularPage(),
    ),
    GetPage(
      name: booksDashboardPage,
      page: () => const BooksDashboardPage(),
    ),
    GetPage(
      name: sewaDashboardPage,
      page: () => const SewaDashboardPage(),
    ),
    GetPage(
      name: booksInventoryPage,
      page: () => const InventoryPage(),
    ),
    GetPage(
      name: booksSalesPage,
      page: () => const SalesPage(),
    ),
    GetPage(
      name: booksReportsPage,
      page: () => const BooksReportsPage(),
    ),
    GetPage(
      name: sewaProgramsPage,
      page: () => const SewaProgramsPage(),
    ),
    GetPage(
      name: sewaProgramDetailsPage,
      page: () {
        final args = Get.arguments as Map<String, dynamic>?;
        return SewaProgramDetailsPage(
          programId: args?['id'] ?? '',
          programTitle: args?['title'] ?? 'Program Details',
        );
      },
    )
  ];
}
