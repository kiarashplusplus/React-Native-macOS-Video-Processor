import type { TurboModule } from 'react-native';
import { TurboModuleRegistry } from 'react-native';

/**
 * Native module interface for VideoProcessor
 * This defines the bridge between JavaScript and native Swift code
 */
export interface Spec extends TurboModule {
    /**
     * Process video with speed adjustment and pitch correction
     */
    processVideo(
        input: string,
        output: string,
        segments: Array<{
            start: number;
            end?: number;
            speed: number;
            pitchCorrection?: string;
        }>,
        outputFormat: string
    ): Promise<string>;

    /**
     * Trim/cut video to specific time range
     */
    trimVideo(
        input: string,
        output: string,
        startTime: number,
        endTime: number
    ): Promise<string>;

    /**
     * Extract metadata from video file
     */
    getMetadata(input: string): Promise<{
        duration: number;
        width: number;
        height: number;
        frameRate: number;
        videoCodec: string;
        audioCodec?: string;
        fileSize: number;
    }>;

    /**
     * Generate thumbnail from video at specified time
     */
    generateThumbnail(
        input: string,
        output: string,
        time: number,
        maxWidth?: number
    ): Promise<string>;

    /**
     * Adjust video volume
     */
    adjustVolume(
        input: string,
        output: string,
        volume: number
    ): Promise<string>;

    /**
     * Cancel ongoing video processing
     */
    cancelProcessing(): void;
}

export default TurboModuleRegistry.getEnforcing<Spec>('VideoProcessor');
