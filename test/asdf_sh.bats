#!/usr/bin/env bats

load test_helpers

setup() {
  cd $(dirname "$BATS_TEST_DIRNAME")
}

cleaned_path() {
  echo $PATH | tr ':' '\n' | grep -v "asdf" | tr '\n' ':'
}

@test "exports ASDF_DIR" {
  run bash -c "
    unset -f asdf
    unset ASDF_DIR
    PATH=$(cleaned_path)

    . asdf.sh
    echo \$ASDF_DIR
  "

  [ "$status" -eq 0 ]
  [ "$output" != "" ]
}

@test "does not error if nounset is enabled" {
  run bash -c "
    unset -f asdf
    unset ASDF_DIR
    PATH=$(cleaned_path)
    set -o nounset

    . asdf.sh
    echo \$ASDF_DIR
  "

  [ "$status" -eq 0 ]
  [ "$output" != "" ]
}

@test "adds asdf dirs to PATH" {
  run bash -c "
    unset -f asdf
    unset ASDF_DIR
    PATH=$(cleaned_path)

    . asdf.sh
    echo \$PATH
  "

  [ "$status" -eq 0 ]
  [[ "$output" =~ "asdf" ]]
}

@test "does not add paths to PATH more than once" {
  run bash -c "
    unset -f asdf
    unset ASDF_DIR
    PATH=$(cleaned_path)

    . asdf.sh
    . asdf.sh
    echo \$PATH
  "

  [ "$status" -eq 0 ]
  repeated_paths=$(echo "$output" | tr ':' '\n' | grep "asdf" | sort | uniq -d)
  [ "$repeated_paths" = "" ]
}

@test "defines the asdf function" {
  run bash -c "
    unset -f asdf
    unset ASDF_DIR
    PATH=$(cleaned_path)

    . asdf.sh
    type asdf
  "

  [ "$status" -eq 0 ]
  [[ "$output" =~ "is a function" ]]
}

@test "function calls asdf command" {
  run bash -c "
    unset -f asdf
    ASDF_DIR=$(pwd)
    PATH=$(cleaned_path)

    . asdf.sh
    asdf info
  "

  [ "$status" -eq 0 ]
  [[ "$output" =~ "ASDF INSTALLED PLUGINS:" ]]
}
