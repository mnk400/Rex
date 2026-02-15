#!/usr/bin/env bats

load 'test_helper/common'

setup() {
    setup_rex_env
}

@test "creates config dir and file on first run" {
    run "$REX_BIN" help
    assert_success
    assert [ -d "$XDG_CONFIG_HOME/rex" ]
    assert [ -f "$XDG_CONFIG_HOME/rex/config" ]
}

@test "respects XDG_CONFIG_HOME" {
    export XDG_CONFIG_HOME="$TEST_TMPDIR/custom-config"
    run "$REX_BIN" help
    assert_success
    assert [ -d "$XDG_CONFIG_HOME/rex" ]
    assert [ -f "$XDG_CONFIG_HOME/rex/config" ]
}

@test "config file skips comments and blank lines" {
    mkdir -p "$XDG_CONFIG_HOME/rex"
    cat > "$XDG_CONFIG_HOME/rex/config" << EOF
# This is a comment
$SCRIPTS_DIR

   # Indented comment
EOF
    run "$REX_BIN" dirs
    assert_success
    assert_output --partial "$SCRIPTS_DIR"
    refute_output --partial "# This is a comment"
}

@test "config file skips non-existent directories" {
    mkdir -p "$XDG_CONFIG_HOME/rex"
    cat > "$XDG_CONFIG_HOME/rex/config" << EOF
/nonexistent/path/that/does/not/exist
$SCRIPTS_DIR
EOF
    # Only the existing dir should appear in dirs list
    create_topic_script "foobar" "foobar-test.sh" "test"
    configure_scripts_dir
    run "$REX_BIN" dirs
    assert_success
    assert_output --partial "$SCRIPTS_DIR"
    refute_output --partial "/nonexistent/path"
}
