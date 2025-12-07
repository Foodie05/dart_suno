/// DartSuno - A Dart library for Suno API integration
///
/// This library provides a convenient way to interact with Suno's music generation APIs.
/// It supports music generation, lyrics creation, task management, and more.
///
/// Example usage:
/// ```dart
/// import 'package:dart_suno/dart_suno.dart';
///
/// final suno = DartSuno(
///   baseUrl: 'https://api.suno.com',
///   apiKey: 'your-api-key',
///   modelName: 'chirp-v3-5',
/// );
///
/// // Generate music
/// final response = await suno.generateMusic(
///   prompt: 'A happy pop song about friendship',
///   title: 'Best Friends Forever',
///   tags: 'pop, upbeat, friendship',
/// );
///
/// print('Task ID: ${response.data}');
/// ```
library dart_suno;

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// Dart Suno API客户端
///
/// 用于与Suno AI音乐生成服务进行交互的Dart库
class DartSuno {
  /// API基础URL
  final String baseUrl;

  /// API密钥
  final String apiKey;

  /// 默认模型名称
  final String modelName;

  /// HTTP客户端
  final http.Client _client;

  /// 构造函数
  ///
  /// [baseUrl] API基础URL，必需参数
  /// [apiKey] API密钥，必需参数
  /// [modelName] 模型名称，默认为 'chirp-v3-0'
  /// [client] HTTP客户端，可选参数，用于测试
  DartSuno({
    required this.baseUrl,
    required this.apiKey,
    this.modelName = 'chirp-v3-0',
    http.Client? client,
  }) : _client = client ?? http.Client();

