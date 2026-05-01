# Flutter RAG Knowledge Engine - Development Plan

## 📋 Project Overview
Complete implementation plan for the Flutter mobile RAG Knowledge Engine client, organized into 6 sequential phases. Each phase builds upon the previous, starting with core infrastructure and progressing to feature-complete UI screens.

---

## Phase 1: Foundation & Core Infrastructure

### 🎯 Objective
Establish project structure, dependencies, core configuration, and navigation routing. All foundation layers required by subsequent phases.

### 📁 Files to Create

**Root Configuration:**
```
pubspec.yaml (updated with dependencies)
```

**Directory Structure:**
```
lib/
  main.dart
  app.dart
  core/
    config/
      app_config.dart
      constants.dart
    network/
      dio_client.dart
      api_exception.dart
    theme/
      app_theme.dart
    widgets/
      app_card.dart
      app_button.dart
      status_badge.dart
      loading_overlay.dart
  features/
    projects/
      data/
        repositories/
      presentation/
        pages/
        providers/
    dashboard/
      presentation/
        pages/
    files/
      data/
        repositories/
      presentation/
        pages/
        providers/
    rag/
      data/
        repositories/
      presentation/
        pages/
        providers/
    translation/
      data/
        repositories/
      presentation/
        pages/
        providers/
```

### 📄 Detailed Files

1. **lib/main.dart**
   - Entry point with MaterialApp wrapper
   - Theme configuration
   - GoRouter setup

2. **lib/app.dart**
   - App widget with routing configuration
   - GoRouter routes definition for all 5 main screens
   - Navigation state management

3. **lib/core/config/app_config.dart**
   - Base URL configuration
   - Android emulator default: `10.0.2.2:8000`
   - Support for environment-based configuration

4. **lib/core/config/constants.dart**
   - API endpoints constants
   - Supported file types
   - Default values (chunk_size, overlap_size, etc.)

5. **lib/core/network/dio_client.dart**
   - Dio instance initialization
   - Request/response interceptors
   - Error handling middleware
   - Multipart upload support

6. **lib/core/network/api_exception.dart**
   - Custom exception class
   - Error parsing from backend responses
   - Network error mapping

7. **lib/core/theme/app_theme.dart**
   - Material 3 theme configuration
   - Color scheme (files: blue/teal, AI: green, translation: orange)
   - Typography and component styles

8. **lib/core/widgets/app_card.dart**
   - Reusable card widget for action grouping
   - Elevation and padding standards

9. **lib/core/widgets/app_button.dart**
   - Reusable button widget with loading state
   - Disabled state handling

10. **lib/core/widgets/status_badge.dart**
    - Status display component
    - Signal/success/error state indicators

11. **lib/core/widgets/loading_overlay.dart**
    - Full-screen loading overlay
    - Prevents repeated submissions

### 📦 Dependencies (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  dio: ^5.3.0
  flutter_riverpod: ^2.4.0
  go_router: ^12.0.0
  file_picker: ^6.1.0
  shared_preferences: ^2.2.0
  intl: ^0.19.0
  google_fonts: ^6.1.0
  cupertino_icons: ^1.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
```

### SRS References
- Section 3.2: External Dependencies
- Section 5: Application Structure
- Section 9.1: Base URL Configuration
- Section 11: Recommended Technical Architecture
- Section 11.5: Folder Structure

### 🔧 Technical Notes

1. **Dio Configuration:**
   - Set request timeout to 30 seconds
   - Add logging interceptor for debug builds only
   - Configure multipart upload with progress tracking

2. **GoRouter Setup:**
   - Define 5 routes: /projects, /dashboard, /files, /ask, /translate
   - Parameter passing for project_id via extra parameter
   - Redirect logic if no project selected

3. **Theme System:**
   - Define semantic colors for features (files/search/translation)
   - Support for future dark mode implementation
   - Use google_fonts for modern typography

4. **Android Emulator:**
   - Set default base URL to `10.0.2.2:8000`
   - Allow override via AppConfig for local testing

5. **Shared Preferences Setup:**
   - Store recent project IDs (max 10)
   - Store last used target language
   - Store backend base URL if modified

### ✅ Acceptance Criteria

- [x] pubspec.yaml contains all required dependencies with correct versions
- [x] Project folder structure matches specification exactly
- [x] main.dart runs without errors
- [x] app.dart defines all 5 routes correctly
- [x] GoRouter navigation is testable (no compilation errors)
- [x] DioClient initializes without crashes
- [x] App theme loads successfully
- [x] All core widgets are importable without errors
- [x] Android emulator base URL defaults to 10.0.2.2:8000
- [x] shared_preferences is initialized for local storage
- [x] No analyzer warnings in core/ folder

### 🔗 Commit Message

```
feat(core): setup project foundation and core infrastructure
- Add pubspec.yaml with dio, flutter_riverpod, go_router, file_picker
- Create complete folder structure for features
- Implement DioClient with interceptors and multipart support
- Setup AppConfig for base URL management (Android emulator default)
- Create AppTheme with semantic colors for features
- Define reusable widgets: AppCard, AppButton, StatusBadge, LoadingOverlay
- Implement GoRouter with 5 main routes and parameter passing
- Setup SharedPreferences for recent projects and settings
```

---

## Phase 2: Core Models

### 🎯 Objective
Define all Dart data models matching backend API responses. Pure data layer with serialization support.

### 📁 Files to Create

**Models:**
```
lib/core/models/
  api_response_base.dart
  upload_response.dart
  process_response.dart
  index_push_response.dart
  search_result_item.dart
  search_response.dart
  rag_answer_response.dart
  translation_job_create_response.dart
  translation_job_status_response.dart
