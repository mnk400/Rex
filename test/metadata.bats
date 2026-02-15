#!/usr/bin/env bats

load 'test_helper/common'

setup() {
    setup_rex_env
    configure_scripts_dir
}

@test "parses Description: comment from script" {
    create_topic_script "foobar" "foobar-greet.sh" "Greet the world"

    run "$REX_BIN" foobar
    assert_success
    assert_output --partial "Greet the world"
}

@test "parses @raycast.description comment from script" {
    mkdir -p "$SCRIPTS_DIR/foobar"
    cat > "$SCRIPTS_DIR/foobar/foobar-launch.sh" << 'EOF'
#!/bin/bash
# @raycast.description Launch the rockets
echo "launch"
EOF
    chmod +x "$SCRIPTS_DIR/foobar/foobar-launch.sh"

    run "$REX_BIN" foobar
    assert_success
    assert_output --partial "Launch the rockets"
}

@test "shows fallback description when none provided" {
    create_topic_script "foobar" "foobar-noop.sh" ""

    run "$REX_BIN" foobar
    assert_success
    assert_output --partial "No description available"
}

@test "rex.ignore excludes script from discovery" {
    create_topic_script "foobar" "foobar-shown.sh" "Shown"
    create_topic_script "foobar" "foobar-secret.sh" "Secret" "# rex.ignore"

    run "$REX_BIN" foobar
    assert_success
    assert_output --partial "shown"
    refute_output --partial "secret"
}

@test "Runbook.ignore excludes script (backwards compat)" {
    create_topic_script "foobar" "foobar-shown.sh" "Shown"
    create_topic_script "foobar" "foobar-oldstyle.sh" "Oldstyle" "# Runbook.ignore"

    run "$REX_BIN" foobar
    assert_success
    assert_output --partial "shown"
    refute_output --partial "oldstyle"
}

@test "rex.ignore excludes standalone scripts from discovery" {
    create_standalone_script "hello-world.sh" "Hello world"
    create_standalone_script "topsecret.sh" "Top secret" "# rex.ignore"

    run "$REX_BIN" list
    assert_success
    assert_output --partial "hello-world"
    refute_output --partial "topsecret"
}
