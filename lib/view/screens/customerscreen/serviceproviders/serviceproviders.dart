import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:svareign/viewmodel/customerprovider/cartprovider/cartprovider.dart';
import 'package:svareign/viewmodel/customerprovider/fetchserviceprovider/fetserviceprovider.dart';

class Serviceproviders extends StatelessWidget {
  final String category;
  final String place;

  const Serviceproviders({
    super.key,
    required this.category,
    required this.place,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<Availablityservice>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "$category Providers",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        elevation: 0,
        // backgroundColor: Colors.black87,
      ),

      body:
          provider.isloading
              ? const Center(child: CircularProgressIndicator())
              : provider.availableProvider.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.location_off, // or Icons.location_on_outlined
                      size: 50,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "No service providers available in this location.",
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
              : GridView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: provider.availableProvider.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemBuilder: (context, index) {
                  final model = provider.availableProvider[index];
                  return Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                            child: Image.network(
                              model.imagepath,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder:
                                  (context, error, stackTrace) => const Center(
                                    child: Icon(Icons.image_not_supported),
                                  ),
                            ),
                          ),
                        ),
                        // Info
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                model.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "₹${model.hourlypayment}/hr",
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Add to cart button
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                backgroundColor: Colors.black87,
                              ),
                              icon: const Icon(
                                Icons.add_shopping_cart,
                                size: 18,
                                color: Colors.white,
                              ),
                              label: const Text(
                                "Add to Cart",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                              onPressed: () async {
                                final cartprovider = Provider.of<Cartprovider>(
                                  context,
                                  listen: false,
                                );
                                final isalreadycart = cartprovider.cartitems
                                    .any(
                                      (element) =>
                                          element.serviceId == model.serviceId,
                                    );
                                if (isalreadycart) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "${model.name} is already in the cart",
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                } else {
                                  cartprovider.addtocart(model);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '${model.name} added to cart',
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
    );
  }
}
