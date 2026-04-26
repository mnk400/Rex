#!/usr/bin/env bats

load 'test_helper/common'

setup() {
    setup_rex_env
}

@test "no args shows help" {
    run "$REX_BIN"
    assert_success
    assert_output --partial "rex v"
    assert_output --partial "Usage:"
}

@test "help shows help" {
    run "$REX_BIN" help
    assert_success
    assert_output --partial "Usage: rex"
}

@test "--help shows help" {
    run "$REX_BIN" --help
    assert_success
    assert_output --partial "Usage: rex"
}

@test "-h shows help" {
    run "$REX_BIN" -h
    assert_success
    assert_output --partial "Usage: rex"
}

@test "version shows version" {
    run "$REX_BIN" version
    assert_success
    assert_output --partial "rex v"
}

@test "--version shows version" {
    run "$REX_BIN" --version
    assert_success
    assert_output --partial "rex v"
}

@test "-v shows version" {
    run "$REX_BIN" -v
    assert_success
    assert_output --partial "rex v"
}

@test "help shows no-dirs message when none configured" {
    run "$REX_BIN" help
    assert_success
    assert_output --partial "No directories configured"
}

@test "help shows topic count when directories configured" {
    configure_scripts_dir
    create_topic_script "widgets" "widgets-spin.sh" "Spin a widget"

    run "$REX_BIN" help
    assert_success
    assert_output --partial "Topics:"
    assert_output --partial "widgets"
}

@test "help shows standalone count when available" {
    configure_scripts_dir
    create_standalone_script "fizzbuzz.sh" "Run fizzbuzz"

    run "$REX_BIN" help
    assert_success
    assert_output --partial "Standalone commands:"
}

@test "list shows all commands" {
    configure_scripts_dir
    create_topic_script "widgets" "widgets-spin.sh" "Spin a widget"
    create_standalone_script "fizzbuzz.sh" "Run fizzbuzz"

    run "$REX_BIN" list
    assert_success
    assert_output --partial "[widgets]"
    assert_output --partial "spin"
    assert_output --partial "[standalone]"
    assert_output --partial "fizzbuzz"
}

@test "list shows no-dirs message when none configured" {
    run "$REX_BIN" list
    assert_success
    assert_output --partial "No directories configured"
}

@test "topic name shows topic help" {
    configure_scripts_dir
    create_topic_script "widgets" "widgets-spin.sh" "Spin a widget"

    run "$REX_BIN" widgets
    assert_success
    assert_output --partial "Usage: rex widgets <command>"
    assert_output --partial "spin"
}

@test "topic help shows topic help" {
    configure_scripts_dir
    create_topic_script "widgets" "widgets-spin.sh" "Spin a widget"

    run "$REX_BIN" widgets help
    assert_success
    assert_output --partial "Usage: rex widgets <command>"
}

@test "topic --help shows topic help" {
    configure_scripts_dir
    create_topic_script "widgets" "widgets-spin.sh" "Spin a widget"

    run "$REX_BIN" widgets --help
    assert_success
    assert_output --partial "Usage: rex widgets <command>"
}

@test "topic list shows topic help" {
    configure_scripts_dir
    create_topic_script "widgets" "widgets-spin.sh" "Spin a widget"

    run "$REX_BIN" widgets list
    assert_success
    assert_output --partial "Available commands:"
}

@test "unknown command shows help with error" {
    configure_scripts_dir
    run "$REX_BIN" nonexistent
    assert_failure
    assert_output --partial "Unknown topic or command"
}

@test "unknown topic command shows topic help with error" {
    configure_scripts_dir
    create_topic_script "widgets" "widgets-spin.sh" "Spin a widget"

    run "$REX_BIN" widgets badcmd
    assert_failure
    assert_output --partial "Unknown widgets command: badcmd"
    assert_output --partial "Available commands:"
}

@test "empty directory is not treated as a topic route" {
    configure_scripts_dir
    mkdir -p "$SCRIPTS_DIR/emptytopic"

    run "$REX_BIN" emptytopic
    assert_failure
    assert_output --partial "Unknown topic or command: emptytopic"
}

# ── Subtopic help tests ──────────────────────────────────────────────────────

@test "topic help shows subtopics when max_depth allows" {
    configure_scripts_dir
    set_max_depth 2
    create_topic_script "nas" "nas-mount.sh" "Mount NAS"
    create_subtopic_script "nas/backup" "backup-create.sh" "Create backup"

    run "$REX_BIN" nas
    assert_success
    assert_output --partial "Subtopics:"
    assert_output --partial "backup"
    assert_output --partial "Available commands:"
    assert_output --partial "mount"
}

@test "topic help does not show subtopics at default depth" {
    configure_scripts_dir
    create_topic_script "nas" "nas-mount.sh" "Mount NAS"
    create_subtopic_script "nas/backup" "backup-create.sh" "Create backup"

    run "$REX_BIN" nas
    assert_success
    refute_output --partial "Subtopics:"
    assert_output --partial "mount"
}

@test "subtopic help shows its commands" {
    configure_scripts_dir
    set_max_depth 2
    create_subtopic_script "nas/backup" "backup-create.sh" "Create backup"
    create_subtopic_script "nas/backup" "backup-restore.sh" "Restore backup"

    run "$REX_BIN" nas backup
    assert_success
    assert_output --partial "Usage: rex nas backup <command>"
    assert_output --partial "create"
    assert_output --partial "restore"
}

@test "subtopic help shows nested subtopics" {
    configure_scripts_dir
    set_max_depth 3
    create_subtopic_script "infra/aws" "aws-status.sh" "AWS status"
    create_subtopic_script "infra/aws/s3" "s3-sync.sh" "Sync S3"

    run "$REX_BIN" infra aws
    assert_success
    assert_output --partial "Subtopics:"
    assert_output --partial "s3"
    assert_output --partial "Available commands:"
    assert_output --partial "status"
}

@test "unknown subtopic command shows subtopic help with error" {
    configure_scripts_dir
    set_max_depth 2
    create_subtopic_script "nas/backup" "backup-create.sh" "Create backup"

    run "$REX_BIN" nas backup badcmd
    assert_failure
    assert_output --partial "Unknown backup command: badcmd"
    assert_output --partial "Available commands:"
}