  /// 获取通用请求头
  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $apiKey',
      };

  /// 生成音乐
  ///
  /// [prompt] 歌词内容，仅用于自定义模式
  /// [title] 歌曲标题，仅用于自定义模式
  /// [tags] 风格标签，仅用于自定义模式，多个标签用半角逗号分隔
  /// [mv] 模型选择，可选 chirp-v3-0、chirp-v3-5，默认使用构造函数中的modelName
  /// [makeInstrumental] 是否生成纯音乐版本，true 表示生成纯音乐
  /// [taskId] 任务ID，用于对已有任务进行操作（如续写）
  /// [continueAt] 续写起始时间点，浮点数，单位为秒
  /// [continueClipId] 需要续写的歌曲ID
  /// [gptDescriptionPrompt] 创作描述提示词，仅用于灵感模式
  /// [notifyHook] 任务完成后的回调通知地址
  ///
  /// 返回包含任务ID的响应
  Future<SunoResponse> generateMusic({
    String? prompt,
    String? title,
    String? tags,
    String? mv,
    bool? makeInstrumental,
    String? taskId,
    double? continueAt,
    String? continueClipId,
    String? gptDescriptionPrompt,
    String? notifyHook,
  }) async {
    final url = Uri.parse('$baseUrl/suno/submit/music');

    final body = <String, dynamic>{};

    // 只添加非空参数
    if (prompt != null) body['prompt'] = prompt;
    if (title != null) body['title'] = title;
    if (tags != null) body['tags'] = tags;
    body['mv'] = mv ?? modelName;
    if (makeInstrumental != null) body['make_instrumental'] = makeInstrumental;
    if (taskId != null) body['task_id'] = taskId;
    if (continueAt != null) body['continue_at'] = continueAt;
    if (continueClipId != null) body['continue_clip_id'] = continueClipId;
    if (gptDescriptionPrompt != null)
      body['gpt_description_prompt'] = gptDescriptionPrompt;
    if (notifyHook != null) body['notify_hook'] = notifyHook;

    final response = await _client.post(
      url,
      headers: _headers,
      body: jsonEncode(body),
    );

    return SunoResponse.fromJson(jsonDecode(response.body));
  }

  /// 生成歌词
  ///
  /// [prompt] 歌词提示词，必需参数
  /// [notifyHook] 回调地址，可选参数
  ///
  /// 返回包含任务ID的响应
  Future<SunoResponse> generateLyrics({
    required String prompt,
    String? notifyHook,
  }) async {
    final url = Uri.parse('$baseUrl/suno/submit/lyrics');

    final body = <String, dynamic>{
      'prompt': prompt,
    };

    if (notifyHook != null) {
      body['notify_hook'] = notifyHook;
    }

    final response = await _client.post(
      url,
      headers: _headers,
      body: jsonEncode(body),
    );

    return SunoResponse.fromJson(jsonDecode(response.body));
  }

  /// 上传音频URL
  ///
  /// [url] 上传的音乐URL，必需参数
  ///
  /// 返回包含任务ID的响应
  Future<SunoResponse> uploadAudioUrl({
    required String url,
  }) async {
    final uploadUrl = Uri.parse('$baseUrl/suno/uploads/audio-url');

    final body = <String, dynamic>{
      'url': url,
    };

    final response = await _client.post(
      uploadUrl,
      headers: _headers,
      body: jsonEncode(body),
    );

    return SunoResponse.fromJson(jsonDecode(response.body));
  }

  /// 歌曲拼接
  ///
  /// [clipId] extend 后的歌曲ID，必需参数
  /// [isInfill] 是否为填充模式，必需参数
  ///
  /// 返回包含任务ID的响应
  Future<SunoResponse> concatSongs({
    required String clipId,
    required bool isInfill,
  }) async {
    final url = Uri.parse('$baseUrl/suno/submit/concat');

    final body = <String, dynamic>{
      'clip_id': clipId,
      'is_infill': isInfill,
    };

    final response = await _client.post(
      url,
      headers: _headers,
      body: jsonEncode(body),
    );

    return SunoResponse.fromJson(jsonDecode(response.body));
  }

  /// 批量获取任务
  ///
  /// [ids] 任务ID列表，必需参数
  ///
  /// 返回包含任务信息的响应
  Future<SunoResponse> fetchTasks({
    required List<String> ids,
  }) async {
    final url = Uri.parse('$baseUrl/suno/fetch');

    final body = <String, dynamic>{
      'ids': ids,
    };

    final response = await _client.post(
      url,
      headers: _headers,
      body: jsonEncode(body),
    );

    return SunoResponse.fromJson(jsonDecode(response.body));
  }

  /// 查询单个任务
  ///
  /// [taskId] 任务ID，必需参数
  ///
  /// 返回包含任务详细信息的响应
  Future<SunoTaskResponse> fetchTask({
    required String taskId,
  }) async {
    final url = Uri.parse('$baseUrl/suno/fetch/$taskId');

    final response = await _client.get(
      url,
      headers: _headers,
    );

    return SunoTaskResponse.fromJson(jsonDecode(response.body));
  }

  /// 轮询任务状态直到完成
  ///
  /// [taskId] 任务ID，必需参数
  /// [onProgress] 进度更新回调函数，可选参数
  /// [onComplete] 任务完成回调函数，传入歌曲列表，可选参数
  /// [pollInterval] 轮询间隔，默认500毫秒
  /// [timeout] 超时时间，默认10分钟
  ///
  /// 返回完成的任务信息，包含歌曲URL等详细信息
  Future<SunoTaskResponse> pollTaskUntilComplete({
    required String taskId,
    void Function(String progress)? onProgress,
    void Function(List<SunoSongData> songs)? onComplete,
    Duration pollInterval = const Duration(milliseconds: 500),
    Duration timeout = const Duration(minutes: 10),
  }) async {
    final startTime = DateTime.now();

    while (DateTime.now().difference(startTime) < timeout) {
      final response = await fetchTask(taskId: taskId);

      if (response.code == 'success' && response.data != null) {
        final progress = response.data!.progress;

        // 调用进度回调
        if (onProgress != null && progress != null) {
          onProgress(progress);
        }

        // 检查是否完成
        if (progress == '100%' || response.data!.status == 'SUCCESS') {
          // 调用完成回调，传入歌曲列表
          if (onComplete != null && response.data!.data != null) {
            onComplete(response.data!.data!);
          }
          return response;
        }
      }

      // 等待下次轮询
      await Future.delayed(pollInterval);
    }

    throw TimeoutException(
        'Task polling timeout after ${timeout.inMinutes} minutes', timeout);
  }

  /// Chat格式的文生音乐
  ///
  /// [messages] 对话消息列表，必需参数
  /// [model] 要使用的模型ID，可选参数，默认使用构造函数中的modelName
  /// [temperature] 采样温度，介于0和2之间，可选参数
  /// [topP] 核采样参数，可选参数
  /// [n] 生成的选择数量，可选参数
  /// [stream] 是否流式输出，可选参数
  /// [stop] 停止序列，可选参数
  /// [maxTokens] 最大token数，可选参数
  /// [presencePenalty] 存在惩罚，可选参数
  /// [frequencyPenalty] 频率惩罚，可选参数
  /// [user] 用户标识符，可选参数
  ///
  /// 返回Chat格式的响应
  Future<SunoChatResponse> chatCompletion({
    required List<ChatMessage> messages,
    String? model,
    double? temperature,
    double? topP,
    int? n,
    bool? stream,
    String? stop,
    int? maxTokens,
    double? presencePenalty,
    double? frequencyPenalty,
    String? user,
  }) async {
    final url = Uri.parse('$baseUrl/v1/chat/completions');

    final body = <String, dynamic>{
      'model': model ?? modelName,
      'messages': messages.map((m) => m.toJson()).toList(),
    };

    // 只添加非空的可选参数
    if (temperature != null) body['temperature'] = temperature;
    if (topP != null) body['top_p'] = topP;
    if (n != null) body['n'] = n;
    if (stream != null) body['stream'] = stream;
    if (stop != null) body['stop'] = stop;
    if (maxTokens != null) body['max_tokens'] = maxTokens;
    if (presencePenalty != null) body['presence_penalty'] = presencePenalty;
    if (frequencyPenalty != null) body['frequency_penalty'] = frequencyPenalty;
    if (user != null) body['user'] = user;

    final response = await _client.post(
      url,
      headers: _headers,
      body: jsonEncode(body),
    );

    return SunoChatResponse.fromJson(jsonDecode(response.body));
  }

  /// 释放资源
  void dispose() {
    _client.close();
  }
}

