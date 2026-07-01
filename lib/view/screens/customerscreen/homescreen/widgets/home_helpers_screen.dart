import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:svareign/model/customer/fetchserviceprovider.dart';
import 'package:svareign/services/location_services/fetchinguseraddress/fetching_address.dart';
import 'package:svareign/services/location_services/location_services.dart';
import 'package:svareign/view/screens/customerscreen/cartscreen/cartscreen.dart';
import 'package:svareign/view/screens/customerscreen/homescreen/widgets/all_providerscreen.dart';
import 'package:svareign/view/screens/customerscreen/serviceproviders/serviceproviders.dart';
import 'package:svareign/view/screens/customerscreen/providerdetail/provider_detail_screen.dart';
import 'package:http/http.dart' as http;
import 'package:svareign/viewmodel/customerprovider/addworkprovider/reviewprovider/reviewprovider.dart';
import 'package:svareign/viewmodel/customerprovider/cartprovider/cartprovider.dart';
import 'package:svareign/viewmodel/customerprovider/fetchserviceprovider/fetserviceprovider.dart';
import 'package:svareign/viewmodel/customerprovider/searchprovider/searchprovider.dart';
import 'package:svareign/viewmodel/customerprovider/servicepostprovider/servicepostprovider.dart';
import 'package:svareign/services/notification/notification_service.dart';
import 'package:svareign/viewmodel/notification/notification_provider.dart';
import 'package:svareign/widgets/cached_image.dart';

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
  bool _showall = false;
  bool _showAllCategories = false;
  String _sortBy = 'rating'; // 'rating', 'reviews', 'name'
  double _searchRadiusKm = 100;

  bool isloading = true;
  @override
  void initState() {
    super.initState();
    // futuredelay();
    // _scrollController.addListener(_onScroll);
    fetshuserlocation();
    // final searchprovider = Provider.of<Searchprovider>(context, listen: false);
    // searchprovider.fetchUserPlace();
    final searchprovider = Provider.of<Searchprovider>(context, listen: false);
    searchprovider.fetchUserPlace().then((place) {
      if (place != null) {
        searchprovider.setUserPlace(place);
      }
    });

    // Fetch service posts with radius after getting user location
    _fetchServicePostsWithRadius();

    // Listen for new requests and show notifications
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _listenForNewRequests();
    });
  }

  // Listen for new requests and show notifications
  void _listenForNewRequests() {
    NotificationService().listenForNewRequests((title, body) {
      if (mounted) {
        final notificationProvider = Provider.of<NotificationProvider>(
          context,
          listen: false,
        );

        notificationProvider.showNotification(
          title: title,
          message: body,
          duration: Duration(seconds: 5),
        );
      }
    });
  }

  // @override
  // void dispose() {
  //   _scrollController.dispose();
  //   super.dispose();
  // }

  // void _onScroll() {
  //   if (_scrollController.position.pixels ==
  //           _scrollController.position.maxScrollExtent &&
  //       !_isLoadingMore &&
  //       !_showNoProvidersMessage) {
  //     setState(() {
  //       _isLoadingMore = true;
  //     });

  //     Future.delayed(const Duration(seconds: 5)).then((_) {
  //       setState(() {
  //         _isLoadingMore = false;
  //         _showNoProvidersMessage = true;
  //       });
  //     });
  //   }
  // }

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
      final lat = data?['location']?['latitude'];
      final long = data?['location']?['longitude'];
      if (lat != null && long != null) {
        await Provider.of<Availablityservice>(
          context,
          listen: false,
        ).fetchavailableProvider(
          userLat: lat,
          userlng: long,
          radiusinKm: _searchRadiusKm,
        );
      }
    } catch (E) {
      debugPrint('error locationn fetching :$E');
    }
  }

  Future<void> _fetchServicePostsWithRadius() async {
    try {
      final userid = FirebaseAuth.instance.currentUser!.uid;
      final snapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userid)
              .get();
      if (!snapshot.exists) return;
      final data = snapshot.data();
      final lat = data?['location']?['latitude'];
      final long = data?['location']?['longitude'];
      if (lat != null && long != null) {
        await Provider.of<ServicePostProvider>(
          context,
          listen: false,
        ).fetchServicePosts(
          userLat: lat,
          userLng: long,
          radiusinKm: _searchRadiusKm,
        );
      }
    } catch (e) {
      debugPrint('error fetching service posts with radius: $e');
    }
  }

  Future<void> _refreshRadiusBasedResults() async {
    try {
      final userid = FirebaseAuth.instance.currentUser!.uid;
      final snapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userid)
              .get();
      if (!snapshot.exists) return;
      final data = snapshot.data();
      final lat = data?['location']?['latitude'];
      final long = data?['location']?['longitude'];
      if (lat != null && long != null) {
        await Provider.of<Availablityservice>(
          context,
          listen: false,
        ).fetchavailableProvider(
          userLat: lat,
          userlng: long,
          radiusinKm: _searchRadiusKm,
        );
        await Provider.of<ServicePostProvider>(
          context,
          listen: false,
        ).fetchServicePosts(
          userLat: lat,
          userLng: long,
          radiusinKm: _searchRadiusKm,
        );
      }
    } catch (e) {
      debugPrint('error refreshing radius-based results: $e');
    }
  }

  Future<Map<String, double>?> _getlatlanfromaddress(String address) async {
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(address)}&format=json&limit=1',
    );
    final response = await http.get(
      url,
      headers: {'User-Agent': 'Svareign-App'},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      if (data.isNotEmpty) {
        return {
          'lat': double.parse(data[0]['lat']),
          'lng': double.parse(data[0]['lon']),
        };
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
              final url = Uri.parse(
                'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(input)}&format=json&limit=5&addressdetails=1',
              );
              final response = await http.get(
                url,
                headers: {'User-Agent': 'Svareign-App'},
              );
              if (response.statusCode == 200) {
                final List data = jsonDecode(response.body);
                localSetState(() {
                  suggestions =
                      data.map((p) => p['display_name'] as String).toList();
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
                      // Save the context before popping the dialog
                      final availablityService =
                          Provider.of<Availablityservice>(
                            context,
                            listen: false,
                          );
                      Navigator.of(
                        context,
                      ).pop(); // Context becomes invalid after this
                      // Use the saved reference instead of context
                      availablityService.fetchavailableProvider(
                        userLat: lat,
                        userlng: lng,
                      );
                      print("Location updated successfully");
                    } else {
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
                  Navigator.of(context).pop(); // Pop the bottom sheet first
                  setState(() {
                    isloading = true;
                  });

                  try {
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
                    // Get the provider reference before potentially losing context
                    final availabilityService = Provider.of<Availablityservice>(
                      context,
                      listen: false,
                    );
                    setState(() {
                      isloading = false;
                    });
                  } catch (e) {
                    setState(() {
                      isloading = false;
                    });
                    print("Error getting location: $e");
                  }
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
    final notificationProvider = Provider.of<NotificationProvider>(context);

    return Scaffold(
      appBar: AppBar(elevation: 0, toolbarHeight: 0),
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
                              style: TextStyle(),
                            );
                          } else if (snapshot.hasError) {
                            return const Text(
                              "Unknown error",
                              style: TextStyle(),
                            );
                          } else if (snapshot.data == null) {
                            return const Text(
                              "Location Not available",
                              style: TextStyle(),
                            );
                          } else {
                            return Text(
                              snapshot.data!,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                  Consumer<Cartprovider>(
                    builder: (context, cartProvider, child) {
                      final itemCount = cartProvider.cartitems.length;
                      return IconButton(
                        icon: Badge(
                          isLabelVisible: itemCount > 0,
                          label: Text(
                            itemCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                          child: const Icon(Icons.shopping_cart_outlined),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Cartscreen(),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: size.height * 0.02),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Search radius: ${_searchRadiusKm.round()} km',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
                Slider.adaptive(
                  value: _searchRadiusKm,
                  min: 10,
                  max: 200,
                  divisions: 19,
                  label: '${_searchRadiusKm.round()} km',
                  onChanged: (value) {
                    setState(() {
                      _searchRadiusKm = value;
                    });
                  },
                  onChangeEnd: (_) {
                    _refreshRadiusBasedResults();
                  },
                ),
              ],
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
                prefixIcon: const Icon(Icons.search),
                suffixIcon: GestureDetector(
                  onTap: () => _showSortFilterSheet(),
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.tune, color: Colors.white),
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.black12),
                ),
                filled: true,
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
                        leading: AppCachedAvatar(
                          imageUrl: data['imageurl'],
                          radius: 20,
                        ),
                        title: Text(data['name'] ?? ''),
                        subtitle: Text(
                          "Jobs: ${data['Jobs'].join(',')}",
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
                                    AppCachedAvatar(
                                      imageUrl: data['imageurl'],
                                      radius: 25,
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
                                          onPressed: () {
                                            final cartprovider =
                                                Provider.of<Cartprovider>(
                                                  context,
                                                  listen: false,
                                                );
                                            final serviceModel =
                                                Fetchserviceprovidermodel(
                                                  serviceId: data['uid'] ?? '',
                                                  name: data['name'] ?? '',
                                                  imagepath:
                                                      data['imageurl'] ?? '',
                                                  role:
                                                      data['Jobs'] is List
                                                          ? List<String>.from(
                                                            data['Jobs'],
                                                          )
                                                          : data['Jobs'] != null
                                                          ? [
                                                            data['Jobs']
                                                                .toString(),
                                                          ]
                                                          : [],
                                                  description:
                                                      data['description'] ?? '',
                                                  hourlypayment: '',
                                                );
                                            print(
                                              "servicemodel: $serviceModel",
                                            );
                                            cartprovider.addtocart(
                                              serviceModel,
                                            );
                                            Navigator.of(context).pop();
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                backgroundColor: Colors.green,
                                                content: Text('Added to cart'),
                                              ),
                                            );
                                          },
                                          label: Text('Add to Cart'),
                                          icon: Icon(Icons.shopping_cart),
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

            // Notification banner (inline, scrolls with content)
            if (notificationProvider.hasNewNotifications &&
                notificationProvider.notifications.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildNotificationBanner(),
              ),

            _sectionHeader(
              "All Categories",
              onpressed: () {
                setState(() {
                  _showAllCategories = !_showAllCategories;
                });
              },
              showall: _showAllCategories,
            ),
            SizedBox(height: size.height * 0.015),
            _buildCategoryRow(size, context),

            SizedBox(height: size.height * 0.03),

            _sectionHeader(
              "Best Services",
              onpressed: () {
                setState(() {
                  _showall = !_showall;
                });
              },
              showall: _showall,
            ),

            SizedBox(height: size.height * 0.015),

            FutureBuilder<List<Map<String, dynamic>>>(
              future: Provider.of<ReviewProvider>(
                context,
                listen: false,
              ).fetchBestProvidersByLocation(
                Provider.of<Searchprovider>(context, listen: false).userPlace ??
                    "",
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text("No top services found");
                }

                final providers = snapshot.data!;

                // Apply sort
                providers.sort((a, b) {
                  switch (_sortBy) {
                    case 'rating':
                      return ((b['avgRating'] ?? 0.0) as double).compareTo(
                        (a['avgRating'] ?? 0.0) as double,
                      );
                    case 'reviews':
                      return ((b['reviewCount'] ?? 0) as int).compareTo(
                        (a['reviewCount'] ?? 0) as int,
                      );
                    case 'name':
                      return (a['fullname'] ?? a['name'] ?? '')
                          .toString()
                          .compareTo(
                            (b['fullname'] ?? b['name'] ?? '').toString(),
                          );
                    default:
                      return 0;
                  }
                });

                final visibleprovider =
                    _showall ? providers : providers.take(3).toList();

                return Column(
                  children:
                      visibleprovider.map((data) {
                        final imageurl = data['imageurl'] ?? "";
                        return _buildServiceCard(
                          providerData: data,
                          size: size,
                          imagePath: imageurl,

                          title:
                              (data['categories'] as List?)?.join(", ") ??
                              "Service",
                          providerName: data['fullname'] ?? data['name'],
                          rating:
                              ((data['avgRating'] ?? 0.0) as double).round(),
                          reviews: data['reviewCount'] ?? 0,
                        );
                      }).toList(),
                );
              },
            ),

            SizedBox(height: 20),
            _sectionHeader(
              'Available Providers',
              onpressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AllProviderScreen()),
                );
              },
            ),
            SizedBox(height: 10),
            SizedBox(
              height: 230,
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
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => ProviderDetailScreen(
                                    provider: providermodel,
                                  ),
                            ),
                          );
                        },
                        child: Container(
                          width: 160,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardTheme.color,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(14),
                                ),
                                child: AppCachedImage(
                                  imageUrl: providermodel.imagepath,
                                  height: 100,
                                  width: double.infinity,
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 8,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        providermodel.name,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        providermodel.role.join(', '),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color:
                                              Theme.of(
                                                context,
                                              ).textTheme.bodySmall?.color,
                                          fontSize: 11,
                                        ),
                                      ),
                                      const Spacer(),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "₹${providermodel.hourlypayment}/hr",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 28,
                                            width: 28,
                                            child: IconButton(
                                              padding: EdgeInsets.zero,
                                              onPressed: () {
                                                final cartprovider =
                                                    Provider.of<Cartprovider>(
                                                      context,
                                                      listen: false,
                                                    );
                                                final isalreadycart =
                                                    cartprovider.cartitems.any(
                                                      (e) =>
                                                          e.serviceId ==
                                                          providermodel
                                                              .serviceId,
                                                    );
                                                if (isalreadycart) {
                                                  Fluttertoast.showToast(
                                                    msg:
                                                        "Already added to the cart",
                                                    backgroundColor:
                                                        Colors.orange,
                                                    textColor: Colors.white,
                                                  );
                                                } else {
                                                  cartprovider.addtocart(
                                                    providermodel,
                                                  );
                                                  Fluttertoast.showToast(
                                                    msg:
                                                        "${providermodel.name} added to the cart",
                                                    backgroundColor:
                                                        Colors.green,
                                                    textColor: Colors.white,
                                                  );
                                                }
                                              },
                                              icon: Icon(
                                                Icons.add_circle,
                                                size: 24,
                                                color:
                                                    Theme.of(
                                                      context,
                                                    ).colorScheme.primary,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
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
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationBanner() {
    final notificationProvider = Provider.of<NotificationProvider>(context);
    if (notificationProvider.notifications.isEmpty) {
      return SizedBox.shrink();
    }

    final latestNotification = notificationProvider.notifications.first;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Dismissible(
        key: Key(latestNotification.id),
        direction: DismissDirection.horizontal,
        onDismissed: (_) {
          notificationProvider.removeNotification(latestNotification);
        },
        child: ListTile(
          leading: Icon(
            Icons.notifications_active,
            color: Theme.of(context).colorScheme.primary,
          ),
          title: Text(
            latestNotification.title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          subtitle: Text(
            latestNotification.message,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              notificationProvider.removeNotification(latestNotification);
            },
          ),
          onTap: () {
            notificationProvider.removeNotification(latestNotification);
          },
        ),
      ),
    );
  }

  void _showSortFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Sort Providers By",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _sortOption(
                    setModalState,
                    icon: Icons.star,
                    label: "Highest Rating",
                    value: "rating",
                  ),
                  _sortOption(
                    setModalState,
                    icon: Icons.reviews,
                    label: "Most Reviews",
                    value: "reviews",
                  ),
                  _sortOption(
                    setModalState,
                    icon: Icons.sort_by_alpha,
                    label: "Name (A-Z)",
                    value: "name",
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _sortOption(
    StateSetter setModalState, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final isSelected = _sortBy == value;
    return ListTile(
      leading: Icon(icon, color: isSelected ? Colors.green : null),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.green : null,
        ),
      ),
      trailing:
          isSelected ? const Icon(Icons.check, color: Colors.green) : null,
      onTap: () {
        setModalState(() {});
        setState(() {
          _sortBy = value;
        });
        Navigator.pop(context);
      },
    );
  }

  Widget _sectionHeader(
    String title, {
    VoidCallback? onpressed,
    bool showall = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        TextButton(
          onPressed: onpressed,
          child: Text(showall ? "Show Less" : "See All"),
        ),
      ],
    );
  }

  Widget _buildCategoryRow(Size size, BuildContext context) {
    final allCategories = [
      ["Carpenter", Icons.handyman],
      ["Cleaner", Icons.cleaning_services],
      ["Painter", Icons.format_paint],
      ["Electrician", Icons.electrical_services],
      ["Beauty", Icons.spa],
      ["AC Repair", Icons.ac_unit],
      ["Plumber", Icons.plumbing],
      ["Men’s Salon", Icons.content_cut],
    ];

    final categories =
        _showAllCategories ? allCategories : allCategories.take(4).toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 12,
        crossAxisSpacing: 8,
        childAspectRatio: 0.85,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final cat = categories[index];
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () async {
                final selectedcategory = cat[0] as String;
                showDialog(
                  context: context,
                  builder:
                      (context) =>
                          const Center(child: CircularProgressIndicator()),
                  barrierDismissible: false,
                );
                final place =
                    Provider.of<Searchprovider>(
                      context,
                      listen: false,
                    ).userPlace;

                // Get user location for radius-based search
                final userid = FirebaseAuth.instance.currentUser!.uid;
                final userDoc =
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(userid)
                        .get();
                final lat = userDoc.data()?['location']?['latitude'];
                final lng = userDoc.data()?['location']?['longitude'];

                if (lat != null && lng != null) {
                  await Provider.of<Availablityservice>(
                    context,
                    listen: false,
                  ).fetchproviderbycategoryandplace(
                    userLat: (lat as num).toDouble(),
                    userlng: (lng as num).toDouble(),
                    category: selectedcategory,
                    radiusinKm: _searchRadiusKm,
                  );
                }
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => Serviceproviders(
                          category: selectedcategory,
                          place: place ?? '',
                        ),
                  ),
                );
              },
              child: CircleAvatar(
                radius: size.width * 0.08,
                backgroundColor:
                    Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Icon(
                  cat[1] as IconData,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              cat[0] as String,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        );
      },
    );
  }

  Widget _buildServiceCard({
    required Size size,
    required String imagePath,
    required String title,
    required String providerName,
    required int rating,
    required int reviews,
    required Map<String, dynamic> providerData,
  }) {
    return GestureDetector(
      onTap: () {
        final model = Fetchserviceprovidermodel(
          serviceId: providerData['providerId'] ?? '',
          name:
              providerData['fullname'] ?? providerData['name'] ?? providerName,
          imagepath: providerData['imageurl'] ?? imagePath,
          role:
              providerData['categories'] is List
                  ? List<String>.from(providerData['categories'])
                  : [],
          description: providerData['description'] ?? '',
          hourlypayment: providerData['payment'] ?? '',
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProviderDetailScreen(provider: model),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: size.width * 0.22,
                height: size.width * 0.22,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: CachedNetworkImageProvider(imagePath),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ...List.generate(
                          rating,
                          (_) => const Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 14,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "($reviews Reviews)",
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          providerName,
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodySmall?.color,
                            fontSize: 13,
                          ),
                        ),
                        SizedBox(
                          height: 32,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {
                              final cartprovider = Provider.of<Cartprovider>(
                                context,
                                listen: false,
                              );

                              final serviceModel = Fetchserviceprovidermodel(
                                serviceId: providerData['providerId'] ?? '',
                                name: providerData['name'] ?? providerName,
                                imagepath:
                                    providerData['imageurl'] ?? imagePath,
                                role:
                                    providerData['categories'] is List
                                        ? List<String>.from(
                                          providerData['categories'],
                                        )
                                        : [],
                                description: providerData['description'] ?? '',
                                hourlypayment: providerData['payment'] ?? '',
                              );

                              final alreadyInCart = cartprovider.cartitems.any(
                                (e) => e.serviceId == serviceModel.serviceId,
                              );

                              if (alreadyInCart) {
                                Fluttertoast.showToast(
                                  msg: 'Already added to the cart',
                                  backgroundColor: Colors.orange,
                                  textColor: Colors.white,
                                );
                              } else {
                                cartprovider.addtocart(serviceModel);
                                Fluttertoast.showToast(
                                  msg: '${serviceModel.name} added to the cart',
                                  backgroundColor: Colors.green,
                                  textColor: Colors.white,
                                );
                              }
                            },
                            child: const Text(
                              "Add",
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