```

### 📄 Detailed Files

1. **lib/core/models/api_response_base.dart**
   ```dart
   // Base response model with signal field
   - signal: String (success/error indicator)
   - Serialization support with fromJson/toJson
   ```

2. **lib/core/models/upload_response.dart**
   ```dart
   - signal: String
   - file_id: String
   - timestamp: DateTime (optional)
   ```

3. **lib/core/models/process_response.dart**
   ```dart
   - signal: String
   - file_id: String
   - inserted_chunks: int
   - processed_files: int
   - chunk_size: int (optional)
   - overlap_size: int (optional)
   ```

4. **lib/core/models/index_push_response.dart**
   ```dart
   - signal: String
   - indexed_count: int (optional)
   - collection_info: Map (optional)
   ```

5. **lib/core/models/search_result_item.dart**
   ```dart
   - text: String
   - score: double
   - meta_data: Map<String, dynamic>
   - id: String (optional)
   ```

6. **lib/core/models/search_response.dart**
   ```dart
   - signal: String
   - search_results: List<SearchResultItem>
   - query: String (echo)
   - execution_time_ms: int (optional)
   ```

7. **lib/core/models/rag_answer_response.dart**
   ```dart
   - signal: String
   - answer: String
   - full_prompt: String (optional)
   - chat_history: List<Map> (optional)
   - retrieved_chunks: int (optional)
   ```

8. **lib/core/models/translation_job_create_response.dart**
   ```dart
   - signal: String
   - job_id: String
   - status: String
   - asset_id: String
   - source_lang: String
   - target_lang: String
   - created_at: DateTime (optional)
   ```

9. **lib/core/models/translation_job_status_response.dart**
   ```dart
   - signal: String
   - job: Map with fields:
     - job_id: String
     - status: String (pending/processing/completed/failed)
     - result_file_id: String (optional)
     - error_message: String (optional)
     - progress_percentage: int (optional)
   ```

### SRS References
- Section 8.1: Client-Side Models

### 🔧 Technical Notes

1. **JSON Serialization:**
   - Implement fromJson/toJson for all models
   - Handle null fields gracefully
   - Use copyWith pattern for immutability

2. **Type Safety:**
   - Strongly typed fields (no dynamic)
   - Nullable vs non-nullable distinction
   - Proper handling of optional fields

3. **Data Validation:**
   - Validate field types in constructors
   - Ensure required fields are present
   - Parse timestamps correctly

### ✅ Acceptance Criteria

- [x] All 9 models compile without errors
- [x] Each model has fromJson/toJson implementations
- [x] JSON field names match backend exactly
- [x] Optional fields marked as nullable
- [x] No unused imports in any model file
- [x] All models handle null values gracefully
- [x] Type safety enforced throughout

### 🔗 Commit Message

```
feat(models): implement core data models
- Create ApiResponseBase with signal field handling
- Implement UploadResponse model
- Implement ProcessResponse with chunk counts
- Implement IndexPushResponse
- Implement SearchResultItem and SearchResponse
- Implement RagAnswerResponse with debug data
- Implement TranslationJobCreateResponse
- Implement TranslationJobStatusResponse
- Add fromJson/toJson for all models
- Handle optional and required fields correctly
```

---

## Phase 3: API Service & Network Layer

### 🎯 Objective
Implement centralized API service for all backend communication with request/response handling.

### 📁 Files to Create

**API Service:**
```
lib/core/network/
  api_service.dart
```

### 📄 Detailed Files

1. **lib/core/network/api_service.dart**
   ```dart
   - Centralized API service class with methods:
     - uploadFile(projectId, file, {onProgress}) -> UploadResponse
     - processFile(projectId, fileId, chunkSize, overlapSize, doReset) -> ProcessResponse
     - pushIndex(projectId, doReset) -> IndexPushResponse
     - getIndexInfo(projectId) -> Map (optional)
     - search(projectId, text, limit) -> SearchResponse
     - askQuestion(projectId, text, limit) -> RagAnswerResponse
     - createTranslationJob(projectId, fileId, sourceLang, targetLang) -> TranslationJobCreateResponse
     - getTranslationStatus(jobId) -> TranslationJobStatusResponse
   - Error handling with ApiException
   - Response validation and parsing
   - Upload progress tracking
   ```

### SRS References
- Section 9: API Integration Requirements
- Section 9.2-9.8: Specific endpoint requirements

### 🔧 Technical Notes

1. **API Service Design:**
   - Single source of truth for all API calls
   - All methods are async and return typed models
   - Centralized base URL and headers management

2. **File Upload:**
   - Multipart form data handling via Dio
   - Progress tracking with onSendProgress callback
   - Support for large files

3. **Response Validation:**
   - Validate required fields in each response
   - Parse signal field to determine success/failure
   - Extract error messages from backend responses

4. **Error Handling:**
   - Wrap all calls in try-catch
   - Convert Dio exceptions to ApiException
   - Log detailed errors in debug mode

### ✅ Acceptance Criteria

- [ ] ApiService class compiles without errors
- [ ] All 8 endpoint methods implemented
- [ ] File upload supports progress callbacks
- [ ] Response models are properly parsed
- [ ] Error handling with signal field works
- [ ] All endpoints match backend spec
- [ ] Multipart upload configured correctly
- [ ] Type safety maintained throughout

### 🔗 Commit Message

```
feat(api): implement centralized API service
- Create ApiService with all 8 endpoint methods
- Implement uploadFile with progress tracking
- Implement processFile with parameter handling
- Implement pushIndex for vector database
- Implement search and askQuestion endpoints
- Implement translation job creation and status
- Add response parsing and validation
- Add comprehensive error handling
- Support multipart file uploads
- Handle async operations correctly
```

---

## Phase 4: Data Repositories

### 🎯 Objective
Create repository layer wrapping API service for feature-specific data access patterns.

### 📁 Files to Create

**Repositories:**
```
lib/features/files/data/
  repositories/
    file_repository.dart
lib/features/rag/data/
  repositories/
    search_repository.dart
    answer_repository.dart
