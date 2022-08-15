#!/usr/bin/env bats

load test_helpers

setup() {
  cd $(dirname "$BATS_TEST_DIRNAME")
}

cleaned_path() {
  echo $PATH | tr ':' '\n' | grep -v "asdf" | tr '\n' ' '
}

@test "exports ASDF_DIR" {
  run fish -c "
    set -e asdf
    set -e ASDF_DIR
    set -e ASDF_DATA_DIR
    set PATH $(cleaned_path)

    . asdf.fish
    echo \$ASDF_DIR
  "

  [ "$status" -eq 0 ]
  [ "$output" != "" ]
}

@test "adds asdf dirs to PATH" {
  run fish -c "
    set -e asdf
    set -e ASDF_DIR
    set -e ASDF_DATA_DIR
    set PATH $(cleaned_path)

    . (pwd)/asdf.fish  # if the full path is not passed, status -f will return the relative path
    echo \$PATH
 "

  [ "$status" -eq 0 ]
  [[ "$output" =~ "asdf" ]]
}

@test "does not add paths to PATH more than once" {
  run fish -c "
    set -e asdf
    set -e ASDF_DIR
    set -e ASDF_DATA_DIR
    set PATH $(cleaned_path)

    . asdf.fish
    . asdf.fish
    echo \$PATH
  "

  [ "$status" -eq 0 ]
  repeated_paths=$(echo "$output" | tr ' ' '\n' | grep "asdf" | sort | uniq -d)
  [ "$repeated_paths" = "" ]
}

@test "defines the asdf function" {
  run fish -c "
    set -e asdf
    set -e ASDF_DIR
    set PATH $(cleaned_path)

    . asdf.fish
    type asdf
  "

  [ "$status" -eq 0 ]
  [[ "$output" =~ "is a function" ]]
}

@test "function calls asdf command" {
  run fish -c "
    set -e asdf
    set -x ASDF_DIR $(pwd)
    set PATH $(cleaned_path)

    . asdf.fish
    asdf info
  "

  [ "$status" -eq 0 ]
  [[ "$output" =~ "ASDF INSTALLED PLUGINS:" ]]
}
