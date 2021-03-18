#!/usr/bin/env bash
#
# Description: Bash completion file for krackctl.
#    Homepage: https://git.sr.ht/~krathalan/krack
#
# Copyright (C) 2020 krathalan
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

# Source a lot of common (between krack scripts) variables
# shellcheck disable=SC1091
source /usr/lib/krack/common

#######################################
# Converts a string to lowercase.
# Globals:
#   none
# Arguments:
#   $1: string to convert
# Returns:
#   none
#######################################
_to_lowercase() {
  printf "%s\n" "${1,,}"
}

#######################################
# Sets the appropriate $COMPREPLY for the user's input.
# Globals:
#   COMP_WORDS
#   COMPREPLY
#   XDG_CONFIG_HOME
#   HOME
# Arguments:
#   none
# Returns:
#   none
#######################################
_krackctl_completions()
{
  # COMP_WORDS[0] = krackctl
  # COMP_WORDS[1] = cmd (e.g. w, c, etc.)

  if [[ "${#COMP_WORDS[@]}" -lt "3" ]]; then
    mapfile -t COMPREPLY <<< "$(compgen -W "awaken build-all clean-logs create-chroot failed-builds request-build pending-builds cancel-all-requests status watch-status" "${COMP_WORDS[1]}")"
  elif [[ "${COMP_WORDS[1]}" == "request-build" ]] && [[ "${#COMP_WORDS[@]}" == "3" ]]; then
    # Return list of all packages in master build dir
    all_packages=("${MASTER_BUILD_DIR}"/*)

    for package in "${MASTER_BUILD_DIR}"/*; do
      # Remove preceding "$MASTER_BUILD_DIR" in completions
      all_packages+=("${package##*/}")
    done

    mapfile -t COMPREPLY <<< "$(compgen -W "${all_packages[*]}" "${COMP_WORDS[2]}")"
  fi
}

complete -F _krackctl_completions krackctl
