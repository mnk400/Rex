#!/usr/bin/env bats

load 'test_helper/common'

setup() {
    setup_rex_env
}

@test "dirs list shows no directories when none configured" {
    run "$REX_BIN" dirs
    assert_success
    assert_output --partial "No directories configured"
}

@test "dirs add adds a directory" {
    run "$REX_BIN" dirs add "$SCRIPTS_DIR"
    assert_success
    assert_output --partial "Added: $SCRIPTS_DIR"

    run "$REX_BIN" dirs
    assert_success
    assert_output --partial "$SCRIPTS_DIR"
}

@test "dirs add resolves to absolute path" {
    local reldir="$TEST_TMPDIR/rel-test"
    mkdir -p "$reldir"

    run "$REX_BIN" dirs add "$reldir"
    assert_success
    # Should contain the absolute path
    assert_output --partial "$reldir"
}

@test "dirs add rejects duplicate directories" {
    run "$REX_BIN" dirs add "$SCRIPTS_DIR"
    assert_success

    run "$REX_BIN" dirs add "$SCRIPTS_DIR"
    assert_success
    assert_output --partial "Already configured"
}

@test "dirs add rejects non-existent paths" {
    run "$REX_BIN" dirs add "/nonexistent/path/xyz"
    assert_failure
    assert_output --partial "does not exist"
}

@test "dirs add with no path shows usage" {
    run "$REX_BIN" dirs add
    assert_failure
    assert_output --partial "Usage:"
}

@test "dirs remove removes a directory" {
    run "$REX_BIN" dirs add "$SCRIPTS_DIR"
    assert_success

    run "$REX_BIN" dirs remove "$SCRIPTS_DIR"
    assert_success
    assert_output --partial "Removed:"

    run "$REX_BIN" dirs
    assert_success
    refute_output --partial "$SCRIPTS_DIR"
}

@test "dirs remove with no path shows usage" {
    run "$REX_BIN" dirs remove
    assert_failure
    assert_output --partial "Usage:"
}

@test "dirs remove handles non-configured path" {
    run "$REX_BIN" dirs remove "/some/random/path"
    assert_failure
    assert_output --partial "Not found in config"
}

@test "dirs unknown subcommand shows error" {
    run "$REX_BIN" dirs badcommand
    assert_failure
    assert_output --partial "Unknown dirs command"
}

@test "dirs list shows topic count per directory" {
    run "$REX_BIN" dirs add "$SCRIPTS_DIR"
    assert_success

    # Create a topic
    create_topic_script "foobar" "foobar-test.sh" "test"

    run "$REX_BIN" dirs
    assert_success
    assert_output --partial "topics)"
}
