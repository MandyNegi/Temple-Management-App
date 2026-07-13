import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:temple/utils/colors.dart';
import 'package:temple/widget/big_text.dart';
import 'package:temple/widget/small_text.dart';

import '../../utils/dimensions.dart';

List<Widget> aboutUs = <Widget>[
  Padding(
    padding: const EdgeInsets.all(8.0),
    child: SingleChildScrollView(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: Dimensions.width20, vertical: Dimensions.height10),
            decoration: BoxDecoration(
                color: AppColors.iconColor1,
                borderRadius: BorderRadius.circular(Dimensions.radius30)),
            child: BigText(
              text: "INTRODUCTION",
              size: Dimensions.font20 * 2,
            ),
          ),
          SizedBox(height: Dimensions.height10),
          Text(
            ''' Hare Krishna! 🙏

Jagannath Mandir is a spiritual home dedicated to the teachings of His Divine Grace A. C. Bhaktivedanta Swami Prabhupada, Founder-Acharya of ISKCON.

Our mission is to spread the timeless wisdom of Bhagavad Gita and Srimad Bhagavatam while helping everyone develop love and devotion for Lord Krishna through Bhakti Yoga.

Our Daily Activities
🌸 Mangala Arati (Morning Worship)
🪔 Sandhya Arati (Evening Worship)
📖 Daily study of Bhagavad Gita and Srimad Bhagavatam
📚 Distribution of spiritual books
🎵 Devotional Kirtan and Bhajans
🍛 Sanctified Prasadam
Every Sunday

Join us for our vibrant Sunday Love Feast, featuring:

🎶 Hare Krishna Kirtan
📖 Spiritual Discourse (Katha)
🍛 Delicious Krishna Prasadam
🤝 Devotee Association

Together, let us chant the Holy Names, learn the teachings of Lord Krishna, and grow in devotion.

Hare Krishna! ''',
            style: TextStyle(
                fontSize: Dimensions.font16, fontWeight: FontWeight.w400),
          )
        ],
      ),
    ),
  ),
  Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: EdgeInsets.symmetric(
              horizontal: Dimensions.width20, vertical: Dimensions.height10),
          decoration: BoxDecoration(
              color: AppColors.iconColor1,
              borderRadius: BorderRadius.circular(Dimensions.radius30)),
          child: Center(
            child: Text(
              "TRUSTIES",
              style: TextStyle(
                  fontSize: Dimensions.font20 * 2, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        SizedBox(height: Dimensions.height30),
        Text(
          "NAME OF THE TRUSTIES ARE :",
          style: TextStyle(
              fontSize: Dimensions.font20, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: Dimensions.height20 / 1.5),
        Padding(
          padding: EdgeInsets.only(left: Dimensions.width30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SmallText(
                text: "1) Shri GM Patel - Chairman",
                size: Dimensions.font16,
              ),
              SizedBox(height: Dimensions.height10 / 2),
              SmallText(
                text: "2) Shri AJ Kulabkar - Secretary",
                size: Dimensions.font16,
              ),
              SizedBox(height: Dimensions.height10 / 2),
              SmallText(
                text: "3) Shri PD Rindani - Treasurer",
                size: Dimensions.font16,
              ),
              SizedBox(height: Dimensions.height10 / 2),
              SmallText(
                text: "4) Shri SA Desai - Member",
                size: Dimensions.font16,
              ),
              SizedBox(height: Dimensions.height10 / 2),
              SmallText(
                text: "5) Shri MM Patel",
                size: Dimensions.font16,
              ),
              SizedBox(height: Dimensions.height10 / 2),
              SmallText(
                text: "6) Shri MJ Acharya",
                size: Dimensions.font16,
              ),
              SizedBox(height: Dimensions.height10 / 2),
              SmallText(
                text: "7) ShriPA Pandya",
                size: Dimensions.font16,
              ),
              SizedBox(height: Dimensions.height10 / 2),
              SmallText(
                text: "8) Shri AN Gohil",
                size: Dimensions.font16,
              ),
              SizedBox(height: Dimensions.height10 / 2),
              SmallText(
                text: "9) Shri RL Dandekar",
                size: Dimensions.font16,
              ),
              SizedBox(height: Dimensions.height10 / 2),
              SmallText(
                text: "10) Shri MS Bhatt",
                size: Dimensions.font16,
              ),
              SizedBox(height: Dimensions.height10 / 2),
              SmallText(
                text: "11) Shri RM Rathod",
                size: Dimensions.font16,
              ),
              SizedBox(height: Dimensions.height10 / 2),
              SmallText(
                text: "12) Shri MB Desai",
                size: Dimensions.font16,
              ),
              SizedBox(height: Dimensions.height10 / 2),
            ],
          ),
        ),
      ])),
  Padding(
    padding: const EdgeInsets.all(8.0),
    child: Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(
              horizontal: Dimensions.width20, vertical: Dimensions.height10),
          decoration: BoxDecoration(
              color: AppColors.iconColor1,
              borderRadius: BorderRadius.circular(Dimensions.radius30)),
          child: BigText(
            text: "DONATORS",
            size: Dimensions.font20 * 2,
          ),
        ),
        SizedBox(height: Dimensions.height10),
        Image.asset(
          ('assets/images/about-img2.jpg'),
          height: Dimensions.height30 * 10,
        ),
        SizedBox(height: Dimensions.height10),
        Column(
          children: [
            SmallText(
              text: "3%-Income Golakh",
              size: Dimensions.font16,
            ),
            SizedBox(height: Dimensions.height10 / 2),
            SmallText(
              text: "10%-Donation through salary of employees",
              size: Dimensions.font16,
            ),
            SizedBox(height: Dimensions.height10 / 2),
            SmallText(
              text: "12%-Interst",
              size: Dimensions.font16,
            ),
            SizedBox(height: Dimensions.height10 / 2),
            SmallText(
              text: "75%-Donation by the worshipers",
              size: Dimensions.font16,
            ),
            SizedBox(height: Dimensions.height10 / 2),
          ],
        )
      ],
    ),
  ),
  Padding(
    padding: const EdgeInsets.all(8.0),
    child: Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(
              horizontal: Dimensions.width20, vertical: Dimensions.height10),
          decoration: BoxDecoration(
              color: AppColors.iconColor1,
              borderRadius: BorderRadius.circular(Dimensions.radius30)),
          child: BigText(
            text: "Expenses",
            size: Dimensions.font20 * 2,
          ),
        ),
        SizedBox(height: Dimensions.height15),
        const Image(
          image: AssetImage('assets/images/about-img3.png'),
          fit: BoxFit.cover,
        )
      ],
    ),
  )
];

