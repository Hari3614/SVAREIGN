import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:svareign/services/location_services/fetchinguseraddress/fetching_address.dart';
import 'package:svareign/services/location_services/location_services.dart';
import 'package:svareign/view/screens/customerscreen/cartscreen/cartscreen.dart';
import 'package:svareign/view/screens/customerscreen/serviceproviders/serviceproviders.dart';
import 'package:http/http.dart' as http;

import 'package:svareign/viewmodel/customerprovider/cartprovider/cartprovider.dart';
import 'package:svareign/viewmodel/customerprovider/fetchserviceprovider/fetserviceprovider.dart';
import 'package:svareign/viewmodel/customerprovider/searchprovider/searchprovider.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeHelpersScreen extends StatefulWidget {
  const HomeHelpersScreen({super.key});

  @override
  State<HomeHelpersScreen> createState() => _HomeHelpersScreenState();
}

class _HomeHelpersScreenState extends State<HomeHelpersScreen> {
  final Userservice userservice = Userservice();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController serarchcontroller = TextEditingController();
  bool _isLoadingMore = false;
  bool _showNoProvidersMessage = false;

  bool isloading = true;
  @override
  void initState() {
    super.initState();
    // futuredelay();
    _scrollController.addListener(_onScroll);
    fetshuserlocation();
    // final searchprovider = Provider.of<Searchprovider>(context, listen: false);
    // searchprovider.fetchUserPlace();
    final searchprovider = Provider.of<Searchprovider>(context, listen: false);
    searchprovider.fetchUserPlace().then((place) {
      if (place != null) {
        searchprovider.setUserPlace(place); // use setter
      }
    });
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

  Future<void> fetshuserlocation() async {
    try {
      final userid = FirebaseAuth.instance.currentUser!.uid;
      final snapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userid)
              .get();
      if (!snapshot.exists) return print('doc not exits');
      final data = snapshot.data();
      final selectedplace = data?['place'];
      final lat = data?['location']?['latitude'];
      final long = data?['location']?['longitude'];
      if (lat != null && long != null && selectedplace != null) {
        await Provider.of<Availablityservice>(
          context,
          listen: false,
        ).fetchavailableProvider(
          selectedplace: selectedplace,
          userLat: lat,
          userlng: long,
          radiusinKm: 10,
        );
      }
    } catch (E) {
      debugPrint('error locationn fetching :$E');
    }
  }

