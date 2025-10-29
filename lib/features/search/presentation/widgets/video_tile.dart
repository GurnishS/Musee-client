import 'package:musee/core/theme/responsive/responsive.dart';
import 'package:flutter/material.dart';

enum DownloadStatus {
  pending,
  downloading,
  completed,
  error,
  paused,
  cancelled,
  none,
}

class VideoTile extends StatelessWidget {
  final String? thumbnailUrl;
  final String title;
  final String? duration;
  final String? fileSize;
  final double downloadProgress;
  final DownloadStatus status;
  final String? quality;
  final String? format;
  final VoidCallback? onTap;
  final VoidCallback? onCancel;
  final VoidCallback? onRetry;
  final VoidCallback? onPause;
  final VoidCallback? onResume;

  const VideoTile({
    super.key,
    this.thumbnailUrl,
    required this.title,
    this.duration,
    this.fileSize,
    this.downloadProgress = 0.0,
    this.status = DownloadStatus.none,
    this.quality,
    this.format,
    this.onTap,
    this.onCancel,
    this.onRetry,
    this.onPause,
    this.onResume,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        // Handle infinite height constraints
        final hasFiniteHeight = constraints.maxHeight != double.infinity;

        // Calculate dimensions
        final thumbnailHeight = hasFiniteHeight
            ? constraints.maxHeight * 0.75
            : (isMobile ? 200.0 : 250.0); // Fallback heights

        return Container(
          width: constraints.maxWidth,
          height: hasFiniteHeight ? constraints.maxHeight : null,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant.withAlpha(60),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.shadow.withAlpha(15),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IntrinsicHeight(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail Section - Fixed height
                SizedBox(
                  height: thumbnailHeight,
                  child: _buildThumbnailSection(context),
                ),

                // Title and Info Section - Flexible height
                hasFiniteHeight
                    ? Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(isMobile ? 8 : 12),
                          child: _buildTitleSection(context, isMobile),
                        ),
                      )
                    : Padding(
                        padding: EdgeInsets.all(isMobile ? 8 : 12),
                        child: _buildTitleSection(context, isMobile),
                      ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildThumbnailSection(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Thumbnail Image
                _buildFullThumbnail(context),

                // Status indicator in top-left corner
                Positioned(
                  top: 8,
                  left: 8,
                  child: _buildStatusIndicator(context),
                ),

                // Duration in bottom-right corner
                if (duration != null)
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.scrim.withAlpha(180),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        duration!,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                // Central Circular Progress (only for downloading/paused)
                if (status == DownloadStatus.downloading ||
                    status == DownloadStatus.paused)
                  _buildCentralProgress(context),

                // Action Buttons in top-right corner
                Positioned(
                  top: 8,
                  right: 8,
                  child: _buildActionButtonsOverlay(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitleSection(BuildContext context, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Title with proper overflow handling
        Flexible(
          child: Text(
            title,
            style: TextStyle(
              fontSize: isMobile ? 13 : 16,
              fontWeight: FontWeight.w600,
              height: 1.25,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        const SizedBox(height: 6),

        // Video Info Chips with overflow handling
        _buildVideoInfoChips(context, isMobile),
      ],
    );
  }

  Widget _buildFullThumbnail(BuildContext context) {
    if (thumbnailUrl != null && thumbnailUrl!.isNotEmpty) {
      return Image.network(
        thumbnailUrl!,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildThumbnailPlaceholder(context);
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildThumbnailPlaceholder(context);
        },
      );
    } else {
      return _buildThumbnailPlaceholder(context);
    }
  }

  Widget _buildThumbnailPlaceholder(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withAlpha(25),
            Theme.of(context).colorScheme.secondary.withAlpha(25),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.video_library_outlined,
              size: Responsive.isMobile(context) ? 48 : 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 8),
            Text(
              'No Thumbnail',
              style: TextStyle(
                fontSize: Responsive.isMobile(context) ? 12 : 14,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCentralProgress(BuildContext context) {
    return Center(
      child: Container(
        width: Responsive.isMobile(context) ? 80 : 100,
        height: Responsive.isMobile(context) ? 80 : 100,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          shape: BoxShape.circle,
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withAlpha(80),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow.withAlpha(20),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Circular Progress Indicator
            SizedBox(
              width: Responsive.isMobile(context) ? 60 : 76,
              height: Responsive.isMobile(context) ? 60 : 76,
              child: CircularProgressIndicator(
                value: downloadProgress.clamp(0.0, 1.0),
                strokeWidth: 4,
                valueColor: AlwaysStoppedAnimation<Color>(_getStatusColor()),
              ),
            ),
            // Center Content
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  status == DownloadStatus.paused
                      ? Icons.pause
                      : Icons.download,
                  size: Responsive.isMobile(context) ? 20 : 24,
                  color: _getStatusColor(),
                ),
                const SizedBox(height: 4),
                Text(
                  '${(downloadProgress * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: Responsive.isMobile(context) ? 12 : 14,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoInfoChips(BuildContext context, bool isMobile) {
    if (quality == null && format == null && fileSize == null) {
      return const SizedBox.shrink();
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          if (quality != null)
            _buildInfoChip(
              icon: Icons.high_quality,
              label: quality!,
              context: context,
              isMobile: isMobile,
            ),
          if (quality != null && (format != null || fileSize != null))
            const SizedBox(width: 4),
          if (format != null)
            _buildInfoChip(
              icon: Icons.movie,
              label: format!.toUpperCase(),
              context: context,
              isMobile: isMobile,
            ),
          if (format != null && fileSize != null) const SizedBox(width: 4),
          if (fileSize != null)
            _buildInfoChip(
              icon: Icons.storage,
              label: fileSize!,
              context: context,
              isMobile: isMobile,
            ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required BuildContext context,
    required bool isMobile,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 6 : 8,
        vertical: isMobile ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withAlpha(100),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withAlpha(60),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: isMobile ? 10 : 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          SizedBox(width: isMobile ? 2 : 3),
          Text(
            label,
            style: TextStyle(
              fontSize: isMobile ? 10 : 11,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtonsOverlay(BuildContext context) {
    return Column(
      children: [
        if (status == DownloadStatus.downloading && onPause != null)
          _buildOverlayActionButton(
            icon: Icons.pause,
            onPressed: onPause!,
            context: context,
          ),

        if (status == DownloadStatus.paused && onResume != null)
          _buildOverlayActionButton(
            icon: Icons.play_arrow,
            onPressed: onResume!,
            context: context,
          ),

        if (status == DownloadStatus.error && onRetry != null)
          _buildOverlayActionButton(
            icon: Icons.refresh,
            onPressed: onRetry!,
            context: context,
          ),

        if ((status == DownloadStatus.downloading ||
                status == DownloadStatus.paused ||
                status == DownloadStatus.pending) &&
            onCancel != null) ...[
          const SizedBox(height: 8),
          _buildOverlayActionButton(
            icon: Icons.close,
            onPressed: onCancel!,
            isDestructive: true,
            context: context,
          ),
        ],
      ],
    );
  }

  Widget _buildOverlayActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    required BuildContext context,
    bool isDestructive = false,
  }) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isDestructive
            ? Theme.of(context).colorScheme.error.withAlpha(230)
            : Theme.of(context).colorScheme.scrim.withAlpha(180),
        shape: BoxShape.circle,
        border: Border.all(
          color: isDestructive
              ? Theme.of(context).colorScheme.error
              : Theme.of(context).colorScheme.outline.withAlpha(60),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(18),
          child: Icon(icon, size: 18, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: _getStatusColor().withAlpha(220),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _getStatusColor(), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getStatusIcon(), size: 10, color: Colors.white),
          const SizedBox(width: 3),
          Text(
            _getStatusText(),
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (status) {
      case DownloadStatus.pending:
        return Colors.orange;
      case DownloadStatus.downloading:
        return Colors.blue;
      case DownloadStatus.completed:
        return Colors.green;
      case DownloadStatus.error:
        return Colors.red;
      case DownloadStatus.paused:
        return Colors.amber;
      case DownloadStatus.cancelled:
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon() {
    switch (status) {
      case DownloadStatus.pending:
        return Icons.schedule;
      case DownloadStatus.downloading:
        return Icons.download;
      case DownloadStatus.completed:
        return Icons.check_circle;
      case DownloadStatus.error:
        return Icons.error;
      case DownloadStatus.paused:
        return Icons.pause_circle;
      case DownloadStatus.cancelled:
        return Icons.cancel;
      case DownloadStatus.none:
        return Icons.help_outline;
    }
  }

  String _getStatusText() {
    switch (status) {
      case DownloadStatus.pending:
        return 'Pending';
      case DownloadStatus.downloading:
        return 'Downloading';
      case DownloadStatus.completed:
        return 'Completed';
      case DownloadStatus.error:
        return 'Error';
      case DownloadStatus.paused:
        return 'Paused';
      case DownloadStatus.cancelled:
        return 'Cancelled';
      case DownloadStatus.none:
        return '';
    }
  }
}

// Example usage and default configurations
class VideoTileDefaults {
  static const String defaultTitle = 'Untitled Video';
  static const String defaultDuration = '00:00';
  static const String defaultFileSize = 'Unknown';
  static const String defaultQuality = '720p';
  static const String defaultFormat = 'MP4';
  static const double defaultProgress = 0.0;
  static const DownloadStatus defaultStatus = DownloadStatus.pending;

  // Factory method for creating a video tile with defaults
  static VideoTile createDefault({
    String? title,
    String? thumbnailUrl,
    String? duration,
    String? fileSize,
    String? quality,
    String? format,
    double? downloadProgress,
    DownloadStatus? status,
    VoidCallback? onTap,
    VoidCallback? onCancel,
    VoidCallback? onRetry,
    VoidCallback? onPause,
    VoidCallback? onResume,
  }) {
    return VideoTile(
      title: title ?? defaultTitle,
      thumbnailUrl: thumbnailUrl,
      duration: duration ?? defaultDuration,
      fileSize: fileSize ?? defaultFileSize,
      quality: quality ?? defaultQuality,
      format: format ?? defaultFormat,
      downloadProgress: downloadProgress ?? defaultProgress,
      status: status ?? defaultStatus,
      onTap: onTap,
      onCancel: onCancel,
      onRetry: onRetry,
      onPause: onPause,
      onResume: onResume,
    );
  }
}
