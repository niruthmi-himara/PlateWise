# PlateWise 🥗

**An AI-powered food logger for iPhone, made with Sri Lanka in mind.**
Snap a photo of a meal, let on-device machine learning recognise it, confirm the calories and track your progress against a daily goal.

> SE4041 Mobile Application Design and Development, Assignment 2, Part A
> K N H Rathnayake (IT23274570), SLIIT, BSc (Hons) in Information Technology, specialising in Interactive Media

---

## Features

| Feature | Details |
|---|---|
| 📸 **AI food recognition** | Pick a meal photo; a Core ML image classifier (MobileNetV2) run through the Vision framework suggests the food and fills in the calories. Runs fully on-device, so photos never leave the phone. |
| 🇱🇰 **Sri Lankan dishes** | When the AI isn't confident (under 30%), the app asks "Is it a Sri Lankan dish?" and offers rice and curry, kottu roti, hoppers and more as one-tap choices. |
| 🔍 **AI transparency** | An "AI saw" section shows the model's top five labels and confidence, so users can see why a suggestion was made. |
| ⭕ **Animated calorie ring** | A custom SwiftUI component shows calories eaten against the daily goal and turns orange when the goal is exceeded. |
| 📊 **Interactive history** | Swift Charts bar chart for 7 or 30 days, with a goal line; tap or drag on the chart to inspect a day. Meals listed by day with swipe-to-delete. |
| 👋 **Onboarding** | Four-page first-launch walkthrough that ends with setting a daily goal. |
| 🎨 **Branding and accessibility** | Custom app icon and in-app logo, green brand colour, Light / Dark / System theme, Dynamic Type support and VoiceOver labels. |
| 💾 **Persistence** | All meals are stored with SwiftData; photos are resized and stored efficiently with external storage. |

## Requirements

- macOS with **Xcode 26** or later
- iOS **26** Simulator (any iPhone), or an iPhone running iOS 26
- No third-party packages or internet connection needed

## How to build and run

1. Clone the repository:
   ```bash
   git clone https://github.com/niruthmi-himara/PlateWise.git
   ```
   Or in Xcode: **Integrate → Clone…** and paste the repository URL. (The repository is private; ask the author for access.)
2. Open **`PlateWise.xcodeproj`** in Xcode.
3. At the top of the Xcode window, choose an **iPhone simulator** (for example, iPhone 17 Pro).
4. Press **⌘R** to build and run.
5. To try the AI on the simulator, drag a food photo (JPG/PNG) from Finder onto the simulator window to add it to Photos, then in the app tap **+** and choose the photo.
6. For a quick demo with full charts: **Settings → Load demo data**.

### Running the tests

Press **⌘U** (Product → Test). Results appear in the Test navigator (**⌘6**).

- **15 unit tests** (Swift Testing): meal model, AI label matching, image resizing, ViewModel validation, SwiftData persistence, demo data and Core ML model loading.
- **7 UI tests** (XCTest): onboarding flow, tab navigation, adding a Sri Lankan dish, Save validation, demo data and Dark Mode, plus launch performance measurement.

## Project structure

```
PlateWise/
├── ML/            MobileNetV2.mlmodel (Core ML image classifier)
├── Models/        Meal (SwiftData @Model) and MealType
├── ViewModels/    AddMealViewModel (photo loading, AI, validation, saving)
├── Services/      FoodClassifier (Core ML + Vision), FoodDatabase, DemoData, Helpers
├── Views/         TodayView, AddMealView, MealDetailView, HistoryView, SettingsView,
│                  OnboardingView, and reusable components CalorieRing, CardStyle, BrandHeader
└── Assets/        App icon, logo and brand accent colour
PlateWiseTests/    Unit tests
PlateWiseUITests/  UI tests
```

## Architecture

PlateWise follows **MVVM**:

- **Model**: `Meal` is a SwiftData `@Model`; `@Query` keeps views updated automatically.
- **View**: SwiftUI screens inside a `TabView`, each with its own `NavigationStack`.
- **ViewModel**: `AddMealViewModel` (`@Observable`, `@MainActor`) holds the Add Meal screen's state and logic.
- **Services**: `FoodClassifier` runs the Core ML model on a background task so the UI stays smooth; `FoodDatabase` maps model labels to foods and calories.

## Technologies

SwiftUI · SwiftData · Core ML · Vision · Swift Charts · PhotosUI · Swift Testing · XCTest

## Known limitations

- MobileNetV2 is a general-purpose model trained on ImageNet's 1,000 categories. It recognises foods like burgers, pizza and bananas well, but not Sri Lankan dishes or some vegetables (for example, carrots may be labelled as cucumber). The app handles this by only auto-filling confident results and offering local dishes otherwise.
- Calorie values are typical per-serving estimates, not exact nutritional measurements.
- **Future work:** train a custom Create ML image classifier on a food dataset that includes Sri Lankan dishes, and add direct camera capture.

## Credits

- **MobileNetV2** Core ML model from [Apple's Core ML model gallery](https://developer.apple.com/machine-learning/models/), based on *Sandler et al., "MobileNetV2: Inverted Residuals and Linear Bottlenecks", 2018*.
- Icons from Apple's **SF Symbols**.

## AI-assisted development

AI assistance (Claude, by Anthropic) was used for guidance, explanations, debugging and code suggestions during development. All prompts and responses are documented in the AI usage log submitted with this assignment, as required by the submission guidelines.
