#!/usr/bin/env bats

load 'test_helper/common'

setup() {
    setup_rex_env
    configure_scripts_dir
}

@test "position 1 completions include built-in commands" {
    run "$REX_BIN" --cmplt 1 rex
    assert_success
    assert_output --partial "help"
    assert_output --partial "version"
    assert_output --partial "list"
    assert_output --partial "dirs"
    assert_output --partial "edit"
    assert_output --partial "completions"
}

@test "position 1 completions include topic names" {
    create_topic_script "widgets" "widgets-spin.sh" "Spin"

    run "$REX_BIN" --cmplt 1 rex
    assert_success
    assert_output --partial "widgets"
}

@test "position 1 completions include standalone commands" {
    create_standalone_script "fizzbuzz.sh" "Run fizzbuzz"

    run "$REX_BIN" --cmplt 1 rex
    assert_success
    assert_output --partial "fizzbuzz"
}

@test "position 2 completions for 'dirs' show subcommands" {
    run "$REX_BIN" --cmplt 2 rex dirs
    assert_success
    assert_output --partial "add"
    assert_output --partial "remove"
    assert_output --partial "list"
}

@test "position 2 completions for 'completions' show shells" {
    run "$REX_BIN" --cmplt 2 rex completions
    assert_success
    assert_output --partial "bash"
    assert_output --partial "zsh"
}

@test "position 2 completions for a topic show its commands" {
    create_topic_script "widgets" "widgets-spin.sh" "Spin"
    create_topic_script "widgets" "widgets-flip.sh" "Flip"

    run "$REX_BIN" --cmplt 2 rex widgets
    assert_success
    assert_output --partial "spin"
    assert_output --partial "flip"
    assert_output --partial "help"
    assert_output --partial "list"
}

@test "completions bash generates valid bash completion script" {
    run "$REX_BIN" completions bash
    assert_success
    assert_output --partial "complete -F"
    assert_output --partial "_rex_bash_completions"
}

@test "completions zsh generates valid zsh completion script" {
    run "$REX_BIN" completions zsh
    assert_success
    assert_output --partial "compdef"
    assert_output --partial "_rex_zsh_completions"
}

@test "completions with no shell shows usage" {
    run "$REX_BIN" completions
    assert_success
    assert_output --partial "Usage: rex completions"
}
