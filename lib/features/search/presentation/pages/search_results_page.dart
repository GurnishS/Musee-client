import 'package:musee/core/common/widgets/loader.dart';
import 'package:musee/features/search/domain/entities/search_result.dart';
import 'package:musee/features/search/presentation/bloc/search_bloc.dart';
import 'package:musee/features/search/presentation/pages/search_suggestions_page.dart';
import 'package:musee/init_dependencies.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:musee/core/common/widgets/bottom_nav_bar.dart';

/// Search results page displaying search results grouped by extractors
/// Features horizontal scrollable sections for each platform (YouTube, etc.)
class SearchResultsPage extends StatefulWidget {
  final String query;

  const SearchResultsPage({super.key, required this.query});

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.query);
    _triggerSearch();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Triggers search when page loads
  void _triggerSearch() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SearchBloc>().add(SearchQuery(query: widget.query));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: const BottomNavBar(selectedIndex: 1),
    );
  }

  /// Builds app bar with search field
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: _buildSearchField(),
    );
  }

  /// Builds search input field
  Widget _buildSearchField() {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: TextField(
        controller: _searchController,
        maxLines: 1,
        readOnly: true,
        style: const TextStyle(fontSize: 16),
        decoration: _buildSearchInputDecoration(),
        onTap: () => _navigateToSearchSuggestions(_searchController.text),
      ),
    );
  }

  /// Creates search field decoration
  InputDecoration _buildSearchInputDecoration() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 16.0,
      ),
      filled: true,
      fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
      hintText: 'Search for videos...',
      hintStyle: TextStyle(
        color: isDark ? Colors.grey[400] : Colors.grey[600],
        fontSize: 16,
      ),
      border: _buildOutlineInputBorder(),
      enabledBorder: _buildOutlineInputBorder(),
      focusedBorder: _buildOutlineInputBorder(borderColor: colorScheme.primary),
      prefixIcon: Icon(
        Icons.search,
        size: 20,
        color: isDark ? Colors.grey[400] : Colors.grey[600],
      ),
    );
  }

  /// Creates consistent outline input border
  OutlineInputBorder _buildOutlineInputBorder({Color? borderColor}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(24.0),
      borderSide: borderColor != null
          ? BorderSide(color: borderColor, width: 2)
          : BorderSide.none,
    );
  }

  /// Builds main body with BLoC consumer
  Widget _buildBody() {
    return BlocConsumer<SearchBloc, SearchState>(
      listener: _handleStateChanges,
      builder: _buildStateBasedContent,
    );
  }

  /// Handles state changes and shows snackbars for errors
  void _handleStateChanges(BuildContext context, SearchState state) {
    if (state is VideosError) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(state.message)));
    }
  }

  /// Builds content based on current state
  Widget _buildStateBasedContent(BuildContext context, SearchState state) {
    return switch (state) {
      SearchQueryLoading() => const Loader(),
      SearchResultsLoaded(results: final results) => _buildSearchResults(
        results,
      ),
      VideosError() => _buildErrorState(),
      _ => _buildInitialState(),
    };
  }

  /// Builds search results content
  Widget _buildSearchResults(List<SearchResult> searchResults) {
    if (searchResults.isEmpty) {
      return _buildEmptyState();
    }

    return CustomScrollView(
      slivers: [
        _buildSearchHeader(),
        ...searchResults.map(_buildExtractorSection),
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }

  /// Builds search results header
  Widget _buildSearchHeader() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'Search results for "${widget.query}"',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  /// Builds extractor section (YouTube, Dailymotion, etc.)
  Widget _buildExtractorSection(SearchResult searchResult) {
    return SliverToBoxAdapter(
      child: _ExtractorSection(searchResult: searchResult),
    );
  }

  /// Builds empty state when no results found
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withAlpha(128),
          ),
          const SizedBox(height: 16),
          Text(
            'No results found for "${widget.query}"',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Try searching with different keywords',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withAlpha(179),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds error state
  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Please try again later',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withAlpha(179),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _triggerSearch, child: const Text('Retry')),
        ],
      ),
    );
  }

  /// Builds initial state
  Widget _buildInitialState() {
    return const Center(child: Loader());
  }

  /// Navigates to search suggestions page
  void _navigateToSearchSuggestions(String currentQuery) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => BlocProvider(
          create: (context) => SearchBloc(serviceLocator(), serviceLocator()),
          child: SearchSuggestionsPage(query: currentQuery),
        ),
      ),
    );
  }
}

/// Widget for displaying results from a single extractor platform
class _ExtractorSection extends StatelessWidget {
  final SearchResult searchResult;

