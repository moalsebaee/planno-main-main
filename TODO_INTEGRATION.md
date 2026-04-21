# Focus Timer → Firebase → Statistics Integration TODO

## Steps (Approved Plan):

### 1. Update FocusSession model (lib/models/focus_session.dart)
   - [x] Add durationInMinutes getter
   - [x] Add fromFirestore() and toFirestore() methods
   - [x] Remove global focusSessions list

### 2. Fix FocusViewModel (lib/viewmodels/focus_viewmodel.dart)
   - [x] Fix _focusRepository reference
   - [x] Expose sessions stream
   - [x] Ensure addFocusSession works

### 3. Update FocusTimerScreen (lib/screens/focus_timer_screen.dart)
   - [x] Import FocusViewModel
   - [x] Replace local focusSessions.add() with Firebase addFocusSession()
   - [x] Save even for 1+ minute sessions (pause/reset/complete)
   - [x] Remove local list usage

### 4. Update StatsViewModel (lib/viewmodels/stats_viewmodel.dart)
   - [x] Add sessions Stream
   - [x] Add totalMinutes and calculate() method
   - [x] Add formattedTime getter
   - [x] Replace hardcoded values
   - [x] Update totalFocusThisWeek to minutes

### 5. Update StatsScreen (lib/screens/stats_screen.dart)
   - [x] Add StreamBuilder for Total Focus StatSmallCard
   - [x] Use viewModel.calculate() and formattedTime
   - [x] Handle empty/no data as '0m'

### 6. Testing
   - [x] Run app, complete sessions (1min+)
   - [x] Verify Firestore saves
   - [x] Check live UI updates in Stats
   - [x] Mark complete, attempt_completion

**Progress: 6/6 steps done - Integration complete!**

