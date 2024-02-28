import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:food_delivery/models/welcome_slide_model.dart';
import 'package:food_delivery/pages/register.dart';
import 'package:food_delivery/pages/login.dart';

class WelcomePage extends StatelessWidget {
  WelcomePage({super.key});

  final List<WelcomeSlide> slides = [
    WelcomeSlide(
      imagePath: "assets/images/welcome_one.webp",
      title: "Budget Bites: DineDash Delivers!",
      desc: "Affordable dining at your fingertips",
    ),
    WelcomeSlide(
      imagePath: "assets/images/welcome_two.webp",
      title: "Flavor Flight: DineDash!",
      desc: "Explore culinary adventures effortlessly",
    ),
    WelcomeSlide(
      imagePath: "assets/images/welcome_three.webp",
      title: "DineDash: Flavor, On the Go!",
      desc: "Unlock culinary delights, anytime, \nanywhere",
    )
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              width: 250,
              child: Image(image: AssetImage("assets/images/logo_text.png")),
            ),
            _buildCarouselSlider(context),
            Column(
              children: [
                SizedBox(
                  width: 350,
                  child: TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginPage()));
                      },
                      style: TextButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 4, 202, 138),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10))),
                      child: const Text(
                        "Login",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700),
                      )),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: 350,
                  child: TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const RegisterPage()));
                      },
                      style: TextButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 4, 202, 138),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10))),
                      child: const Text(
                        "Create new account",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700),
                      )),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  CarouselSlider _buildCarouselSlider(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
          autoPlay: true,
          autoPlayInterval: const Duration(seconds: 6),
          height: 400,
          enableInfiniteScroll: true,
          enlargeCenterPage: true,
          enlargeFactor: 0.3,
          viewportFraction: 1),
      items: slides.map((slide) {
        return Container(
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.symmetric(horizontal: 5.0),
          child: Column(
            children: [
              SizedBox(
                width: 250,
                height: 250,
                child: Image(image: AssetImage(slide.imagePath)),
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                slide.title,
                textAlign: TextAlign.center,
                softWrap: true,
                style:
                    const TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
              ),
              Flexible(
                child: Text(
                  slide.desc,
                  textAlign: TextAlign.center,
                  softWrap: true,
                  style: const TextStyle(
                      fontWeight: FontWeight.w400, fontSize: 15),
                ),
              )
            ],
          ),
        );
      }).toList(),
    );
  }
}
