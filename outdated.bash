#!/usr/bin/env bash
# pass outdated - Password Store Extension (https://www.passwordstore.org/)
# Copyright (C) 2021 Zsolt Kozaroczy <kiskoza@gmail.com>.
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.

readonly VERSION="0.1"
OUTDATED_DIR="${PASSWORD_STORE_DIR:-$HOME/.password-store}"

sub_version() {
  echo $VERSION
}

sub_help(){
  echo "Usage: pass outdated [<subcommand>]"
  echo ""
  echo "Gives back outdated passwords that need to be changed"
  echo ""
  echo "Subcommands:"
  echo "    ignore add <file>  Add entry to ignored list"
  echo "    ignore remove      remove entry from ignored list"
  echo "    ignore             Show ignored list"
  echo "    refresh            Regenerates cached outdated list"
  echo "    help               Show this help message"
  echo ""
}

sub_ignore(){
  case "$2" in
    "add")
      sub_ignore_add $@
      ;;
    "remove")
      sub_ignore_remove $@
      ;;
    "")
      sub_ignore_show
      ;;
    *)
      sub_help
      ;;
  esac
}

sub_ignore_add(){
  touch "$OUTDATED_DIR/.ignore-outdated"

  echo "$3.gpg" |\
    sort -m "$OUTDATED_DIR/.ignore-outdated" - |\
    uniq > "$OUTDATED_DIR/.ignore-outdated.new" \
    && mv "$OUTDATED_DIR/.ignore-outdated.new" "$OUTDATED_DIR/.ignore-outdated"

  sub_refresh
  sub_ignore_show
}

sub_ignore_remove(){
  touch "$OUTDATED_DIR/.ignore-outdated"

  comm -23 "$OUTDATED_DIR/.ignore-outdated" <(echo "$3.gpg") \
  > "$OUTDATED_DIR/.ignore-outdated.new" \
  && mv "$OUTDATED_DIR/.ignore-outdated.new" "$OUTDATED_DIR/.ignore-outdated"

  sub_refresh
  sub_ignore_show
}

sub_ignore_show(){
  cat "$OUTDATED_DIR/.ignore-outdated"
}

sub_refresh(){
  touch "$OUTDATED_DIR/.outdated"
  touch "$OUTDATED_DIR/.ignore-outdated"

  comm -13 "$OUTDATED_DIR/.ignore-outdated" <(
      pass git ls-files |\
      grep '/' --color=NEVER |\
      xargs -I'{}' pass git log -n 1 --format="%as {}" -- '{}' |\
      awk -v date="$(date --date='-12 month' +'%Y-%m-%d')" '{ if ($1 <= date) { print $2 } }' |\
      sort) \
      > "$OUTDATED_DIR/.outdated.new" \
      && mv "$OUTDATED_DIR/.outdated.new" "$OUTDATED_DIR/.outdated"
}

sub_show(){
  touch -a "$OUTDATED_DIR/.outdated"

  if [[ "$(date +'%Y-%m-%d')" > "$(stat -c %y "$OUTDATED_DIR/.outdated" | awk '{ print $1 }')" ]]
  then
    sub_refresh > /dev/null 2>&1 &
  fi

  cat "$OUTDATED_DIR/.outdated"
}

case "$1" in
  "ignore")
    sub_ignore "$@"
    ;;
  "refresh")
    sub_refresh "$@"
    ;;
  "version")
    sub_version "$@"
    ;;
  "help")
    sub_help "$@"
    ;;
  "")
    sub_show "$@"
    ;;
  *)
    sub_help "$@"
    ;;
esac
exit 0
