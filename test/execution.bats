#!/usr/bin/env bats

load 'test_helper/common'

setup() {
    setup_rex_env
    configure_scripts_dir
}

# Helper to create a script that prints its args and REX_CMD
_create_echo_script_topic() {
    local topic="$1"
    local name="$2"
    local dir="$SCRIPTS_DIR/$topic"
    mkdir -p "$dir"
    cat > "$dir/$name" << 'SCRIPT'
#!/bin/bash
echo "ARGS: $*"
echo "REX_CMD: $REX_CMD"
SCRIPT
    chmod +x "$dir/$name"
}

_create_echo_script_standalone() {
    local name="$1"
    cat > "$SCRIPTS_DIR/$name" << 'SCRIPT'
#!/bin/bash
echo "ARGS: $*"
echo "REX_CMD: $REX_CMD"
SCRIPT
    chmod +x "$SCRIPTS_DIR/$name"
}

@test "topic command runs the correct script" {
    _create_echo_script_topic "widgets" "widgets-spin.sh"

    run "$REX_BIN" widgets spin
    assert_success
    assert_output --partial "ARGS:"
}

@test "standalone command runs the correct script" {
    _create_echo_script_standalone "fizzbuzz.sh"

    run "$REX_BIN" fizzbuzz
    assert_success
    assert_output --partial "ARGS:"
}

@test "arguments are passed through to topic command" {
    _create_echo_script_topic "widgets" "widgets-spin.sh"

    run "$REX_BIN" widgets spin --speed fast --count 3
    assert_success
    assert_output --partial "ARGS: --speed fast --count 3"
}

@test "arguments are passed through to standalone command" {
    _create_echo_script_standalone "fizzbuzz.sh"

    run "$REX_BIN" fizzbuzz --verbose foo bar
    assert_success
    assert_output --partial "ARGS: --verbose foo bar"
}

@test "REX_CMD is set for topic commands" {
    _create_echo_script_topic "widgets" "widgets-spin.sh"

    run "$REX_BIN" widgets spin --speed fast
    assert_success
    assert_output --partial "REX_CMD: rex"
}

@test "REX_CMD is set for standalone commands" {
    _create_echo_script_standalone "fizzbuzz.sh"

    run "$REX_BIN" fizzbuzz --verbose
    assert_success
    assert_output --partial "REX_CMD: rex"
}
