extends Node
class_name AssetPathBugChecker

## Asset Path Bug Checker
##
## This script debugs asset file path issues across the entire project.
## It checks:
## 1. All .tscn files for broken asset references
## 2. All PNG/image files referenced in scenes
## 3. File existence at expected locations
## 4. Path resolution issues (relative vs absolute)
##
## USAGE: Run this script from the command line or add as an autoload to debug paths

## Colors for console output
const COLOR_RED = "\033[31m"
const COLOR_GREEN = "\033[32m"
const COLOR_YELLOW = "\033[33m"
const COLOR_BLUE = "\033[34m"
const COLOR_RESET = "\033[0m"

## Track all issues found
var issues_found: Array = []
var files_checked: int = 0
var broken_paths: int = 0

func _ready():
	print("\n" + "=" * 80)
	print(COLOR_BLUE + "ASSET PATH BUG CHECKER - Starting Diagnostics" + COLOR_RESET)
	print("=" * 80 + "\n")

	# Run all checks
	check_white_knight_assets()
	check_all_tscn_files()
	check_chess_piece_sprite_paths()

	# Print summary
	print_summary()

## ============================================================================
## CHECK 1: White Knight Specific Assets
## ============================================================================
func check_white_knight_assets():
	print(COLOR_BLUE + "\n[CHECK 1] White Knight Asset Files" + COLOR_RESET)
	print("-" * 80)

	var character_id = 4
	var base_path = "res://assets/characters/character_%d/pieces/held/white_knight/" % character_id

	var expected_files = [
		"scene/hovereffect_scyka.tscn",
		"eye.png",
		"eye.png.import",
		"ghost flip.png",
		"ghost flip.png.import",
		"ghost.png",
		"ghost.png.import",
		"icon.svg",
		"icon.svg.import",
		"purple piece.png",
		"purple piece.png.import"
	]

	print("Base path: %s" % base_path)
	print("\nChecking files:")

	for file in expected_files:
		var full_path = base_path + file
		files_checked += 1

		if FileAccess.file_exists(full_path):
			print(COLOR_GREEN + "  ✓ FOUND: %s" % file + COLOR_RESET)
		else:
			print(COLOR_RED + "  ✗ MISSING: %s" % file + COLOR_RESET)
			issues_found.append({
				"type": "missing_file",
				"path": full_path,
				"context": "White Knight assets"
			})
			broken_paths += 1

## ============================================================================
## CHECK 2: Scan All .tscn Files for Broken Paths
## ============================================================================
func check_all_tscn_files():
	print(COLOR_BLUE + "\n[CHECK 2] Scanning .tscn Files for Broken Paths" + COLOR_RESET)
	print("-" * 80)

	var tscn_files = find_all_tscn_files()
	print("Found %d .tscn files to check\n" % tscn_files.size())

	for tscn_path in tscn_files:
		check_tscn_file_paths(tscn_path)

func find_all_tscn_files() -> Array:
	"""Recursively find all .tscn files in the project"""
	var result: Array = []
	scan_directory_for_tscn("res://", result)
	return result

func scan_directory_for_tscn(path: String, result: Array):
	"""Recursive directory scanner"""
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				# Skip hidden directories and .godot folder
				if not file_name.begins_with(".") and file_name != "addons":
					scan_directory_for_tscn(path + file_name + "/", result)
			else:
				if file_name.ends_with(".tscn"):
					result.append(path + file_name)
			file_name = dir.get_next()

func check_tscn_file_paths(tscn_path: String):
	"""Check all resource paths in a .tscn file"""
	var file = FileAccess.open(tscn_path, FileAccess.READ)
	if not file:
		print(COLOR_RED + "  ✗ Cannot read: %s" % tscn_path + COLOR_RESET)
		return

	files_checked += 1
	var line_number = 0
	var has_issues = false

	while not file.eof_reached():
		var line = file.get_line()
		line_number += 1

		# Check for ext_resource paths
		if "path=" in line:
			var path_match = extract_path_from_line(line)
			if path_match != "":
				if not check_resource_path(path_match, tscn_path, line_number):
					has_issues = true

	if has_issues:
		broken_paths += 1
	else:
		print(COLOR_GREEN + "  ✓ OK: %s" % tscn_path + COLOR_RESET)

func extract_path_from_line(line: String) -> String:
	"""Extract the path from a line containing path=\"...\""""
	var start = line.find('path="')
	if start == -1:
		return ""
	start += 6  # Length of 'path="'
	var end = line.find('"', start)
	if end == -1:
		return ""
	return line.substr(start, end - start)

