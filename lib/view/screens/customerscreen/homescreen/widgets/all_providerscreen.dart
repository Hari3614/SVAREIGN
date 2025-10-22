import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:svareign/viewmodel/customerprovider/cartprovider/cartprovider.dart';
import 'package:svareign/viewmodel/customerprovider/fetchserviceprovider/fetserviceprovider.dart';

class AllProviderScreen extends StatefulWidget {
  const AllProviderScreen({super.key});

  @override
  State<AllProviderScreen> createState() => _AllProviderScreenState();
}

class _AllProviderScreenState extends State<AllProviderScreen> {
  String searchQuery = "";
  bool isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          "Available Providers",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            AnimatedContainer(
              duration: Duration(milliseconds: 300),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color:
                        isFocused
                            ? Colors.blue.withOpacity(0.2)
                            : Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                onTap: () {
                  setState(() {
                    isFocused = true;
                  });
                },
                onEditingComplete: () {
                  setState(() {
                    isFocused = false;
                  });
                },
                decoration: InputDecoration(
                  hintText: "Search provider",
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 20,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: Consumer<Availablityservice>(
                builder: (context, provider, _) {
                  if (provider.isloading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final filteredprovider =
                      provider.availableProvider
                          .where(
                            (prov) => prov.role
                                .toString()
                                .toLowerCase()
                                .contains(searchQuery.toLowerCase()),
                          )
                          .toList();
                  if (filteredprovider.isEmpty) {
                    return const Center(child: Text("No Provider found "));
                  }
                  return GridView.builder(
                    padding: const EdgeInsets.all(10),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 12,
                        ),
                    itemCount: filteredprovider.length,
                    itemBuilder: (context, index) {
                      final providermodel = filteredprovider[index];
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(16),
                        ),
                        elevation: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadiusGeometry.circular(16),
                              child: Image.network(
                                providermodel.imagepath,
                                height: 120,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    providermodel.name,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    providermodel.description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${providermodel.hourlypayment}/hr",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      final cartprovider =
                                          Provider.of<Cartprovider>(
                                            context,
                                            listen: false,
                                          );
                                      final isalreadyincart = cartprovider
                                          .cartitems
                                          .any(
                                            (e) =>
                                                e.serviceId ==
                                                providermodel.serviceId,
                                          );
                                      if (isalreadyincart) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              "Already in the Cart",
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
                                              "${providermodel.name}add to cart",
                                            ),
                                            backgroundColor: Colors.lightGreen,
                                          ),
                                        );
                                      }
                                    },
                                    label: const Text("Add"),
                                    icon: Icon(Icons.add_shopping_cart),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black,
                                      foregroundColor: Colors.white,
                                      minimumSize: const Size(
                                        double.infinity,
                                        35,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
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
}