  Future<Map<String, double>?> _getlatlanfromaddress(String address) async {
    final String apiKey = "AIzaSyDqpOdQdfhCp5iv-2TdmOCYJwEI0K_O8IY";
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(address)}&key=$apiKey',
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final results = data['results'] as List;
      if (results.isNotEmpty) {
        final location = results[0]['geometry']['location'];
        return {'lat': location['lat'], 'lng': location['lng']};
      }
    } else {
      print('error fetching geocode');
    }
    return null;
  }

  // Future<void> futuredelay(BuildContext con) async {
  //   await Future.delayed(Duration(milliseconds: 200));
  //   await location;
  //   setState(() {});
  // }

  void _manuallocationdialogue() {
    String newlocation = "";
    List<String> suggestions = [];
    final TextEditingController searchcontroller = TextEditingController();
    String selectedlocation = "";
    Map<String, double>? selectedcoordinates;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, localSetState) {
            Future<void> fetchSuggestions(String input) async {
              final String apiKey = "AIzaSyDqpOdQdfhCp5iv-2TdmOCYJwEI0K_O8IY";
              final url = Uri.parse(
                'https://maps.googleapis.com/maps/api/place/autocomplete/json'
                '?input=$input&key=$apiKey&types=geocode&language=en',
              );
              final response = await http.get(url);
              if (response.statusCode == 200) {
                final data = jsonDecode(response.body);
                final List predictions = data['predictions'];
                localSetState(() {
                  suggestions =
                      predictions
                          .map((p) => p['description'] as String)
                          .toList();
                });
              } else {
                print('Error fetching suggestions: ${response.body}');
                localSetState(() => suggestions = []);
              }
            }

            return AlertDialog(
              title: const Text("Enter New Location"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: searchcontroller,
                      onChanged: (value) {
                        newlocation = value;
                        if (value.length > 2) {
                          fetchSuggestions(value);
                        } else {
                          localSetState(() => suggestions = []);
                        }
                      },
                      decoration: const InputDecoration(
                        hintText: "Search location",
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...suggestions.map(
                      (location) => ListTile(
                        title: Text(location),
                        onTap: () async {
                          searchcontroller.text = location;
                          selectedlocation = location;
                          final coordinates = await _getlatlanfromaddress(
                            selectedlocation,
                          );
                          if (coordinates != null) {
                            selectedcoordinates = coordinates;
                            localSetState(() {
                              suggestions = [];
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final uid = FirebaseAuth.instance.currentUser!.uid;
                    if (selectedcoordinates != null) {
                      double lat = selectedcoordinates!['lat']!;
                      double lng = selectedcoordinates!['lng']!;
                      await FirebaseFirestore.instance
                          .collection("users")
                          .doc(uid)
                          .update({
                            'location': {'latitude': lat, 'longitude': lng},
                          });
                      Provider.of<Availablityservice>(
                        context,
                      ).fetchavailableProvider(
                        selectedplace: selectedlocation,
                        userLat: lat,
                        userlng: lng,
                      );
                      // Provider.of<Appstate>(context, listen: false).reloadapp();
                      Navigator.of(context).pop();
                      print("No location selected");
                    }
                  },
                  child: Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showlocationoption() {
    showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      context: context,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Choose location option",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 18),
              ListTile(
                leading: const Icon(Icons.my_location),
                title: const Text(
                  "Use my current location",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                onTap: () async {
                  CircularProgressIndicator();
                  Navigator.of(context).pop();
                  setState(() {
                    isloading = true;
                  });
                  Position? position = await LocationService()
                      .getCurrentLocation(context);
                  double lat = position.latitude;
                  double lng = position.longitude;
                  String userId = FirebaseAuth.instance.currentUser!.uid;
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(userId)
                      .update({
                        'location': {'latitude': lat, 'longitude': lng},
                      });
                  //  Provider.of<Appstate>(context, listen: false).reloadapp();
                  setState(() {
                    isloading = false;
                  });
                },
              ),
              ListTile(
                leading: Icon(Icons.location_city),
                title: const Text(
                  "Change Location",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                onTap: () => _manuallocationdialogue(),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final searchprovider = Provider.of<Searchprovider>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.04,
          vertical: size.height * 0.00,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Location and Cart
            GestureDetector(
              onTap: _showlocationoption,
              child: Row(
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
                  IconButton(
                    icon: Icon(Icons.shopping_cart_outlined),
                    color: Colors.black,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Cartscreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: size.height * 0.02),

            // Search Bar
            TextField(
              keyboardType: TextInputType.emailAddress,
              controller: serarchcontroller,
              onChanged: (value) {
                final userplace = searchprovider.userPlace;
                if (value.trim().isNotEmpty &&
                    searchprovider.userPlace != null) {
                  searchprovider.debouncesearch(value.trim(), userplace!);
                }
              },
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
            const SizedBox(height: 10),
            Consumer<Searchprovider>(
              builder: (context, provider, _) {
                final results = provider.searchresults;

                if (serarchcontroller.text.isNotEmpty && results.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 16.0),
                    child: Center(child: Text("No service providers found.")),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final data = results[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 5,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage:
                              data['imageurl'] != null
                                  ? NetworkImage(data['imageurl'])
                                  : null,
                          backgroundColor: Colors.grey.shade300,
                        ),
                        title: Text(data['name'] ?? ''),
                        subtitle: Text(
                          "Jobs: ${data['Jobs'].join(', ')}",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        trailing: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Text(data['phonenumber'] ?? ''),
                            // if (data['experience'] != null)
                            //   Text("${data['experience']} yrs"),
                          ],
                        ),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                title: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 25,
                                      backgroundImage:
                                          data['imageurl'] != null
                                              ? NetworkImage(data['imageurl'])
                                              : null,
                                      backgroundColor: Colors.grey.shade300,
                                    ),
                                    const SizedBox(width: 20),
                                    Expanded(
                                      child: Text(
                                        data['name'] ?? "",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (data['description'] != null)
                                      Text(
                                        data['description'],
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    const SizedBox(height: 8),
                                    if (data['experience'] != null)
                                      Text(
                                        "Experience: ${data['experience']}",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        ElevatedButton.icon(
                                          onPressed: () async {
                                            final phone = data['phonenumber'];
                                            final Uri phoneUri = Uri(
                                              scheme: 'tel',
                                              path: phone,
                                            );
                                            if (await canLaunchUrl(phoneUri)) {
                                              await launchUrl(phoneUri);
                                            }
                                          },
                                          icon: Icon(
                                            Icons.call,
                                            color: Colors.white,
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blue,
                                          ),
                                          label: const Text(
                                            'Call',
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        ElevatedButton.icon(
                                          onPressed: () async {
                                            final phone = data['phonenumber'];
                                            final Uri whatsappUri = Uri.parse(
                                              "https://wa.me/$phone?text=Hello, I found your service on the app",
                                            );
                                            if (await canLaunchUrl(
                                              whatsappUri,
                                            )) {
                                              await launchUrl(
                                                whatsappUri,
                                                mode:
                                                    LaunchMode
                                                        .externalApplication,
                                              );
                                            }
                                          },
                                          icon: Icon(
                                            Icons.chat,
                                            color: Colors.white,
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                          ),
                                          label: const Text(
                                            'Whatsapp',
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    );
                  },
                );
              },
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
            SizedBox(height: 20),
            _sectionHeader('Available Providers'),
            SizedBox(height: 10),
            SizedBox(
              height: 400,
              child: Consumer<Availablityservice>(
                builder: (context, provider, _) {
                  if (provider.isloading) {
                    return const Text("No Service Provider Available");
                  }
                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: provider.availableProvider.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      final providermodel = provider.availableProvider[index];
                      return Container(
                        width: 200,
                        margin: EdgeInsets.only(right: 16),
                        child: Card(
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(16),
                                  bottom: Radius.circular(16),
                                ),
                                child: Image.network(
                                  providermodel.imagepath,
                                  height: 150,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      providermodel.name,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      providermodel.description,
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      "Jobs:${providermodel.role.join(',')}",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      "Payment/hour: ${providermodel.hourlypayment}",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        foregroundColor: Colors.white,
                                        backgroundColor: Colors.black,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      ),
                                      onPressed: () {
                                        final cartprovider =
                                            Provider.of<Cartprovider>(
                                              context,
                                              listen: false,
                                            );
                                        final isalreadycart = cartprovider
                                            .cartitems
                                            .any(
                                              (e) =>
                                                  e.serviceId ==
                                                  providermodel.serviceId,
                                            );
                                        if (isalreadycart) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                "Already added to the cart",
                                              ),
                                              backgroundColor: Colors.orange,
                                            ),
                                          );
                                        } else {
                                          cartprovider.addtocart(providermodel);
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                "${providermodel.name} added to the cart",
                                              ),
                                              backgroundColor:
                                                  Colors.lightGreen,
                                            ),
                                          );
                                        }
                                      },
                                      icon: Icon(Icons.shopping_cart),
                                      label: Text("Add to cart"),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
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