/// Suno API通用响应模型
class SunoResponse {
  /// 响应代码
  final String code;

  /// 响应数据（通常是任务ID）
  final String? data;

  /// 响应消息
  final String message;

  SunoResponse({
    required this.code,
    this.data,
    required this.message,
  });

  factory SunoResponse.fromJson(Map<String, dynamic> json) {
    return SunoResponse(
      code: json['code'] as String,
      data: json['data'] as String?,
      message: json['message'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'data': data,
      'message': message,
    };
  }
}

/// Suno任务详细响应模型
class SunoTaskResponse {
  /// 响应代码
  final String code;

  /// 响应消息
  final String message;

  /// 任务详细数据
  final SunoTaskData? data;

  SunoTaskResponse({
    required this.code,
    required this.message,
    this.data,
  });

  factory SunoTaskResponse.fromJson(Map<String, dynamic> json) {
    return SunoTaskResponse(
      code: json['code'] as String,
      message: json['message'] as String,
      data: json['data'] != null ? SunoTaskData.fromJson(json['data']) : null,
    );
  }
}

/// Suno任务数据模型
class SunoTaskData {
  /// 任务ID
  final String taskId;

  /// 操作类型
  final String action;

  /// 任务状态
  final String status;

  /// 失败原因
  final String? failReason;

  /// 提交时间
  final int? submitTime;

  /// 开始时间
  final int? startTime;

  /// 完成时间
  final int? finishTime;

  /// 进度百分比
  final String? progress;

  /// 歌曲数据列表
  final List<SunoSongData>? data;

  SunoTaskData({
    required this.taskId,
    required this.action,
    required this.status,
    this.failReason,
    this.submitTime,
    this.startTime,
    this.finishTime,
    this.progress,
    this.data,
  });

  factory SunoTaskData.fromJson(Map<String, dynamic> json) {
    return SunoTaskData(
      taskId: json['task_id'] as String,
      action: json['action'] as String,
      status: json['status'] as String,
      failReason: json['fail_reason'] as String?,
      submitTime: json['submit_time'] as int?,
      startTime: json['start_time'] as int?,
      finishTime: json['finish_time'] as int?,
      progress: json['progress'] as String?,
      data: json['data'] != null
          ? (json['data'] is List
              ? (json['data'] as List<dynamic>)
                  .map((item) =>
                      SunoSongData.fromJson(item as Map<String, dynamic>))
                  .toList()
              : null)
          : null,
    );
  }
}

/// Suno歌曲数据模型
class SunoSongData {
  /// 歌曲ID
  final String id;

