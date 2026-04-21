# Task Date to Weekly Chart Connection

## Current Progress
✅ Created TODO for new task

## Steps:
- [✅] Step 1: Update Task model in main.dart (add scheduledDate)

- [✅] Step 2: Enhance StatsViewModel (onTaskChanged notify, use scheduledDate for weekly)
- [✅] Step 3: new_task_screen.dart (save selectedDate to scheduledDate, notify)
- [✅] Step 4: tasks_screen.dart (notify on toggle)
- [✅] Step 5: task_home_screen.dart (notify on toggle)

- [ ] Step 6: Test & complete

## Notes
- Use selectedDate from date picker
- Chart groups by scheduledDate day of week this week
- Real-time via Provider notifyListeners()
- Keep UI same
