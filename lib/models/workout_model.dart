class WorkoutExercise {
  final String name;
  final String setsAndReps;
  final String targetMuscle;
  final String icon;
  final String tip;

  const WorkoutExercise({
    required this.name,
    required this.setsAndReps,
    required this.targetMuscle,
    this.icon = '💪',
    this.tip = '',
  });
}

class DailyWorkoutPlan {
  final String dayName;
  final String title;
  final String category; // 'Home' or 'Gym'
  final int durationMinutes;
  final int estimatedCalories;
  final String level;
  final String focusArea;
  final List<WorkoutExercise> exercises;

  const DailyWorkoutPlan({
    required this.dayName,
    required this.title,
    required this.category,
    required this.durationMinutes,
    required this.estimatedCalories,
    required this.level,
    required this.focusArea,
    required this.exercises,
  });
}

class WorkoutDatabase {
  static DailyWorkoutPlan getWorkoutForDay({
    required int weekday, // 1: Mon, ... 7: Sun
    required bool isGym,
  }) {
    if (isGym) {
      return _gymPlans[weekday] ?? _gymPlans[1]!;
    } else {
      return _homePlans[weekday] ?? _homePlans[1]!;
    }
  }

  // ----------------- HOME WORKOUTS (NO EQUIPMENT / BODYWEIGHT) -----------------
  static final Map<int, DailyWorkoutPlan> _homePlans = {
    // 1: Monday
    1: const DailyWorkoutPlan(
      dayName: 'Monday',
      title: 'Chest & Triceps Blast (Home)',
      category: 'Home',
      durationMinutes: 35,
      estimatedCalories: 260,
      level: 'All Levels',
      focusArea: 'Chest, Arms & Shoulders',
      exercises: [
        WorkoutExercise(
          name: 'Standard Push-ups',
          setsAndReps: '4 Sets × 15 Reps',
          targetMuscle: 'Chest',
          icon: '💪',
          tip: 'Keep your body in a straight plank line and elbows at 45 degrees.',
        ),
        WorkoutExercise(
          name: 'Diamond Push-ups',
          setsAndReps: '3 Sets × 10-12 Reps',
          targetMuscle: 'Triceps',
          icon: '💎',
          tip: 'Form a diamond with your hands beneath your chest.',
        ),
        WorkoutExercise(
          name: 'Chair / Bed Dips',
          setsAndReps: '3 Sets × 15 Reps',
          targetMuscle: 'Triceps',
          icon: '🪑',
          tip: 'Lower hips straight down without flaring elbows out.',
        ),
        WorkoutExercise(
          name: 'Wide-Arm Push-ups',
          setsAndReps: '3 Sets × 12 Reps',
          targetMuscle: 'Outer Chest',
          icon: '👐',
          tip: 'Hands placed wider than shoulder-width for maximum chest stretch.',
        ),
        WorkoutExercise(
          name: 'Plank to Push-up',
          setsAndReps: '3 Sets × 10 Reps',
          targetMuscle: 'Chest & Core',
          icon: '⚡',
          tip: 'Alternate arms when pushing up from forearm plank.',
        ),
      ],
    ),

    // 2: Tuesday
    2: const DailyWorkoutPlan(
      dayName: 'Tuesday',
      title: 'Back, Biceps & Posture (Home)',
      category: 'Home',
      durationMinutes: 35,
      estimatedCalories: 240,
      level: 'All Levels',
      focusArea: 'Upper & Lower Back, Biceps',
      exercises: [
        WorkoutExercise(
          name: 'Doorframe Bodyweight Rows',
          setsAndReps: '4 Sets × 15 Reps',
          targetMuscle: 'Lats & Upper Back',
          icon: '🚪',
          tip: 'Hold the doorframe firmly, lean back, and pull your chest inward.',
        ),
        WorkoutExercise(
          name: 'Superman Back Extensions',
          setsAndReps: '3 Sets × 15 Reps (2s hold)',
          targetMuscle: 'Lower Back & Glutes',
          icon: '🦸',
          tip: 'Lift arms and legs simultaneously and pause at the top.',
        ),
        WorkoutExercise(
          name: 'Towel Isometric Bicep Curls',
          setsAndReps: '3 Sets × 12 Reps',
          targetMuscle: 'Biceps',
          icon: '🧣',
          tip: 'Step on towel with one foot and pull up creating self-resistance.',
        ),
        WorkoutExercise(
          name: 'Reverse Snow Angels (Prone)',
          setsAndReps: '3 Sets × 15 Reps',
          targetMuscle: 'Rhomboids & Rear Delts',
          icon: '🦅',
          tip: 'Lie on stomach and sweep arms from hips to above head.',
        ),
        WorkoutExercise(
          name: 'Bird-Dog Core Stability',
          setsAndReps: '3 Sets × 12 Reps per side',
          targetMuscle: 'Back & Core',
          icon: '🐕',
          tip: 'Extend opposite arm and leg while keeping hips square.',
        ),
      ],
    ),

    // 3: Wednesday
    3: const DailyWorkoutPlan(
      dayName: 'Wednesday',
      title: 'Core, Abs & Fat Burn HIIT (Home)',
      category: 'Home',
      durationMinutes: 30,
      estimatedCalories: 310,
      level: 'Fat Burn & Core',
      focusArea: 'Abs, Obliques & Cardiovascular',
      exercises: [
        WorkoutExercise(
          name: 'Mountain Climbers',
          setsAndReps: '4 Sets × 35 Seconds',
          targetMuscle: 'Core & Cardio',
          icon: '🏔️',
          tip: 'Drive knees toward chest in a fast, rhythmic running pace.',
        ),
        WorkoutExercise(
          name: 'Bicycle Crunches',
          setsAndReps: '3 Sets × 20 Reps',
          targetMuscle: 'Six-Pack & Obliques',
          icon: '🚴',
          tip: 'Touch opposite elbow to opposite knee with controlled rotation.',
        ),
        WorkoutExercise(
          name: 'Jumping Jacks',
          setsAndReps: '4 Sets × 45 Seconds',
          targetMuscle: 'Full Body Cardio',
          icon: '⭐',
          tip: 'Stay light on your toes to maintain steady heart rate.',
        ),
        WorkoutExercise(
          name: 'Forearm Plank Hold',
          setsAndReps: '3 Sets × 45-60 Seconds',
          targetMuscle: 'Core & Transverse Abdominis',
          icon: '🧱',
          tip: 'Tighten glutes and pull belly button toward spine.',
        ),
        WorkoutExercise(
          name: 'Burpees (Full Body Finisher)',
          setsAndReps: '3 Sets × 10-12 Reps',
          targetMuscle: 'Full Body Stamina',
          icon: '🔥',
          tip: 'Drop chest to floor, jump up and clap above head.',
        ),
      ],
    ),

    // 4: Thursday
    4: const DailyWorkoutPlan(
      dayName: 'Thursday',
      title: 'Shoulders & Arms Sculpt (Home)',
      category: 'Home',
      durationMinutes: 35,
      estimatedCalories: 250,
      level: 'All Levels',
      focusArea: 'Deltoids, Biceps & Forearms',
      exercises: [
        WorkoutExercise(
          name: 'Pike Push-ups',
          setsAndReps: '4 Sets × 10-12 Reps',
          targetMuscle: 'Anterior Deltoids',
          icon: '📐',
          tip: 'Hips high in V-shape, lower top of head towards ground.',
        ),
        WorkoutExercise(
          name: 'Arm Circles & Overhead Pulses',
          setsAndReps: '3 Sets × 45 Seconds',
          targetMuscle: 'Deltoid Endurance',
          icon: '🔄',
          tip: 'Keep arms parallel to ground without lowering them.',
        ),
        WorkoutExercise(
          name: 'Wall Handstand or Incline Hold',
          setsAndReps: '3 Sets × 30 Seconds',
          targetMuscle: 'Shoulder Strength',
          icon: '🧗',
          tip: 'Walk feet up wall into an inverted hold.',
        ),
        WorkoutExercise(
          name: 'Water Bottle Lateral Raises',
          setsAndReps: '4 Sets × 15 Reps',
          targetMuscle: 'Side Deltoids',
          icon: '🍶',
          tip: 'Use two 1.5L filled bottles for smooth isolation raises.',
        ),
        WorkoutExercise(
          name: 'Crab Walk / Tricep Hold',
          setsAndReps: '3 Sets × 40 Seconds',
          targetMuscle: 'Triceps & Rear Delts',
          icon: '🦀',
          tip: 'Palms on floor behind you, lift hips and step forward and backward.',
        ),
      ],
    ),

    // 5: Friday
    5: const DailyWorkoutPlan(
      dayName: 'Friday',
      title: 'Leg Day & Lower Body Power (Home)',
      category: 'Home',
      durationMinutes: 40,
      estimatedCalories: 330,
      level: 'High Calorie Burn',
      focusArea: 'Quads, Glutes, Hamstrings & Calves',
      exercises: [
        WorkoutExercise(
          name: 'Bodyweight Air Squats',
          setsAndReps: '4 Sets × 20 Reps',
          targetMuscle: 'Quads & Glutes',
          icon: '🏋️',
          tip: 'Break parallel depth and push through heels on the ascent.',
        ),
        WorkoutExercise(
          name: 'Walking Lunges',
          setsAndReps: '3 Sets × 12 Reps per leg',
          targetMuscle: 'Hamstrings & Glutes',
          icon: '🚶',
          tip: 'Take a long stride, keeping front knee behind toe line.',
        ),
        WorkoutExercise(
          name: 'Glute Bridges (Pause at top)',
          setsAndReps: '3 Sets × 20 Reps',
          targetMuscle: 'Glutes & Hip Extensors',
          icon: '🌉',
          tip: 'Squeeze glutes at top for 2 full seconds.',
        ),
        WorkoutExercise(
          name: 'Single-Leg Step Calf Raises',
          setsAndReps: '4 Sets × 20 Reps per leg',
          targetMuscle: 'Calves',
          icon: '🦶',
          tip: 'Stand on a stair edge for full stretch at the bottom.',
        ),
        WorkoutExercise(
          name: 'Wall Sit Isometric Hold',
          setsAndReps: '3 Sets × 45 Seconds',
          targetMuscle: 'Quads Endurance',
          icon: '🧱',
          tip: 'Thighs parallel to floor, back flat against wall.',
        ),
      ],
    ),

    // 6: Saturday
    6: const DailyWorkoutPlan(
      dayName: 'Saturday',
      title: 'Full Body Athletic Conditioning (Home)',
      category: 'Home',
      durationMinutes: 35,
      estimatedCalories: 320,
      level: 'Conditioning',
      focusArea: 'Total Body Mobility & Endurance',
      exercises: [
        WorkoutExercise(
          name: 'High Knee Sprints in Place',
          setsAndReps: '4 Sets × 35 Seconds',
          targetMuscle: 'Full Body Cardio',
          icon: '🏃',
          tip: 'Drive knees up to waist height with powerful arm swings.',
        ),
        WorkoutExercise(
          name: 'Squat Jumps',
          setsAndReps: '3 Sets × 12 Reps',
          targetMuscle: 'Explosive Legs',
          icon: '🚀',
          tip: 'Land softly on the balls of your feet.',
        ),
        WorkoutExercise(
          name: 'Push-up to T-Rotation',
          setsAndReps: '3 Sets × 10 Reps',
          targetMuscle: 'Chest & Obliques',
          icon: '📐',
          tip: 'Rotate torso and reach upper hand to ceiling at the top.',
        ),
        WorkoutExercise(
          name: 'Bear Crawl Steps',
          setsAndReps: '3 Sets × 30 Seconds',
          targetMuscle: 'Core & Shoulders',
          icon: '🐻',
          tip: 'Keep knees 1 inch off the floor while crawling forward and back.',
        ),
      ],
    ),

    // 7: Sunday
    7: const DailyWorkoutPlan(
      dayName: 'Sunday',
      title: 'Active Recovery & Full Body Mobility',
      category: 'Home',
      durationMinutes: 20,
      estimatedCalories: 110,
      level: 'Recovery',
      focusArea: 'Flexibility, Spine & Joint Health',
      exercises: [
        WorkoutExercise(
          name: 'Cat-Cow Spinal Flexion',
          setsAndReps: '3 Sets × 10 Slow Reps',
          targetMuscle: 'Spine & Neck',
          icon: '🐈',
          tip: 'Inhale arching back, exhale rounding spine smoothly.',
        ),
        WorkoutExercise(
          name: 'Downward Dog to Cobra Stretch',
          setsAndReps: '3 Sets × 8 Reps',
          targetMuscle: 'Hamstrings & Abs',
          icon: '🧘',
          tip: 'Flow slowly between stretching calves and opening chest.',
        ),
        WorkoutExercise(
          name: 'World\'s Greatest Stretch',
          setsAndReps: '3 Sets × 5 Reps per side',
          targetMuscle: 'Hips & Thoracic Spine',
          icon: '🌍',
          tip: 'Deep lunge with elbow to inside ankle, then rotate open.',
        ),
        WorkoutExercise(
          name: 'Deep Breathing Child\'s Pose',
          setsAndReps: '3 Sets × 60 Seconds',
          targetMuscle: 'Full Body Relaxation',
          icon: '🕊️',
          tip: 'Sink hips back onto heels and relax arms forward.',
        ),
      ],
    ),
  };

