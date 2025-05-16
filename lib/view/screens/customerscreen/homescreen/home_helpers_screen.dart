import 'package:flutter/material.dart';
import 'package:svareign/services/location_services/fetchingaddress/fetching_address.dart';
import 'package:svareign/view/screens/customerscreen/serviceproviders/serviceproviders.dart';

class HomeHelpersScreen extends StatefulWidget {
  const HomeHelpersScreen({Key? key}) : super(key: key);

  @override
  State<HomeHelpersScreen> createState() => _HomeHelpersScreenState();
}

class _HomeHelpersScreenState extends State<HomeHelpersScreen> {
  final Userservice userservice = Userservice();
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  bool _showNoProvidersMessage = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !_isLoadingMore &&
        !_showNoProvidersMessage) {
      setState(() {
        _isLoadingMore = true;
      });

      Future.delayed(const Duration(seconds: 5)).then((_) {
        setState(() {
          _isLoadingMore = false;
          _showNoProvidersMessage = true;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.04,
          vertical: size.height * 0.02,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Location and Cart
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, color: Colors.green),
                    const SizedBox(width: 5),
                    FutureBuilder<String?>(
                      future: userservice.getuseraddress(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Text(
                            "Loading ...",
                            style: TextStyle(color: Colors.black54),
                          );
                        } else if (snapshot.hasError) {
                          return const Text(
                            "Unknown error",
                            style: TextStyle(color: Colors.black54),
                          );
                        } else if (snapshot.data == null) {
                          return const Text(
                            "Location Not available",
                            style: TextStyle(color: Colors.black54),
                          );
                        } else {
                          return Text(
                            snapshot.data!,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
                const Icon(Icons.shopping_cart_outlined, color: Colors.black),
              ],
            ),
            SizedBox(height: size.height * 0.02),

            // Search Bar
            TextField(
              decoration: InputDecoration(
                hintText: "Search for services...",
                hintStyle: const TextStyle(color: Colors.black54),
                prefixIcon: const Icon(Icons.search, color: Colors.black),
                suffixIcon: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.tune, color: Colors.white),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.black12),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
            ),
            SizedBox(height: size.height * 0.03),

            _sectionHeader("All Categories"),
            SizedBox(height: size.height * 0.015),
            _buildCategoryRow(size, context),

            SizedBox(height: size.height * 0.03),
            _sectionHeader("Best Services"),
            SizedBox(height: size.height * 0.015),

            _buildServiceCard(
              size: size,
              imagePath: 'assets/images/citc.jpg',
              title: "Complete Kitchen Cleaning",
              oldPrice: "\$180",
              newPrice: "\$150",
              providerName: "Mark Willions",
              rating: 5,
              reviews: 130,
            ),
            SizedBox(height: size.height * 0.02),

            _buildServiceCard(
              size: size,
              imagePath: 'assets/images/images.jpeg',
              title: "Living Room Cleaning",
              oldPrice: "\$230",
              newPrice: "\$200",
              providerName: "Ronald Mark",
              rating: 5,
              reviews: 240,
            ),
            SizedBox(height: 500),
            if (_isLoadingMore)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: CircularProgressIndicator(),
                ),
              ),
            if (_showNoProvidersMessage)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: [
                      Icon(Icons.location_off, size: 20, color: Colors.black38),
                      SizedBox(height: 10),
                      Text(
                        "There is no Provider in Your location",
                        style: TextStyle(fontSize: 16, color: Colors.black38),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.black,
          ),
        ),
        const Text(
          "See All",
          style: TextStyle(color: Colors.black54, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildCategoryRow(Size size, BuildContext context) {
    final categories = [
      ["Carpenter", Icons.handyman],
      ["Cleaner", Icons.cleaning_services],
      ["Painter", Icons.format_paint],
      ["Electrician", Icons.electrical_services],
      ["Beauty", Icons.spa],
      ["AC Repair", Icons.ac_unit],
      ["Plumber", Icons.plumbing],
      ["Men’s Salon", Icons.content_cut],
    ];

    return Wrap(
      spacing: size.width * 0.05,
      runSpacing: size.height * 0.02,
      children:
          categories.map((cat) {
            return SizedBox(
              width: size.width * 0.18,
              child: Column(
                children: [
                  InkWell(
                    onTap: () async {
                      showDialog(
                        context: context,
                        builder:
                            (context) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                      );

                      await Future.delayed(const Duration(seconds: 5));
                      Navigator.pop(context);
                      navigatescreen(context);
                    },
                    child: CircleAvatar(
                      radius: size.width * 0.08,
                      backgroundColor: Colors.grey.shade200,
                      child: Icon(cat[1] as IconData, color: Colors.black),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    cat[0] as String,
                    style: const TextStyle(fontSize: 12, color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

  Widget _buildServiceCard({
    required Size size,
    required String imagePath,
    required String title,
    required String oldPrice,
    required String newPrice,
    required String providerName,
    required int rating,
    required int reviews,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            // Image section
            Container(
              width: size.width * 0.25,
              height: size.width * 0.25,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: AssetImage(imagePath),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: List.generate(
                      rating,
                      (_) =>
                          const Icon(Icons.star, color: Colors.green, size: 14),
                    ),
                  ),
                  Text(
                    "($reviews Reviews)",
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        newPrice,
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        oldPrice,
                        style: const TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: Colors.black45,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        providerName,
                        style: const TextStyle(color: Colors.black87),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {},
                        child: const Text("Add"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> navigatescreen(BuildContext context) async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Serviceproviders()),
    );
  }
}