lib/features/translation/data/
  repositories/
    translation_repository.dart
```

### 📄 Detailed Files

1. **lib/features/files/data/repositories/file_repository.dart**
   ```dart
   - Wrapper around ApiService for file operations
   - Methods: 
     - uploadFile(projectId, file) with progress callback
     - processFile(projectId, fileId, chunkSize, overlapSize, doReset)
     - pushIndex(projectId, doReset)
     - getIndexInfo(projectId)
   - Local state management for current file_id and process parameters
   ```

2. **lib/features/rag/data/repositories/search_repository.dart**
   ```dart
   - Wrapper around ApiService for search
   - Method: search(projectId, text, limit) -> SearchResponse
   - Optional caching of recent searches
   ```

3. **lib/features/rag/data/repositories/answer_repository.dart**
   ```dart
   - Wrapper around ApiService for RAG answers
   - Method: askQuestion(projectId, text, limit) -> RagAnswerResponse
   - Optional caching of recent questions
   ```

4. **lib/features/translation/data/repositories/translation_repository.dart**
   ```dart
   - Wrapper around ApiService for translation
   - Methods:
     - createJob(projectId, fileId, sourceLang, targetLang) -> TranslationJobCreateResponse
     - getJobStatus(jobId) -> TranslationJobStatusResponse
   - Local state for job polling
   ```

### SRS References
- Section 8: Data Model Requirements
- Section 9: API Integration Requirements

### 🔧 Technical Notes

1. **Repository Pattern:**
   - Wrapper around ApiService
   - Feature-specific data access logic
   - Centralized error handling per feature

2. **State Management:**
   - Local state for UI-related data
   - No business logic in repositories
   - Clean data-access interface

3. **Error Handling:**
   - Pass through ApiExceptions
   - Add feature-specific error context
   - Log failures appropriately

### ✅ Acceptance Criteria

- [ ] All 4 repositories compile without errors
- [ ] Each repository wraps ApiService correctly
- [ ] File repository has all required methods
- [ ] Search/Answer repositories implement correctly
- [ ] Translation repository with polling support
- [ ] Error handling maintained
- [ ] All repositories use correct endpoints

### 🔗 Commit Message

```
feat(repositories): implement data access layer
- Create FileRepository for file operations
- Create SearchRepository for semantic search
- Create AnswerRepository for RAG answers
- Create TranslationRepository for translation jobs
- Add progress callback support to file operations
- Implement error handling for all repositories
- Add optional caching for searches/answers
- Support job polling for translation
```

---

## Phase 5: ProjectsPage (Projects Feature)

### 🎯 Objective
Implement the first user-facing screen. Users can enter project IDs, validate input, view recent projects, and navigate to the project dashboard.

### 📁 Files to Create

```
lib/features/projects/
  data/
    repositories/
      projects_repository.dart
  presentation/
    pages/
      projects_page.dart
    providers/
      recent_projects_provider.dart
      projects_notifier.dart
```

### 📄 Detailed Files

1. **lib/features/projects/data/repositories/projects_repository.dart**
   ```dart
   - Methods:
     - getRecentProjects() -> List<int> (from SharedPreferences)
     - saveRecentProject(projectId: int) -> void
     - addToRecent(projectId: int) -> void (keep last 10)
     - clearRecentProjects() -> void
   - Local state management for recent projects
   ```

2. **lib/features/projects/presentation/providers/projects_notifier.dart**
   ```dart
   - StateNotifier managing:
     - currentProjectId: int?
     - recentProjects: List<int>
     - isLoading: bool
     - errorMessage: String?
   - Methods:
     - loadRecentProjects()
     - openProject(projectId: int)
     - clearError()
     - validateProjectId(String) -> bool
   ```

3. **lib/features/projects/presentation/providers/recent_projects_provider.dart**
   ```dart
   - Riverpod StateNotifierProvider for ProjectsNotifier
   - Select providers for:
     - recent projects list
     - current project id
     - loading state
     - error state
   ```

4. **lib/features/projects/presentation/pages/projects_page.dart**
   ```dart
   UI Elements:
   - AppBar with title "Knowledge Engine"
   - Column with:
     - Subtitle/description text
     - TextFormField for project_id input
       - Keyboard: numeric only
       - Validation: non-empty, numeric only
       - Error text display
     - SizedBox (spacing)
     - ElevatedButton "Open Project"
       - Disabled during loading
       - Shows loading spinner when active
     - SizedBox (spacing)
     - "Recent Projects" section
       - Conditional display if recentProjects.isEmpty
       - Horizontal scroll ListView of project ID cards
         - Each card is tappable
         - Shows project_id
         - Shows small 'x' to remove option (optional)
     - Error message display if present
   
   Behavior:
   - On "Open Project" click:
     - Validate input (reject empty, non-numeric)
     - Show validation error in UI
     - If valid, save to recent projects
     - Navigate to dashboard with project_id
   - On recent project card tap:
     - Navigate to dashboard with project_id
   - Preserve TextField value until navigation
   - Handle network errors gracefully (for future)
   
   Responsive Design:
   - Padding for safe area
   - Column with mainAxisAlignment.start
   - Responsive spacing based on screen height
   ```

### SRS References
- Section 6.1: Project Entry Requirements
- Section 7.1: ProjectsPage Requirements
- Section 10.1: Usability Requirements
- Section 4.1: Primary Workflow (step 1)

### 🔧 Technical Notes

1. **Input Validation:**
   - Regex or int.tryParse() to validate numeric input
   - Real-time validation feedback
   - Disable button if invalid

2. **Recent Projects Storage:**
   - Use SharedPreferences with key 'recent_projects'
   - Store as JSON string of List<int>
   - Limit to 10 most recent
   - Newest first ordering

3. **Navigation:**
   - Use GoRouter to navigate to /dashboard with project_id
   - Pass project_id via route parameters or extra
   - Handle navigation state properly

4. **Riverpod State:**
   - Use StateNotifier for complex logic
   - Separate notifier from provider
   - Use select() for granular rebuilds

5. **Error Handling:**
   - Display validation errors inline
   - Show snackbars for system errors (future)
   - Clear errors when user types

6. **Mobile UX:**
   - Large touch targets (48px minimum)
   - Adequate spacing between elements
   - Clear visual feedback on interactions

### ✅ Acceptance Criteria

- [ ] ProjectsPage renders without errors
- [ ] TextField accepts numeric input only
- [ ] "Open Project" button validates project_id
- [ ] Empty input shows validation error
- [ ] Non-numeric input shows validation error
- [ ] Valid project_id navigates to dashboard
- [ ] Recent projects list displays correctly
- [ ] Recent projects are stored in SharedPreferences
- [ ] Clicking recent project navigates to dashboard
- [ ] Recent projects limited to 10 items
- [ ] Loading state shows spinner on button
- [ ] Button disabled during loading
- [ ] Error messages display clearly
- [ ] Riverpod providers work without errors
- [ ] All widgets are styled consistently
- [ ] Touch targets are 48px minimum

### 🔗 Commit Message

```
feat(projects): implement ProjectsPage with project selection
- Create ProjectsNotifier for state management
- Implement recent projects storage in SharedPreferences
- Create ProjectsPage with validation and navigation
- Add text input validation (numeric only)
- Implement recent projects list with tap navigation
- Add loading and error states
- Use Riverpod StateNotifierProvider for state management
- Style with consistent app theme and spacing
- Support project_id parameter passing to dashboard
```

---

## Phase 4: FilesPage (File Management)

### 🎯 Objective
Implement complete file workflow: selection, upload, processing, and indexing. Three distinct sub-flows: upload → process → index.

### 📁 Files to Create

```
lib/features/files/
  data/
    repositories/
      file_repository.dart (expanded)
  presentation/
    pages/
      files_page.dart
    providers/
      files_notifier.dart
      files_provider.dart
    widgets/
      upload_section.dart
      process_section.dart
      index_section.dart
      status_log_widget.dart
