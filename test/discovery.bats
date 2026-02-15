#!/usr/bin/env bats

load 'test_helper/common'

setup() {
    setup_rex_env
    configure_scripts_dir
}

@test "discovers topics from subdirectories with executables" {
    create_topic_script "widgets" "widgets-spin.sh" "Spin a widget"
    create_topic_script "gadgets" "gadgets-zap.sh" "Zap a gadget"

    run "$REX_BIN" list
    assert_success
    assert_output --partial "[widgets]"
    assert_output --partial "[gadgets]"
}

@test "does not discover empty subdirectories as topics" {
    mkdir -p "$SCRIPTS_DIR/emptytopic"

    run "$REX_BIN" help
    assert_success
    refute_output --partial "emptytopic"
}

@test "discovers commands within a topic" {
    create_topic_script "widgets" "widgets-spin.sh" "Spin a widget"
    create_topic_script "widgets" "widgets-flip.sh" "Flip a widget"

    run "$REX_BIN" widgets
    assert_success
    assert_output --partial "spin"
    assert_output --partial "flip"
}

@test "strips topic prefix from command names" {
    create_topic_script "widgets" "widgets-spin.sh" "Spin a widget"

    run "$REX_BIN" widgets
    assert_success
    # Should show "spin" not "widgets-spin"
    assert_output --partial "spin"
    refute_output --partial "widgets-spin"
}

@test "discovers standalone commands at root level" {
    create_standalone_script "fizzbuzz.sh" "Run fizzbuzz"

    run "$REX_BIN" list
    assert_success
    assert_output --partial "[standalone]"
    assert_output --partial "fizzbuzz"
}

@test "excludes rex* and runbook* from standalone discovery" {
    create_standalone_script "rex-helper.sh" "Helper"
    create_standalone_script "runbook-old.sh" "Old runbook"
    create_standalone_script "zapper.sh" "Zap things"

    run "$REX_BIN" list
    assert_success
    assert_output --partial "zapper"
    refute_output --partial "rex-helper"
    refute_output --partial "runbook-old"
}

@test "first directory wins for duplicate topic commands" {
    configure_scripts_dir
    create_second_scripts_dir

    # Create same command in both dirs
    create_topic_script "widgets" "widgets-spin.sh" "First dir spin"

    # Create in second dir
    local dir2="$SCRIPTS_DIR2/widgets"
    mkdir -p "$dir2"
    cat > "$dir2/widgets-spin.sh" << 'EOF'
#!/bin/bash
# Description: Second dir spin
echo "second"
EOF
    chmod +x "$dir2/widgets-spin.sh"

    run "$REX_BIN" widgets
    assert_success
    assert_output --partial "First dir spin"
    refute_output --partial "Second dir spin"
}

@test "first directory wins for duplicate standalone commands" {
    configure_scripts_dir
    create_second_scripts_dir

    create_standalone_script "fizzbuzz.sh" "First dir fizzbuzz"

    cat > "$SCRIPTS_DIR2/fizzbuzz.sh" << 'EOF'
#!/bin/bash
# Description: Second dir fizzbuzz
echo "second"
EOF
    chmod +x "$SCRIPTS_DIR2/fizzbuzz.sh"

    run "$REX_BIN" list
    assert_success
    assert_output --partial "First dir fizzbuzz"
    refute_output --partial "Second dir fizzbuzz"
}
