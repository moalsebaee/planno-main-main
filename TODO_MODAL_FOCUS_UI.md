# TODO_MODAL_FOCUS_UI

## Step 1: Repo understanding
- [ ] Locate where the focus modal/time selection currently lives (likely FocusTimerScreen / existing dialogs).
- [ ] Identify current accent/brand color usage across the app.
- [ ] Confirm how to open the modal from the existing dashboard.

## Step 2: Implement modal UI
- [ ] Create a dedicated widget for the modal (e.g., SetFocusTimeModal / FocusTimeModal).
- [ ] Implement blurred background + centered light card.
- [ ] Add header (clock + title) with brand-tinted styling.
- [ ] Add time selection pill row with selected state.
- [ ] Add manual minutes input with blinking cursor.
- [ ] Add focus duration slider with active track/thumb/value styling.
- [ ] Add illustration + text + heart icon.
- [ ] Add primary/secondary buttons (Start Focus / Cancel).

## Step 3: Wire behavior
- [ ] Connect selected minutes to existing FocusTimerScreen (_setMinutes, _selectedMinutes, _secondsLeft).
- [ ] Start Focus should close modal and start timer using current selection.
- [ ] Cancel should just close modal.

## Step 4: Styling consistency + build verification
- [ ] Ensure spacing, radii, shadows, and typography match existing design language.
- [ ] Run `flutter analyze`.
- [ ] Run app (or at least `flutter test`) to confirm no compile errors.

