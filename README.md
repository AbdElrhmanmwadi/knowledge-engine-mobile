# 📱 Knowledge Engine Mobile

A powerful Flutter mobile client for the RAG (Retrieval-Augmented Generation) Knowledge Engine backend. This application enables seamless file management, semantic search, AI-powered question answering, and document translation workflows.

## 🎯 Project Overview

Knowledge Engine Mobile is a comprehensive solution for interacting with a RAG knowledge system. Users can upload documents, process them into semantic chunks, push data to a vector database, perform intelligent searches, and leverage AI to answer questions based on their knowledge base.

**Status:** 🚀 In Active Development (Phase 1: Foundation)

---

## ✨ Key Features

### 📂 **File Management**
- Upload multiple file formats (.txt, .pdf, .docx, .csv, .html, .xlsx)
- Real-time upload progress tracking
- File chunking with customizable parameters
- Vector database indexing with optional full reindex

### 🔍 **Semantic Search**
- Full-text semantic search across indexed documents
- Retrieve relevant chunks with confidence scores
- Configurable result limits
- Fast and accurate information retrieval

### 🤖 **AI Question Answering**
- Ask natural language questions about your knowledge base
- RAG-powered responses with contextual accuracy
- Retrieved chunk tracking
- Full prompt visibility for transparency

### 🌐 **Document Translation**
- Translate indexed documents between multiple languages
- Async job-based translation workflow
- Progress tracking for long-running translations
- Result file generation and download

### 💾 **Local Project Management**
- Save and access recent projects (last 10)
- Quick project switching
- Persistent local storage via SharedPreferences

---

## 🛠️ Technology Stack

| Component | Package | Version |
|-----------|---------|---------|
| **Framework** | Flutter & Dart | 3.10.4+ |
| **HTTP Client** | Dio | ^5.3.0 |
| **State Management** | Flutter Riverpod | ^3.3.1 |
| **Navigation** | GoRouter | ^17.2.2 |
| **Local Storage** | SharedPreferences | ^2.2.0 |
| **Internationalization** | Intl | ^0.20.2 |
| **Typography** | Google Fonts | ^8.1.0 |
| **UI Icons** | Cupertino Icons | ^1.0.8 |

---

## 📋 Architecture

### **Project Structure**
```
lib/
├── main.dart                    # Entry point
├── app.dart                     # App configuration & routing
├── core/
│   ├── config/
│   │   ├── app_config.dart      # Environment & base URL config
│   │   └── constants.dart       # API endpoints & constants
│   ├── network/
│   │   ├── dio_client.dart      # HTTP client setup
│   │   ├── api_exception.dart   # Error handling
│   │   └── api_service.dart     # Centralized API service
│   ├── models/                  # Data models for API responses
│   ├── theme/
│   │   └── app_theme.dart       # Material 3 theme
│   └── widgets/                 # Reusable UI components
├── features/
│   ├── projects/                # Project selection & management
│   ├── dashboard/               # Main dashboard
│   ├── files/                   # File upload & management
│   ├── rag/                     # Search & question answering
│   └── translation/             # Document translation
```

### **Design Patterns**
- **Repository Pattern**: Clean data access layer
- **State Management**: Riverpod StateNotifier for reactive UI
- **Separation of Concerns**: Features organized by domain
- **Error Handling**: Centralized exception management

---

## 🚀 Getting Started

### **Prerequisites**
- Flutter 3.10.4 or higher
- Dart 3.10.4 or higher
- Android Studio / Xcode (for mobile deployment)
- Backend RAG Knowledge Engine running

### **Installation**

1. **Clone the repository:**
   ```bash
   git clone https://github.com/AbdElrhmanmwadi/knowledge-engine-mobile.git
   cd knowledge-engine-mobile/knowledge_engine_mobile
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure backend URL:**
   Edit `lib/core/config/app_config.dart` and update the base URL:
   ```dart
   // For Android emulator (default)
   const String baseUrl = 'http://10.0.2.2:8000';
   
   // For physical device/iOS simulator
   const String baseUrl = 'http://YOUR_SERVER_IP:8000';
   ```

4. **Run the app:**
   ```bash
   flutter run
   ```

---

## 📱 Usage Guide

### **1. Start with a Project**
- Launch the app and enter your project ID (numeric)
- Or select from recent projects
- The app stores your last 10 projects for quick access

### **2. Upload & Process Files**
- Navigate to **Files** section
- Select a document (.txt, .pdf, .docx, etc.)
- Track upload progress in real-time
- Configure chunking parameters (chunk_size, overlap_size)
- Process the file to create semantic chunks

### **3. Push to Vector Database**
- After processing, push indexed data to the vector database
- Optionally perform a full reindex
- Monitor indexing status

### **4. Search Your Knowledge Base**
- Go to **Search** section
- Enter your search query
- View semantically relevant chunks with scores
- Adjust result limit as needed

### **5. Ask Questions**
- Navigate to **Ask** section
- Type your question in natural language
- Receive AI-generated answers with context
- View retrieved chunks and full prompts for transparency

### **6. Translate Documents**
- Go to **Translation** section
- Select a file and target language
- Create a translation job
- Monitor job status
- Download translated results when ready

---

## 🔧 Configuration

### **Backend Connection**
- **Android Emulator**: `http://10.0.2.2:8000` (default)
- **Physical Device**: Update `app_config.dart` with your server IP

