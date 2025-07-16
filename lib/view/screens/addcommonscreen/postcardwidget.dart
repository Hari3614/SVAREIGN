import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class Postcardwidget extends StatefulWidget {
  final String imageurl;
  final String description;
  const Postcardwidget({
    super.key,
    required this.imageurl,
    required this.description,
  });

  @override
  State<Postcardwidget> createState() => _PostcardwidgetState();
}

class _PostcardwidgetState extends State<Postcardwidget> {
  bool isliked = false;
  int likecount = 0;
  void toggleLike() {
    setState(() {
      isliked = !isliked;
      likecount += isliked ? 1 : -1;
    });
  }

  void opencomments() {
    showBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('comments go here.....'),
        );
      },
    );
  }

  void sharePost() {
    Share.share("checkout this post : ${widget.description}");
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.asset(
              widget.imageurl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              widget.description,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  onPressed: () {
                    toggleLike();
                  },
                  icon: Icon(isliked ? Icons.favorite : Icons.favorite_border),
                  color: isliked ? Colors.red : Colors.grey,
                ),
                Text("${likecount}"),
                IconButton(
                  onPressed: () {
                    opencomments();
                  },
                  icon: const Icon(Icons.comment),
                ),
                IconButton(
                  onPressed: () {
                    sharePost();
                  },
                  icon: Icon(Icons.share),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
