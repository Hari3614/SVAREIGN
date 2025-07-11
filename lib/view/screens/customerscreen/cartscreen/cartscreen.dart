import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:svareign/view/screens/customerscreen/bottomnavbar/bottomnav_screen.dart';
import 'package:svareign/view/screens/customerscreen/cartscreen/widgets/bookingscreen.dart';
import 'package:svareign/view/screens/customerscreen/homescreen/homescreen.dart';
import 'package:svareign/viewmodel/customerprovider/cartprovider/cartprovider.dart';

class Cartscreen extends StatefulWidget {
  const Cartscreen({super.key});

  @override
  State<Cartscreen> createState() => _CartscreenState();
}

class _CartscreenState extends State<Cartscreen> {
  bool isloading = true;

  @override
  void initState() {
    super.initState();
    loadcart();
  }

  Future<void> loadcart() async {
    await Provider.of<Cartprovider>(context, listen: false).fetchcart();
    setState(() {
      isloading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final width = MediaQuery.sizeOf(context).width;
    final cartprovider = Provider.of<Cartprovider>(context);
    final cartitems = cartprovider.cartitems;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "My Cart",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
        ),
        automaticallyImplyLeading: false,
      ),
      body:
          isloading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Expanded(
                    child:
                        cartitems.isEmpty
                            ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Lottie.asset(
                                    "assets/lottie/Animation - 1751879006493.json",
                                    height: 300,
                                  ),
                                  const Text(
                                    "Cart is Empty",
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => HomeContainer(),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange,
                                      fixedSize: Size(
                                        width * 0.7,
                                        height * 0.05,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    child: const Text(
                                      "Browse",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            )
                            : ListView.builder(
                              padding: const EdgeInsets.all(12),
                              itemCount: cartitems.length,
                              itemBuilder: (context, index) {
                                final item = cartitems[index];
                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 5,
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(10),
                                    leading: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        item.imagepath,
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    title: Text(
                                      item.name,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.role.join(', '),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (context) => Bookingscreen(
                                                      serviceitem: item,
                                                    ),
                                              ),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 8,
                                            ),
                                          ),
                                          child: const Text(
                                            "Book Now",
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {
                                        cartprovider.removefromcart(
                                          item.serviceId,
                                        );
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              "${item.name} removed from cart",
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                  ),
                  if (cartitems.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () {
                            cartprovider.clearcart();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Cart cleared")),
                            );
                          },
                          icon: const Icon(
                            Icons.delete_forever,
                            color: Colors.red,
                          ),
                          label: const Text(
                            "Clear Cart",
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
    );
  }
}
