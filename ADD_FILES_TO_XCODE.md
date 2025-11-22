# Adding New Files to Xcode Project

The following files have been created for Phase 4: Presentation Layer but need to be manually added to the Xcode project:

## Files Created

1. **lich-plus/ViewModels/CalendarCellViewModel.swift** (85 lines)
   - Presentation layer ViewModel for calendar cells
   - 7 computed properties for UI presentation logic

2. **lich-plusTests/CalendarCellViewModelTests.swift** (195 lines)
   - 9 comprehensive unit tests following TDD principles

## Steps to Add Files to Xcode Project

### Option 1: Using Xcode UI (Recommended)

1. Open the project in Xcode (already open):
   ```bash
   open lich-plus.xcodeproj
   ```

2. Add CalendarCellViewModel.swift:
   - Right-click on the "ViewModels" folder in Project Navigator (create if it doesn't exist)
   - Select "Add Files to lich-plus..."
   - Navigate to: `lich-plus/ViewModels/CalendarCellViewModel.swift`
   - Check "Copy items if needed" is UNCHECKED (file already in correct location)
   - Ensure "lich-plus" target is CHECKED
   - Click "Add"

3. Add CalendarCellViewModelTests.swift:
   - Right-click on the "lich-plusTests" folder in Project Navigator
   - Select "Add Files to lich-plus..."
   - Navigate to: `lich-plusTests/CalendarCellViewModelTests.swift`
   - Check "Copy items if needed" is UNCHECKED
   - Ensure "lich-plusTests" target is CHECKED (NOT lich-plus)
   - Click "Add"

4. Verify the files are added:
   - You should see both files in the Project Navigator
   - CalendarCellViewModel.swift should show target membership: lich-plus
   - CalendarCellViewModelTests.swift should show target membership: lich-plusTests

5. Build and test:
   ```bash
   # In Xcode: Product → Test (Cmd+U)
   # Or via command line:
   xcodebuild test -scheme lich-plus -destination 'platform=iOS Simulator,name=iPhone 15'
   ```

### Option 2: Using Command Line (if Xcode is not available)

If you prefer command line, you can modify the project.pbxproj file, but this is error-prone and not recommended for Xcode projects.

## Expected Test Results

Once files are added to the project:

- **Total Tests**: 37 tests (28 existing + 9 new)
- **New Tests**: All 9 CalendarCellViewModel tests should pass
- **Coverage**: Weekend coloring, lunar month highlighting, dot visibility, today border

## Verification Checklist

- [ ] CalendarCellViewModel.swift added to lich-plus target
- [ ] CalendarCellViewModelTests.swift added to lich-plusTests target
- [ ] Project builds successfully
- [ ] All 37 tests pass (28 existing + 9 new)
- [ ] No warnings or errors in build log
