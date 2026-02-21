#!/usr/bin/env bats

load 'test_helper/common'

setup() {
    setup_rex_env
    configure_scripts_dir
    export EDITOR="echo"
}

@test "new with no args shows usage" {
    run "$REX_BIN" new
    assert_failure
    assert_output --partial "Usage: rex new"
}

@test "new creates standalone script" {
    run "$REX_BIN" new my-tool
    assert_success
    assert_output --partial "Created: $SCRIPTS_DIR/my-tool.sh"

    [[ -f "$SCRIPTS_DIR/my-tool.sh" ]]
    [[ -x "$SCRIPTS_DIR/my-tool.sh" ]]
}

@test "new standalone script has correct template" {
    run "$REX_BIN" new my-tool

    local content
    content=$(cat "$SCRIPTS_DIR/my-tool.sh")
    [[ "$content" == *"#!/bin/bash"* ]]
    [[ "$content" == *"# Description:"* ]]
}

@test "new creates topic command" {
    run "$REX_BIN" new deploy setup
    assert_success
    assert_output --partial "Created: $SCRIPTS_DIR/deploy/deploy-setup.sh"

    [[ -f "$SCRIPTS_DIR/deploy/deploy-setup.sh" ]]
    [[ -x "$SCRIPTS_DIR/deploy/deploy-setup.sh" ]]
}

@test "new creates topic subdirectory if it does not exist" {
    [[ ! -d "$SCRIPTS_DIR/newtopic" ]]
    run "$REX_BIN" new newtopic cmd
    assert_success
    [[ -d "$SCRIPTS_DIR/newtopic" ]]
}

@test "new topic command under existing topic directory" {
    mkdir -p "$SCRIPTS_DIR/deploy"
    run "$REX_BIN" new deploy rollback
    assert_success
    [[ -f "$SCRIPTS_DIR/deploy/deploy-rollback.sh" ]]
}

@test "new errors if standalone script already exists" {
    run "$REX_BIN" new my-tool
    assert_success

    run "$REX_BIN" new my-tool
    assert_failure
    assert_output --partial "already exists"
}

@test "new errors if topic script already exists" {
    run "$REX_BIN" new deploy setup
    assert_success

    run "$REX_BIN" new deploy setup
    assert_failure
    assert_output --partial "already exists"
}

@test "new opens editor with script path" {
    run "$REX_BIN" new my-tool
    assert_success
    # EDITOR=echo so the last line is the path it was called with
    assert_output --partial "$SCRIPTS_DIR/my-tool.sh"
}

@test "new with multiple dirs prompts for selection" {
    create_second_scripts_dir

    # Pipe in selection of "1" to pick first dir
    run bash -c "echo 1 | EDITOR=echo $REX_BIN new pick-me"
    assert_success
    assert_output --partial "Select a directory"
    [[ -f "$SCRIPTS_DIR/pick-me.sh" ]]
}

@test "new with multiple dirs invalid selection fails" {
    create_second_scripts_dir

    run bash -c "echo 99 | EDITOR=echo $REX_BIN new pick-me"
    assert_failure
    assert_output --partial "Invalid selection"
}

@test "new with no configured dirs shows error" {
    # Start fresh with no dirs
    export XDG_CONFIG_HOME="$TEST_TMPDIR/empty-config"
    run "$REX_BIN" new my-tool
    assert_failure
    assert_output --partial "No directories configured"
}

@test "new appears in help output" {
    run "$REX_BIN" help
    assert_success
    assert_output --partial "rex new"
}

@test "new appears in completions" {
    run "$REX_BIN" --cmplt 1
    assert_success
    assert_output --partial "new"
}
