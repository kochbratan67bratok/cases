#!/usr/bin/env python3
"""Apply the repository's reproducible visual theme patch to the upstream submodule."""
from pathlib import Path
import sys

if len(sys.argv) != 2:
    raise SystemExit("usage: apply_case_lab_theme.py <path-to-CS2-Simulator>")

root = Path(sys.argv[1]).resolve()
main_file = root / "lib" / "main.dart"
home_file = root / "lib" / "presentation" / "screens" / "home_screen.dart"

for path in (main_file, home_file):
    if not path.is_file():
        raise SystemExit(f"expected upstream file not found: {path}")

main = main_file.read_text(encoding="utf-8")
old_theme = "theme: ThemeData.dark(),"
if main.count(old_theme) != 2:
    raise SystemExit(f"expected two default themes in {main_file}, found {main.count(old_theme)}")
if "_caseLabTheme()" in main:
    raise SystemExit("theme patch appears to have already been applied")

main = main.replace(old_theme, "theme: _caseLabTheme(),")
theme_fn = """
ThemeData _caseLabTheme() {
  return ThemeData.dark(useMaterial3: true).copyWith(
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF55D6BE),
      secondary: Color(0xFF8A7DFF),
      surface: Color(0xFF172130),
      error: Color(0xFFFF647C),
    ),
    scaffoldBackgroundColor: const Color(0xFF080C13),
    cardColor: const Color(0xE91A2432),
    dividerColor: Colors.white12,
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xF20D121B),
      foregroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFF55D6BE),
        foregroundColor: const Color(0xFF07110F),
      ),
    ),
  );
}
"""
main_file.write_text(main.rstrip() + "\n\n" + theme_fn.lstrip(), encoding="utf-8")

home = home_file.read_text(encoding="utf-8")
old_body = "      body: LayoutBuilder(\n"
new_body = """      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF080C13),
              Color(0xFF111A28),
              Color(0xFF0A0E16),
            ],
          ),
        ),
        child: LayoutBuilder(
"""
if home.count(old_body) != 1:
    raise SystemExit(f"expected one home body anchor in {home_file}, found {home.count(old_body)}")
home = home.replace(old_body, new_body, 1)
old_end = """          );
        },
      ),
    );
  }

  void _push(BuildContext context, Widget screen) {
"""
if home.count(old_end) != 1:
    raise SystemExit("home build end anchor not found")
home = home.replace(old_end, """          );
        },
      )),
    );
  }

  void _push(BuildContext context, Widget screen) {
""", 1)
home_file.write_text(home, encoding="utf-8")
print("Applied Case Lab colors and layered background to upstream Flutter sources.")
