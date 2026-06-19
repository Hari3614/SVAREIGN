import 'package:flutter/material.dart';
import 'package:svareign/view/screens/addcommonscreen/postcardwidget.dart';

class Addcommonscreen extends StatelessWidget {
  const Addcommonscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offers'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: const [
          Postcardwidget(
            title: "New User Offer",
            description:
                "Get 30% off on your first booking! Use code WELCOME30",
            icon: Icons.celebration,
            gradientColors: [Color(0xFFFF6B6B), Color(0xFFEE5A24)],
            discount: "30% OFF",
          ),
          Postcardwidget(
            title: "Weekend Special",
            description: "Book any home service this weekend and save 20%",
            icon: Icons.home_repair_service,
            gradientColors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
            discount: "20% OFF",
          ),
          Postcardwidget(
            title: "Refer & Earn",
            description: "Refer a friend and both get ₹200 off on next booking",
            icon: Icons.people,
            gradientColors: [Color(0xFF00B894), Color(0xFF55E6C1)],
            discount: "₹200",
          ),
          Postcardwidget(
            title: "Cleaning Services",
            description:
                "Professional deep cleaning at flat 15% off this month",
            icon: Icons.cleaning_services,
            gradientColors: [Color(0xFF0984E3), Color(0xFF74B9FF)],
            discount: "15% OFF",
          ),
          Postcardwidget(
            title: "Loyalty Reward",
            description:
                "Complete 5 bookings and get the 6th one absolutely free!",
            icon: Icons.card_giftcard,
            gradientColors: [Color(0xFFFD79A8), Color(0xFFE84393)],
            discount: "FREE",
          ),
        ],
      ),
    );
  }
}