func check_resource_path(resource_path: String, tscn_path: String, line_number: int) -> bool:
	"""Check if a resource path exists and is valid"""

	# Check if path is relative (doesn't start with res://)
	if not resource_path.begins_with("res://"):
		print(COLOR_RED + "  ✗ RELATIVE PATH: %s" % tscn_path + COLOR_RESET)
		print(COLOR_YELLOW + "    Line %d: %s" % [line_number, resource_path] + COLOR_RESET)
		print(COLOR_YELLOW + "    This should be an absolute path starting with res://" + COLOR_RESET)

		# Try to guess the correct path
		var tscn_dir = tscn_path.get_base_dir()
		var potential_path = tscn_dir + "/" + resource_path
		print(COLOR_BLUE + "    Potential fix: %s" % potential_path + COLOR_RESET)

		issues_found.append({
			"type": "relative_path",
			"file": tscn_path,
			"line": line_number,
			"path": resource_path,
			"suggested_fix": potential_path
		})
		return false

	# Check if file exists
	if not FileAccess.file_exists(resource_path):
		print(COLOR_RED + "  ✗ BROKEN PATH: %s" % tscn_path + COLOR_RESET)
		print(COLOR_YELLOW + "    Line %d: %s (FILE NOT FOUND)" % [line_number, resource_path] + COLOR_RESET)

		issues_found.append({
			"type": "broken_path",
			"file": tscn_path,
			"line": line_number,
			"path": resource_path
		})
		return false

	return true

## ============================================================================
## CHECK 3: Chess Piece Sprite Path Resolution
## ============================================================================
func check_chess_piece_sprite_paths():
	print(COLOR_BLUE + "\n[CHECK 3] Chess Piece Sprite Path Resolution" + COLOR_RESET)
	print("-" * 80)

	# Test the find_piece_scene function for white_knight
	var piece_type = "knight"
	var character_id = 4
	var is_held = true

	print("\nTesting ChessPieceSprite.find_piece_scene():")
	print("  piece_type: %s" % piece_type)
	print("  character_id: %d" % character_id)
	print("  is_held: %s" % is_held)

	var scene_path = ChessPieceSprite.find_piece_scene(piece_type, character_id, is_held)

	if scene_path != "":
		print(COLOR_GREEN + "  ✓ Found scene: %s" % scene_path + COLOR_RESET)

		# Now check if that scene has valid paths
		print("\n  Checking if scene can be loaded...")
		var scene = load(scene_path)
		if scene:
			print(COLOR_GREEN + "    ✓ Scene loads successfully" + COLOR_RESET)

			# Try to instantiate it
			print("  Attempting to instantiate scene...")
			var instance = scene.instantiate()
			if instance:
				print(COLOR_GREEN + "    ✓ Scene instantiated successfully" + COLOR_RESET)
				instance.queue_free()
			else:
				print(COLOR_RED + "    ✗ Failed to instantiate scene" + COLOR_RESET)
				issues_found.append({
					"type": "instantiation_failed",
					"path": scene_path
				})
		else:
			print(COLOR_RED + "    ✗ Failed to load scene" + COLOR_RESET)
			issues_found.append({
				"type": "scene_load_failed",
				"path": scene_path
			})
	else:
		print(COLOR_RED + "  ✗ No scene found for white_knight" + COLOR_RESET)
		issues_found.append({
			"type": "scene_not_found",
			"piece_type": piece_type,
			"character_id": character_id,
			"is_held": is_held
		})

## ============================================================================
## SUMMARY AND REPORTING
## ============================================================================
func print_summary():
	print("\n" + "=" * 80)
	print(COLOR_BLUE + "BUG CHECKER SUMMARY" + COLOR_RESET)
	print("=" * 80)

	print("\nStatistics:")
	print("  Files checked: %d" % files_checked)
	print("  Issues found: %d" % issues_found.size())
	print("  Broken paths: %d" % broken_paths)

	if issues_found.size() == 0:
		print(COLOR_GREEN + "\n✓ All checks passed! No issues found." + COLOR_RESET)
	else:
		print(COLOR_RED + "\n✗ Issues detected:" + COLOR_RESET)

		# Group issues by type
		var by_type = {}
		for issue in issues_found:
			var type = issue.get("type", "unknown")
			if not by_type.has(type):
				by_type[type] = []
			by_type[type].append(issue)

		for type in by_type.keys():
			print(COLOR_YELLOW + "\n  %s: %d issues" % [type.to_upper(), by_type[type].size()] + COLOR_RESET)
			for issue in by_type[type]:
				print("    - %s" % JSON.stringify(issue, "  "))

	print("\n" + "=" * 80)

	# Write detailed report to file
	write_report_to_file()

func write_report_to_file():
	"""Write a detailed report to a JSON file"""
	var report = {
		"timestamp": Time.get_datetime_string_from_system(),
		"files_checked": files_checked,
		"issues_count": issues_found.size(),
		"broken_paths": broken_paths,
		"issues": issues_found
	}

	var file = FileAccess.open("res://asset_path_bug_report.json", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(report, "  "))
		print(COLOR_BLUE + "\nDetailed report saved to: res://asset_path_bug_report.json" + COLOR_RESET)
	else:
		print(COLOR_RED + "\nFailed to write report file" + COLOR_RESET)

## ============================================================================
## STANDALONE EXECUTION
## ============================================================================

## Call this function to run the checker from code
static func run_check():
	var checker = AssetPathBugChecker.new()
	checker._ready()
	return checker.issues_found