  /// 风格标签
  final String? tags;

  /// 状态
  final String? state;

  /// 标题
  final String? title;

  /// 用户句柄
  final String? handle;

  /// 提示词/歌词
  final String? prompt;

  /// 状态
  final String? status;

  /// 片段ID
  final String? clipId;

  /// 时长（秒）
  final double? duration;

  /// 是否包含显式内容
  final bool? explicit;

  /// 音频URL
  final String? audioUrl;

  /// 图片URL
  final String? imageUrl;

  /// 大图片URL
  final String? imageLargeUrl;

  /// 视频URL
  final String? videoUrl;

  /// 创建时间
  final String? createdAt;

  /// 模型名称
  final String? modelName;

  /// 播放次数
  final int? playCount;

  /// 点赞数
  final int? upvoteCount;

  /// 评论数
  final int? commentCount;

  /// 元数据
  final SunoSongMetadata? metadata;

  /// 是否有Hook
  final bool? hasHook;

  /// 是否已点赞
  final bool? isLiked;

  /// 是否公开
  final bool? isPublic;

  /// 举报次数
  final int? flagCount;

  /// 是否已删除
  final bool? isTrashed;

  /// 批次索引
  final int? batchIndex;

  /// 实体类型
  final String? entityType;

  /// 显示名称
  final String? displayName;

  /// 是否允许评论
  final bool? allowComments;

  /// 是否为竞赛片段
  final bool? isContestClip;

  /// 头像图片URL
  final String? avatarImageUrl;

  /// 是否更新了句柄
  final bool? isHandleUpdated;

  /// 主要模型版本
  final String? majorModelVersion;

  /// 是否关注了创作者
  final bool? isFollowingCreator;

  SunoSongData({
    required this.id,
    this.tags,
    this.state,
    this.title,
    this.handle,
    this.prompt,
    this.status,
    this.clipId,
    this.duration,
    this.explicit,
    this.audioUrl,
    this.imageUrl,
    this.imageLargeUrl,
    this.videoUrl,
    this.createdAt,
    this.modelName,
    this.playCount,
    this.upvoteCount,
    this.commentCount,
    this.metadata,
    this.hasHook,
    this.isLiked,
    this.isPublic,
    this.flagCount,
    this.isTrashed,
    this.batchIndex,
    this.entityType,
    this.displayName,
    this.allowComments,
    this.isContestClip,
    this.avatarImageUrl,
    this.isHandleUpdated,
    this.majorModelVersion,
    this.isFollowingCreator,
  });

  factory SunoSongData.fromJson(Map<String, dynamic> json) {
    return SunoSongData(
      id: json['id'] as String,
      tags: json['tags'] as String?,
      state: json['state'] as String?,
      title: json['title'] as String?,
      handle: json['handle'] as String?,
      prompt: json['prompt'] as String?,
      status: json['status'] as String?,
      clipId: json['clip_id'] as String?,
      duration: json['duration']?.toDouble(),
      explicit: json['explicit'] as bool?,
      audioUrl: json['audio_url'] as String?,
      imageUrl: json['image_url'] as String?,
      imageLargeUrl: json['image_large_url'] as String?,
      videoUrl: json['video_url'] as String?,
      createdAt: json['created_at'] as String?,
      modelName: json['model_name'] as String?,
      playCount: json['play_count'] as int?,
      upvoteCount: json['upvote_count'] as int?,
      commentCount: json['comment_count'] as int?,
      metadata: json['metadata'] != null
          ? SunoSongMetadata.fromJson(json['metadata'])
          : null,
      hasHook: json['has_hook'] as bool?,
      isLiked: json['is_liked'] as bool?,
      isPublic: json['is_public'] as bool?,
      flagCount: json['flag_count'] as int?,
      isTrashed: json['is_trashed'] as bool?,
      batchIndex: json['batch_index'] as int?,
      entityType: json['entity_type'] as String?,
      displayName: json['display_name'] as String?,
      allowComments: json['allow_comments'] as bool?,
      isContestClip: json['is_contest_clip'] as bool?,
      avatarImageUrl: json['avatar_image_url'] as String?,
      isHandleUpdated: json['is_handle_updated'] as bool?,
      majorModelVersion: json['major_model_version'] as String?,
      isFollowingCreator: json['is_following_creator'] as bool?,
    );
  }
}

/// Suno歌曲元数据模型
class SunoSongMetadata {
  /// 标签
  final String? tags;

