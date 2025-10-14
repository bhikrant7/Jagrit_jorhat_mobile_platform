
# 🏛️ Jagrit Jorhat Mobile Application

[![Flutter](https://img.shields.io/badge/Flutter-v3.x-blue?logo=flutter)](https://flutter.dev/)
[![PHP](https://img.shields.io/badge/PHP-8.x-777BB4?logo=php)](https://www.php.net/)
[![MySQL](https://img.shields.io/badge/MySQL-8.x-orange?logo=mysql)](https://www.mysql.com/)
[![License](https://img.shields.io/badge/license-MIT-green)](#)

A **cross-platform mobile application** developed for the **Jagrit Jorhat** e-Governance initiative of the **District Commissioner’s Office, Jorhat (Assam, India)**.
It extends the official [Jagrit Jorhat Portal](https://jagritjorhat.assam.gov.in) to mobile devices, allowing citizens to submit and track grievances directly from their smartphones.

---

## 📖 Overview

The **Jagrit Jorhat Mobile App** provides:

* 📄 Digital submission of grievances and documents
* 🔒 Secure login and authentication
* 📊 Real-time case tracking (Pending / Forwarded / Resolved)
* 📱 User-friendly Flutter interface

The app connects to an **independent PHP backend server**, which **shares the database** with the official web portal.

---

## ⚙️ Architecture

| Layer                 | Technology     | Description                                            |
| --------------------- | -------------- | ------------------------------------------------------ |
| **Client (Frontend)** | Flutter (Dart) | Mobile app UI and logic                                |
| **Server (Backend)**  | Core PHP       | REST APIs for authentication, submission, and tracking |
| **Database**          | MySQL          | Shared with the official Jagrit Jorhat website         |

All communication between Flutter and PHP happens through **secure REST endpoints** over **HTTPS**.

---

## 🧰 Tech Stack

| Category                 | Technology                 | Purpose                                                               |
| ------------------------ | -------------------------- | --------------------------------------------------------------------- |
| Cross-Platform Framework | **Flutter (Dart)**         | Build for Android & iOS                                               |
| State Management         | **Provider**               | Manage global state                                                   |
| Local Storage            | **flutter_secure_storage** | Encrypted local session storage                                       |
| API Communication        | **http / dio**             | REST requests to PHP backend                                          |
| Backend                  | **PHP 8.x**                | API server handling user operations                                   |
| Database                 | **MySQL 8.x**              | Shared with [Jagrit Jorhat Portal](https://jagritjorhat.assam.gov.in) |

---

## 📁 Project Structure

```
Jagrit-Jorhat-App/
│
├── assets/
│
├── BACKEND/
│   └── flutter_server/
│       ├── uploads/                     # File uploads from users
│       ├── vendor/                      # Composer dependencies
│       ├── .env                         # Environment variables (DB config)
│       ├── composer.json
│       ├── db.php                       # Database connection
│       ├── login.php                    # User login
│       ├── register.php                 # User registration
│       ├── send_otp.php / verify_otp.php# OTP verification
│       ├── get_user.php / update_user.php
│       ├── form.php / fetchform.php     # Application form handling
│       ├── get_categories.php           # Fetch case categories
│       ├── track_status.php             # Track case progress
│       ├── reset_password.php           # Password reset
│       ├── phone_email_check.php        # Validate contact info
│       └── test_db.php                  # DB connection test
│
├── lib/
│   ├── api/
│   ├── models/
│   ├── screens/
│   ├── utils/
│   ├── widgets/
│   └── main.dart
│
├── ios/
├── linux/
├── build/
└── README.md
```

---

## ⚡ Setup & Installation

### 1️⃣ Clone the Repository

```bash
git clone https://github.com/<your-username>/Jagrit-Jorhat-App.git
cd Jagrit-Jorhat-App
```

---

### 2️⃣ Configure the PHP Backend

#### 🔧 Requirements

* PHP 8.x or higher
* MySQL 8.x
* Composer

#### 🗂️ Steps

1. Navigate to backend folder:

   ```bash
   cd BACKEND/flutter_server
   ```

2. Install dependencies:

   ```bash
   composer install
   ```

3. Create a `.env` file:

   ```env
   DB_HOST=localhost
   DB_USER=root
   DB_PASS=yourpassword
   DB_NAME=jagritjorhat_db
   BASE_URL=http://localhost/flutter_server/
   ```

   > ⚠️ The database credentials should match the same DB used by the [Jagrit Jorhat official site](https://jagritjorhat.assam.gov.in).

4. Start local PHP server:

   ```bash
   php -S localhost:8000
   ```

   Your backend API will now be available at `http://localhost:8000/`.

---

### 3️⃣ Configure the Flutter App

#### 📱 Requirements

* Flutter SDK 3.x
* Android Studio or VS Code
* Emulator or physical device

#### 🛠️ Setup

1. Navigate to the Flutter project root:

   ```bash
   cd ../../
   ```
2. Get dependencies:

   ```bash
   flutter pub get
   ```
3. Update the API base URL in your app (usually in `lib/api/` or `lib/utils/`):

   ```dart
   const String baseUrl = "http://localhost:8000/";
   ```
4. Run the app:

   ```bash
   flutter run
   ```

---

## 🧪 Testing

✅ **Unit Tests** – Widgets, state providers
✅ **Integration Tests** – Flutter ↔ PHP API
✅ **UI/UX Testing** – Device responsiveness
✅ **Security Tests** – HTTPS, token persistence

---

## 🌐 Official Website

> 🔗 [Jagrit Jorhat Portal (Official Site)](https://jagritjorhat.assam.gov.in)

The app backend shares the same **MySQL database** as the official portal, ensuring data consistency between mobile and web platforms.

---

## 👨‍💻 Author

**Bhikrant Borah**
B.Tech (CSE), Jorhat Engineering College
🧑‍💻 Internship: *National Informatics Centre (NIC), Jorhat District Centre*
**Guide:** Arunjyoti Das (District Informatics Officer, NIC Jorhat)

---

## 🪪 License

This project was developed for educational and governmental use under NIC Jorhat.
© 2025 Bhikrant Borah. All Rights Reserved.

---
