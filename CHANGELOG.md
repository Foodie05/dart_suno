# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2025-06-05

### Added
- Updated `SunoSongData` model to support detailed song metadata and status fields
- Added `SunoSongMetadata` model for parsing complex metadata including GPT prompts and tags
- Support for retrieving preview information (audio/image URLs) during task generation
- Added new fields: `displayName`, `avatarImageUrl`, `majorModelVersion`, `isPublic`, `hasHook`, etc.
- Enhanced JSON parsing to handle new API response structure safely

## [1.0.0] - 2024-01-21

### Added
- Initial release of DartSuno library
- Complete implementation of Suno AI API integration
- Support for music generation with text prompts and style tags
- Support for lyrics generation from prompts
- Support for task status querying (single and batch)
- Support for audio URL uploads
- Support for song concatenation and audio processing
- Support for Chat-based conversational music generation
- Automatic task polling with customizable intervals and timeouts
- Progress tracking with real-time callbacks
- Comprehensive error handling and timeout management
- Complete data models for all API responses (SunoResponse, SunoTaskResponse, SunoSongData, etc.)
- Extensive documentation with examples in both English and Chinese
- Type-safe API with full null safety support

### Features
- **DartSuno Class**: Main client class with configurable base URL, API key, and model name
- **Flexible API Methods**: All methods support optional parameters for maximum flexibility
- **Async/Await Support**: Full asynchronous support with proper error handling
- **Progress Callbacks**: Real-time progress updates for long-running music generation tasks
- **Resource Management**: Proper HTTP client disposal and resource cleanup
- **Comprehensive Models**: Type-safe data models matching Suno API response structure
- **Error Handling**: Custom exceptions with detailed error messages
- **Polling System**: Intelligent task polling with configurable intervals and timeout protection

### Technical Details
- Dart SDK: >=2.17.0 <4.0.0
- Dependencies: http ^1.1.0
- Dev Dependencies: test ^1.21.0, lints ^2.0.0
- Platform Support: All platforms supported by Dart (Web, Mobile, Desktop, Server)
- Null Safety: Full null safety compliance
- Model Support: chirp-v3-0, chirp-v3-5, suno-v3.5 and other Suno AI models

### API Coverage
- ✅ Music Generation API (`/suno/submit/music`)
- ✅ Lyrics Generation API (`/suno/submit/lyrics`)
- ✅ Task Query API - Single (`/suno/fetch/{task_id}`)
- ✅ Task Query API - Batch (`/suno/fetch`)
- ✅ Audio Upload API (`/suno/uploads/audio-url`)
- ✅ Song Concatenation API (`/suno/submit/concat`)
- ✅ Chat Completion API (`/v1/chat/completions`)
- ✅ Task Polling with Progress Tracking
- ✅ Error Handling & Timeout Management
- ✅ Resource Management & Cleanup