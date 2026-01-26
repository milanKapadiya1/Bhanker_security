# Bhanker Security Calculator

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![Android](https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white)

**Bhanker Security Calculator** is a robust mobile application designed to streamline payroll processing and employee management for security agencies. It simplifies complex salary calculations, manages employee records, and generates detailed reports, ensuring accuracy and efficiency in daily operations.

---

## 🚀 Features

### 📊 Smart Salary Calculator
- **Precise Calculations**: Automatically checks total days in a month and calculates salary based on attendance.
- **Deduction Management**: Easily handle deductions for WC (Welfare Fund), Uniform charges, and Advances.
- **Point Salary System**: Track distinct "Point Salary" values for specific employee roles or locations.
- **Session History**: Keeps track of recent calculations for quick review.

### 👥 Comprehensive Employee Management
- **Digital Records**: Store detailed profiles including Name, Photo, Phone Number, Aadhar Card, and Address.
- **Photo Integration**: Add employee photos directly from the gallery for easy identification.
- **Location Tracking**: Assign and view employee "Points" (Work Locations).
- **Search & Filter**: Quickly find employees by name or ID.

### 📝 Reporting & History
- **Calculation History**: View a log of all salary calculations.
- **PDF Reports**: Generate and export salary slips or summary reports (feature integrated via `pdf` package).

### 🎨 Modern & Responsive UI
- **User-Friendly Interface**: Clean, intuitive design using a professional color palette (Indigo Blue & Mint Green).
- **Responsive Layout**: Optimized for various screen sizes using `flutter_screenutil`.

---

## 🛠️ Built With

*   **[Flutter](https://flutter.dev/)** - The cross-platform framework used.
*   **[Dart](https://dart.dev/)** - The programming language.
*   **[Provider](https://pub.dev/packages/provider)** - For state management.
*   **[flutter_screenutil](https://pub.dev/packages/flutter_screenutil)** - For responsive sizing.
*   **[pdf](https://pub.dev/packages/pdf)** - For generating PDF documents.
*   **[image_picker](https://pub.dev/packages/image_picker)** - For selecting employee photos.
*   **[shared_preferences](https://pub.dev/packages/shared_preferences)** - For local data persistence.

---

## 🏁 Getting Started

Follow these steps to set up the project locally.

### Prerequisites

*   Flutter SDK (Version 3.6.1 or higher)
*   Dart SDK
*   Android Studio / VS Code

### Installation

1.  **Clone the repository**
    ```sh
    git clone https://github.com/yourusername/bhanker-security-cal.git
    ```

2.  **Navigate to the project directory**
    ```sh
    cd bhanker_cal
    ```

3.  **Install dependencies**
    ```sh
    flutter pub get
    ```

4.  **Run the application**
    ```sh
    flutter run
    ```

---

## 📱 Usage

1.  **Add Employees**: Go to the "Employees" screen via the drawer to add new staff members with their details and photos.
2.  **Calculate Salary**: On the home screen, select an employee (or type a name), enter the present days, and add any deductions.
3.  **View Results**: The app instantly calculates the final payout and displays it in a clear summary card.
4.  **Reset**: Use the refresh icon in the app bar to clear the form and start a new session.


## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.

---

## 📞 Contact

Project Link: [https://github.com/milanKapadiya1/bhanker-security-cal](https://github.com/milanKapadiya1/bhanker-security-cal)