```

### 📄 Detailed Files

1. **lib/features/files/presentation/providers/files_notifier.dart**
   ```dart
   - StateNotifier managing:
     - selectedFile: File?
     - selectedFileName: String?
     - fileId: String?
     - uploadProgress: double (0.0-1.0)
     - isUploading: bool
     - processParameters: {
         chunk_size: int,
         overlap_size: int,
         do_reset: bool
       }
     - isProcessing: bool
     - processedStatus: String?
     - isIndexing: bool
     - indexStatus: String?
     - statusLog: List<String>
     - errorMessage: String?
     - currentProjectId: int
   
   - Methods:
     - selectFile()
     - uploadFile()
     - processFile()
     - pushIndex(doReset: bool)
     - updateChunkSize(int)
     - updateOverlapSize(int)
     - toggleDoReset()
     - clearStatus()
     - addToLog(String message)
   ```

2. **lib/features/files/presentation/providers/files_provider.dart**
   ```dart
   - Riverpod StateNotifierProvider for FilesNotifier
   - Select providers for:
     - selected file
     - file_id
     - upload progress
     - process status
     - index status
     - status log
     - error message
     - chunk/overlap parameters
   - Dependency on recent_projects_provider for currentProjectId
   ```

3. **lib/features/files/presentation/widgets/upload_section.dart**
   ```dart
   UI Elements:
   - Card container with title "1. Upload File"
   - File picker button with icon
   - Selected file name display (if selected)
   - Upload button (enabled only if file selected)
     - Shows upload progress bar during upload
     - Shows percentage text
   - Uploaded file_id display (if successful)
   - Supported file types info: .txt, .pdf, .docx, .csv, .html, .xlsx
   
   Behavior:
   - On file picker button: open device file picker
   - On upload button: call filesNotifier.uploadFile()
   - Progress bar updates in real-time
   - Display success/error feedback
   ```

4. **lib/features/files/presentation/widgets/process_section.dart**
   ```dart
   UI Elements:
   - Card container with title "2. Process File"
   - Enabled only if fileId is set
   - TextFormField for chunk_size (default: 512)
   - TextFormField for overlap_size (default: 50)
   - CheckboxListTile for "Advanced Options"
     - Toggles visibility of chunk/overlap fields
   - CheckboxListTile for "do_reset" (default: false)
   - Process button
     - Shows loading spinner during processing
     - Disabled if no fileId
   - Status display:
     - inserted_chunks count
     - processed_files count
   
   Behavior:
   - Input validation for chunk/overlap (positive integers)
   - On process button: call filesNotifier.processFile()
   - Show response data after success
   ```

5. **lib/features/files/presentation/widgets/index_section.dart**
   ```dart
   UI Elements:
   - Card container with title "3. Push to Index"
   - CheckboxListTile for "Full Reindex (do_reset)"
   - Push Index button
     - Shows loading spinner during indexing
     - Disabled until file is processed
   - Status display:
     - "Pushing to vector database..."
     - Success message on completion
   
   Behavior:
   - On push button: call filesNotifier.pushIndex()
   - Show loading state during request
   - Display success confirmation
   ```

6. **lib/features/files/presentation/widgets/status_log_widget.dart**
   ```dart
   UI Elements:
   - Card container with title "Status Log"
   - ListView of timestamped log entries
   - Auto-scroll to latest entry
   - Copy log button (optional)
   - Clear log button
   
   Behavior:
   - Display all actions with timestamps
   - Different colors for info/success/error
   - Max 50 entries before clearing
   ```

7. **lib/features/files/presentation/pages/files_page.dart**
   ```dart
   Structure:
   - AppBar with title "Manage Files" and back button
   - SingleChildScrollView with:
     - SafeArea padding
     - Column with:
       - Instruction text: "Upload, process, and index files"
       - UploadSection widget
       - ProcessSection widget (conditional)
       - IndexSection widget (conditional)
       - StatusLogWidget
   
   Behavior:
   - Read currentProjectId from provider
   - Display three sections sequentially
   - Enable/disable sections based on progress
   - Show loading overlays for long operations
   ```

8. **lib/features/files/data/repositories/file_repository.dart (expanded)**
   ```dart
   - Methods (detailed implementation):
     - uploadFile(projectId, file) with progress callback
     - processFile(projectId, fileId, chunkSize, overlapSize, doReset)
     - pushIndex(projectId, doReset)
     - getIndexInfo(projectId) -> optional metadata
   - Error handling and response parsing
   - Progress tracking for uploads
   ```

### SRS References
- Section 6.3: File Upload Requirements
- Section 6.4: File Processing Requirements
- Section 6.5: Vector Index Push Requirements
- Section 7.3: FilesPage Requirements
- Section 9.2: Upload API
- Section 9.3: Process API
- Section 9.4: Index Push API

### 🔧 Technical Notes

1. **File Selection:**
   - Use file_picker package for cross-platform support
   - Filter by supported file types
   - Validate file size on client (optional)

2. **Upload Progress:**
   - Dio's onSendProgress callback
   - Update progress bar in real-time
   - Store fileId from response

3. **Process Parameters:**
   - Defaults: chunk_size=512, overlap_size=50
   - Keep advanced options hidden by default
   - Validate numeric inputs before sending

4. **Sequential Flow:**
   - Disable process until file uploaded
   - Disable index until file processed
   - Allow retry at each step

5. **Status Log:**
   - Timestamp each action
   - Use different colors/icons for states
   - Preserve log across interactions

6. **Error Recovery:**
   - Show error messages clearly
   - Allow retry without re-selecting file
   - Log errors in status log

7. **State Persistence:**
   - Clear fileId on navigation away
   - Optional: save last used parameters

### ✅ Acceptance Criteria

- [ ] FilesPage renders without errors
- [ ] File picker opens and allows selection
- [ ] Selected file name displays correctly
- [ ] Upload button disabled until file selected
- [ ] Upload shows progress bar with percentage
- [ ] fileId displays after successful upload
- [ ] Process button disabled until fileId exists
- [ ] Chunk size and overlap size fields accept numeric input
- [ ] Process button shows loading state
- [ ] inserted_chunks and processed_files display after processing
- [ ] Index button disabled until file processed
- [ ] Index push shows loading state
- [ ] do_reset checkbox works and is sent to backend
- [ ] Status log shows all actions with timestamps
- [ ] Error messages display clearly
- [ ] Advanced options section toggles correctly
- [ ] Three-step sequential workflow works end-to-end
- [ ] All network calls use correct endpoint URLs
- [ ] Loading overlays prevent duplicate submissions

### 🔗 Commit Message

```
feat(files): implement complete file upload, process, and index workflow
- Create FilesNotifier with state management for upload/process/index
- Implement upload section with file picker and progress tracking
- Implement process section with chunk/overlap configuration
- Implement index section with reset options
- Add status log widget showing all operations
- Create three-step sequential workflow
- Add input validation for numeric parameters
- Show real-time upload progress with Dio callbacks
- Display fileId and operation results
- Support advanced options toggle
- Add error handling and status feedback
- Style sections with app theme
```

---

## Phase 5: AskPage (RAG & Search)

### 🎯 Objective
Implement semantic search and RAG question-answer workflows. Two parallel flows: search for chunks, ask for AI-generated answers.

### 📁 Files to Create

```
lib/features/rag/
  data/
    repositories/
      search_repository.dart (expanded)
      answer_repository.dart (expanded)
  presentation/
    pages/
      ask_page.dart
    providers/
      rag_notifier.dart
      rag_provider.dart
    widgets/
      search_section.dart
      answer_section.dart
      search_results_widget.dart
      answer_display_widget.dart
      debug_section_widget.dart
