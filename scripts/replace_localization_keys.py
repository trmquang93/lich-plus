#!/usr/bin/env python3
"""
Replace localization keys in Swift files with their English text.

This script:
1. Uses a mapping of localization keys to their English text
2. Scans Swift files for localization key references
3. Replaces the key references with their English text (keeping String(localized:) wrapper)

Usage:
    python scripts/replace_localization_keys.py --dry-run    # Preview changes
    python scripts/replace_localization_keys.py              # Apply changes
    python scripts/replace_localization_keys.py --verbose    # Detailed output
"""

import argparse
import re
from pathlib import Path
from typing import Dict, List, Tuple


# Comprehensive mapping of localization keys to English text
# This mapping is inferred from the context where each key is used
KEY_TO_ENGLISH = {
    # AI Input keys (from AIInputSection.swift)
    "ai.input.title": "AI Assistant",
    "ai.input.placeholder": "Type your message...",
    "ai.input.parse": "Parse",
    "ai.input.hint": "AI-powered input",

    # Empty state keys
    "all.empty.title": "No Items",
    "all.empty.message": "You don't have any items yet.",

    # Create item keys
    "createItem.title": "New Item",
    "createItem.save": "Save",
    "createItem.createEvent": "Create Event",
    "createItem.createTask": "Create Task",
    "createItem.editEvent": "Edit Event",
    "createItem.editTask": "Edit Task",
    "createItem.eventTitle": "Title",
    "createItem.eventTitlePlaceholder": "Enter title",
    "createItem.taskTitle": "Task Title",
    "createItem.taskTitlePlaceholder": "Enter task title",
    "createItem.eventCategory": "Category",
    "createItem.allDay": "All Day",
    "createItem.allDayToggle": "All Day",
    "createItem.startDate": "Start Date",
    "createItem.endDate": "End Date",
    "createItem.starts": "Starts",
    "createItem.ends": "Ends",
    "createItem.location": "Location",
    "createItem.locationPlaceholder": "Add location",
    "createItem.description": "Description",
    "createItem.recurrence": "Recurrence",
    "createItem.category": "Category",
    "createItem.dueDate": "Due Date",
    "createItem.priority": "Priority",

    # Category keys
    "category.birthday": "Birthday",
    "category.holiday": "Holiday",
    "category.meeting": "Meeting",
    "category.other": "Other",
    "category.personal": "Personal",
    "category.work": "Work",

    # Notification keys
    "notification.enable": "Enable Notifications",
    "notification.permissionDenied.footer": "Enable notifications in Settings to receive reminders.",
    "notification.openSettings": "Open Settings",
    "notification.events.section": "Event Reminders",
    "notification.events.enable": "Event Reminders",
    "notification.defaultReminder": "Default Reminder",
    "notification.ram.section": "Rằm (15th) Reminders",
    "notification.ram.enable": "Rằm Reminders",
    "notification.ram.title": "Rằm %d",
    "notification.ram.body": "Today is Rằm (15th day of lunar month)",
    "notification.mung1.section": "Mùng 1 Reminders",
    "notification.mung1.enable": "Mùng 1 Reminders",
    "notification.mung1.title": "Mùng 1 %d",
    "notification.mung1.body": "Today is Mùng 1 (1st day of lunar month)",
    "notification.fixed.section": "Fixed Reminders",
    "notification.fixed.enable": "Fixed Reminders",
    "notification.fixed.reminderDays": "Reminder Days",
    "notification.onDay": "On day",
    "notification.time": "Time",
    "notification.daysBefore": "%d days before",
    "notification.minutesBefore": "%d minutes before",
    "notification.event.startsIn": "starts in %d",
    "notification.holiday.inDays": "Holiday in %d days",
    "notification.settings.title": "Notification Settings",
    "notification.settings.subtitle": "Configure reminders and notifications",

    # Date picker keys
    "datePicker.lunarMonthYear": "Lunar Date",
    "datePicker.monthYear": "Date",
    "datePicker.selectTime": "Select Time",
    "date.today": "Today",

    # Delete confirmation keys
    "delete.confirm": "Delete",
    "delete.cancel": "Cancel",
    "delete.recurring.title": "Recurring Item",
    "delete.recurring.message": "This is a recurring item. Choose what to delete.",
    "delete.event.message": "Delete this event?",
    "delete.task.message": "Delete this task?",

    # Event keys
    "event.allDay": "All Day",

    # Item type keys
    "item.event": "Event",
    "item.task": "Task",
    "task.completed": "Completed",

    # Priority keys
    "priority.high": "High",
    "priority.medium": "Medium",
    "priority.low": "Low",
    "priority.none": "None",

    # Recurrence keys
    "recurrence.none": "None",
    "recurrence.daily": "Daily",
    "recurrence.weekly": "Weekly",
    "recurrence.monthly": "Monthly",
    "recurrence.yearly": "Yearly",
    "recurrence.lunarMonthly": "Lunar Monthly",
    "recurrence.lunarYearly": "Lunar Yearly",

    # Reminder keys
    "reminder.1hr": "1 hour before",
    "reminder.15min": "15 minutes before",
    "reminder.30min": "30 minutes before",

    # Notification keys
    "notification.cancel": "Cancel",
    "notification.enable": "Enable Notifications",
    "notification.permissionDenied.footer": "Enable notifications in Settings to receive reminders.",
    "notification.openSettings": "Open Settings",
    "notification.events.section": "Event Reminders",
    "notification.events.enable": "Event Reminders",
    "notification.defaultReminder": "Default Reminder",
    "notification.ram.section": "Rằm (15th) Reminders",
    "notification.ram.enable": "Rằm Reminders",
    "notification.ram.title": "Rằm %d",
    "notification.ram.body": "Today is Rằm (15th day of lunar month)",
    "notification.mung1.section": "Mùng 1 Reminders",
    "notification.mung1.enable": "Mùng 1 Reminders",
    "notification.mung1.title": "Mùng 1 %d",
    "notification.mung1.body": "Today is Mùng 1 (1st day of lunar month)",
    "notification.fixed.section": "Fixed Reminders",
    "notification.fixed.enable": "Fixed Reminders",
    "notification.fixed.reminderDays": "Reminder Days",
    "notification.onDay": "On day",
    "notification.time": "Time",
    "notification.daysBefore": "%d days before",
    "notification.minutesBefore": "%d minutes before",
    "notification.event.startsIn": "starts in %d",
    "notification.holiday.inDays": "Holiday in %d days",
    "notification.settings.title": "Notification Settings",
    "notification.settings.subtitle": "Configure reminders and notifications",
    "notification.permissionRequired.title": "Enable Notifications",
    "notification.permissionRequired.message": "Please enable notifications in Settings to receive reminders.",

    # Date picker keys
    "datePicker.lunarMonthYear": "Lunar Date",
    "datePicker.monthYear": "Date",
    "datePicker.selectTime": "Select Time",
    "date.today": "Today",

    # Delete confirmation keys
    "delete.confirm": "Delete",
    "delete.cancel": "Cancel",
    "delete.recurring.title": "Recurring Item",
    "delete.recurring.message": "This is a recurring item. Choose what to delete.",
    "delete.event.message": "Delete this event?",
    "delete.task.message": "Delete this task?",

    # Event keys
    "event.allDay": "All Day",

    # Item type keys
    "item.event": "Event",
    "item.task": "Task",
    "task.completed": "Completed",

    # Priority keys
    "priority.high": "High",
    "priority.medium": "Medium",
    "priority.low": "Low",
    "priority.none": "None",

    # Recurrence keys
    "recurrence.none": "None",
    "recurrence.daily": "Daily",
    "recurrence.weekly": "Weekly",
    "recurrence.monthly": "Monthly",
    "recurrence.yearly": "Yearly",
    "recurrence.lunarMonthly": "Lunar Monthly",
    "recurrence.lunarYearly": "Lunar Yearly",

    # Reminder keys
    "reminder.1hr": "1 hour before",
    "reminder.15min": "15 minutes before",
    "reminder.30min": "30 minutes before",

    # Settings keys
    "settings.builtInCalendars": "Built-in Calendars",
    "settings.myCalendars": "My Calendars",
    "settings.systemCalendar": "System Calendar",

    # Tab keys
    "tab.calendar": "Calendar",
    "tab.tasks": "Tasks",
    "tab.ai": "AI",
    "tab.settings": "Settings",
    "tab.greetings": "Greetings",
    "tab.timeline": "Timeline",

    # Task keys
    "task.all": "All",
    "task.today": "Today",
    "task.thisWeek": "This Week",
    "task.thisMonth": "This Month",
    "task.tomorrow": "Tomorrow",
    "task.reminderMinutes": "minutes before",
    "task.done": "Done",

    # Timeline keys
    "timeline.allDay": "All Day",
    "timeline.noAllDayEvents": "No all-day events",
    "timeline.today": "Today",
    "timeline.title": "Timeline",
    "timeline.search": "Search",

    # Generic UI strings that should be kept as-is (they're already English)
    "About": "About",
    "Account": "Account",
    "Add an ICS calendar URL to get started": "Add an ICS calendar URL to get started",
    "Add Calendar": "Add Calendar",
    "Add ICS Calendar": "Add ICS Calendar",
    "Add new item": "Add new item",
    "Automatically sync calendar changes": "Automatically sync calendar changes",
    "Available Calendars": "Available Calendars",
    "Background Sync": "Background Sync",
    "Background sync feature coming soon": "Background sync feature coming soon",
    "Calendar Access Required": "Calendar Access Required",
    "Calendar Name": "Calendar Name",
    "Calendar Sync": "Calendar Sync",
    "Calendar URL": "Calendar URL",
    "Calendars": "Calendars",
    "Calendars to Sync": "Calendars to Sync",
    "Cancel": "Cancel",
    "Clear search": "Clear search",
    "Connect with Google": "Connect with Google",
    "Connect your Google account to sync your Google Calendar events with this app.": "Connect your Google account to sync your Google Calendar events with this app.",
    "Connect your Microsoft account to sync your Outlook calendar events with this app.": "Connect your Microsoft account to sync your Outlook calendar events with this app.",
    "Connected": "Connected",
    "Delete": "Delete",
    "Disconnect Google Account": "Disconnect Google Account",
    "Disconnect Microsoft Account": "Disconnect Microsoft Account",
    "Done": "Done",
    "Edit": "Edit",
    "empty.addButton": "Add Item",
    "Error": "Error",
    "Event not found": "Event not found",
    "Google Calendar": "Google Calendar",
    "Google Calendars": "Google Calendars",
    "Grant Access": "Grant Access",
    "ICS Calendar": "ICS Calendar",
    "ICS Calendar subscriptions are read-only. Events are automatically synced with your calendar app.": "ICS Calendar subscriptions are read-only. Events are automatically synced with your calendar app.",
    "Import from Apple Calendar": "Import from Apple Calendar",
    "Information": "Information",
    "Last sync: %@": "Last sync: %@",
    "Last synced": "Last synced",
    "Last synced: %@": "Last synced: %@",
    "Loading...": "Loading...",
    "Mark Complete": "Mark Complete",
    "Mark Incomplete": "Mark Incomplete",
    "No Calendar Subscriptions": "No Calendar Subscriptions",
    "No calendars found": "No calendars found",
    "No Calendars Found": "No Calendars Found",
    "Not connected": "Not connected",
    "Now": "Now",
    "OK": "OK",
    "Open Settings": "Open Settings",
    "Outlook Calendar": "Outlook Calendar",
    "Outlook Calendars": "Outlook Calendars",
    "Refresh Calendars": "Refresh Calendars",
    "Search": "Search",
    "Select Calendars": "Select Calendars",
    "Settings": "Settings",
    "Sign in with Microsoft": "Sign in with Microsoft",
    "Signed in as": "Signed in as",
    "Signing in...": "Signing in...",
    "Status": "Status",
    "Subscribe to calendars": "Subscribe to calendars",
    # Weekdays
    "Sun": "Sun",
    "Mon": "Mon",
    "Tue": "Tue",
    "Wed": "Wed",
    "Thu": "Thu",
    "Fri": "Fri",
    "Sat": "Sat",
}


