# Dart Suno

[![pub package](https://img.shields.io/pub/v/dart_suno.svg)](https://pub.dev/packages/dart_suno)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A powerful Dart library for interacting with Suno AI music generation API. Generate music from text prompts, manage tasks, and retrieve audio files with ease.

一个用于与Suno AI音乐生成服务交互的强大Dart库。

## Features | 功能特性

- 🎵 **Music Generation** - Generate music from lyrics and style tags | 根据歌词和风格标签生成音乐
- 📝 **Lyrics Generation** - Auto-generate lyrics from prompts | 基于提示词自动生成歌词
- 🔄 **Task Polling** - Automatic task status polling until completion | 自动轮询任务状态直到完成
- 📁 **Audio Upload** - Upload audio files via URL | 支持通过URL上传音频文件
- 🎼 **Song Concatenation** - Concatenate multiple audio clips | 将多个音频片段拼接成完整歌曲
- 💬 **Chat Format** - ChatGPT-style conversational music generation | 支持ChatGPT风格的对话式音乐生成
- 📊 **Batch Queries** - Query multiple task statuses simultaneously | 同时查询多个任务状态

## Installation | 安装

Add this to your package's `pubspec.yaml` file:

在你的 `pubspec.yaml` 文件中添加依赖：

```yaml
dependencies:
  dart_suno: ^1.0.0
```

Then run:

然后运行：

```bash
dart pub get
```

## 快速开始

```dart
import 'package:dart_suno/dart_suno.dart';

void main() async {
  // 初始化客户端
  final suno = DartSuno(
    baseUrl: 'https://api.suno.ai',
    apiKey: 'your-api-key-here',
    modelName: 'chirp-v3-5', // 可选，默认为chirp-v3-0
  );

  try {
    // 生成音乐
    final response = await suno.generateMusic(
      prompt: '''[Verse]
Hello world, this is my song
Dancing through the night so long

[Chorus]
Music flows like a river
Makes my heart beat and shiver''',
      title: 'Hello World Song',
      tags: 'pop, upbeat, electronic',
      makeInstrumental: false,
    );

    if (response.code == 'success' && response.data != null) {
      // 轮询直到完成
      final result = await suno.pollTaskUntilComplete(
        taskId: response.data!,
        onProgress: (progress) => print('进度: $progress'),
      );

      // 获取生成的音乐
      if (result.data?.data != null) {
        for (final song in result.data!.data!) {
          print('歌曲标题: ${song.title}');
          print('音频链接: ${song.audioUrl}');
          print('封面图片: ${song.imageUrl}');
        }
      }
    }
  } finally {
    suno.dispose();
  }
}
```

## API 文档

### 构造函数

```dart
DartSuno({
  required String baseUrl,    // API基础URL
  required String apiKey,     // API密钥
  String modelName = 'chirp-v3-0',  // 默认模型名称
  http.Client? client,        // 可选的HTTP客户端
})
```

### 主要方法

#### 1. 生成音乐

```dart
Future<SunoResponse> generateMusic({
  String? prompt,              // 歌词内容
  String? title,               // 歌曲标题
  String? tags,                // 风格标签，用逗号分隔
  String? mv,                  // 模型版本
  bool? makeInstrumental,      // 是否生成纯音乐
  String? taskId,              // 任务ID（用于续写）
  double? continueAt,          // 续写起始时间点
  String? continueClipId,      // 需要续写的歌曲ID
  String? gptDescriptionPrompt, // 灵感模式提示词
  String? notifyHook,          // 回调通知地址
})
```

#### 2. 生成歌词

```dart
Future<SunoResponse> generateLyrics({
  required String prompt,      // 歌词提示词
  String? notifyHook,          // 回调地址
})
```

#### 3. 轮询任务状态

```dart
Future<SunoTaskResponse> pollTaskUntilComplete({
  required String taskId,      // 任务ID
  void Function(String progress)? onProgress,  // 进度回调
  Duration pollInterval = const Duration(milliseconds: 500),  // 轮询间隔
  Duration timeout = const Duration(minutes: 10),  // 超时时间
})
```

#### 4. Chat格式音乐生成

```dart
Future<SunoChatResponse> chatCompletion({
  required List<ChatMessage> messages,  // 对话消息
  String? model,               // 模型名称
  double? temperature,         // 采样温度
  double? topP,                // 核采样参数
  int? n,                      // 生成选择数量
  bool? stream,                // 是否流式输出
  String? stop,                // 停止序列
  int? maxTokens,              // 最大token数
  double? presencePenalty,     // 存在惩罚
  double? frequencyPenalty,    // 频率惩罚
  String? user,                // 用户标识符
})
```

#### 5. 其他方法

```dart
// 上传音频URL
Future<SunoResponse> uploadAudioUrl({required String url})

// 歌曲拼接
Future<SunoResponse> concatSongs({required String clipId, required bool isInfill})

// 查询单个任务
Future<SunoTaskResponse> fetchTask({required String taskId})

// 批量查询任务
Future<SunoResponse> fetchTasks({required List<String> ids})
```

## 数据模型

### SunoResponse
基础响应模型，包含：
- `code`: 响应代码
- `data`: 响应数据（通常是任务ID）
- `message`: 响应消息

### SunoTaskResponse
任务详细响应模型，包含：
- `code`: 响应代码
- `message`: 响应消息
- `data`: 任务详细数据

### SunoSongData
歌曲数据模型，包含：
- `id`: 歌曲ID
- `title`: 歌曲标题
- `audioUrl`: 音频下载链接
- `imageUrl`: 封面图片链接
- `duration`: 歌曲时长
- `tags`: 风格标签
- 等等...

## 错误处理

库提供了完善的错误处理机制：

```dart
try {
  final response = await suno.generateMusic(/* ... */);
  // 处理成功响应
} on TimeoutException catch (e) {
  print('任务超时: $e');
} catch (e) {
  print('发生错误: $e');
} finally {
  suno.dispose(); // 释放资源
}
```

## 高级用法

### 自定义轮询参数

```dart
final result = await suno.pollTaskUntilComplete(
  taskId: taskId,
  onProgress: (progress) {
    print('当前进度: $progress');
    // 可以在这里更新UI进度条
  },
  pollInterval: Duration(seconds: 1),  // 每秒轮询一次
  timeout: Duration(minutes: 15),      // 15分钟超时
);
```

### Chat格式对话

```dart
final messages = [
  ChatMessage(role: 'user', content: '创作一首关于友谊的歌'),
  ChatMessage(role: 'assistant', content: '好的，我来为你创作...'),
  ChatMessage(role: 'user', content: '请让它更加欢快一些'),
];

final response = await suno.chatCompletion(
  messages: messages,
  temperature: 0.8,
  maxTokens: 1000,
);
```

## 注意事项

1. **API密钥安全**: 请妥善保管你的API密钥，不要在代码中硬编码
2. **资源释放**: 使用完毕后记得调用 `dispose()` 方法释放HTTP客户端资源
3. **轮询频率**: 建议轮询间隔不要太短，避免对服务器造成过大压力
4. **超时设置**: 音乐生成可能需要较长时间，建议设置合理的超时时间

## 许可证

MIT License

## 贡献

欢迎提交Issue和Pull Request！

## 更新日志

### 1.0.0
- 初始版本发布
- 支持所有Suno API功能
- 完善的错误处理和文档