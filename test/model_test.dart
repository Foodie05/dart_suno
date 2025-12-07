import 'dart:convert';
import 'package:test/test.dart';
import 'package:dart_suno/dart_suno.dart';

void main() {
  group('Model Parsing Tests', () {
    test('Parse SunoTaskResponse with new fields', () {
      final jsonString = r'''
{
    "code": "success",
    "message": "",
    "data": {
        "task_id": "45ec8cd5-cd30-45dc-ae65-b40ba15a72b2",
        "action": "MUSIC",
        "status": "IN_PROGRESS",
        "fail_reason": "",
        "submit_time": 1765108231,
        "start_time": 1765108231,
        "finish_time": 0,
        "progress": "0%",
        "data": [
            {
                "id": "0ee116c8-dd0e-4c8e-98e3-ef7d91aec3de",
                "tags": "ambient, ethereal textures with soft atmospheric layers, flute-driven, serene",
                "state": "running",
                "title": "Whispering Leaves",
                "handle": "titillatingvocalstems7367",
                "prompt": "[Verse]\nThe leaves drift down in slow parade",
                "status": "streaming",
                "clip_id": "0ee116c8-dd0e-4c8e-98e3-ef7d91aec3de",
                "duration": 0,
                "has_hook": false,
                "is_liked": false,
                "metadata": {
                    "tags": "ambient",
                    "type": "gen",
                    "prompt": "lyrics...",
                    "stream": true,
                    "has_stem": false,
                    "is_remix": false,
                    "priority": 10,
                    "can_remix": true,
                    "gpt_description_prompt": "A serene ambient music..."
                },
                "audio_url": "https://audiopipe.suno.ai/?item_id=0ee116c8-dd0e-4c8e-98e3-ef7d91aec3de",
                "image_url": "https://cdn2.suno.ai/image_0ee116c8-dd0e-4c8e-98e3-ef7d91aec3de.jpeg",
                "is_public": false,
                "ownership": {
                    "ownership_reason": "subscribed"
                },
                "video_url": "",
                "created_at": "2025-12-07T11:50:31.531Z",
                "flag_count": 0,
                "is_trashed": false,
                "model_name": "chirp-v4",
                "play_count": 0,
                "batch_index": 0,
                "entity_type": "song_schema",
                "display_name": "TitillatingVocalStems7367",
                "upvote_count": 0,
                "comment_count": 0,
                "allow_comments": true,
                "image_large_url": "https://cdn2.suno.ai/image_large_0ee116c8-dd0e-4c8e-98e3-ef7d91aec3de.jpeg",
                "is_contest_clip": false,
                "avatar_image_url": "https://cdn1.suno.ai/sAura10.jpg",
                "is_handle_updated": false,
                "major_model_version": "v4",
                "is_following_creator": false
            }
        ]
    }
}
''';

      final jsonMap = jsonDecode(jsonString);
      final response = SunoTaskResponse.fromJson(jsonMap);

      expect(response.code, 'success');
      expect(response.data, isNotNull);
      expect(response.data!.data, isNotNull);
      expect(response.data!.data!.isNotEmpty, true);

      final song = response.data!.data![0];
      expect(song.id, '0ee116c8-dd0e-4c8e-98e3-ef7d91aec3de');
      expect(song.audioUrl,
          'https://audiopipe.suno.ai/?item_id=0ee116c8-dd0e-4c8e-98e3-ef7d91aec3de');
      expect(song.imageUrl,
          'https://cdn2.suno.ai/image_0ee116c8-dd0e-4c8e-98e3-ef7d91aec3de.jpeg');
      expect(song.imageLargeUrl,
          'https://cdn2.suno.ai/image_large_0ee116c8-dd0e-4c8e-98e3-ef7d91aec3de.jpeg');

      // Test new fields
      expect(song.displayName, 'TitillatingVocalStems7367');
      expect(song.majorModelVersion, 'v4');
      expect(song.metadata, isNotNull);
      expect(song.metadata!.gptDescriptionPrompt,
          contains('A serene ambient music'));
      expect(song.isPublic, false);
      expect(song.hasHook, false);
    });
  });
}
