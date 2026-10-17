# 🏋️ Coach Studio

> **A modern workout program builder for personal trainers and fitness coaches.**

**Coach Studio** is a Persian-first, RTL Flutter application designed to help personal trainers create, manage, configure, and professionally export workout programs.

The goal is simple:

**Turn workout-program creation from a messy manual process into a clean, structured, professional workflow.**

---

## ✨ Features

### 🏋️ Exercise Library

Manage a reusable exercise database with information such as:

* Exercise name
* Target muscle
* Difficulty
* Equipment
* Description
* Instructions
* Common mistakes
* Image & video references
* Active / inactive status

Exercises can be:

* ➕ Added
* ✏️ Edited
* 🗑️ Deleted
* 🔎 Searched
* 🔄 Updated

---

### 📋 Workout Program Builder

Create complete workout programs with:

* Program title
* Training goal
* Difficulty level
* Number of training days
* Program notes
* Template support

Supported goals include:

* 💪 Hypertrophy
* 🏋️ Strength
* 🔥 Fat Loss
* 🫀 Endurance
* 🩹 Rehabilitation

Supported levels:

* 🟢 Beginner
* 🟡 Intermediate
* 🔴 Advanced

---

### 📅 Day-Based Workout Planning

Organize exercises by training day and order:

```text
Day 1
 ├── Exercise Block 1
 ├── Exercise Block 2
 └── Exercise Block 3

Day 2
 ├── Exercise Block 1
 └── Exercise Block 2

Day 3
 └── ...
```

Exercises maintain their own order within each training day.

Moving an exercise to another day automatically assigns it the next available position in the destination day.

---

### ⚙️ Exercise Configuration

Each exercise block can be configured with:

* Sets
* Repetitions
* Tempo
* Rest
* Description
* Training system

---

### 🔗 Superset Support

Coach Studio supports different training systems, including:

```text
Normal
Superset
```

A Superset can contain multiple exercises inside the same training block.

---

### 📄 Professional PDF Export

Generate a professional workout-program PDF directly from the application.

The PDF is designed specifically for Persian-speaking coaches and athletes:

* 🇮🇷 Persian RTL layout
* 📄 A4 format
* 🏋️ Training-day separation
* 👤 Athlete information
* 🏢 Club branding
* 📊 Structured exercise tables
* 📝 Program notes
* 🔗 Superset-aware layout

Each training day is designed to appear on a separate page.

A key architectural decision is that the **same `WorkoutProgramDetails` structure used by the UI is also used to generate the PDF**.

This prevents the UI and exported document from drifting apart.

---

## 🧠 Architecture

Coach Studio follows a **Feature-First Clean Architecture** approach.

The architecture keeps Firebase-specific concerns inside the **Data layer**, while the Domain layer remains independent of Firebase.

---

## 🧪 Development Principles

When contributing to Coach Studio, follow these principles:

### Clean Architecture

Keep responsibilities separated.

```text
UI ≠ Business Logic
Business Logic ≠ Firebase
Firebase ≠ Domain
```

### SOLID

Prefer:

* Single Responsibility
* Dependency Inversion
* Open/Closed design
* Interface-based dependencies

### Reuse Before Duplication

Before creating a new:

* Button
* Text field
* Dropdown
* Search bar
* Dialog
* Entity
* Repository

check whether an existing implementation already covers the requirement.

### Keep Domain Independent

Avoid putting Firebase-specific types inside Domain:

```dart
DocumentSnapshot
Timestamp
FirebaseFirestore
```

The Domain layer should not know that Firestore even exists.

---

## 📌 Current Scope

The current core focus of Coach Studio is:

```text
        ┌─────────────────────┐
        │   Exercise Library  │
        └──────────┬──────────┘
                   ↓
        ┌─────────────────────┐
        │ Workout Program     │
        │      Builder        │
        └──────────┬──────────┘
                   ↓
        ┌─────────────────────┐
        │ Exercise Config     │
        │ Sets / Reps / Tempo │
        │ Rest / Systems      │
        └──────────┬──────────┘
                   ↓
        ┌─────────────────────┐
        │ Professional PDF    │
        └─────────────────────┘
```

The central workflow is:

> **Coach → Create → Configure → Organize → Export**

---

## 🧠 Design Philosophy

Coach Studio is built around a few simple ideas:

> **Keep the coach focused on coaching, not paperwork.**

> **One source of truth for workout-program data.**

> **Clean architecture without unnecessary complexity.**

> **Persian-first UX with professional output.**

The goal isn't to build the biggest fitness platform.

The goal is to build a **fast, clean, professional tool that a coach actually wants to use.**

---

## 📜 License

This project is currently under active development.

License information will be added when the project reaches its appropriate release stage.

---

<div align="center">

### 🏋️ Coach Studio

**Build better programs. Spend less time managing them.**

Made with ❤️ and Flutter

</div>
