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
        scrolledUnderElevation: 0,
        centerTitle: true,
        foregroundColor: Colors.black,
        title: const Text(
          "Available Providers",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w500,
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
                            ? Colors.blue.withValues(alpha: 0.2)
                            : Colors.grey.withValues(alpha: 0.2),
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
                            (prov) =>
                                prov.name.toLowerCase().contains(
                                  searchQuery.toLowerCase(),
                                ) ||
                                prov.role.any(
                                  (cat) => cat
                                      .toString()
                                      .toLowerCase()
                                      .contains(searchQuery.toLowerCase()),
                                ),
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
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.7,
                        ),
                    itemCount: filteredprovider.length,
                    itemBuilder: (context, index) {
                      final providermodel = filteredprovider[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(14),
                              ),
                              child: Image.network(
                                providermodel.imagepath,
                                height: 120,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 8,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                        color: Colors.grey[600],
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
                                            color: Colors.black87,
                                            fontSize: 13,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 28,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              final cartprovider =
                                                  Provider.of<Cartprovider>(
                                                    context,
                                                    listen: false,
                                                  );
                                              final isalreadyincart =
                                                  cartprovider.cartitems.any(
                                                    (e) =>
                                                        e.serviceId ==
                                                        providermodel.serviceId,
                                                  );
                                              if (isalreadyincart) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      "Already in the Cart",
                                                    ),
                                                    backgroundColor:
                                                        Colors.orange,
                                                  ),
                                                );
                                              } else {
                                                cartprovider.addtocart(
                                                  providermodel,
                                                );
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      "${providermodel.name} added to cart",
                                                    ),
                                                    backgroundColor:
                                                        Colors.lightGreen,
                                                  ),
                                                );
                                              }
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.black87,
                                              foregroundColor: Colors.white,
                                              elevation: 0,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                  ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                            ),
                                            child: const Text(
                                              "Add",
                                              style: TextStyle(fontSize: 11),
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
