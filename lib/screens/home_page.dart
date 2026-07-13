import 'dart:async'; // Required for Timer auto-scroll operations
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:temple/routes/route_helper.dart';
import 'package:temple/utils/dimensions.dart';
import 'package:temple/widget/drawer.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  PageController pageController = PageController(viewportFraction: 0.85);
  var currPageValue = 0.0;
  double scaleFactor = 0.8;
  final double _height = 160;

  // Background timer tracking variable for the slider auto-movement
  Timer? _sliderTimer;

  // Firebase Firestore Collection References
  final CollectionReference _sliderCollection = FirebaseFirestore.instance.collection('slider_images');
  final CollectionReference _eventsCollection = FirebaseFirestore.instance.collection('temple_events');

  @override
  void initState() {
    super.initState();
    pageController.addListener(() {
      setState(() {
        currPageValue = pageController.page!;
      });
    });
  }

  // Timer loop method to calculate and shift slider pages automatically
  void _startAutoScroll(int totalItems) {
    if (_sliderTimer != null || totalItems <= 1) return;

    _sliderTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (pageController.hasClients) {
        int nextPage = pageController.page!.floor() + 1;
        if (nextPage >= totalItems) {
          nextPage = 0; // Seamlessly wraps back to the first slide
        }
        pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _sliderTimer?.cancel(); // Prevents memory leaks by stopping the timer
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const CustomeDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.orange,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          "Jagannath Temple",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. DYNAMIC SLIDER SECTION (WITH AUTO-MOVE LOGIC)
            StreamBuilder<QuerySnapshot>(
              stream: _sliderCollection.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const SizedBox(height: 160, child: Center(child: CircularProgressIndicator(color: Colors.orange)));
                }
                
                final sliderDocs = snapshot.data!.docs;
                
                // Safely fires up the slider timer cycle once database items compile into view
                WidgetsBinding.instance.addPostFrameCallback((_) => _startAutoScroll(sliderDocs.length));
                
                return Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          height: 120,
                          decoration: const BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(left: 20, top: 10),
                              child: Text(
                                "Temples",
                                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              height: _height,
                              child: PageView.builder(
                                controller: pageController,
                                itemCount: sliderDocs.length,
                                itemBuilder: (context, position) {
                                  final data = sliderDocs[position].data() as Map<String, dynamic>;
                                  final imageUrl = data['url'] ?? '';
                                  return _buildPageItem(position, imageUrl);
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: DotsIndicator(
                        dotsCount: sliderDocs.length,
                        position: currPageValue.clamp(0.0, (sliderDocs.length - 1).toDouble()),
                        decorator: DotsDecorator(
                          activeColor: Colors.orange,
                          size: const Size.square(8),
                          activeSize: const Size(16, 8),
                          activeShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            // LIVE DARSHAN SECTION
            _buildSectionHeader("Live Darshan"),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(child: _buildLiveCard("assets/images/event1.jpg")),
                  const SizedBox(width: 12),
                  Expanded(child: _buildLiveCard("assets/images/event1.jpg")),
                ],
              ),
            ),

            // FEATURED GRID SECTION
            _buildSectionHeader("Featured"),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 12,
                childAspectRatio: 0.75,
                children: [
                  _buildGridItemWithAsset(
                    "assets/images/books_management.png",
                    "Books Mgmt",
                    () => Get.toNamed(RouteHelper.getBooksDashboardPage()),
                  ),
                  _buildGridItemWithAsset(
                    "assets/images/book_pooja.png",
                    "Sewa Mgmt",
                    () => Get.toNamed(RouteHelper.getSewaDashboardPage()),
                  ),
                  _buildGridItemWithAsset(
                    "assets/images/donation.png",
                    "Donation",
                    () => Get.toNamed(RouteHelper.getDonationPage()),
                  ),
                  _buildGridItemWithAsset(
                    "assets/images/book_pooja.png",
                    "Book A Pooja",
                    () => Get.toNamed(RouteHelper.getSlotBookPage()),
                  ),
                  _buildGridItemWithAsset(
                    "assets/images/prasad.png",
                    "Sponsor Prasad",
                    () {},
                  ),
                ],
              ),
            ),

            // 2. DYNAMIC TEMPLE EVENTS & FESTIVALS SECTION
            _buildSectionHeader("Temple events & Festival"),
            SizedBox(
              height: 130,
              child: StreamBuilder<QuerySnapshot>(
                stream: _eventsCollection.snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: CircularProgressIndicator(color: Colors.orange));
                  }
                  
                  final eventDocs = snapshot.data!.docs;
                  
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: eventDocs.length,
                    itemBuilder: (context, index) {
                      final data = eventDocs[index].data() as Map<String, dynamic>;
                      final imageUrl = data['url'] ?? '';
                      return Padding(
                        padding: EdgeInsets.only(right: index == eventDocs.length - 1 ? 0 : 12),
                        child: _buildEventCard(imageUrl),
                      );
                    },
                  );
                },
              ),
            ),
            
            // 🟢 SYSTEM NAVIGATION OVERLAP FIX: Safe padding for modern edge-to-edge phones
            const SafeArea(
              top: false,
              left: false,
              right: false,
              bottom: true,
              child: SizedBox(height: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 24, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
      ),
    );
  }

  Widget _buildPageItem(int index, String imageUrl) {
    Matrix4 matrix = Matrix4.identity();
    if (index == currPageValue.floor()) {
      var currScale = 1 - (currPageValue - index) * (1 - scaleFactor);
      var currTrans = _height * (1 - currScale) / 2;
      matrix = Matrix4.diagonal3Values(1, currScale, 1)..setTranslationRaw(0, currTrans, 0);
    } else if (index == currPageValue.floor() + 1) {
      var currScale = scaleFactor + (currPageValue - index + 1) * (1 - scaleFactor);
      var currTrans = _height * (1 - currScale) / 2;
      matrix = Matrix4.diagonal3Values(1, currScale, 1)..setTranslationRaw(0, currTrans, 0);
    } else {
      var currScale = 0.8;
      matrix = Matrix4.diagonal3Values(1, currScale, 1)
        ..setTranslationRaw(0, _height * (1 - scaleFactor) / 2, 0);
    }

    return Transform(
      transform: matrix,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.grey,
          image: imageUrl.isNotEmpty
              ? DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover)
              : null,
        ),
        child: imageUrl.isEmpty 
            ? const Center(child: Icon(Icons.image, color: Colors.white54, size: 40)) 
            : null,
      ),
    );
  }

  Widget _buildLiveCard(String imagePath) {
    return Stack(
      children: [
        Container(
          height: 110,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey,
            image: DecorationImage(image: AssetImage(imagePath), fit: BoxFit.cover),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(4)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.circle, size: 6, color: Colors.white),
                SizedBox(width: 4),
                Text("Live", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _buildGridItemWithAsset(String assetPath, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 52,
            width: 52,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Image.asset(
              assetPath,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.image, color: Colors.orange);
              },
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.grey),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(String imageUrl) {
    return Container(
      width: 240,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey,
        image: imageUrl.isNotEmpty
            ? DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover)
            : null,
      ),
      child: imageUrl.isEmpty 
          ? const Center(child: Icon(Icons.broken_image, color: Colors.black26)) 
          : null,
    );
  }
} // Final closing bracket for the entire class state