### **API Endpoints**
All endpoints are defined in `lib/core/config/constants.dart`:
- `/upload` - File upload
- `/process` - File processing
- `/push_to_index` - Vector database push
- `/search` - Semantic search
- `/ask` - RAG question answering
- `/translate/create` - Translation job creation
- `/translate/status` - Translation job status

### **Supported File Types**
- `.txt` - Plain text
- `.pdf` - PDF documents
- `.docx` - Word documents
- `.csv` - CSV files
- `.html` - HTML files
- `.xlsx` - Excel spreadsheets

### **Processing Parameters**
- **chunk_size**: Size of semantic chunks (default: 512)
- **overlap_size**: Overlap between chunks (default: 50)
- **do_reset**: Full reindex option (default: false)

---

## 📊 Development Phases

### **Phase 1** ✅ Foundation & Core Infrastructure (Current)
- Project structure and navigation
- HTTP client setup with Dio
- Theme configuration
- Core reusable widgets

### **Phase 2** 📋 Core Models
- API response data models
- JSON serialization/deserialization
- Type-safe data handling

### **Phase 3** 📋 API Service & Network Layer
- Centralized API service
- All endpoint implementations
- Response validation
- Error handling

### **Phase 4** 📋 Data Repositories
- Repository pattern implementation
- Feature-specific data access
- Local state management

### **Phase 5** 📋 ProjectsPage
- Project selection UI
- Recent projects management
- Input validation
- Navigation

### **Phase 6** 📋 Feature UI Screens
- Files management page
- RAG search page
- Question answering page
- Translation page
- Dashboard

See `plan.md` for detailed development roadmap.

---

## 🔌 API Integration

### **File Upload**
```dart
POST /upload
- multipart/form-data
- File data with progress tracking
- Returns: file_id
```

### **Process File**
```dart
POST /process
- Parameters: chunk_size, overlap_size, do_reset
- Returns: inserted_chunks, processed_files
```

### **Push to Index**
```dart
POST /push_to_index
- Parameters: do_reset (optional)
- Returns: indexed_count, collection_info
```

### **Search**
```dart
POST /search
- Query: search text
- Parameters: limit (default: 5)
- Returns: List of results with scores
```

### **Ask Question**
```dart
POST /ask
- Query: question text
- Parameters: limit (default: 5)
- Returns: answer, retrieved_chunks, full_prompt
```

### **Create Translation Job**
```dart
POST /translate/create
- Parameters: file_id, source_lang, target_lang
- Returns: job_id, status
```

### **Check Translation Status**
```dart
GET /translate/status/{job_id}
- Returns: job details, progress, result_file_id (if complete)
```

---

## 🧪 Testing

### **Run Tests**
```bash
flutter test
```

### **Build Release**
```bash
# Android
flutter build apk

# iOS
flutter build ios
```

---

## 🤝 Contributing

We welcome contributions! Here's how to help:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### **Development Guidelines**
- Follow Flutter best practices
- Use meaningful variable/function names
- Add comments for complex logic
- Test your changes thoroughly
- Keep commits atomic and descriptive

---

## 📝 Project Status

**Current Phase**: Phase 1 - Foundation & Core Infrastructure

**Last Updated**: 2026-05-07

**Development Roadmap**: See `plan.md` for detailed phases and acceptance criteria

---

## 📄 License

This project is part of the RAG Knowledge Engine system. Please refer to the backend repository for licensing details.

---

## 👤 Author

**Developed by**: AbdElrhmanmwadi

**Repository**: [knowledge-engine-mobile](https://github.com/AbdElrhmanmwadi/knowledge-engine-mobile)

---

## 🆘 Support & Troubleshooting

### **Common Issues**

**Issue**: App cannot connect to backend
- **Solution**: Verify backend is running and update `app_config.dart` with correct URL

**Issue**: File upload fails
- **Solution**: Check file size and format are supported; ensure network connectivity

**Issue**: Flutter dependencies error
- **Solution**: Run `flutter clean && flutter pub get`

### **Debug Mode**
Enable verbose logging by setting debug mode in `app_config.dart`:
```dart
const bool debugMode = true;
```

### **Need Help?**
- Check the `plan.md` file for detailed specifications
- Review the code comments and documentation
- Consult Flutter/Dart official documentation

---

## 🎯 Roadmap

- [ ] Complete API Service implementation
- [ ] Implement data models and repositories
- [ ] Build ProjectsPage UI
- [ ] Implement FilesPage with upload workflow
- [ ] Create Search/Ask pages with RAG functionality
- [ ] Add Translation management
- [ ] Implement Dashboard
- [ ] Add unit and widget tests
- [ ] Optimize performance
- [ ] Release beta version

---

**Happy coding! 🚀**