  // ----------------- GYM WORKOUTS (WEIGHTS & MACHINES) -----------------
  static final Map<int, DailyWorkoutPlan> _gymPlans = {
    // 1: Monday
    1: const DailyWorkoutPlan(
      dayName: 'Monday',
      title: 'Heavy Chest & Triceps (Gym)',
      category: 'Gym',
      durationMinutes: 50,
      estimatedCalories: 380,
      level: 'Hypertrophy',
      focusArea: 'Pecs, Front Delts & Triceps',
      exercises: [
        WorkoutExercise(
          name: 'Barbell Flat Bench Press',
          setsAndReps: '4 Sets × 8-10 Reps',
          targetMuscle: 'Middle Chest',
          icon: '🏋️',
          tip: 'Retract scapula, arch lower back slightly, press explosively.',
        ),
        WorkoutExercise(
          name: 'Incline Dumbbell Press (30°)',
          setsAndReps: '3 Sets × 10-12 Reps',
          targetMuscle: 'Upper Chest',
          icon: '📐',
          tip: 'Control the descent for 2-3 seconds for maximum hypertrophy.',
        ),
        WorkoutExercise(
          name: 'Cable Standing Chest Flyes',
          setsAndReps: '3 Sets × 12-15 Reps',
          targetMuscle: 'Inner / Lower Chest',
          icon: '🦅',
          tip: 'Squeeze hands together at the front and feel the peak contraction.',
        ),
        WorkoutExercise(
          name: 'Cable Tricep Rope Pushdowns',
          setsAndReps: '4 Sets × 12-15 Reps',
          targetMuscle: 'Triceps Lateral Head',
          icon: '🪢',
          tip: 'Spread rope apart at the bottom of the movement.',
        ),
        WorkoutExercise(
          name: 'Overhead Dumbbell Tricep Extension',
          setsAndReps: '3 Sets × 10-12 Reps',
          targetMuscle: 'Triceps Long Head',
          icon: '💪',
          tip: 'Keep elbows tucked close to head while extending weight.',
        ),
      ],
    ),

    // 2: Tuesday
    2: const DailyWorkoutPlan(
      dayName: 'Tuesday',
      title: 'Back Thickness & Biceps (Gym)',
      category: 'Gym',
      durationMinutes: 50,
      estimatedCalories: 390,
      level: 'Hypertrophy',
      focusArea: 'Lats, Rhomboids, Biceps',
      exercises: [
        WorkoutExercise(
          name: 'Wide-Grip Lat Pulldowns',
          setsAndReps: '4 Sets × 10-12 Reps',
          targetMuscle: 'Latissimus Dorsi (Width)',
          icon: '⬇️',
          tip: 'Pull bar to upper collarbone with chest tall and proud.',
        ),
        WorkoutExercise(
          name: 'Seated Cable Row (Close Grip)',
          setsAndReps: '3 Sets × 10-12 Reps',
          targetMuscle: 'Mid-Back Thickness',
          icon: '🛶',
          tip: 'Pull elbows back past torso and squeeze shoulder blades.',
        ),
        WorkoutExercise(
          name: 'Barbell Bent-over Row',
          setsAndReps: '3 Sets × 8-10 Reps',
          targetMuscle: 'Lats & Lower Back',
          icon: '🏋️',
          tip: 'Hinge at 45 degrees, pull bar towards belly button.',
        ),
        WorkoutExercise(
          name: 'Standing Barbell Bicep Curls',
          setsAndReps: '4 Sets × 10 Reps',
          targetMuscle: 'Biceps Brachii',
          icon: '💪',
          tip: 'Do not swing hips; keep upper arms locked by your sides.',
        ),
        WorkoutExercise(
          name: 'Incline Dumbbell Hammer Curls',
          setsAndReps: '3 Sets × 12 Reps',
          targetMuscle: 'Brachialis & Forearms',
          icon: '🔨',
          tip: 'Neutral palms facing each other to build arm thickness.',
        ),
      ],
    ),

    // 3: Wednesday
    3: const DailyWorkoutPlan(
      dayName: 'Wednesday',
      title: 'Abs, Core & Treadmill HIIT (Gym)',
      category: 'Gym',
      durationMinutes: 45,
      estimatedCalories: 420,
      level: 'Fat Burn & Stamina',
      focusArea: 'Core, Abs & Cardio Intervals',
      exercises: [
        WorkoutExercise(
          name: 'Hanging Leg / Knee Raises',
          setsAndReps: '4 Sets × 12-15 Reps',
          targetMuscle: 'Lower Abs',
          icon: '🧗',
          tip: 'Curl pelvis up toward chest rather than just swinging legs.',
        ),
        WorkoutExercise(
          name: 'Cable Woodchoppers (High to Low)',
          setsAndReps: '3 Sets × 12 Reps per side',
          targetMuscle: 'Obliques',
          icon: '🪓',
          tip: 'Rotate through core while keeping arms straight.',
        ),
        WorkoutExercise(
          name: 'Ab Roller Wheel Rollouts',
          setsAndReps: '3 Sets × 10 Reps',
          targetMuscle: 'Deep Core Wall',
          icon: '🛞',
          tip: 'Roll forward with hips tucked under; avoid sagging lower back.',
        ),
        WorkoutExercise(
          name: 'Incline Treadmill Sprints / Intervals',
          setsAndReps: '15 Minutes (1 min run / 1 min walk)',
          targetMuscle: 'Cardio Endurance',
          icon: '🏃',
          tip: 'Set incline to 8-10% for intense calorie burn.',
        ),
      ],
    ),

    // 4: Thursday
    4: const DailyWorkoutPlan(
      dayName: 'Thursday',
      title: 'Shoulders 3D & Traps (Gym)',
      category: 'Gym',
      durationMinutes: 50,
      estimatedCalories: 370,
      level: 'Hypertrophy',
      focusArea: 'Deltoids & Trapezius',
      exercises: [
        WorkoutExercise(
          name: 'Seated Dumbbell Shoulder Press',
          setsAndReps: '4 Sets × 8-10 Reps',
          targetMuscle: 'Front & Side Delts',
          icon: '🏋️',
          tip: 'Lower dumbbells until elbows are at 90 degrees, press upward.',
        ),
        WorkoutExercise(
          name: 'Dumbbell Standing Lateral Raises',
          setsAndReps: '4 Sets × 15 Reps',
          targetMuscle: 'Lateral Delts (Shoulder Width)',
          icon: '🦅',
          tip: 'Lead with elbows slightly forward in scapular plane.',
        ),
        WorkoutExercise(
          name: 'Cable Face Pulls with External Rotation',
          setsAndReps: '4 Sets × 15 Reps',
          targetMuscle: 'Rear Delts & Rotator Cuff',
          icon: '🎯',
          tip: 'Pull rope towards eyes while rotating thumbs backward.',
        ),
        WorkoutExercise(
          name: 'Dumbbell Heavy Shrugs',
          setsAndReps: '3 Sets × 12-15 Reps (2s hold)',
          targetMuscle: 'Upper Trapezius',
          icon: '🤷',
          tip: 'Shrug straight up to ears without rolling shoulders.',
        ),
      ],
    ),

    // 5: Friday
    5: const DailyWorkoutPlan(
      dayName: 'Friday',
      title: 'Heavy Leg Day & Calves (Gym)',
      category: 'Gym',
      durationMinutes: 55,
      estimatedCalories: 450,
      level: 'High Intensity',
      focusArea: 'Quads, Hamstrings, Glutes & Calves',
      exercises: [
        WorkoutExercise(
          name: 'Barbell Back Squats',
          setsAndReps: '4 Sets × 8-10 Reps',
          targetMuscle: 'Quads & Glutes',
          icon: '🏋️',
          tip: 'Brace core with deep breath, squat down to parallel or below.',
        ),
        WorkoutExercise(
          name: 'Angled Leg Press Machine',
          setsAndReps: '4 Sets × 12 Reps',
          targetMuscle: 'Overall Legs',
          icon: '🦾',
          tip: 'Do not lock knees completely at top to protect joints.',
        ),
        WorkoutExercise(
          name: 'Romanian Dumbbell Deadlifts',
          setsAndReps: '3 Sets × 10-12 Reps',
          targetMuscle: 'Hamstrings & Glutes',
          icon: '🦵',
          tip: 'Push hips back keeping spine flat until deep hamstring stretch.',
        ),
        WorkoutExercise(
          name: 'Seated Hamstring Leg Curls',
          setsAndReps: '3 Sets × 12 Reps',
          targetMuscle: 'Hamstrings',
          icon: '🔄',
          tip: 'Slow negative return to maximize muscle fiber activation.',
        ),
        WorkoutExercise(
          name: 'Standing Machine Calf Raises',
          setsAndReps: '4 Sets × 15-20 Reps',
          targetMuscle: 'Calves (Gastrocnemius)',
          icon: '🦶',
          tip: 'Full stretch at bottom, explosive squeeze at top.',
        ),
      ],
    ),

    // 6: Saturday
    6: const DailyWorkoutPlan(
      dayName: 'Saturday',
      title: 'Full Body Functional Conditioning (Gym)',
      category: 'Gym',
      durationMinutes: 45,
      estimatedCalories: 410,
      level: 'Metabolic Conditioning',
      focusArea: 'Full Body Functional Strength',
      exercises: [
        WorkoutExercise(
          name: 'Kettlebell Swings',
          setsAndReps: '4 Sets × 15 Reps',
          targetMuscle: 'Glutes, Core & Posterior Chain',
          icon: '🔔',
          tip: 'Power comes from explosive hip snap, not lifting with arms.',
        ),
        WorkoutExercise(
          name: 'Dumbbell Thrusters (Squat to Press)',
          setsAndReps: '3 Sets × 12 Reps',
          targetMuscle: 'Quads & Shoulders',
          icon: '🚀',
          tip: 'Drive out of the squat directly into an overhead press.',
        ),
        WorkoutExercise(
          name: 'Battle Ropes Alternating Waves',
          setsAndReps: '4 Sets × 30 Seconds',
          targetMuscle: 'Shoulders & Grip Cardio',
          icon: '🌊',
          tip: 'Stay in quarter squat and generate waves with quick wrists.',
        ),
        WorkoutExercise(
          name: 'Rowing Machine Concept2',
          setsAndReps: '15 Minutes Steady Pace',
          targetMuscle: 'Total Body Cardio',
          icon: '🚣',
          tip: 'Legs drive first, then lean back, then pull arms to chest.',
        ),
      ],
    ),

    // 7: Sunday
    7: const DailyWorkoutPlan(
      dayName: 'Sunday',
      title: 'Recovery, Sauna & Core Stretching',
      category: 'Gym',
      durationMinutes: 25,
      estimatedCalories: 130,
      level: 'Rest & Recovery',
      focusArea: 'Joint Decompression & Muscle Repair',
      exercises: [
        WorkoutExercise(
          name: 'Light Incline Treadmill Walk',
          setsAndReps: '15 Minutes (Easy Pace 4.5 km/h)',
          targetMuscle: 'Cardiovascular Flush',
          icon: '🚶',
          tip: 'Flush lactic acid from the week with easy walking.',
        ),
        WorkoutExercise(
          name: 'Foam Rolling Major Muscle Groups',
          setsAndReps: '10 Minutes',
          targetMuscle: 'Myofascial Release',
          icon: '🧘',
          tip: 'Roll quads, lats, and upper back for 30s per tight knot.',
        ),
        WorkoutExercise(
          name: 'Static Hamstring & Hip Flexor Stretches',
          setsAndReps: '3 Sets × 30s per stretch',
          targetMuscle: 'Mobility & Hamstrings',
          icon: '🕊️',
          tip: 'Breathe deeply into every stretch; never bounce.',
        ),
      ],
    ),
  };
}
