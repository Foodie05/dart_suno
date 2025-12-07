/// Dart Suno Example
///
/// This example demonstrates how to use the dart_suno package to interact
/// with Suno AI music generation API.
///
/// Before running this example, make sure to:
/// 1. Replace 'your-api-key-here' with your actual Suno API key
/// 2. Replace the baseUrl with the correct API endpoint
/// 3. Install dependencies: dart pub get

import 'package:dart_suno/dart_suno.dart';

void main() async {
  // Initialize DartSuno client
  // 初始化DartSuno客户端
  final suno = DartSuno(
    baseUrl: 'https://api.suno.ai', // Replace with actual API base URL
    apiKey: 'your-api-key-here', // Replace with your API key
    modelName: 'chirp-v3-5', // Optional, defaults to chirp-v3-0
  );

  try {
    // Example 1: Generate Music
    // 示例1: 生成音乐
    print('=== Music Generation Example | 生成音乐示例 ===');
    final musicResponse = await suno.generateMusic(
      prompt: '''[Verse]
Paws up high
Paws down low
Swing that tail
Let it flow (ooh-yeah!)

[Chorus]
Cat dance
Cat dance
Move your feet
Cat dance
Cat dance
Feel the beat''',
      title: 'Cat Dance',
      tags: 'electronic, danceable, playful',
      makeInstrumental: false,
      gptDescriptionPrompt: 'cat dance',
    );

    print('Music generation task ID | 音乐生成任务ID: ${musicResponse.data}');

    if (musicResponse.data != null) {
      // Example 2: Poll task status until completion
      // 示例2: 轮询任务状态直到完成
      print('\n=== Task Polling Example | 轮询任务状态 ===');
      await suno.pollTaskUntilComplete(
        taskId: musicResponse.data!,
        onProgress: (progress) {
          print('Task progress | 任务进度: $progress');
        },
        onComplete: (songs) {
          print('\n=== Task Completed | 任务完成 ===');
          for (int i = 0; i < songs.length; i++) {
            final song = songs[i];
            print('Song ${i + 1} | 歌曲 ${i + 1}:');
            print('  Title | 标题: ${song.title}');
            print('  Duration | 时长: ${song.duration} seconds');
            print('  Audio URL | 音频URL: ${song.audioUrl}');
            print('  Image URL | 图片URL: ${song.imageUrl}');
            print('  Status | 状态: ${song.status}');
            print('  Model Version | 模型版本: ${song.majorModelVersion}');
            print('  Display Name | 显示名称: ${song.displayName}');
            print('  Metadata | 元数据:');
            print('    - Prompt: ${song.metadata?.prompt}');
            print('    - Tags: ${song.metadata?.tags}');
            print('    - Type: ${song.metadata?.type}');
            print('    - Stream: ${song.metadata?.stream}');
          }
        },
        pollInterval: Duration(milliseconds: 500),
        timeout: Duration(minutes: 10),
      );

      print('Task completed! | 任务完成！');
    }

    // Example 3: Generate Lyrics
    // 示例3: 生成歌词
    print('\n=== Lyrics Generation Example | 生成歌词示例 ===');
    final lyricsTaskResponse = await suno.generateLyrics(
      prompt: 'Write a song about friendship and adventure',
    );
    print('Lyrics generation task ID | 歌词生成任务ID: ${lyricsTaskResponse.data}');

    // Example 4: Chat-based Music Generation
    // 示例4: Chat格式的文生音乐
    print('\n=== Chat-based Music Generation | Chat格式音乐生成示例 ===');
    final chatResponse = await suno.chatCompletion(
      messages: [
        ChatMessage(
            role: 'user',
            content: 'Create a cheerful song about spring | 写一首关于春天的轻快歌曲'),
      ],
      temperature: 0.8,
      stream: false,
    );

    print('Chat response ID | Chat响应ID: ${chatResponse.id}');
    for (final choice in chatResponse.choices) {
      print('Generated content | 生成内容: ${choice.message.content}');
    }

    // Example 5: Upload Audio URL
    // 示例5: 上传音频URL
    print('\n=== Audio Upload Example | 上传音频URL示例 ===');
    final uploadResponse = await suno.uploadAudioUrl(
      url: 'https://example.com/audio.mp3',
    );
    print('Upload task ID | 上传任务ID: ${uploadResponse.data}');

    // Example 6: Song Concatenation
    // 示例6: 歌曲拼接
    print('\n=== Song Concatenation Example | 歌曲拼接示例 ===');
    final concatResponse = await suno.concatSongs(
      clipId: 'some-clip-id',
      isInfill: false,
    );
    print('Concatenation task ID | 拼接任务ID: ${concatResponse.data}');

    // Example 7: Batch Task Query
    // 示例7: 批量获取任务
    print('\n=== Batch Task Query Example | 批量获取任务示例 ===');
    final batchResponse = await suno.fetchTasks(
      ids: ['task-id-1', 'task-id-2', 'task-id-3'],
    );
    print('Batch query result | 批量查询结果: ${batchResponse.code}');
  } catch (e) {
    print('Error occurred | 发生错误: $e');
  } finally {
    // Clean up resources
    // 释放资源
    suno.dispose();
  }
}

