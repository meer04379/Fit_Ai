# FitAI — Smart AI Fitness, Nutrition & Workout Coach 🏋️‍♂️🥗

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev)
[![Google Gemini AI](https://img.shields.io/badge/Google_Gemini-Vision_AI-4285F4?logo=google)](https://aistudio.google.com/)
[![Supabase](https://img.shields.io/badge/Supabase-Backend_%26_Auth-3ECF8E?logo=supabase)](https://supabase.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**FitAI** is an advanced, AI-powered health and fitness mobile application built with Flutter. It combines Google's cutting-edge Gemini Vision AI, real-time hardware pedometer tracking, dynamic home and gym workout routines, automated weight transformation analytics, and cloud synchronization to deliver a complete personal fitness coaching experience right in your pocket.

---

## ✨ Key Features

### 📸 1. AI Food & Calorie Scanner (Gemini Vision)
- **Instant Meal Recognition:** Point your camera or upload an image to identify any dish, including complex meals, beverages, teas, and local cuisines.
- **Accurate Nutrition Breakdown:** Automatically calculates total calories, proteins, carbohydrates, and healthy fats with estimated AI confidence.
- **Ingredient Detection:** Lists individual food components with respective calorie estimates.
- **Permanent Local & Cloud Storage:** Logged meals are instantly cached in local storage (`SharedPreferences`) and synced to Supabase so your scan history is never lost across app restarts.

### 👟 2. Real-Time Hardware Step Tracker & Pedometer
- **Live Sensor Integration:** Directly connects to your device's built-in step sensor.
- **Dynamic Daily Targets:** Customize your step goal (e.g., 6,000, 8,000, 10,000+ steps) with real-time completion percentages.
- **Zero Raw-Step Leakage:** Smart in-memory and persistent baseline caching ensures your step count always accurately matches your actual walks.
- **Quick Reset & Walk Logging:** Re-zero baseline before starting a workout walk or log manual sessions.

### 🏋️ 3. Workout Routines — Home (Ghar Par) & Gym
- **Dual-Mode Switcher:** Easily toggle between **🏠 Home Workouts** (no equipment / bodyweight) and **🏋️ Gym Workouts** (weights, dumbbells, and machines).
- **Automated Day Detection:** Automatically highlights today's routine (Monday to Sunday) based on your live calendar date.
- **Exact Sets, Reps & Guidance:** Tells you exactly *"konsa workout aur kitna"* (e.g., *4 Sets × 12 Reps*, *3 Sets × 45s*), target muscle groups, and pro form tips.
- **Interactive Checklist & Consistency Streak:** Check off exercises as you finish them and log your session to build your 5-day weekly workout streak.

### ⚖️ 4. Weight Transformation & Progress Analytics
- **Start vs. Current vs. Goal:** Tracks where you started, where you are now, and how close you are to your goal.
- **Automated Progress Percentage:** Dynamically calculates progress based on whether your goal is **Weight Loss** or **Muscle Gain**.
- **Interactive Check-in Sheet:** Quick-tap chips (`-0.5kg`, `-0.2kg`, `+0.2kg`, `+0.5kg`) and custom input for effortless weigh-ins.
- **Live Trend Graph:** Visual weight transformation chart powered by FL Chart with historical check-in logs.

### 📊 5. Nutrition Insights & Macronutrient Charts
- **Interactive Donut Charts:** Real-time percentage breakdowns of Protein, Carbs, and Fats.
- **Categorized Daily Logs:** Clean breakdown into Breakfast, Lunch, Dinner, and Snacks.
- **Working Calendar Date Picker:** Pick any date to review historical nutrition logs and calorie intake.

### 🤖 6. FitAI Personal Assistant Coach
- Interactive fitness coach chatbot providing workout guidance, diet suggestions, calorie advice, and recovery tips tailored to your goals.

### 📋 7. Navigation Drawer & 🔔 Smart Notification Center
- **Sidebar Drawer:** Quick access to profile stats, today's meals, AI coach, workouts, weight tracker, and target adjustments dialog.
- **Live Notifications Sheet:** Context-aware alerts for hydration, step milestones, today's workout plan, remaining calorie budget, and weekly weigh-in reminders.

### 🔒 8. Bulletproof API Key & Secret Security
- **No Hardcoded Secrets:** All sensitive API keys (`GEMINI_API_KEY`, `SUPABASE_URL`, `SUPABASE_ANON_KEY`) are managed via `.env` and `flutter_dotenv`.
- **Git Protection:** `.env` is strictly gitignored and excluded from all version control commits.

---

## 🛠️ Tech Stack & Architecture

| Technology | Purpose |
| :--- | :--- |
| **Flutter & Dart** | Cross-platform mobile UI framework |
| **Google Gemini API** | AI multimodal vision & meal nutrition analysis |
| **Supabase** | Cloud Postgres database, authentication & user profiles |
| **Provider** | Reactive state management (`FitnessProvider`, `ChatProvider`) |
| **FL Chart** | Interactive weight trend and macronutrient charts |
| **Hardware Pedometer** | Real-time physical step sensor tracking |
| **Shared Preferences** | Offline local caching & instant persistence |
| **Flutter Dotenv** | Secure environment variable configuration |

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.19 or higher)
- [Dart SDK](https://dart.dev/get-dart) (v3.3 or higher)
- Android Studio / VS Code with Flutter extensions
- A connected physical Android/iOS device or emulator

### Installation

1. **Clone the Repository:**
   ```bash
   git clone https://github.com/meer04379/Fit_Ai.git
   cd Fit_Ai
   ```

2. **Install Dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure Environment Variables:**
   Duplicate the provided `.env.example` file and rename it to `.env`:
   ```bash
   cp .env.example .env
   ```
   Open `.env` and enter your credentials:
   ```env
   # Google Gemini API Key (https://aistudio.google.com/app/apikey)
   GEMINI_API_KEY=your_actual_gemini_api_key_here

   # Supabase Credentials (https://supabase.com)
   SUPABASE_URL=https://your-project-id.supabase.co
   SUPABASE_ANON_KEY=your_actual_supabase_anon_key_here
   ```

4. **Run the Application:**
   ```bash
   flutter run
   ```

---

## 📂 Project Structure

```
lib/
├── core/
│   ├── config/         # AppConfig & environment variable loaders
│   ├── constants/      # AppColors, typography, layout constants
│   └── theme/          # Light & dark theme definitions
├── models/             # MealLogItem, WorkoutExercise, DailyWorkoutPlan, etc.
├── providers/          # FitnessProvider (state & calculations), ChatProvider
├── screens/
│   ├── auth/           # Login & registration screens
│   ├── coach/          # FitAI personal chatbot screen
│   ├── home/           # Main dashboard, drawer, and notification center
│   ├── insights/       # Nutrition breakdown & macro donut charts
│   ├── meals/          # Today's meals detailed log
│   ├── onboarding/     # Goal selection & profile setup
│   ├── progress/       # Weight tracker & Home/Gym workout routines
│   ├── scanner/        # Camera & image picker food analysis
│   └── splash/         # Animated startup splash screen
├── services/           # GeminiService, SupabaseService, StepTrackerService
└── widgets/            # Reusable UI cards, pills, progress rings, custom buttons
```

---

## 🛡️ Security & Privacy
- **Zero Secret Commits:** API keys are never pushed to the remote repository.
- **Offline First:** The app runs smoothly even when internet is unavailable by using local storage and baseline nutrition heuristics.

---

## 📄 License
This project is open-source and available under the [MIT License](LICENSE).
