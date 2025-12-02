/**
 * Error codes for video processing operations
 */
export enum VideoProcessorErrorCode {
    FILE_NOT_FOUND = 'FILE_NOT_FOUND',
    UNSUPPORTED_FORMAT = 'UNSUPPORTED_FORMAT',
    EXPORT_FAILED = 'EXPORT_FAILED',
    INSUFFICIENT_SPACE = 'INSUFFICIENT_SPACE',
    INVALID_PARAMETERS = 'INVALID_PARAMETERS',
    CANCELLED = 'CANCELLED',
}

/**
 * Custom error class for video processor errors
 */
export class VideoProcessorError extends Error {
    code: VideoProcessorErrorCode;

    constructor(code: VideoProcessorErrorCode, message: string) {
        super(message);
        this.name = 'VideoProcessorError';
        this.code = code;
    }
}

/**
 * Pitch correction algorithm to use during speed adjustment
 */
export type PitchCorrectionAlgorithm = 'voice' | 'highQuality' | 'none';

/**
 * A segment of video with specific speed settings
 */
export interface SpeedSegment {
    /** Start time in seconds */
    start: number;
    /** End time in seconds (omit to continue until next segment or end of video) */
    end?: number;
    /** Speed multiplier (0.1x to 32x) */
    speed: number;
    /** Pitch correction algorithm (default: 'highQuality') */
    pitchCorrection?: PitchCorrectionAlgorithm;
}

/**
 * Preset configurations for common use cases
 */
export type ProcessingPreset = '2x-lecture' | '16x-timelapse' | 'slowmo-sports';

/**
 * Output format options
 */
export type OutputFormat = 'video' | 'audio' | 'both';

/**
 * Options for video processing
 */
export interface ProcessingOptions {
    /** Input file path (absolute path or file:// URI) */
    input: string;
    /** Output file path (absolute path or file:// URI) */
    output: string;
    /** Array of speed segments (if omitted, applies single speed to entire video) */
    segments?: SpeedSegment[];
    /** Preset configuration (alternative to segments) */
    preset?: ProcessingPreset;
    /** Output format (default: 'both') */
    outputFormat?: OutputFormat;
    /** Progress callback (0.0 to 1.0) */
    onProgress?: (progress: number) => void;
}

/**
 * Options for trimming/cutting video
 */
export interface TrimOptions {
    /** Input file path */
    input: string;
    /** Output file path */
    output: string;
    /** Start time in seconds */
    startTime: number;
    /** End time in seconds */
    endTime: number;
    /** Progress callback */
    onProgress?: (progress: number) => void;
}

/**
 * Video metadata information
 */
export interface VideoMetadata {
    /** Duration in seconds */
    duration: number;
    /** Video width in pixels */
    width: number;
    /** Video height in pixels */
    height: number;
    /** Frame rate (frames per second) */
    frameRate: number;
    /** Video codec name */
    videoCodec: string;
    /** Audio codec name (if present) */
    audioCodec?: string;
    /** File size in bytes */
    fileSize: number;
}

/**
 * Options for thumbnail generation
 */
export interface ThumbnailOptions {
    /** Input file path */
    input: string;
    /** Output image path */
    output: string;
    /** Time in seconds to capture thumbnail (default: 0) */
    time?: number;
    /** Maximum width in pixels (maintains aspect ratio) */
    maxWidth?: number;
}

/**
 * Options for volume control
 */
export interface VolumeOptions {
    /** Input file path */
    input: string;
    /** Output file path */
    output: string;
    /** Volume multiplier (0.0 = mute, 1.0 = original, 2.0 = double) */
    volume: number;
    /** Progress callback */
    onProgress?: (progress: number) => void;
}
