import * as React from 'react';
import {
  StyleSheet,
  View,
  Text,
  Button,
  TextInput,
  ScrollView,
  Alert,
} from 'react-native';
import {
  processVideo,
  trimVideo,
  getVideoMetadata,
  generateThumbnail,
  adjustVolume,
  type VideoMetadata,
} from 'react-native-macos-video-processor';

export default function App() {
  const [inputPath, setInputPath] = React.useState('');
  const [outputPath, setOutputPath] = React.useState('');
  const [progress, setProgress] = React.useState(0);
  const [metadata, setMetadata] = React.useState<VideoMetadata | null>(null);
  const [isProcessing, setIsProcessing] = React.useState(false);

  const handleProcessVideo = async () => {
    if (!inputPath || !outputPath) {
      Alert.alert('Error', 'Please provide input and output paths');
      return;
    }

    setIsProcessing(true);
    setProgress(0);

    try {
      const result = await processVideo({
        input: inputPath,
        output: outputPath,
        preset: '2x-lecture',
        onProgress: (prog) => {
          setProgress(prog);
        },
      });

      Alert.alert('Success', `Video processed: ${result}`);
    } catch (error: any) {
      Alert.alert('Error', error.message || 'Processing failed');
    } finally {
      setIsProcessing(false);
    }
  };

  const handleCustomSpeed = async () => {
    if (!inputPath || !outputPath) {
      Alert.alert('Error', 'Please provide input and output paths');
      return;
    }

    setIsProcessing(true);
    setProgress(0);

    try {
      const result = await processVideo({
        input: inputPath,
        output: outputPath,
        segments: [
          { start: 0, end: 10, speed: 2.0, pitchCorrection: 'voice' },
          { start: 10, speed: 1.0, pitchCorrection: 'highQuality' },
        ],
        onProgress: (prog) => {
          setProgress(prog);
        },
      });

      Alert.alert('Success', `Video processed with custom segments: ${result}`);
    } catch (error: any) {
      Alert.alert('Error', error.message || 'Processing failed');
    } finally {
      setIsProcessing(false);
    }
  };

  const handleTrim = async () => {
    if (!inputPath || !outputPath) {
      Alert.alert('Error', 'Please provide input and output paths');
      return;
    }

    setIsProcessing(true);
    setProgress(0);

    try {
      const result = await trimVideo({
        input: inputPath,
        output: outputPath,
        startTime: 5.0,
        endTime: 15.0,
        onProgress: (prog) => {
          setProgress(prog);
        },
      });

      Alert.alert('Success', `Video trimmed: ${result}`);
    } catch (error: any) {
      Alert.alert('Error', error.message || 'Processing failed');
    } finally {
      setIsProcessing(false);
    }
  };

  const handleGetMetadata = async () => {
    if (!inputPath) {
      Alert.alert('Error', 'Please provide input path');
      return;
    }

    try {
      const meta = await getVideoMetadata(inputPath);
      setMetadata(meta);
      Alert.alert('Metadata Retrieved', 'See metadata display below');
    } catch (error: any) {
      Alert.alert('Error', error.message || 'Failed to get metadata');
    }
  };

  const handleGenerateThumbnail = async () => {
    if (!inputPath) {
      Alert.alert('Error', 'Please provide input path');
      return;
    }

    const thumbnailPath = outputPath || '/tmp/thumbnail.jpg';

    try {
      const result = await generateThumbnail({
        input: inputPath,
        output: thumbnailPath,
        time: 5.0,
        maxWidth: 1920,
      });

      Alert.alert('Success', `Thumbnail saved: ${result}`);
    } catch (error: any) {
      Alert.alert('Error', error.message || 'Failed to generate thumbnail');
    }
  };

  const handleAdjustVolume = async () => {
    if (!inputPath || !outputPath) {
      Alert.alert('Error', 'Please provide input and output paths');
      return;
    }

    setIsProcessing(true);
    setProgress(0);

    try {
      const result = await adjustVolume({
        input: inputPath,
        output: outputPath,
        volume: 2.0, // Double volume
        onProgress: (prog) => {
          setProgress(prog);
        },
      });

      Alert.alert('Success', `Volume adjusted: ${result}`);
    } catch (error: any) {
      Alert.alert('Error', error.message || 'Failed to adjust volume');
    } finally {
      setIsProcessing(false);
    }
  };

  return (
    <ScrollView style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.title}>React Native macOS Video Processor</Text>
        <Text style={styles.subtitle}>Example App</Text>
      </View>

      <View style={styles.section}>
        <Text style={styles.sectionTitle}>File Paths</Text>
        <TextInput
          style={styles.input}
          placeholder="Input video path (e.g., /path/to/input.mp4)"
          value={inputPath}
          onChangeText={setInputPath}
        />
        <TextInput
          style={styles.input}
          placeholder="Output video path (e.g., /path/to/output.mp4)"
          value={outputPath}
          onChangeText={setOutputPath}
        />
      </View>

      {isProcessing && (
        <View style={styles.progressContainer}>
          <Text style={styles.progressText}>
            Progress: {Math.round(progress * 100)}%
          </Text>
          <View style={styles.progressBar}>
            <View
              style={[styles.progressFill, { width: `${progress * 100}%` }]}
            />
          </View>
        </View>
      )}

      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Speed Processing</Text>
        <Button
          title="2x Speed (Lecture Preset)"
          onPress={handleProcessVideo}
          disabled={isProcessing}
        />
        <View style={styles.buttonSpacer} />
        <Button
          title="Custom Speed Segments"
          onPress={handleCustomSpeed}
          disabled={isProcessing}
        />
      </View>

      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Quick-Win Features</Text>
        <Button
          title="Trim Video (5s-15s)"
          onPress={handleTrim}
          disabled={isProcessing}
        />
        <View style={styles.buttonSpacer} />
        <Button title="Get Metadata" onPress={handleGetMetadata} />
        <View style={styles.buttonSpacer} />
        <Button
          title="Generate Thumbnail (at 5s)"
          onPress={handleGenerateThumbnail}
        />
        <View style={styles.buttonSpacer} />
        <Button
          title="Double Volume"
          onPress={handleAdjustVolume}
          disabled={isProcessing}
        />
      </View>

      {metadata && (
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Video Metadata</Text>
          <Text style={styles.metadataText}>
            Duration: {metadata.duration.toFixed(2)}s
          </Text>
          <Text style={styles.metadataText}>
            Resolution: {metadata.width}x{metadata.height}
          </Text>
          <Text style={styles.metadataText}>
            Frame Rate: {metadata.frameRate.toFixed(2)} fps
          </Text>
          <Text style={styles.metadataText}>
            Video Codec: {metadata.videoCodec}
          </Text>
          {metadata.audioCodec && (
            <Text style={styles.metadataText}>
              Audio Codec: {metadata.audioCodec}
            </Text>
          )}
          <Text style={styles.metadataText}>
            File Size: {(metadata.fileSize / 1024 / 1024).toFixed(2)} MB
          </Text>
        </View>
      )}

      <View style={styles.footer}>
        <Text style={styles.footerText}>
          Built with AVFoundation • macOS 11+
        </Text>
      </View>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  header: {
    padding: 20,
    backgroundColor: '#007AFF',
    alignItems: 'center',
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    color: 'white',
  },
  subtitle: {
    fontSize: 16,
    color: 'white',
    marginTop: 5,
  },
  section: {
    margin: 20,
    padding: 15,
    backgroundColor: 'white',
    borderRadius: 10,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: '600',
    marginBottom: 15,
    color: '#333',
  },
  input: {
    borderWidth: 1,
    borderColor: '#ddd',
    borderRadius: 5,
    padding: 10,
    marginBottom: 10,
    backgroundColor: '#fff',
  },
  progressContainer: {
    margin: 20,
    padding: 15,
    backgroundColor: 'white',
    borderRadius: 10,
  },
  progressText: {
    fontSize: 16,
    fontWeight: '600',
    marginBottom: 10,
    color: '#007AFF',
  },
  progressBar: {
    height: 10,
    backgroundColor: '#e0e0e0',
    borderRadius: 5,
    overflow: 'hidden',
  },
  progressFill: {
    height: '100%',
    backgroundColor: '#007AFF',
  },
  buttonSpacer: {
    height: 10,
  },
  metadataText: {
    fontSize: 14,
    color: '#666',
    marginBottom: 5,
  },
  footer: {
    padding: 20,
    alignItems: 'center',
  },
  footerText: {
    fontSize: 12,
    color: '#999',
  },
});

