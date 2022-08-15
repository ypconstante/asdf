#!/usr/bin/env bats

load test_helpers

setup() {
  cd $(dirname "$BATS_TEST_DIRNAME")
  mkdir -p $HOME/.config/elvish/lib
  cp ./asdf.elv $HOME/.config/elvish/lib/asdftest.elv
}

teardown() {
  rm $HOME/.config/elvish/lib/asdftest.elv
}

cleaned_path() {
  echo $PATH | tr ':' '\n' | grep -v "asdf" | tr '\n' ' '
}

@test "exports ASDF_DIR" {
  run elvish -norc -c "
    unset-env ASDF_DIR
    set paths = [$(cleaned_path)]
    use asdftest _asdf; var asdf~ = \$_asdf:asdf~
    echo \$E:ASDF_DIR
  "

  [ "$status" -eq 0 ]
  [ "$output" = "$HOME/.asdf" ]
}

@test "retains ASDF_DIR" {
  run elvish -norc -c "
    set-env ASDF_DIR "/path/to/asdf"
    set paths = [$(cleaned_path)]
    use asdftest _asdf; var asdf~ = \$_asdf:asdf~
    echo \$E:ASDF_DIR
  "

  [ "$status" -eq 0 ]
  [ "$output" = "/path/to/asdf" ]
}

@test "retains ASDF_DATA_DIR" {
  run elvish -norc -c "
    set-env ASDF_DATA_DIR "/path/to/asdf-data"
    set paths = [$(cleaned_path)]
    use asdftest _asdf; var asdf~ = \$_asdf:asdf~
    echo \$E:ASDF_DATA_DIR
  "

  [ "$status" -eq 0 ]
  [ "$output" = "/path/to/asdf-data" ]
}

@test "adds asdf dirs to PATH" {
  run elvish -norc -c "
    unset-env ASDF_DIR
    set paths = [$(cleaned_path)]
    use asdftest _asdf; var asdf~ = \$_asdf:asdf~
    echo \$E:PATH
  "

  [ "$status" -eq 0 ]
  [[ "$output" =~ "asdf" ]]
}

@test "defines the _asdf namespace" {
  run elvish -norc -c "
    unset-env ASDF_DIR
    set paths = [$(cleaned_path)]
    use asdftest _asdf; var asdf~ = \$_asdf:asdf~
    pprint \$_asdf:
  "

  [ "$status" -eq 0 ]
  [[ "$output" =~ "<ns " ]]
}

@test "does not add paths to PATH more than once" {
  run elvish -norc -c "
    unset-env ASDF_DIR
    set paths = [$(cleaned_path)]

    use asdftest _asdf; var asdf~ = \$_asdf:asdf~
    use asdftest _asdf; var asdf~ = \$_asdf:asdf~
    echo \$E:PATH
  "

  [ "$status" -eq 0 ]
  repeated_paths=$(echo "$output" | tr ':' '\n' | grep "asdf" | sort | uniq -d)
  [ "$repeated_paths" = "" ]
}

@test "defines the asdf function" {
  run elvish -norc -c "
    unset-env ASDF_DIR
    set paths = [$(cleaned_path)]
    use asdftest _asdf; var asdf~ = \$_asdf:asdf~
    pprint \$asdf~
  "

  [ "$status" -eq 0 ]
  [[ "$output" =~ "<closure " ]]
}

@test "function calls asdf command" {
  run elvish -norc -c "
    set-env ASDF_DIR $(pwd)
    set paths = [$(cleaned_path)]
    use asdftest _asdf; var asdf~ = \$_asdf:asdf~
    asdf info
  "

  [ "$status" -eq 0 ]
  [[ "$output" =~ "ASDF INSTALLED PLUGINS:" ]]
}
