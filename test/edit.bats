#!/usr/bin/env bats

load 'test_helper/common'

setup() {
    setup_rex_env
    configure_scripts_dir
    # Use 'echo' as the editor so we can capture the path it receives
    export EDITOR="echo"
}

@test "edit with no args shows usage" {
    run "$REX_BIN" edit
    assert_failure
    assert_output --partial "Usage: rex edit"
}

@test "edit standalone command opens correct script" {
    local script_path
    script_path=$(create_standalone_script "fizzbuzz.sh" "Run fizzbuzz")

    run "$REX_BIN" edit fizzbuzz
    assert_success
    assert_output --partial "$script_path"
}

@test "edit topic command opens correct script" {
    local script_path
    script_path=$(create_topic_script "widgets" "widgets-spin.sh" "Spin a widget")

    run "$REX_BIN" edit widgets spin
    assert_success
    assert_output --partial "$script_path"
}

@test "edit topic with no command shows usage" {
    create_topic_script "widgets" "widgets-spin.sh" "Spin a widget"

    run "$REX_BIN" edit widgets
    assert_failure
    assert_output --partial "Usage: rex edit <topic> [subtopic...] <command>"
}

@test "edit unknown standalone shows error" {
    run "$REX_BIN" edit nonexistent
    assert_failure
    assert_output --partial "Unknown command"
}

@test "edit unknown topic command shows error" {
    create_topic_script "widgets" "widgets-spin.sh" "Spin a widget"

    run "$REX_BIN" edit widgets nonexistent
    assert_failure
    assert_output --partial "Unknown widgets command"
}

@test "edit empty directory does not require topic command syntax" {
    mkdir -p "$SCRIPTS_DIR/emptytopic"

    run "$REX_BIN" edit emptytopic
    assert_failure
    assert_output --partial "Unknown command: emptytopic"
}

# ── Subtopic edit tests ──────────────────────────────────────��───────────────

@test "edit subtopic command opens correct script" {
    set_max_depth 2
    local script_path
    script_path=$(create_subtopic_script "nas/backup" "backup-create.sh" "Create backup")

    run "$REX_BIN" edit nas backup create
    assert_success
    assert_output --partial "$script_path"
}

@test "edit subtopic with no command shows usage" {
    set_max_depth 2
    create_subtopic_script "nas/backup" "backup-create.sh" "Create backup"

    run "$REX_BIN" edit nas backup
    assert_failure
    assert_output --partial "Usage: rex edit <topic> [subtopic...] <command>"
}

@test "edit unknown subtopic command shows error" {
    set_max_depth 2
    create_subtopic_script "nas/backup" "backup-create.sh" "Create backup"

    run "$REX_BIN" edit nas backup nonexistent
    assert_failure
    assert_output --partial "Unknown backup command"
}
