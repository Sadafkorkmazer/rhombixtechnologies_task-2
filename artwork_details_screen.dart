import 'package:flutter/material.dart';

class ArtworkDetailsScreen extends StatelessWidget {
  final String title;
  final String artist;
  final String image;
  final VoidCallback onFavorite;

  const ArtworkDetailsScreen({
    super.key,
    required this.title,
    required this.artist,
    required this.image,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Artwork Details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 1100,
          ),

          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ================= ARTWORK IMAGE =================
                Container(
                  width: double.infinity,
                  height: 520,

                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),

                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 25,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),

                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),

                    child: Image.asset(
                      image,
                      fit: BoxFit.cover,

                      errorBuilder: (
                          context,
                          error,
                          stackTrace,
                          ) {
                        return Container(
                          color: Colors.grey.shade200,

                          child: const Center(
                            child: Icon(
                              Icons.broken_image_outlined,
                              size: 70,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // ================= TITLE =================
                Text(
                  title,

                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                // ================= ARTIST =================
                Row(
                  children: [

                    CircleAvatar(
                      radius: 25,

                      backgroundColor:
                      primary.withOpacity(0.12),

                      child: Text(
                        artist.isNotEmpty
                            ? artist[0].toUpperCase()
                            : '?',

                        style: TextStyle(
                          color: primary,
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,

                      children: [

                        Text(
                          'Created by',

                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),

                        const SizedBox(height: 3),

                        Text(
                          artist,

                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // ================= ABOUT =================
                Container(
                  width: double.infinity,

                  padding: const EdgeInsets.all(22),

                  decoration: BoxDecoration(
                    color: primary.withOpacity(0.05),

                    borderRadius:
                    BorderRadius.circular(20),
                  ),

                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,

                    children: [

                      Row(
                        children: [

                          Icon(
                            Icons.info_outline,
                            color: primary,
                          ),

                          const SizedBox(width: 10),

                          const Text(
                            'About this artwork',

                            style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      Text(
                        'This digital artwork is part of the '
                            'Digital Art Gallery collection. It '
                            'represents creativity, imagination and '
                            'digital artistic expression. Explore '
                            'more artwork in our gallery to discover '
                            'different styles and creative ideas.',

                        style: TextStyle(
                          fontSize: 15,
                          height: 1.7,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // ================= BUTTONS =================
                Row(
                  children: [

                    // FAVORITE BUTTON
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onFavorite,

                        icon: const Icon(
                          Icons.favorite_border,
                        ),

                        label: const Text(
                          'Add to Favorites',
                        ),

                        style:
                        ElevatedButton.styleFrom(
                          padding:
                          const EdgeInsets.symmetric(
                            vertical: 17,
                          ),

                          shape:
                          RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 14),

                    // SHARE BUTTON
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Sharing feature coming soon',
                              ),
                            ),
                          );
                        },

                        icon: const Icon(
                          Icons.share_outlined,
                        ),

                        label: const Text(
                          'Share',
                        ),

                        style:
                        OutlinedButton.styleFrom(
                          padding:
                          const EdgeInsets.symmetric(
                            vertical: 17,
                          ),

                          shape:
                          RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}