import 'package:flutter/material.dart';
import 'package:svareign/view/screens/addcommonscreen/postcardwidget.dart';

class Addcommonscreen extends StatelessWidget {
  const Addcommonscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ads'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: const [
          Postcardwidget(
            imageurl:
                "assets/images/sale-promotion-ad-poster-design-template_53876-57700.avif",
            description: "Offer upto 30%",
          ),
          Postcardwidget(
            imageurl:
                "assets/images/sale-promotion-ad-poster-design-template_53876-57700.avif",
            description: "Offer upto 20%",
          ),
          Postcardwidget(
            imageurl:
                "assets/images/sale-promotion-ad-poster-design-template_53876-57700.avif",
            description: "Offer upto 20%",
          ),
          Postcardwidget(
            imageurl: "assets/images/istockphoto-1155451635-612x612.jpg",
            description: "Offer upto 10%",
          ),
          Postcardwidget(
            imageurl:
                "assets/images/sale-promotion-ad-poster-design-template_53876-57700.avif",
            description: "Offer upto 10%",
          ),
        ],
      ),
    );
  }
}
