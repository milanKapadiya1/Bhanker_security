# Bhanker Security ERP: Workforce Management Solution

> **A production-grade, offline-first mobile application designed to digitize payroll and workforce management for security agencies.**

---

## 🚀 Project Overview

**The Problem:**
Security agencies often rely on manual paper records for attendance and payroll, leading to calculation errors, data loss, and administrative bottlenecks.

**The Solution:**
I engineered **Bhanker Security ERP**, a robust mobile solution that automates complex salary logic and digitizes employee records. Built with an **Offline-First architecture**, the app ensures 100% functionality even in remote locations with zero network connectivity.

---

## 🏗️ Technical Architecture & Key Challenges

### 1. Offline-First Engineering (Local Persistence)
* **Challenge:** The app needed to function reliably in remote field locations where internet access is unstable or non-existent.
* **Solution:** Implemented a robust local database architecture. All employee data, attendance logs, and salary history are stored locally, ensuring zero latency and full data availability without a server connection.

### 2. Automated Payroll Engine
* **Challenge:** Salary calculations involve complex variables including varying month lengths (28-31 days), role-based "Point Salaries," welfare deductions, and uniform charges.
* **Solution:** Developed a custom Dart utility class to encapsulate this business logic. The engine automatically validates input, processes deductions, and computes net pay with high precision, eliminating manual errors.

### 3. PDF Report Generation
* **Challenge:** Transforming raw data into professional, printable salary slips on a mobile device.
* **Solution:** Integrated the `pdf` package to programmatically render invoices. The system formats text, tables, and images into a standardized layout, allowing managers to export and share reports via WhatsApp or Email instantly.

---

## 📱 Key Modules

### 💰 Smart Payroll System
* **Dynamic Calculation:** Automatically adjusts for month duration and attendance metrics.
* **Deduction Management:** Granular control over WC (Welfare Fund), Advances, and Uniform charges.
* **Session History:** Immutable logs of past calculations for audit trails.

### 👥 Workforce Management
* **Digital Personnel Files:** Centralized storage for Name, Aadhar ID, Contact Info, and biometric photos.
* **Gallery Integration:** Optimized image picking and compression for storing employee profile photos locally.
* **Location Tracking:** Role-based assignment system to track employee deployment across different sites ("Points").

---

## 🛠️ Tech Stack

| Domain | Technology |
| :--- | :--- |
| **Framework** | Flutter (Dart) |
| **Architecture** | MVC / Service-Locator Pattern |
| **Local Database** |  SharedPrefs |
| **UI System** | Material Design 3, `flutter_screenutil` (Responsive) |
| **Utilities** | `pdf` (Reporting), `image_picker` (Media) |

---

<p align="center">
  <img src="https://github.com/user-attachments/assets/e6eaa942-8fe0-4f27-8b64-718be1360068" width="240" alt="one" />
  <img src="https://github.com/user-attachments/assets/4e49db45-0971-4d45-ba10-13509cdcd351" width="240" alt="two" />
  <img src="https://github.com/user-attachments/assets/82ecd9e9-c0f2-4cad-a983-87bb7b6bee81" width="240" alt="ten" />
  
  <img src="https://github.com/user-attachments/assets/e6d61d85-97eb-4954-a5be-e027fef626de" width="240" alt="four" />
  <img src="https://github.com/user-attachments/assets/0fb689fa-5300-4d59-8b37-1fe5f71f2a4c" width="240" alt="five" />
  <img src="https://github.com/user-attachments/assets/ae7a269e-162d-42d1-b5f9-5c60137fe898" width="240" alt="six" />
  <img src="https://github.com/user-attachments/assets/e3581d6a-15c6-4793-bc3b-af86b863460f" width="240" alt="seven" />
  <img src="https://github.com/user-attachments/assets/3e066974-e21c-4c87-b517-5cb7fb014adf" width="240" alt="eight" />
  <img src="https://github.com/user-attachments/assets/bfe4a204-f173-49ac-bf16-0e10d8dc38c5" width="240" alt="nine" />
</p>

