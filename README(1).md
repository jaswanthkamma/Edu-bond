# Edu-Bond

Edu-Bond is an education-focused mobile & web application designed to connect students, tutors, and educational content in a seamless platform. The project consists of a Flutter frontend (mobile), a Node.js backend API, and a MySQL database for persistent storage.

---

## 📋 Technologies Used

- **Frontend**: Flutter (Dart) — for cross-platform (iOS & Android) mobile application  
- **Backend**: Node.js — RESTful API services  
- **Database**: MySQL — relational database for storing users, content, sessions, etc.

---

## 🎯 Features (Expected / Core)

Here are typical features you might find in this kind of project (these could be implemented or planned):

- User authentication (student / tutor)  
- Profiles for students and tutors  
- Posting & browsing educational content (lessons, resources)  
- Scheduling / booking sessions  
- In-app messaging or notifications  
- Admin dashboards or content moderation  

---

## 🚀 Prerequisites

Before you start, make sure you have:

- Flutter SDK installed (with setup for iOS/Android emulators or devices)  
- Node.js (version 14+ recommended)  
- npm (comes with Node.js)  
- MySQL server installed & running  
- Git to clone repository  

---

## 🛠 Installation & Setup

Here’s how to get the project running locally:

### 1. Clone the Repository

```bash
git clone https://github.com/naresh-2026/edu-bond.git
cd edu-bond
```

### 2. Setup Backend

```bash
cd backend_project
```

- Install dependencies:

  ```bash
  npm install
  ```

- Configure environment variables:  
  Create a `.env` file (or whatever config mechanism you have) with items like:

  ```
  DB_HOST=localhost
  DB_USER=your_mysql_username
  DB_PASSWORD=your_mysql_password
  DB_NAME=edu_bond_db
  JWT_SECRET=your_secret_key
  PORT=3000
  ```

- Initialize database (run migrations / schema SQL) if available.  

- Start backend server:

  ```bash
  npm start
  # or npm run dev (if using nodemon or similar)
  ```

### 3. Setup Frontend (Flutter)

```bash
cd ../flutter_project
```

- Install Flutter dependencies:

  ```bash
  flutter pub get
  ```

- Configure any required config (e.g. API base URL, keys, etc.).  

- Run the app:

  ```bash
  flutter run
  ```

  (You can run in emulator or physical device.)

---

## 🔧 Configuration & Environment

- **Database**: MySQL must be running and accessible with the credentials set in the backend config.  
- **Backend**: Ensure CORS is handled (if needed) so Flutter app can communicate without issues.  
- **API Base URL**: Set correctly in Flutter app so requests are pointed to the running backend.  
- **Ports**: Default ports must be free (backend, etc.).  

---

## ✅ Usage

After setup:

1. Sign up / login as a user (student or tutor).  
2. Create or update profile.  
3. Browse or post educational content.  
4. Book sessions, send/receive messages (if implemented).  
5. Admin or moderation flows (if you have them).

---

## ⚠️ Limitations & Future Enhancements

- Offline support may be limited or absent.  
- Real‑time features (chat, live video) may need further implementation.  
- UI/UX polishing, error handling, input validation, security enhancements (e.g. rate limiting, sanitization) could be improved.   

---