def escape_for_swift_string(text: str) -> str:
    """Escape text for use in Swift string literal."""
    text = text.replace('\\', '\\\\')
    text = text.replace('"', '\\"')
    return text


def replace_in_swift_file(
    file_path: Path,
    key_mappings: Dict[str, str],
    dry_run: bool = False,
    verbose: bool = False
) -> List[Tuple[str, str, int]]:
    """
    Replace localization keys with English text in a Swift file.

    Returns a list of (key, replacement, count) tuples for changes made.
    """
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    original_content = content
    changes = []

    # Sort keys by length (descending) to handle overlapping keys
    sorted_keys = sorted(key_mappings.keys(), key=len, reverse=True)

    for key in sorted_keys:
        english_text = key_mappings[key]
        escaped_key = re.escape(key)
        escaped_english = escape_for_swift_string(english_text)

        # Pattern 1: String(localized: "key") -> String(localized: "English text")
        pattern = rf'String\(localized:\s*"{escaped_key}"\)'
        replacement = f'String(localized: "{escaped_english}")'

        new_content = re.sub(pattern, replacement, content)
        if new_content != content:
            count = len(re.findall(pattern, content))
            if count > 0:
                changes.append((key, english_text, count))
                if verbose:
                    print(f"  {file_path.name}: {key} -> \"{english_text}\"")
            content = new_content

        # Pattern 2: Label("key", systemImage:) -> Label("English", systemImage:)
        # This handles direct string literals in Label() (not wrapped in String(localized:))
        pattern2 = rf'(?<=Label\()"({escaped_key})"(?=,\s*systemImage:)'
        replacement2 = f'"{escaped_english}"'

        new_content = re.sub(pattern2, replacement2, content)
        if new_content != content:
            count = len(re.findall(pattern2, content))
            if count > 0:
                changes.append((key, english_text, count))
                if verbose:
                    print(f"  {file_path.name}: Label({key} -> \"{english_text}\")")
            content = new_content

        # Pattern 3: Text("key") -> Text("English")
        # This handles direct string literals in Text() (not wrapped in String(localized:))
        pattern3 = rf'(?<=Text\()"({escaped_key})"(?=\))'
        replacement3 = f'"{escaped_english}"'

        new_content = re.sub(pattern3, replacement3, content)
        if new_content != content:
            count = len(re.findall(pattern3, content))
            if count > 0:
                changes.append((key, english_text, count))
                if verbose:
                    print(f"  {file_path.name}: Text({key} -> \"{english_text}\")")
            content = new_content

        # Pattern 4: NSLocalizedString("key", comment:) -> "English text"
        # This handles keys wrapped in NSLocalizedString() with comments
        pattern4 = rf'NSLocalizedString\(\s*"{escaped_key}"\s*,\s*comment:\s*"[^"]*"\s*\)'
        replacement4 = f'"{escaped_english}"'

        new_content = re.sub(pattern4, replacement4, content)
        if new_content != content:
            count = len(re.findall(pattern4, content))
            if count > 0:
                changes.append((key, english_text, count))
                if verbose:
                    print(f"  {file_path.name}: NSLocalizedString({key} -> \"{english_text}\")")
            content = new_content

        # Pattern 5: TextField("key", text:) -> TextField("English", text:)
        # This handles direct string literals in TextField() (not wrapped in String(localized:))
        pattern5 = rf'(?<=TextField\()"({escaped_key})"(?=,\s*text:)'
        replacement5 = f'"{escaped_english}"'

        new_content = re.sub(pattern5, replacement5, content)
        if new_content != content:
            count = len(re.findall(pattern5, content))
            if count > 0:
                changes.append((key, english_text, count))
                if verbose:
                    print(f"  {file_path.name}: TextField({key} -> \"{english_text}\")")
            content = new_content

    # Write the file if not in dry-run mode and there were changes
    if content != original_content and not dry_run:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)

    return changes