```

### 📄 Detailed Files

1. **lib/features/rag/presentation/providers/rag_notifier.dart**
   ```dart
   - StateNotifier managing:
     - searchQuery: String
     - searchLimit: int (default: 10)
     - searchResults: List<SearchResultItem>
     - isSearching: bool
     - searchError: String?
     - answerQuestion: String
     - answerLimit: int (default: 5)
     - answer: String?
     - fullPrompt: String?
     - chatHistory: List<Map>?
     - isAnswering: bool
     - answerError: String?
     - showDebugInfo: bool
     - currentProjectId: int
   
   - Methods:
     - updateSearchQuery(String)
     - updateSearchLimit(int)
     - performSearch()
     - clearSearch()
     - updateAnswerQuestion(String)
     - updateAnswerLimit(int)
     - askQuestion()
     - clearAnswer()
     - toggleDebugInfo()
     - clearErrors()
   ```

2. **lib/features/rag/presentation/providers/rag_provider.dart**
   ```dart
   - Riverpod StateNotifierProvider for RagNotifier
   - Select providers for:
     - search state (query, results, loading, error)
     - answer state (question, answer, loading, error)
     - debug visibility
     - limits configuration
   - Dependency on projects_provider for currentProjectId
   ```

3. **lib/features/rag/presentation/widgets/search_section.dart**
   ```dart
   UI Elements:
   - Card with title "Search Knowledge"
   - TextFormField for search query
     - Multi-line input
     - Placeholder: "Enter search query..."
     - Character count display
   - Row with:
     - "Results:" label
     - NumberPicker or TextFormField for limit (1-50)
     - Search button
       - Shows loading spinner when searching
   - Status text: "Searching..." or error message
   
   Behavior:
   - On search button: validate query not empty
   - Show validation error if empty
   - Disable button while searching
   - Display error if backend fails
   - Trigger performSearch() method
   ```

4. **lib/features/rag/presentation/widgets/search_results_widget.dart**
   ```dart
   UI Elements:
   - Card with title "Search Results"
   - Conditional display: "No results" if empty
   - Ranked list of results:
     - Each result as card:
       - Result rank (#1, #2, etc.)
       - Score badge (colored: 0.9-1.0 green, 0.7-0.9 yellow, <0.7 orange)
       - Result text (truncated with "Read more" expansion)
       - Metadata section (if present):
         - Display key-value pairs
         - Collapse/expand toggle
   - Result count display
   - Execution time display (if available)
   
   Behavior:
   - Tap result to expand full text
   - Collapse other results when opening one
   - Display score with semantic meaning
   - Show metadata in secondary color
   ```

5. **lib/features/rag/presentation/widgets/answer_section.dart**
   ```dart
   UI Elements:
   - Card with title "Ask AI"
   - TextFormField for question
     - Multi-line input
     - Placeholder: "Ask a question about your knowledge..."
     - Character count display
   - Row with:
     - "Retrieved chunks:" label
     - NumberPicker or TextFormField for limit (1-20)
     - Ask button
       - Shows loading spinner when answering
   - Status text: "Generating answer..." or error message
   
   Behavior:
   - On ask button: validate question not empty
   - Show validation error if empty
   - Disable button while answering
   - Display error if backend fails
   - Trigger askQuestion() method
   ```

6. **lib/features/rag/presentation/widgets/answer_display_widget.dart**
   ```dart
   UI Elements:
   - Card with title "AI Answer"
   - Conditional display: "No answer yet" if empty
   - Answer text displayed in:
     - White Card with padding
     - Readable font size
     - Line break preservation
   - Copy answer button
   - Debug info toggle button (if debug info available)
   
   Behavior:
   - Tap copy button to copy to clipboard
   - Show snackbar confirmation
   - Toggle debug section on button press
   - Smooth scroll to debug section if opening
   ```

7. **lib/features/rag/presentation/widgets/debug_section_widget.dart**
   ```dart
   UI Elements:
   - Expandable/collapsible Card with title "Debug Info"
   - Two tabs or sections:
     - "Full Prompt" tab:
       - Display full_prompt text
       - Code-style formatting
       - Copy button
     - "Chat History" tab:
       - Expandable list of chat items
       - Each item shows role and content
       - Message count
       - Copy all button
   - Close button or collapse toggle
   
   Behavior:
   - Only shown if debug data available
   - Copy functionality for each section
   - Scroll overflow handling
   - Optional: format JSON for readability
   ```

8. **lib/features/rag/presentation/pages/ask_page.dart**
   ```dart
   Structure:
   - AppBar with title "Ask AI" and back button
   - SingleChildScrollView with:
     - SafeArea padding
     - Column with:
       - Instruction text
       - SearchSection widget
       - SearchResultsWidget (conditional)
       - SizedBox divider
       - AnswerSection widget
       - AnswerDisplayWidget (conditional)
       - DebugSectionWidget (conditional)
   
   Behavior:
   - Read currentProjectId from provider
   - Search and answer flows independent
   - Scroll to results when available
   - Show loading overlays for long operations
   ```

9. **lib/features/rag/data/repositories/search_repository.dart (expanded)**
   ```dart
   - Methods:
     - search(projectId, text, limit) with error handling
     - Parse SearchResponse correctly
     - Extract SearchResultItem list
   - Optional: cache recent searches
   ```

10. **lib/features/rag/data/repositories/answer_repository.dart (expanded)**
    ```dart
    - Methods:
      - askQuestion(projectId, text, limit) with error handling
      - Parse RagAnswerResponse correctly
      - Extract answer, prompt, and chat history
    - Optional: cache recent questions and answers
    ```

### SRS References
- Section 6.7: Semantic Search Requirements
- Section 6.8: RAG Answer Generation Requirements
- Section 7.4: AskPage Requirements
- Section 9.5: Search API
- Section 9.6: Answer API
- Section 12: UI and UX Requirements

### 🔧 Technical Notes

1. **Search Flow:**
   - Client-side validation (non-empty query)
   - Endpoint: POST /api/v1/nlp/index/search/{project_id}
   - Display results ranked by score
   - Parse metadata if provided

2. **Answer Generation:**
   - Client-side validation (non-empty question)
   - Endpoint: POST /api/v1/nlp/index/answer/{project_id}
   - Display full answer text clearly
   - Show debug info in collapsible section

3. **Score Visualization:**
   - Color-code by confidence: 0.9+ green, 0.7-0.9 yellow, <0.7 orange
   - Display as percentage (0-100)
   - Show score to 2 decimal places

4. **Metadata Display:**
   - Handle dynamic metadata fields
   - Display as key-value pairs
   - Make expandable for long values

5. **Debug Section:**
   - Optional but recommended for development
   - Show full prompt for transparency
   - Display chat history if returned
   - Toggle visibility without full page reload

6. **UX Flow:**
   - Search and answer are independent operations
   - User can search, see results, then ask a question
   - Both share the limit configuration

7. **Error Handling:**
   - Show validation errors for empty input
   - Display backend errors clearly
   - Allow retry without clearing text

### ✅ Acceptance Criteria

- [ ] AskPage renders without errors
- [ ] Search section displays with query input
- [ ] Search limit input validates numeric range
- [ ] Search button validates non-empty query
- [ ] Search results display in ranked order
- [ ] Result scores display with colors
- [ ] Result metadata displays correctly
- [ ] Answer section displays with question input
- [ ] Answer limit input validates numeric range
- [ ] Ask button validates non-empty question
- [ ] Answer text displays in readable format
- [ ] Debug info section toggles on/off
- [ ] Full prompt displays in debug section
- [ ] Chat history displays in debug section
- [ ] Copy buttons work for answer and debug sections
- [ ] Both flows work independently
- [ ] Error messages display clearly
- [ ] Loading states show spinners
- [ ] Buttons disabled while loading
- [ ] Search results expandable/collapsible

### 🔗 Commit Message

```
feat(rag): implement semantic search and RAG question answering
- Create RagNotifier with state management for search and answer flows
- Implement SearchSection with query input and limit configuration
- Implement AnswerSection with question input and limit configuration
- Add SearchResultsWidget with ranked results and score visualization
- Add AnswerDisplayWidget with answer text and copy functionality
- Add DebugSectionWidget showing full prompt and chat history
- Support collapsible debug info for development
- Add color-coded score display (confidence visualization)
- Implement metadata display for search results
- Add expandable result text display
- Implement input validation for queries and questions
- Add error handling and status feedback
- Support independent search and answer workflows
```

---

## Phase 6: TranslatePage (Translation Management)

### 🎯 Objective
Implement file translation workflow: job creation with language selection, status tracking with polling support.

### 📁 Files to Create

```
lib/features/translation/
  data/
    repositories/
      translation_repository.dart (expanded)
  presentation/
    pages/
      translate_page.dart
    providers/
      translation_notifier.dart
      translation_provider.dart
    widgets/
      job_creation_section.dart
      job_status_section.dart
      language_selector_widget.dart
      translation_status_card.dart
```

### 📄 Detailed Files

1. **lib/features/translation/presentation/providers/translation_notifier.dart**
   ```dart
   - StateNotifier managing:
     - fileId: String?
     - sourceLang: String (default: "en")
     - targetLang: String (default: "ar")
     - isCreatingJob: bool
     - createdJobId: String?
     - creationError: String?
     - jobStatusId: String? (for manual checking)
     - jobStatus: String?
     - jobStatusData: TranslationJobStatusResponse?
     - isCheckingStatus: bool
     - statusError: String?
     - autoRefreshEnabled: bool
     - refreshInterval: Duration (default: 5 seconds)
     - lastRefreshTime: DateTime?
     - currentProjectId: int
   
   - Methods:
     - updateFileId(String)
     - updateSourceLang(String)
     - updateTargetLang(String)
     - createTranslationJob()
     - updateJobStatusId(String)
     - checkJobStatus()
     - toggleAutoRefresh()
     - updateRefreshInterval(Duration)
     - clearJob()
     - clearError()
   ```

2. **lib/features/translation/presentation/providers/translation_provider.dart**
   ```dart
   - Riverpod StateNotifierProvider for TranslationNotifier
   - Select providers for:
     - file_id input
     - source/target languages
     - created job_id
     - job status
     - status details
     - creation loading/error
     - status loading/error
     - auto-refresh settings
   - Dependency on projects_provider for currentProjectId
   - Timer for auto-refresh polling
   ```

3. **lib/features/translation/presentation/widgets/language_selector_widget.dart**
   ```dart
   UI Elements:
   - Row with two columns (source and target):
     - Column 1: "From (Source Language)"
       - Dropdown or ListTile
       - Selected language display
     - Spacer/Icon (swap button optional)
     - Column 2: "To (Target Language)"
       - Dropdown or ListTile
       - Selected language display
   - Language list:
     - English (en)
     - Arabic (ar)
     - Spanish (es)
     - French (fr)
     - German (de)
     - Chinese (zh)
     - [expandable for more]
   
   Behavior:
   - Show both language dropdowns
   - Tap to open selection menu
   - Validate selected languages
   - Optional: prevent same source/target
   - Trigger updateSourceLang/updateTargetLang
   ```

4. **lib/features/translation/presentation/widgets/job_creation_section.dart**
   ```dart
   UI Elements:
   - Card with title "Create Translation Job"
   - TextFormField for file_id input
     - Placeholder: "Enter file ID to translate"
     - Validation text if invalid
   - LanguageSelectorWidget (embedded)
   - Create Job button
     - Shows loading spinner when creating
     - Disabled if file_id empty
   - Status text: "Creating job..." or error message
   - Success message with created job_id
   
   Behavior:
   - On create button: validate file_id not empty
   - Show validation error if empty
   - Disable button while creating
   - Display error if backend fails
   - Show created job_id on success
   - Trigger createTranslationJob() method
   ```

5. **lib/features/translation/presentation/widgets/translation_status_card.dart**
   ```dart
   UI Elements:
   - Card showing job status with:
     - Job ID display
     - Large status badge (pending/processing/completed/failed)
       - Color-coded: yellow (pending/processing), green (completed), red (failed)
     - Status details row:
       - Created time (if available)
       - Progress percentage (if available)
     - Result file ID (if completed)
       - Copy button
     - Error message (if failed)
       - Red text display
     - Last refreshed timestamp
   
   Behavior:
   - Update dynamically when status changes
   - Color change on status update
   - Show/hide fields based on status
   - Auto-update when polling
   ```

6. **lib/features/translation/presentation/widgets/job_status_section.dart**
   ```dart
   UI Elements:
   - Card with title "Check Job Status"
   - TextFormField for job_id input (if created job_id not set)
     - Placeholder: "Enter job ID"
     - Validation text if invalid
   - Row with:
     - Check Status button
       - Shows loading spinner when checking
       - Disabled if job_id empty
     - Auto-refresh toggle (CheckboxListTile)
       - Label: "Auto-refresh (every X seconds)"
   - Optional: refresh interval selector (1-30 seconds)
   - Status text: "Checking status..." or error message
   - TranslationStatusCard displaying current status
   - Manually refresh button
   
   Behavior:
   - On check button: validate job_id not empty
   - Show validation error if empty
   - Disable button while checking
   - Display error if backend fails
   - Trigger checkJobStatus() method
   - Auto-refresh polls every N seconds (if enabled)
   - Disable auto-refresh when job completes
   - Display last refresh time
   ```

7. **lib/features/translation/presentation/pages/translate_page.dart**
   ```dart
   Structure:
   - AppBar with title "File Translation" and back button
   - SingleChildScrollView with:
     - SafeArea padding
     - Column with:
       - Instruction text
       - JobCreationSection widget
       - SizedBox divider
       - JobStatusSection widget
       - TranslationStatusCard (conditional)
   
   Behavior:
   - Read currentProjectId from provider
   - Support both job creation and status checking
   - Show loading overlays for long operations
   - Preserve created job_id between sections
   ```

8. **lib/features/translation/data/repositories/translation_repository.dart (expanded)**
   ```dart
   - Methods:
     - createJob(projectId, fileId, sourceLang, targetLang)
     - getJobStatus(jobId)
     - Both with error handling and response parsing
   - Optional: store job history
   ```

### SRS References
- Section 6.9: File Translation Requirements
- Section 6.10: Translation Status Tracking Requirements
- Section 7.5: TranslatePage Requirements
- Section 9.7: Translation Create API
- Section 9.8: Translation Status API
- Section 12: UI and UX Requirements

### 🔧 Technical Notes

1. **Job Creation Flow:**
   - Endpoint: POST /translate/file
   - Send: project_id, file_id, source_lang, target_lang
   - Receive: job_id, status, asset_id
   - Store job_id for status tracking

2. **Job Status Tracking:**
   - Endpoint: GET /translate/status/{job_id}
   - Poll manually or automatically
   - Status values: pending, processing, completed, failed

3. **Auto-Refresh Polling:**
   - Use Timer for periodic requests
   - Default: 5-second intervals
   - Configurable: 1-30 seconds
   - Stop when job completes or user disables

4. **Language Support:**
   - Start with common languages: en, ar, es, fr, de, zh
   - Extensible for future additions
   - Store in constants or separate file

5. **Status Visualization:**
   - Pending/Processing: yellow
   - Completed: green
   - Failed: red
   - Include progress percentage if available

6. **Error Handling:**
   - Validate file_id not empty
   - Validate job_id format
   - Display backend error messages
   - Handle polling errors gracefully

7. **UX Considerations:**
   - Create and status checking are sequential workflows
   - Allow manual refresh between auto-refresh cycles
   - Show last refresh timestamp
   - Disable auto-refresh on completion or error

### ✅ Acceptance Criteria

- [ ] TranslatePage renders without errors
- [ ] FileId input displays and validates
- [ ] LanguageSelector displays both dropdowns
- [ ] Language options include at least 6 languages
- [ ] Create Job button validates file_id
- [ ] Create button shows loading spinner
- [ ] Created job_id displays on success
- [ ] Job status section displays
- [ ] Check Status button validates job_id
- [ ] Status check shows loading spinner
- [ ] TranslationStatusCard updates on status change
- [ ] Status colors match specifications (yellow/green/red)
- [ ] Auto-refresh toggle works
- [ ] Auto-refresh polls every N seconds correctly
- [ ] Manual refresh button works
- [ ] Last refresh timestamp displays
- [ ] Error messages display clearly
- [ ] Buttons disabled while loading
- [ ] Result file ID displays when completed
- [ ] Error message displays on failed status
- [ ] Auto-refresh stops on completion

### 🔗 Commit Message

```
feat(translation): implement file translation with job tracking
- Create TranslationNotifier with state management
- Implement JobCreationSection with file_id and language selection
- Implement LanguageSelectorWidget supporting 6+ languages
- Implement JobStatusSection with manual and auto-refresh
- Add TranslationStatusCard with color-coded status display
- Add Timer-based auto-refresh polling (1-30 second intervals)
- Show progress percentage if available
- Display result file ID on completion
- Display error messages on failure
- Add last refresh timestamp display
- Support both sequential and manual job status checking
- Implement language dropdown with common languages
```

---

## 📊 Summary of Phases

| Phase | Focus | Main Deliverable | Depends On |
|-------|-------|------------------|-----------|
| 1 | Infrastructure | Folder structure, core configuration, routing | None |
| 2 | API Layer | Models, repositories, API service | Phase 1 |
| 3 | First Screen | ProjectsPage with recent projects | Phases 1-2 |
| 4 | File Management | Complete upload/process/index flow | Phases 1-3 |
| 5 | RAG Features | Search and question-answering | Phases 1-3 |
| 6 | Translation | Job creation and status tracking | Phases 1-3 |

---

## 🔄 Inter-Phase Workflow

### After Each Phase:
1. **Review Summary** — List all files created/modified
2. **Await Approval** — User reviews and approves
3. **Display Commit Message** — Standard Conventional Commits format
4. **Execute Commit** — (When user says "commit" or "وافقت")
5. **Start Next Phase** — Only after approval

### State Management Flow (All Phases)
```
Riverpod Providers
    ↓
StateNotifier (business logic)
    ↓
Repositories (API calls)
    ↓
ApiService (HTTP requests)
    ↓
Backend
```

### No Phase Can Skip
All 6 phases are sequential. Phase N+1 begins only after Phase N is complete and approved.

---

## 📝 Notes for Implementation

1. **Error Handling:** Every API call must handle errors gracefully
2. **Loading States:** Every async operation must show loading feedback
3. **Validation:** Client-side validation on all user inputs
4. **Responsive Design:** All screens tested on mobile (375px width minimum)
5. **Accessibility:** Button sizes ≥48px, clear contrast ratios
6. **Performance:** No blocking operations on main thread
7. **Navigation:** Use GoRouter consistently throughout
8. **Testing:** Optional but recommended for Phase 2+ API layer
9. **Documentation:** Inline comments for complex logic
10. **Git:** Commit after each phase with provided message format

---

**Plan Created:** April 30, 2026
**Status:** Phase 2 completed, ready for Phase 3 implementation
**Total Estimated Files:** ~50+ implementation files across 6 phases
