import { NativeEventEmitter, NativeModules, Platform } from 'react-native';
import NativeVideoProcessor from './NativeVideoProcessor';
import type {
  ProcessingOptions,
  TrimOptions,
  VideoMetadata,
  ThumbnailOptions,
  VolumeOptions,
  SpeedSegment,
  ProcessingPreset,
} from './types';
import { VideoProcessorError, VideoProcessorErrorCode } from './types';

// Export all types
export * from './types';

const LINKING_ERROR =
  `The package 'react-native-macos-video-processor' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo Go\n';

// For legacy native modules (fallback)
const VideoProcessorModule = NativeVideoProcessor
  ? NativeVideoProcessor
  : NativeModules.VideoProcessor;

if (!VideoProcessorModule) {
  throw new Error(LINKING_ERROR);
}

// Event emitter for progress updates
const eventEmitter = new NativeEventEmitter(VideoProcessorModule);

/**
 * Preset configurations mapped to speed segments
 */
const PRESETS: Record<ProcessingPreset, SpeedSegment[]> = {
  '2x-lecture': [{ start: 0, speed: 2.0, pitchCorrection: 'voice' }],
  '16x-timelapse': [{ start: 0, speed: 16.0, pitchCorrection: 'none' }],
  'slowmo-sports': [{ start: 0, speed: 0.5, pitchCorrection: 'highQuality' }],
};

/**
 * Normalize file path (handle both absolute paths and file:// URIs)
 */
function normalizePath(path: string): string {
  if (path.startsWith('file://')) {
    return path.substring(7);
  }
  return path;
}

/**
 * Process video with variable speed and pitch correction
 *
 * @param options - Processing options
 * @returns Promise that resolves to the output file path
 *
 * @example
 * ```typescript
 * await processVideo({
 *   input: '/path/to/input.mp4',
 *   output: '/path/to/output.mp4',
 *   segments: [
 *     { start: 0, end: 10, speed: 2.0, pitchCorrection: 'voice' },
 *     { start: 10, speed: 1.0 }
 *   ],
 *   onProgress: (progress) => console.log(`Progress: ${progress * 100}%`)
 * });
 * ```
 */
export async function processVideo(
  options: ProcessingOptions
): Promise<string> {
  const { input, output, segments, preset, outputFormat, onProgress } = options;

  // Validate input
  if (!input || !output) {
    throw new VideoProcessorError(
      VideoProcessorErrorCode.INVALID_PARAMETERS,
      'Input and output paths are required'
    );
  }

  // Determine segments (either from preset or custom)
  let finalSegments: SpeedSegment[];
  if (preset) {
    finalSegments = PRESETS[preset];
  } else if (segments && segments.length > 0) {
    finalSegments = segments;
  } else {
    // Default: 1x speed for entire video
    finalSegments = [{ start: 0, speed: 1.0, pitchCorrection: 'highQuality' }];
  }

  // Validate speed ranges
  for (const segment of finalSegments) {
    if (segment.speed < 0.1 || segment.speed > 32) {
      throw new VideoProcessorError(
        VideoProcessorErrorCode.INVALID_PARAMETERS,
        `Speed must be between 0.1x and 32x, got ${segment.speed}x`
      );
    }
  }

  // Set up progress listener
  let progressSubscription: any = null;
  if (onProgress) {
    progressSubscription = eventEmitter.addListener(
      'VideoProcessorProgress',
      (event: any) => {
        onProgress(event.progress);
      }
    );
  }

  try {
    const result = await VideoProcessorModule.processVideo(
      normalizePath(input),
      normalizePath(output),
      finalSegments.map((seg) => ({
        start: seg.start,
        end: seg.end,
        speed: seg.speed,
        pitchCorrection: seg.pitchCorrection || 'highQuality',
      })),
      outputFormat || 'both'
    );

    return result;
  } catch (error: any) {
    // Map native errors to typed errors
    if (error.code) {
      throw new VideoProcessorError(error.code, error.message);
    }
    throw error;
  } finally {
    // Clean up progress listener
    if (progressSubscription) {
      progressSubscription.remove();
    }
  }
}

/**
 * Trim/cut video to specific time range
 *
 * @param options - Trim options
 * @returns Promise that resolves to the output file path
 *
 * @example
 * ```typescript
 * await trimVideo({
 *   input: '/path/to/input.mp4',
 *   output: '/path/to/trimmed.mp4',
 *   startTime: 10.5,
 *   endTime: 45.0
 * });
 * ```
 */
export async function trimVideo(options: TrimOptions): Promise<string> {
  const { input, output, startTime, endTime, onProgress } = options;

  if (!input || !output) {
    throw new VideoProcessorError(
      VideoProcessorErrorCode.INVALID_PARAMETERS,
      'Input and output paths are required'
    );
  }

  if (startTime < 0 || endTime <= startTime) {
    throw new VideoProcessorError(
      VideoProcessorErrorCode.INVALID_PARAMETERS,
      'Invalid time range'
    );
  }

  let progressSubscription: any = null;
  if (onProgress) {
    progressSubscription = eventEmitter.addListener(
      'VideoProcessorProgress',
      (event: any) => {
        onProgress(event.progress);
      }
    );
  }

  try {
    const result = await VideoProcessorModule.trimVideo(
      normalizePath(input),
      normalizePath(output),
      startTime,
      endTime
    );
    return result;
  } catch (error: any) {
    if (error.code) {
      throw new VideoProcessorError(error.code, error.message);
    }
    throw error;
  } finally {
    if (progressSubscription) {
      progressSubscription.remove();
    }
  }
}

/**
 * Get video metadata (duration, dimensions, codecs, etc.)
 *
 * @param filePath - Path to video file
 * @returns Promise that resolves to video metadata
 *
 * @example
 * ```typescript
 * const metadata = await getVideoMetadata('/path/to/video.mp4');
 * console.log(`Duration: ${metadata.duration}s`);
 * console.log(`Resolution: ${metadata.width}x${metadata.height}`);
 * ```
 */
export async function getVideoMetadata(
  filePath: string
): Promise<VideoMetadata> {
  if (!filePath) {
    throw new VideoProcessorError(
      VideoProcessorErrorCode.INVALID_PARAMETERS,
      'File path is required'
    );
  }

  try {
    const metadata = await VideoProcessorModule.getMetadata(
      normalizePath(filePath)
    );
    return metadata;
  } catch (error: any) {
    if (error.code) {
      throw new VideoProcessorError(error.code, error.message);
    }
    throw error;
  }
}

/**
 * Generate thumbnail from video at specified time
 *
 * @param options - Thumbnail generation options
 * @returns Promise that resolves to the output image path
 *
 * @example
 * ```typescript
 * await generateThumbnail({
 *   input: '/path/to/video.mp4',
 *   output: '/path/to/thumb.jpg',
 *   time: 5.0,
 *   maxWidth: 1920
 * });
 * ```
 */
export async function generateThumbnail(
  options: ThumbnailOptions
): Promise<string> {
  const { input, output, time = 0, maxWidth } = options;

  if (!input || !output) {
    throw new VideoProcessorError(
      VideoProcessorErrorCode.INVALID_PARAMETERS,
      'Input and output paths are required'
    );
  }

  try {
    const result = await VideoProcessorModule.generateThumbnail(
      normalizePath(input),
      normalizePath(output),
      time,
      maxWidth
    );
    return result;
  } catch (error: any) {
    if (error.code) {
      throw new VideoProcessorError(error.code, error.message);
    }
    throw error;
  }
}

/**
 * Adjust video volume
 *
 * @param options - Volume adjustment options
 * @returns Promise that resolves to the output file path
 *
 * @example
 * ```typescript
 * // Mute video
 * await adjustVolume({ input: 'video.mp4', output: 'muted.mp4', volume: 0 });
 *
 * // Double volume
 * await adjustVolume({ input: 'video.mp4', output: 'loud.mp4', volume: 2.0 });
 * ```
 */
export async function adjustVolume(options: VolumeOptions): Promise<string> {
  const { input, output, volume, onProgress } = options;

  if (!input || !output) {
    throw new VideoProcessorError(
      VideoProcessorErrorCode.INVALID_PARAMETERS,
      'Input and output paths are required'
    );
  }

  if (volume < 0) {
    throw new VideoProcessorError(
      VideoProcessorErrorCode.INVALID_PARAMETERS,
      'Volume must be non-negative'
    );
  }

  let progressSubscription: any = null;
  if (onProgress) {
    progressSubscription = eventEmitter.addListener(
      'VideoProcessorProgress',
      (event: any) => {
        onProgress(event.progress);
      }
    );
  }

  try {
    const result = await VideoProcessorModule.adjustVolume(
      normalizePath(input),
      normalizePath(output),
      volume
    );
    return result;
  } catch (error: any) {
    if (error.code) {
      throw new VideoProcessorError(error.code, error.message);
    }
    throw error;
  } finally {
    if (progressSubscription) {
      progressSubscription.remove();
    }
  }
}

/**
 * Cancel ongoing video processing
 */
export function cancelProcessing(): void {
  VideoProcessorModule.cancelProcessing();
}
