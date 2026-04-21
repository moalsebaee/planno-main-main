# Statistics Integration - Progress Tracker

## Plan Summary
Replace static data in StatsViewModel with real dynamic calculations from TaskViewModel stream + FocusSessions.

## Steps (0/8) - Approved

### 1. [x] Update StatsViewModel: Listen to TaskViewModel stream
Added TaskViewModel dep to constructor, stream listener in StatsViewModel.
Updated main.dart providers.
Fixed stats_screen.dart to use global provider ✅

### 2. [ ] Add FocusService/Stream for focus_sessions Firestore
Model exists, add repository/stream like tasks.

### 3. [ ] Compute dynamic metrics
- productivityScore: completed/total * 100
- weeklyData: weeklyCompletedTasks(tasks)
- totalTasks/completedTasks from TaskViewModel
- totalFocusThisWeek from FocusSessions

### 4. [ ] Connect StatsScreen Consumers to real data
Replace hardcoded with viewModel getters.

### 5. [ ] Fix WeeklyActivityCard data source
Use viewModel.weeklyData (dynamic)

### 6. [ ] StatsScreen local _viewModel → Provider.of<StatsViewModel>

### 7. [ ] Task toggle → StatsViewModel.onTaskChanged() call from TaskViewModel

### 8. [ ] Test
- Add/complete task → stats update
- Focus session → focus time updates

**Status**: Planning complete