/// Advanced Usage Example: Complete Music Generation Workflow with Error Handling
/// 高级使用示例：带错误处理的完整音乐生成流程
Future<void> advancedMusicGeneration() async {
  final suno = DartSuno(
    baseUrl: 'https://api.suno.ai',
    apiKey: 'your-api-key-here',
  );

  try {
    // Step 1: Generate Lyrics
    // 第一步：生成歌词
    print('Generating lyrics... | 正在生成歌词...');
    final lyricsResponse = await suno.generateLyrics(
      prompt:
          'Write an inspirational song about dreams and persistence | 写一首关于梦想和坚持的励志歌曲',
    );

    if (lyricsResponse.code != 'success') {
      throw Exception(
          'Lyrics generation failed | 歌词生成失败: ${lyricsResponse.message}');
    }

    // Poll lyrics generation status
    // 轮询歌词生成状态
    final lyricsTaskResult = await suno.pollTaskUntilComplete(
      taskId: lyricsResponse.data!,
      onProgress: (progress) =>
          print('Lyrics generation progress | 歌词生成进度: $progress'),
    );

    print(
        'Lyrics generation completed | 歌词生成完成: ${lyricsTaskResult.data?.data?.first.title}');

    // Step 2: Generate music using the generated lyrics
    // 第二步：使用生成的歌词创建音乐
    print('Generating music... | 正在生成音乐...');
    final musicResponse = await suno.generateMusic(
      prompt: 'Generated lyrics here', // In real usage, get from lyricsTask
      title: 'Dreams and Persistence',
      tags: 'inspirational, pop, uplifting',
      makeInstrumental: false,
    );

    if (musicResponse.code != 'success') {
      throw Exception(
          'Music generation failed | 音乐生成失败: ${musicResponse.message}');
    }

    // Poll music generation status
    // 轮询音乐生成状态
    await suno.pollTaskUntilComplete(
      taskId: musicResponse.data!,
      onProgress: (progress) =>
          print('Music generation progress | 音乐生成进度: $progress'),
      onComplete: (songs) {
        print('Music generation completed! | 音乐生成完成！');
        for (final song in songs) {
          print('Song | 歌曲: ${song.title}');
          print('Download link | 下载链接: ${song.audioUrl}');
        }
      },
    );
  } on TimeoutException catch (e) {
    print('Task timeout | 任务超时: $e');
  } catch (e) {
    print('Error occurred | 发生错误: $e');
  } finally {
    suno.dispose();
  }
}

/// Simple Usage Example for Quick Start
/// 简单使用示例，快速开始
Future<void> simpleExample() async {
  final suno = DartSuno(
    baseUrl: 'https://api.suno.ai',
    apiKey: 'your-api-key-here',
    modelName: 'chirp-v3-5',
  );

  try {
    // Generate music with minimal parameters
    // 使用最少参数生成音乐
    final response = await suno.generateMusic(
      prompt: 'A happy song about coding',
      title: 'Code Joy',
      tags: 'upbeat, electronic',
    );

    if (response.code == 'success' && response.data != null) {
      // Wait for completion and get results
      // 等待完成并获取结果
      final result = await suno.pollTaskUntilComplete(
        taskId: response.data!,
        onProgress: (progress) => print('Progress: $progress'),
      );

      // Print results
      // 打印结果
      if (result.data?.data != null) {
        for (final song in result.data!.data!) {
          print('Generated song: ${song.title}');
          print('Listen at: ${song.audioUrl}');
        }
      }
    }
  } finally {
    suno.dispose();
  }
}
