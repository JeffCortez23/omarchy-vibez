#!/usr/bin/env bash
set -u

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

missing=0

check_cmd() {
  local cmd="$1"
  local required="${2:-required}"

  if command -v "$cmd" >/dev/null 2>&1; then
    printf "${GREEN}✓ ok${NC}   %s\n" "$cmd"
  else
    if [ "$required" = "required" ]; then
      printf "${RED}✗ miss${NC} %s (%s)\n" "$cmd" "$required"
      missing=1
    else
      printf "${YELLOW}! warn${NC} %s (%s)\n" "$cmd" "$required"
    fi
  fi
}

printf "${BOLD}Omarchy Vibez Prerequisite Check${NC}\n\n"

check_cmd omarchy required
check_cmd omarchy-shell required
check_cmd vibez required
check_cmd tmux recommended

if command -v ghostty >/dev/null 2>&1 ||
   command -v alacritty >/dev/null 2>&1 ||
   command -v kitty >/dev/null 2>&1 ||
   command -v foot >/dev/null 2>&1 ||
   command -v xdg-terminal-exec >/dev/null 2>&1; then
  printf "${GREEN}✓ ok${NC}   terminal launcher (ghostty, alacritty, kitty, foot, or xdg-terminal-exec)\n"
else
  printf "${RED}✗ miss${NC} terminal launcher (ghostty, alacritty, kitty, foot, or xdg-terminal-exec)\n"
  missing=1
fi

if busctl --user list 2>/dev/null | grep -qi 'vibez'; then
  printf "${GREEN}✓ ok${NC}   vibez MPRIS player is active\n"
else
  printf "${BLUE}ℹ info${NC} vibez MPRIS player is not currently active; launch vibez to play tracks\n"
fi

printf "\n"
if [ "$missing" -eq 0 ]; then
  printf "${GREEN}${BOLD}All essential prerequisites met!${NC}\n"
else
  printf "${RED}${BOLD}Some required tools are missing. Please install them above.${NC}\n"
fi

exit "$missing"