  /// 类型
  final String? type;

  /// 提示词
  final String? prompt;

  /// 是否流式传输
  final bool? stream;

  /// 是否有分轨
  final bool? hasStem;

  /// 是否为混音
  final bool? isRemix;

  /// 优先级
  final int? priority;

  /// 是否可混音
  final bool? canRemix;

  /// 是否使用最新模型
  final bool? usesLatestModel;

  /// GPT描述提示词
  final String? gptDescriptionPrompt;

  SunoSongMetadata({
    this.tags,
    this.type,
    this.prompt,
    this.stream,
    this.hasStem,
    this.isRemix,
    this.priority,
    this.canRemix,
    this.usesLatestModel,
    this.gptDescriptionPrompt,
  });

  factory SunoSongMetadata.fromJson(Map<String, dynamic> json) {
    return SunoSongMetadata(
      tags: json['tags'] as String?,
      type: json['type'] as String?,
      prompt: json['prompt'] as String?,
      stream: json['stream'] as bool?,
      hasStem: json['has_stem'] as bool?,
      isRemix: json['is_remix'] as bool?,
      priority: json['priority'] as int?,
      canRemix: json['can_remix'] as bool?,
      usesLatestModel: json['uses_latest_model'] as bool?,
      gptDescriptionPrompt: json['gpt_description_prompt'] as String?,
    );
  }
}

/// Chat消息模型
class ChatMessage {
  /// 角色（user, assistant, system）
  final String role;

  /// 消息内容
  final String content;

  ChatMessage({
    required this.role,
    required this.content,
  });

  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'content': content,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      role: json['role'] as String,
      content: json['content'] as String,
    );
  }
}

/// Chat响应模型
class SunoChatResponse {
  /// 响应ID
  final String id;

  /// 对象类型
  final String object;

  /// 创建时间
  final int created;

  /// 选择列表
  final List<ChatChoice> choices;

  /// 使用情况
  final ChatUsage usage;

  SunoChatResponse({
    required this.id,
    required this.object,
    required this.created,
    required this.choices,
    required this.usage,
  });

  factory SunoChatResponse.fromJson(Map<String, dynamic> json) {
    return SunoChatResponse(
      id: json['id'] as String,
      object: json['object'] as String,
      created: json['created'] as int,
      choices: (json['choices'] as List)
          .map((item) => ChatChoice.fromJson(item))
          .toList(),
      usage: ChatUsage.fromJson(json['usage']),
    );
  }
}

/// Chat选择模型
class ChatChoice {
  /// 索引
  final int index;

  /// 消息
  final ChatMessage message;

  /// 完成原因
  final String finishReason;

  ChatChoice({
    required this.index,
    required this.message,
    required this.finishReason,
  });

  factory ChatChoice.fromJson(Map<String, dynamic> json) {
    return ChatChoice(
      index: json['index'] as int,
      message: ChatMessage.fromJson(json['message']),
      finishReason: json['finish_reason'] as String,
    );
  }
}

/// Chat使用情况模型
class ChatUsage {
  /// 提示token数
  final int promptTokens;

  /// 完成token数
  final int completionTokens;

  /// 总token数
  final int totalTokens;

  ChatUsage({
    required this.promptTokens,
    required this.completionTokens,
    required this.totalTokens,
  });

  factory ChatUsage.fromJson(Map<String, dynamic> json) {
    return ChatUsage(
      promptTokens: json['prompt_tokens'] as int,
      completionTokens: json['completion_tokens'] as int,
      totalTokens: json['total_tokens'] as int,
    );
  }
}

/// 超时异常
class TimeoutException implements Exception {
  final String message;
  final Duration timeout;

  TimeoutException(this.message, this.timeout);

  @override
  String toString() => 'TimeoutException: $message';
}
