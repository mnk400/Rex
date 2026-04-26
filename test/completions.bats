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

# ── Subtopic completion tests ──────────────────────��──────────────────────────

@test "position 3 completions for subtopic show its commands" {
    set_max_depth 2
    create_subtopic_script "nas/backup" "backup-create.sh" "Create"
    create_subtopic_script "nas/backup" "backup-restore.sh" "Restore"

    run "$REX_BIN" --cmplt 3 rex nas backup
    assert_success
    assert_output --partial "create"
    assert_output --partial "restore"
    assert_output --partial "help"
}

@test "position 2 completions show subtopics when depth allows" {
    set_max_depth 2
    create_topic_script "nas" "nas-mount.sh" "Mount"
    create_subtopic_script "nas/backup" "backup-create.sh" "Create"

    run "$REX_BIN" --cmplt 2 rex nas
    assert_success
    assert_output --partial "mount"
    assert_output --partial "backup"
}

@test "position 2 completions do not show subtopics at default depth" {
    create_topic_script "nas" "nas-mount.sh" "Mount"
    create_subtopic_script "nas/backup" "backup-create.sh" "Create"

    run "$REX_BIN" --cmplt 2 rex nas
    assert_success
    assert_output --partial "mount"
    refute_output --partial "backup"
}
