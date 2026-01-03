# 🥗 Dopamine Menu

**Dopamine Menu** is a productivity and wellness app designed to gamify daily habits and tasks. By organizing "dopamine-inducing" activities into a restaurant-style menu—Starters, Entrees, Sides, and Desserts—users can intentionally choose how they consume their focus and energy while earning points for a daily streak.

## 🚀 Features

### 1. Restaurant-Style Categorization

Activities are organized into four distinct courses to help manage energy levels:

- **Starters:** Quick, low-effort wins (e.g., making the bed).
    
- **Entrees:** Deep work or big tasks (e.g., 2-hour coding session).
    
- **Sides:** Healthy supplementary habits (e.g., drinking water, stretching).
    
- **Desserts:** High-dopamine rewards (e.g., 20 minutes of gaming).
    

### 2. Immersive Navigation (2D PageView)

The app uses a unique dual-axis navigation system:

- **Horizontal Swiping:** Move seamlessly between courses (Starters → Entrees → Sides → Desserts).
    
- **Vertical Swiping:** Scroll through individual items within a specific category.
    

### 3. Gamification & Feedback

- **Points System:** Each item has a point value. Completing a task triggers a **Confetti Explosion** and updates your total score.
    
- **Daily Reset:** Points reset every 24 hours to encourage fresh starts and consistent daily habits.
    
- **Haptic Feedback:** Physical vibrations accompany major actions to provide a tactile sense of achievement.
    

### 4. Favorites & Profile Management

- **Save for Later:** Users can "heart" items to save them to a personalized Favorites grid in their Profile.
    
- **Deep Linking:** Clicking a favorite item in the Profile grid instantly transports the user back to that specific item in the menu.
    
- **Personalization:** Custom avatars and daily point tracking.
    

---

## 🛠️ Architecture

The app is built using a modern **MVVM (Model-View-ViewModel)** inspired architecture to ensure the code is clean, testable, and scalable.

- **`HomeController` (ChangeNotifier):** Acts as the "Brain." It manages state, database interactions, and navigation logic, decoupling it from the UI.
    
- **`DatabaseHelper` (SQLite):** Handles persistent storage for user profiles and menu items.
    
- **Modular UI:** Navigation elements, category views, and full-screen cards are refactored into independent widgets for maximum reusability.
    

---

## 📦 Installation & Setup

1. **Clone the repository:**
    
    Bash
    
    ```
    git clone https://github.com/bmaxwell112/DopamineMenuApp.git
    ```
    
2. **Install dependencies:**
    
    Bash
    
    ```
    flutter pub get
    ```
    
3. **Generate Launcher Icons:**
    
    Bash
    
    ```
    flutter pub run flutter_launcher_icons
    ```
    
4. **Run the app:**
    
    Bash
    
    ```
    flutter run
    ```
    

---

## 🛠️ Tech Stack

- **Framework:** Flutter (Dart)
    
- **Database:** SQFlite
    
- **Animations:** Confetti package & Flutter built-in PageView
    
- **State Management:** ChangeNotifier (Provider pattern)

- **Icons:** Material Icons & Custom Launcher Icons