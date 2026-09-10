import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'artwork_details_screen.dart';
import 'home_screen.dart';

class BottomNavScreen extends StatefulWidget {
  const BottomNavScreen({super.key});

  @override
  State<BottomNavScreen> createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  int currentIndex = 0;

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  void addToFavorites(Map<String, String> artwork) async {
    try {
      final existing = await firestore
          .collection('favorites')
          .where('title', isEqualTo: artwork['title'])
          .limit(1)
          .get();

      if (existing.docs.isEmpty) {
        await firestore.collection('favorites').add({
          'title': artwork['title'],
          'artist': artwork['artist'],
          'image': artwork['image'],
          'createdAt': FieldValue.serverTimestamp(),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Artwork added to favorites ❤️'),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Already in favorites ❤️'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not save favorite: $e'),
          ),
        );
      }
    }
  }

  Future<void> removeFromFavorites(String documentId) async {
    try {
      await firestore
          .collection('favorites')
          .doc(documentId)
          .delete();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not remove favorite: $e'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: [
          HomeScreen(onFavorite: addToFavorites),
          ExploreScreen(onFavorite: addToFavorites),
          FavoritesScreen(
            onRemove: removeFromFavorites,
          ),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------
// EXPLORE SCREEN
// ------------------------------------------------------------

class ExploreScreen extends StatefulWidget {
  final Function(Map<String, String>) onFavorite;

  const ExploreScreen({
    super.key,
    required this.onFavorite,
  });

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController searchController =
  TextEditingController();

  final ValueNotifier<String> searchNotifier =
  ValueNotifier<String>('');

  @override
  void dispose() {
    searchController.dispose();
    searchNotifier.dispose();
    super.dispose();
  }

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

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Explore',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Explore Artwork',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Find artwork and discover talented artists.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 24),

                // SEARCH FIELD
                TextField(
                  controller: searchController,
                  onChanged: (value) {
                    searchNotifier.value =
                        value.trim().toLowerCase();
                  },
                  decoration: InputDecoration(
                    hintText: 'Search artwork or artist...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: ValueListenableBuilder<String>(
                      valueListenable: searchNotifier,
                      builder: (context, value, child) {
                        if (value.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        return IconButton(
                          onPressed: () {
                            searchController.clear();
                            searchNotifier.value = '';
                          },
                          icon: const Icon(Icons.clear),
                        );
                      },
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 16,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // FIRESTORE ARTWORKS
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: firestoreStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Unable to load artwork\n${snapshot.error}',
                            textAlign: TextAlign.center,
                          ),
                        );
                      }

                      final documents = snapshot.data?.docs ?? [];

                      final artworks = documents.map((document) {
                        final data =
                        document.data() as Map<String, dynamic>;

                        return {
                          'title':
                          data['title']?.toString() ??
                              'Untitled Artwork',
                          'artist':
                          data['artist']?.toString() ??
                              'Unknown Artist',
                          'image':
                          data['image']?.toString() ?? '',
                        };
                      }).toList();

                      return ValueListenableBuilder<String>(
                        valueListenable: searchNotifier,
                        builder: (context, searchText, child) {
                          final filteredArtworks =
                          artworks.where((artwork) {
                            final title =
                            artwork['title']!.toLowerCase();
                            final artist =
                            artwork['artist']!.toLowerCase();

                            return title.contains(searchText) ||
                                artist.contains(searchText);
                          }).toList();

                          return Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${filteredArtworks.length} artworks found',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),

                              Expanded(
                                child: filteredArtworks.isEmpty
                                    ? Center(
                                  child: Column(
                                    mainAxisAlignment:
                                    MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.search_off,
                                        size: 70,
                                        color:
                                        Colors.grey.shade400,
                                      ),
                                      const SizedBox(height: 15),
                                      const Text(
                                        'No artwork found',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight:
                                          FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                                    : GridView.builder(
                                  itemCount:
                                  filteredArtworks.length,
                                  gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: columns,
                                    crossAxisSpacing: 18,
                                    mainAxisSpacing: 18,
                                    childAspectRatio: 0.78,
                                  ),
                                  itemBuilder:
                                      (context, index) {
                                    final artwork =
                                    filteredArtworks[index];

                                    return ArtworkCard(
                                      title:
                                      artwork['title']!,
                                      artist:
                                      artwork['artist']!,
                                      image:
                                      artwork['image']!,
                                      onFavorite: () {
                                        widget.onFavorite(
                                          artwork,
                                        );
                                      },
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ArtworkDetailsScreen(
                                                  title:
                                                  artwork['title']!,
                                                  artist:
                                                  artwork['artist']!,
                                                  image:
                                                  artwork['image']!,
                                                  onFavorite: () {
                                                    widget.onFavorite(
                                                      artwork,
                                                    );
                                                  },
                                                ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Stream<QuerySnapshot> firestoreStream() {
    return FirebaseFirestore.instance
        .collection('artworks')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}

// ------------------------------------------------------------
// ARTWORK CARD
// ------------------------------------------------------------

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
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: onFavorite,
                        icon: const Icon(
                          Icons.favorite_border,
                          size: 20,
                        ),
                        color: Colors.deepPurple,
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'by $artist',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
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

// ------------------------------------------------------------
// FAVORITES SCREEN
// ------------------------------------------------------------

class FavoritesScreen extends StatelessWidget {
  final Future<void> Function(String documentId) onRemove;

  const FavoritesScreen({
    super.key,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final int columns;

    if (screenWidth >= 1100) {
      columns = 4;
    } else if (screenWidth >= 700) {
      columns = 3;
    } else {
      columns = 2;
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Favorites',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('favorites')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Unable to load favorites\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final documents = snapshot.data?.docs ?? [];

          if (documents.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.favorite_border,
                      size: 80,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'No Favorites Yet',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap the heart icon on any artwork\nto save it here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return Center(
            child: ConstrainedBox(
              constraints:
              const BoxConstraints(maxWidth: 1200),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: GridView.builder(
                  itemCount: documents.length,
                  gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: 18,
                    mainAxisSpacing: 18,
                    childAspectRatio: 0.78,
                  ),
                  itemBuilder: (context, index) {
                    final document = documents[index];

                    final data =
                    document.data()
                    as Map<String, dynamic>;

                    final artwork = {
                      'title':
                      data['title']?.toString() ??
                          'Untitled Artwork',
                      'artist':
                      data['artist']?.toString() ??
                          'Unknown Artist',
                      'image':
                      data['image']?.toString() ?? '',
                    };

                    return ArtworkCard(
                      title: artwork['title']!,
                      artist: artwork['artist']!,
                      image: artwork['image']!,
                      onFavorite: () async {
                        await onRemove(document.id);

                        if (context.mounted) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Removed from favorites',
                              ),
                            ),
                          );
                        }
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
                                  onFavorite: () async {
                                    await onRemove(document.id);
                                  },
                                ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ------------------------------------------------------------
// PROFILE SCREEN
// ------------------------------------------------------------

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final primary =
        Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('favorites')
            .snapshots(),
        builder: (context, snapshot) {
          final favoriteCount =
              snapshot.data?.docs.length ?? 0;

          return Center(
            child: ConstrainedBox(
              constraints:
              const BoxConstraints(maxWidth: 850),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor:
                      primary.withOpacity(0.12),
                      child: Icon(
                        Icons.person,
                        size: 52,
                        color: primary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Digital Art Enthusiast',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Art lover & digital creativity explorer',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 25),

                    Row(
                      children: [
                        const Expanded(
                          child: _ProfileStat(
                            value: '15',
                            label: 'Artworks',
                          ),
                        ),
                        Expanded(
                          child: _ProfileStat(
                            value: '',
                            label: 'Favorites',
                            dynamicValue: true,
                            favoriteCount: 0,
                            streamCount: favoriteCount,
                          ),
                        ),
                        const Expanded(
                          child: _ProfileStat(
                            value: '15',
                            label: 'Explored',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    _ProfileOption(
                      icon: Icons.settings_outlined,
                      title: 'Settings',
                      subtitle:
                      'Manage your app preferences',
                      onTap: () {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          const SnackBar(
                            content:
                            Text('Settings coming soon'),
                          ),
                        );
                      },
                    ),

                    _ProfileOption(
                      icon: Icons.palette_outlined,
                      title:
                      'About Digital Art Gallery',
                      subtitle:
                      'Learn more about this application',
                      onTap: () {
                        showAboutDialog(
                          context: context,
                          applicationName:
                          'Digital Art Gallery',
                          applicationVersion: '1.0.0',
                          applicationIcon: Icon(
                            Icons.palette_outlined,
                            color: primary,
                            size: 35,
                          ),
                          children: const [
                            Text(
                              'A digital art gallery where users can explore and discover creative artwork.',
                            ),
                          ],
                        );
                      },
                    ),

                    _ProfileOption(
                      icon: Icons.help_outline,
                      title: 'Help & Support',
                      subtitle:
                      'Get help with the application',
                      onTap: () {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Help & Support coming soon',
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 25),

                    Text(
                      'Digital Art Gallery • Version 1.0.0',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ------------------------------------------------------------
// PROFILE STAT
// ------------------------------------------------------------

class _ProfileStat extends StatelessWidget {
  final String value;
  final String label;
  final bool dynamicValue;
  final int favoriteCount;
  final int streamCount;

  const _ProfileStat({
    required this.value,
    required this.label,
    this.dynamicValue = false,
    this.favoriteCount = 0,
    this.streamCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final displayedValue =
    dynamicValue ? streamCount.toString() : value;

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 18,
        ),
        child: Column(
          children: [
            Text(
              displayedValue,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------
// PROFILE OPTION
// ------------------------------------------------------------

class _ProfileOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ProfileOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary =
        Theme.of(context).colorScheme.primary;

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding:
        const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 7,
        ),
        leading: CircleAvatar(
          backgroundColor:
          primary.withOpacity(0.1),
          child: Icon(
            icon,
            color: primary,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }
}