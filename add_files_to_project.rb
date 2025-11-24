#!/usr/bin/env ruby
# Script to add star system files to Xcode project

require 'xcodeproj'

project_path = 'lich-plus.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Get the main target
target = project.targets.first

# Find the Calendar group
calendar_group = project.main_group.find_subpath('lich-plus/Features/Calendar', true)

# Find or create Models group
models_group = calendar_group.find_subpath('Models', true) || calendar_group.new_group('Models')

# Find or create Data group
data_group = calendar_group.find_subpath('Data', true) || calendar_group.new_group('Data')

# Find or create Utilities group
utilities_group = calendar_group.find_subpath('Utilities', true) || calendar_group.new_group('Utilities')

# Add StarModels.swift
star_models_path = 'lich-plus/Features/Calendar/Models/StarModels.swift'
if File.exist?(star_models_path)
  star_models_ref = models_group.new_reference(star_models_path)
  target.add_file_references([star_models_ref])
  puts "✅ Added StarModels.swift to project"
else
  puts "❌ StarModels.swift not found at #{star_models_path}"
end

# Add StarCalculator.swift
star_calc_path = 'lich-plus/Features/Calendar/Utilities/StarCalculator.swift'
if File.exist?(star_calc_path)
  star_calc_ref = utilities_group.new_reference(star_calc_path)
  target.add_file_references([star_calc_ref])
  puts "✅ Added StarCalculator.swift to project"
else
  puts "❌ StarCalculator.swift not found at #{star_calc_path}"
end

# Add Month9StarData.swift
month9_path = 'lich-plus/Features/Calendar/Data/Month9StarData.swift'
if File.exist?(month9_path)
  month9_ref = data_group.new_reference(month9_path)
  target.add_file_references([month9_ref])
  puts "✅ Added Month9StarData.swift to project"
else
  puts "❌ Month9StarData.swift not found at #{month9_path}"
end

# Save the project
project.save
puts "✅ Project saved successfully!"
