import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'artwork_details_screen.dart';

class HomeScreen extends StatelessWidget {
  final Function(Map<String, String>) onFavorite;

  const HomeScreen({
    super.key,
    required this.onFavorite,
  });

  int getColumns(double width) {
    if (width >= 1100) {
      return 4;
    } else if (width >= 700) {
      return 3;
    } else {
      return 2;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final columns = getColumns(screenWidth);
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Digital Art Gallery',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Search',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Use the Explore tab to search artwork.',
                  ),
                ),
              );
            },
            icon: const Icon(Icons.search),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('artworks')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          // LOADING
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // ERROR
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 60,
                      color: Colors.redAccent.shade200,
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'Unable to load artwork',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          final documents = snapshot.data?.docs ?? [];

          // EMPTY
          if (documents.isEmpty) {
            return const Center(
              child: Text(
                'No artwork available.',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }

          // FIRESTORE DATA
          final artworks = documents.map((document) {
            final data =
            document.data() as Map<String, dynamic>;

            return {
              'title': data['title']?.toString() ??
                  'Untitled Artwork',
              'artist': data['artist']?.toString() ??
                  'Unknown Artist',
              'image': data['image']?.toString() ?? '',
            };
          }).toList();

          return SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 1200,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      // ================= HERO SECTION =================
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              primary.withOpacity(0.12),
                              primary.withOpacity(0.04),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius:
                          BorderRadius.circular(24),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Discover Digital Art',
                                    style: TextStyle(
                                      fontSize:
                                      screenWidth >= 700
                                          ? 32
                                          : 26,
                                      fontWeight:
                                      FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Explore creative artwork from '
                                        'talented artists and discover '
                                        'new ideas.',
                                    style: TextStyle(
                                      fontSize: 16,
                                      height: 1.5,
                                      color:
                                      Colors.grey.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  Row(
                                    mainAxisSize:
                                    MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.auto_awesome,
                                        size: 20,
                                        color: primary,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Creative • Inspiring • Digital',
                                        style: TextStyle(
                                          color: primary,
                                          fontWeight:
                                          FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            if (screenWidth >= 600)
                              Container(
                                padding:
                                const EdgeInsets.all(22),
                                decoration: BoxDecoration(
                                  color: Colors.white
                                      .withOpacity(0.8),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.palette_outlined,
                                  size: 65,
                                  color: primary,
                                ),
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // ================= SECTION HEADER =================
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Featured Artwork',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding:
                            const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color:
                              primary.withOpacity(0.08),
                              borderRadius:
                              BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${artworks.length} artworks',
                              style: TextStyle(
                                color: primary,
                                fontSize: 13,
                                fontWeight:
                                FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // ================= ARTWORK GRID =================
                      GridView.builder(
                        shrinkWrap: true,
                        physics:
                        const NeverScrollableScrollPhysics(),
                        itemCount: artworks.length,
                        gridDelegate:
                        SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          crossAxisSpacing: 18,
                          mainAxisSpacing: 18,
                          childAspectRatio: 0.78,
                        ),
                        itemBuilder: (context, index) {
                          final artwork = artworks[index];

                          return ArtworkCard(
                            title: artwork['title']!,
                            artist: artwork['artist']!,
                            image: artwork['image']!,
                            onFavorite: () {
                              onFavorite(artwork);
                            },
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ArtworkDetailsScreen(
                                        title: artwork['title']!,
                                        artist: artwork['artist']!,
                                        image: artwork['image']!,
                                        onFavorite: () {
                                          onFavorite(artwork);
                                        },
                                      ),
                                ),
                              );
                            },
                          );
                        },
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ============================================================
// ARTWORK CARD
// ============================================================

class ArtworkCard extends StatelessWidget {
  final String title;
  final String artist;
  final String image;
  final VoidCallback onFavorite;
  final VoidCallback onTap;

  const ArtworkCard({
    super.key,
    required this.title,
    required this.artist,
    required this.image,
    required this.onFavorite,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary =
        Theme.of(context).colorScheme.primary;

    return Card(
      elevation: 3,
      shadowColor: Colors.black26,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            // ================= IMAGE =================
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      image,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: Icon(
                              Icons.broken_image_outlined,
                              size: 50,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // FAVORITE BUTTON
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      decoration: BoxDecoration(
                        color:
                        Colors.white.withOpacity(0.92),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color:
                            Colors.black.withOpacity(0.12),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: IconButton(
                        tooltip: 'Add to favorites',
                        onPressed: onFavorite,
                        icon: const Icon(
                          Icons.favorite_border,
                          size: 20,
                        ),
                        color: primary,
                        padding:
                        const EdgeInsets.all(8),
                        constraints:
                        const BoxConstraints(),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ================= TEXT =================
            Padding(
              padding: const EdgeInsets.fromLTRB(
                12,
                11,
                12,
                13,
              ),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow:
                    TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'by $artist',
                    maxLines: 1,
                    overflow:
                    TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color:
                      Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}