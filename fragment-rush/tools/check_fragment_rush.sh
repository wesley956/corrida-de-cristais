#!/usr/bin/env bash
set -e

echo "== Fragment Rush checkpoint =="
echo
echo "== Branch =="
git branch --show-current
echo
echo "== Git status =="
git status --short
echo
echo "== Recent commits =="
git log --oneline --decorate -8
echo
echo "== Godot headless load test =="
if [ -x "./Godot_v4.2.2-stable_linux.x86_64" ]; then
  ./Godot_v4.2.2-stable_linux.x86_64 --headless --path . --quit || true
else
  echo "Godot binary not found or not executable."
fi
echo
echo "== Script line counts =="
wc -l scripts/Main.gd scripts/core/*.gd scripts/player/PlayerController.gd scripts/autoloads/*.gd 2>/dev/null || true
echo
echo "== Core systems =="
find scripts -maxdepth 3 -type f | sort
echo
echo "== Project mobile settings =="
grep -n "config/name\|run/main_scene\|viewport_width\|viewport_height\|orientation\|rendering_method\|autoload" project.godot || true
echo
echo "== Export presets =="
if [ -f export_presets.cfg ]; then
  grep -n "name=\|platform=\|export_path=" export_presets.cfg || true
else
  echo "export_presets.cfg not found"
fi
echo
echo "== Done =="
