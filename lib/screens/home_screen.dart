import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cat_tinder_hsse/models/cat_model.dart';
import 'package:cat_tinder_hsse/services/cat_api.dart';
import 'package:cat_tinder_hsse/widgets/action_button.dart';
import 'package:cat_tinder_hsse/screens/detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CatApi _catApi = CatApi();
  Cat? _currentCat;
  int _likesCount = 0;
  double _dragOffset = 0.0;
  double _startDragX = 0.0;
  bool _isLoading = false;

  Future<void> _loadNewCat() async {
    setState(() => _isLoading = true);
    try {
      final cat = await _catApi.fetchRandomCat();
      if (!mounted) return;
      setState(() {
        _currentCat = cat;
        _dragOffset = 0.0;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ошибка: ${e.toString()}')));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _handleSwipe(bool isLike) {
    const animationDuration = Duration(milliseconds: 300);

    setState(() {
      _dragOffset = isLike ? 500 : -500;
    });

    Future.delayed(animationDuration, () {
      if (isLike) setState(() => _likesCount++);
      _loadNewCat();
      if (mounted) {
        setState(() => _dragOffset = 0);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _loadNewCat();
  }

  Widget _buildCatCard() {
    return GestureDetector(
      onPanStart: (details) {
        _startDragX = details.localPosition.dx;
      },
      onPanUpdate: (details) {
        final currentX = details.localPosition.dx;
        setState(() {
          _dragOffset = currentX - _startDragX;
        });
      },
      onPanEnd: (details) {
        final threshold = MediaQuery.of(context).size.width * 0.2;
        final velocityThreshold = MediaQuery.of(context).size.width * 0.5;

        if (_dragOffset.abs() > threshold ||
            details.velocity.pixelsPerSecond.dx.abs() > velocityThreshold) {
          _handleSwipe(_dragOffset > 0);
        } else {
          setState(() => _dragOffset = 0);
        }
      },
      onTap:
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailScreen(cat: _currentCat!),
            ),
          ),
      child: Transform.translate(
        offset: Offset(_dragOffset, 0),
        child: Stack(
          children: [
            Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  const BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: CachedNetworkImage(
                  imageUrl: _currentCat!.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  placeholder: (_, __) => Container(color: Colors.grey[200]),
                  errorWidget:
                      (context, url, error) =>
                          const Icon(Icons.error_outline, size: 50),
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 24,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xB2000000),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  _currentCat!.breedName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Roboto',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Catinder',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0x33FFFFFF),
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.favorite, color: Colors.red, size: 28),
                const SizedBox(width: 8),
                Text(
                  '$_likesCount',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 4,
                        color: Colors.black,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body:
          _isLoading || _currentCat == null
              ? const Center(child: CircularProgressIndicator())
              : Listener(
                behavior: HitTestBehavior.opaque,
                child: Column(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: _buildCatCard(),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 24,
                        horizontal: 40,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ActionButton(
                            icon: Icons.close,
                            color: Colors.red,
                            onPressed: () => _handleSwipe(false),
                          ),
                          ActionButton(
                            icon: Icons.favorite,
                            color: Colors.green,
                            onPressed: () => _handleSwipe(true),
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