  const _ExtractorSection({required this.searchResult});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(context, colorScheme, textTheme),
          _buildHorizontalVideoList(),
        ],
      ),
    );
  }

  /// Builds section header with extractor name and result count
  Widget _buildSectionHeader(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildExtractorBadge(colorScheme, textTheme),
          const SizedBox(width: 12),
          _buildResultCount(colorScheme, textTheme),
          const Spacer(),
          _buildSeeAllButton(),
        ],
      ),
    );
  }

  /// Builds extractor name badge
  Widget _buildExtractorBadge(ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _getExtractorIcon(searchResult.extractorKey),
          const SizedBox(width: 6),
          Text(
            searchResult.title,
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds result count text
  Widget _buildResultCount(ColorScheme colorScheme, TextTheme textTheme) {
    return Text(
      '${searchResult.results.length} results',
      style: textTheme.bodyMedium?.copyWith(
        color: colorScheme.onSurface.withAlpha(179),
      ),
    );
  }

  /// Builds see all button
  Widget _buildSeeAllButton() {
    return TextButton(
      onPressed: () {
        // TODO: Navigate to see all results from this extractor
      },
      child: const Text('See all'),
    );
  }

  /// Builds horizontal scrollable video list
  Widget _buildHorizontalVideoList() {
    return SizedBox(
      height: 280,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: searchResult.results.length,
        itemBuilder: (context, index) {
          return _VideoCard(
            searchItem: searchResult.results[index],
            extractorKey: searchResult.extractorKey,
          );
        },
      ),
    );
  }

  /// Gets icon for extractor platform
  Widget _getExtractorIcon(String extractorKey) {
    return switch (extractorKey.toLowerCase()) {
      'youtube' => const Icon(
        Icons.play_circle_fill,
        size: 18,
        color: Colors.red,
      ),
      'dailymotion' => const Icon(
        Icons.video_library,
        size: 18,
        color: Colors.blue,
      ),
      _ => const Icon(Icons.play_arrow, size: 18),
    };
  }
}

/// Individual video card widget
class _VideoCard extends StatelessWidget {
  final SearchItem searchItem;
  final String extractorKey;
  static const double cardWidth = 220;

  const _VideoCard({required this.searchItem, required this.extractorKey});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: () => _handleVideoTap(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: cardWidth,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildThumbnail(context, colorScheme, textTheme),
            const SizedBox(height: 8),
            _buildVideoInfo(colorScheme, textTheme),
          ],
        ),
      ),
    );
  }

  /// Builds video thumbnail with duration overlay
  Widget _buildThumbnail(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        children: [
          _buildThumbnailImage(colorScheme),
          if (searchItem.duration != null) _buildDurationOverlay(textTheme),
        ],
      ),
    );
  }

  /// Builds thumbnail image container
  Widget _buildThumbnailImage(ColorScheme colorScheme) {
    final hasValidThumbnail = searchItem.thumbnail?.isNotEmpty == true;

    return Container(
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(8),
        image: hasValidThumbnail
            ? DecorationImage(
                image: NetworkImage(searchItem.thumbnail!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: !hasValidThumbnail
          ? Center(
              child: Icon(
                Icons.play_circle_fill,
                size: 48,
                color: colorScheme.onSurface.withAlpha(153),
              ),
            )
          : null,
    );
  }

  /// Builds duration overlay
  Widget _buildDurationOverlay(TextTheme textTheme) {
    return Positioned(
      right: 8,
      bottom: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(179),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          _formatDuration(searchItem.duration!),
          style: textTheme.bodySmall?.copyWith(color: Colors.white),
        ),
      ),
    );
  }

  /// Builds video information section
  Widget _buildVideoInfo(ColorScheme colorScheme, TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitle(textTheme),
        const SizedBox(height: 6),
        if (searchItem.uploader != null) ...[
          _buildUploader(colorScheme, textTheme),
          const SizedBox(height: 4),
        ],
        if (searchItem.uploadDate != null)
          _buildUploadDate(colorScheme, textTheme),
      ],
    );
  }

  /// Builds video title
  Widget _buildTitle(TextTheme textTheme) {
    return Text(
      searchItem.title,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w500),
    );
  }

  /// Builds uploader name
  Widget _buildUploader(ColorScheme colorScheme, TextTheme textTheme) {
    return Text(
      searchItem.uploader!,
      style: textTheme.bodySmall?.copyWith(
        color: colorScheme.onSurface.withAlpha(204),
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Builds upload date
  Widget _buildUploadDate(ColorScheme colorScheme, TextTheme textTheme) {
    return Text(
      _formatUploadDate(searchItem.uploadDate!),
      style: textTheme.bodySmall?.copyWith(
        color: colorScheme.onSurface.withAlpha(153),
      ),
    );
  }

  /// Handles video card tap
  void _handleVideoTap(BuildContext context) {
    final encodedUrl = Uri.encodeComponent(searchItem.url);
    final videoId = searchItem.id;

    context.push(
      "/info?url=$encodedUrl&video_id=$videoId&extractor_key=$extractorKey",
    );
  }

  /// Formats duration from seconds to readable string
  String _formatDuration(int durationInSeconds) {
    final hours = durationInSeconds ~/ 3600;
    final minutes = (durationInSeconds % 3600) ~/ 60;
    final seconds = durationInSeconds % 60;

    if (hours > 0) {
      return "$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
    }
    return "$minutes:${seconds.toString().padLeft(2, '0')}";
  }

  /// Formats upload date to readable string
  String _formatUploadDate(String uploadDate) {
    try {
      final date = DateTime.parse(uploadDate);
      final difference = DateTime.now().difference(date);

      if (difference.inDays > 365) {
        final years = (difference.inDays / 365).floor();
        return "$years year${years > 1 ? 's' : ''} ago";
      } else if (difference.inDays > 30) {
        final months = (difference.inDays / 30).floor();
        return "$months month${months > 1 ? 's' : ''} ago";
      } else if (difference.inDays > 0) {
        return "${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago";
      } else if (difference.inHours > 0) {
        return "${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago";
      }
      return "Just now";
    } catch (e) {
      return uploadDate;
    }
  }
}