def main():
    parser = argparse.ArgumentParser(
        description='Replace localization keys with English text in Swift files'
    )
    parser.add_argument(
        '--dry-run',
        action='store_true',
        help='Show changes without writing to files'
    )
    parser.add_argument(
        '--verbose',
        '-v',
        action='store_true',
        help='Show detailed output of all replacements'
    )
    parser.add_argument(
        '--swift-dir',
        type=Path,
        default=Path('lich-plus/lich-plus'),
        help='Path to directory containing Swift files'
    )
    args = parser.parse_args()

    # Validate paths
    if not args.swift_dir.exists():
        print(f"Error: Swift directory not found: {args.swift_dir}")
        return 1

    # Show key mappings
    print(f"Using {len(KEY_TO_ENGLISH)} predefined key mappings")

    # Find all Swift files
    print("Scanning Swift files...")
    swift_files = list(args.swift_dir.rglob('*.swift'))
    print(f"Found {len(swift_files)} Swift files")

    # Process each file
    all_changes = {}
    files_with_changes = 0
    total_replacements = 0

    for swift_file in swift_files:
        # Skip test files
        if 'Test' in swift_file.name or swift_file.parent.name.endswith('Tests'):
            continue

        changes = replace_in_swift_file(
            swift_file,
            KEY_TO_ENGLISH,
            dry_run=args.dry_run,
            verbose=args.verbose
        )

        if changes:
            all_changes[str(swift_file.relative_to(args.swift_dir.parent))] = changes
            files_with_changes += 1
            total_replacements += sum(count for _, _, count in changes)

    # Print summary
    print(f"\n{'='*60}")
    if args.dry_run:
        print("DRY RUN - No files were modified")
    print(f"Processed {len(swift_files)} Swift files")
    print(f"Files with changes: {files_with_changes}")
    print(f"Total replacements: {total_replacements}")

    if files_with_changes > 0 and not args.verbose:
        print(f"\nFiles modified:")
        for file_path, changes in all_changes.items():
            print(f"  {file_path}: {sum(count for _, _, count in changes)} replacements")

    return 0


if __name__ == '__main__':
    exit(main())