class AboutUsBody extends StatefulWidget {
  const AboutUsBody({Key? key}) : super(key: key);

  @override
  State<AboutUsBody> createState() => _AboutUsBodyState();
}

class _AboutUsBodyState extends State<AboutUsBody> {
final CarouselSliderController controller = CarouselSliderController();
  int activeIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        CarouselSlider.builder(
          carouselController: controller,
          itemCount: aboutUs.length,
          itemBuilder: ((context, index, realIndex) {
            return aboutUs[index];
          }),
          options: CarouselOptions(
            height: Dimensions.height10 * 60,
            reverse: false,
            enableInfiniteScroll: false,
            initialPage: 0,
            viewportFraction: 1,
            enlargeCenterPage: true,
            onPageChanged: (index, reason) {
              setState(() {
                activeIndex = index;
              });
            },
          ),
        ),
        buildIndicator(),
        SizedBox(height: Dimensions.height20),
        buildButtons(false, activeIndex),
        SizedBox(height: Dimensions.height20),
      ],
    );
  }

  Widget buildIndicator() {
    return AnimatedSmoothIndicator(
      onDotClicked: animateToSlide,
      effect: SlideEffect(
          dotWidth: Dimensions.width20,
          dotHeight: Dimensions.height20,
          activeDotColor: AppColors.mainColor),
      activeIndex: activeIndex,
      count: aboutUs.length,
    );
  }

  Widget buildButtons(bool stretch, int index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: previous,
          style: ElevatedButton.styleFrom(
              backgroundColor: index == 0
                  ? Theme.of(context).disabledColor
                  : AppColors.mainColor,
              padding: EdgeInsets.symmetric(
                  horizontal: Dimensions.width15 * 2,
                  vertical: Dimensions.height15)),
          child: Icon(Icons.arrow_back, size: Dimensions.iconSize16 * 2),
        ),
        stretch ? const Spacer() : SizedBox(width: Dimensions.width15 * 2),
        ElevatedButton(
          onPressed: next,
          style: ElevatedButton.styleFrom(
              backgroundColor: index == 3
                  ? Theme.of(context).disabledColor
                  : AppColors.mainColor,
              padding: EdgeInsets.symmetric(
                  horizontal: Dimensions.width15 * 2,
                  vertical: Dimensions.height15)),
          child: Icon(Icons.arrow_forward, size: Dimensions.iconSize16 * 2),
        ),
      ],
    );
  }

  void animateToSlide(int index) {
    controller.animateToPage(index);
  }

  void previous() {
    controller.previousPage();
  }

  void next() {
    controller.nextPage();
  }
}
