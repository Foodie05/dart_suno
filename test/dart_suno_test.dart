import 'dart:convert';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;
import 'package:dart_suno/dart_suno.dart';

// Mock HTTP客户端
class MockHttpClient extends http.BaseClient {
  final Map<String, dynamic> mockResponses;

  MockHttpClient(this.mockResponses);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final url = request.url.toString();
    final method = request.method;
    final key = '$method $url';

    if (mockResponses.containsKey(key)) {
      final response = mockResponses[key];
      return http.StreamedResponse(
        Stream.fromIterable([utf8.encode(jsonEncode(response))]),
        200,
        headers: {'content-type': 'application/json'},
      );
    }

    return http.StreamedResponse(
      Stream.fromIterable([utf8.encode('{"error": "Not found"}')]),
      404,
    );
  }
}

void main() {
  group('DartSuno', () {
    late DartSuno suno;
    late MockHttpClient mockClient;

    setUp(() {
      mockClient = MockHttpClient({
        'POST https://api.example.com/suno/submit/music': {
          'code': 'success',
          'data': 'test-task-id-123',
          'message': '',
        },
        'POST https://api.example.com/suno/submit/lyrics': {
          'code': 'success',
          'data': 'lyrics-task-id-456',
          'message': '',
        },
        'GET https://api.example.com/suno/fetch/test-task-id-123': {
          'code': 'success',
          'message': '',
          'data': {
            'task_id': 'test-task-id-123',
            'action': 'MUSIC',
            'status': 'SUCCESS',
            'progress': '100%',
            'data': [
              {
                'id': 'song-id-1',
                'title': 'Test Song',
                'audio_url': 'https://example.com/song.mp3',
                'image_url': 'https://example.com/cover.jpg',
                'duration': 180.5,
                'tags': 'pop, electronic',
                'status': 'complete',
              }
            ]
          }
        },
        'POST https://api.example.com/v1/chat/completions': {
          'id': 'chatcmpl-123',
          'object': 'chat.completion',
          'created': 1677652288,
          'choices': [
            {
              'index': 0,
              'message': {
                'role': 'assistant',
                'content': 'Generated music content here'
              },
              'finish_reason': 'stop'
            }
          ],
          'usage': {
            'prompt_tokens': 9,
            'completion_tokens': 12,
            'total_tokens': 21
          }
        }
      });

      suno = DartSuno(
        baseUrl: 'https://api.example.com',
        apiKey: 'test-api-key',
        modelName: 'chirp-v3-5',
        client: mockClient,
      );
    });

    tearDown(() {
      suno.dispose();
    });

    test('should initialize with correct parameters', () {
      expect(suno.baseUrl, equals('https://api.example.com'));
      expect(suno.apiKey, equals('test-api-key'));
      expect(suno.modelName, equals('chirp-v3-5'));
    });

    test('should generate music successfully', () async {
      final response = await suno.generateMusic(
        prompt: 'Test lyrics',
        title: 'Test Song',
        tags: 'pop, electronic',
        makeInstrumental: false,
      );

      expect(response.code, equals('success'));
      expect(response.data, equals('test-task-id-123'));
      expect(response.message, equals(''));
    });

    test('should generate lyrics successfully', () async {
      final response = await suno.generateLyrics(
        prompt: 'Write a song about friendship',
      );

      expect(response.code, equals('success'));
      expect(response.data, equals('lyrics-task-id-456'));
    });

    test('should fetch task successfully', () async {
      final response = await suno.fetchTask(taskId: 'test-task-id-123');

      expect(response.code, equals('success'));
      expect(response.data, isNotNull);
      expect(response.data!.taskId, equals('test-task-id-123'));
      expect(response.data!.status, equals('SUCCESS'));
      expect(response.data!.progress, equals('100%'));
      expect(response.data!.data, hasLength(1));

      final song = response.data!.data!.first;
      expect(song.id, equals('song-id-1'));
      expect(song.title, equals('Test Song'));
      expect(song.audioUrl, equals('https://example.com/song.mp3'));
      expect(song.duration, equals(180.5));
    });

    test('should handle chat completion successfully', () async {
      final messages = [
        ChatMessage(role: 'user', content: 'Create a happy song'),
      ];

      final response = await suno.chatCompletion(
        messages: messages,
        temperature: 0.8,
      );

      expect(response.id, equals('chatcmpl-123'));
      expect(response.choices, hasLength(1));
      expect(response.choices.first.message.content,
          equals('Generated music content here'));
      expect(response.usage.totalTokens, equals(21));
    });

    test('should create ChatMessage correctly', () {
      final message = ChatMessage(role: 'user', content: 'Hello');
      final json = message.toJson();

      expect(json['role'], equals('user'));
      expect(json['content'], equals('Hello'));

      final fromJson = ChatMessage.fromJson(json);
      expect(fromJson.role, equals('user'));
      expect(fromJson.content, equals('Hello'));
    });

    test('should create SunoResponse from JSON correctly', () {
      final json = {
        'code': 'success',
        'data': 'task-123',
        'message': 'OK',
      };

      final response = SunoResponse.fromJson(json);
      expect(response.code, equals('success'));
      expect(response.data, equals('task-123'));
      expect(response.message, equals('OK'));

      final backToJson = response.toJson();
      expect(backToJson, equals(json));
    });

    test('should handle optional parameters correctly', () async {
      // 测试只传必需参数
      final response1 = await suno.generateMusic(
        prompt: 'Simple test',
      );
      expect(response1.code, equals('success'));

      // 测试传入所有参数
      final response2 = await suno.generateMusic(
        prompt: 'Full test',
        title: 'Full Test Song',
        tags: 'test, full',
        mv: 'chirp-v3-0',
        makeInstrumental: true,
        taskId: 'existing-task',
        continueAt: 30.5,
        continueClipId: 'clip-123',
        gptDescriptionPrompt: 'test description',
        notifyHook: 'https://webhook.example.com',
      );
      expect(response2.code, equals('success'));
    });
  });

  group('Data Models', () {
    test('SunoSongData should parse JSON correctly', () {
      final json = {
        'id': 'song-123',
        'title': 'Test Song',
        'audio_url': 'https://example.com/audio.mp3',
        'image_url': 'https://example.com/image.jpg',
        'duration': 240.0,
        'tags': 'pop, rock',
        'status': 'complete',
        'play_count': 100,
        'upvote_count': 50,
      };

      final song = SunoSongData.fromJson(json);
      expect(song.id, equals('song-123'));
      expect(song.title, equals('Test Song'));
      expect(song.audioUrl, equals('https://example.com/audio.mp3'));
      expect(song.duration, equals(240.0));
      expect(song.playCount, equals(100));
    });

    test('SunoTaskData should parse JSON correctly', () {
      final json = {
        'task_id': 'task-456',
        'action': 'MUSIC',
        'status': 'SUCCESS',
        'progress': '100%',
        'submit_time': 1677652288,
        'data': [
          {
            'id': 'song-1',
            'title': 'Song 1',
            'audio_url': 'https://example.com/song1.mp3',
          }
        ]
      };

      final taskData = SunoTaskData.fromJson(json);
      expect(taskData.taskId, equals('task-456'));
      expect(taskData.action, equals('MUSIC'));
      expect(taskData.status, equals('SUCCESS'));
      expect(taskData.progress, equals('100%'));
      expect(taskData.data, hasLength(1));
      expect(taskData.data!.first.id, equals('song-1'));
    });

    test('ChatUsage should parse JSON correctly', () {
      final json = {
        'prompt_tokens': 10,
        'completion_tokens': 20,
        'total_tokens': 30,
      };

      final usage = ChatUsage.fromJson(json);
      expect(usage.promptTokens, equals(10));
      expect(usage.completionTokens, equals(20));
      expect(usage.totalTokens, equals(30));
    });
  });

  group('Error Handling', () {
    test('TimeoutException should have correct message', () {
      final timeout = Duration(minutes: 5);
      final exception = TimeoutException('Test timeout', timeout);

      expect(exception.message, equals('Test timeout'));
      expect(exception.timeout, equals(timeout));
      expect(exception.toString(), contains('TimeoutException: Test timeout'));
    });
  });
}
