#!/bin/bash
# Shared test helper for Rex tests

# Load bats helpers
load "${BATS_TEST_DIRNAME}/helpers/bats-support/load"
load "${BATS_TEST_DIRNAME}/helpers/bats-assert/load"

# Path to the rex binary under test
REX_BIN="$(cd "$BATS_TEST_DIRNAME/.." && pwd)/bin/rex"

# Create isolated test environment
setup_rex_env() {
    # Create temp directories for config and scripts
    export TEST_TMPDIR=$(mktemp -d "$BATS_TEST_TMPDIR/rex-test.XXXXXX")
    export XDG_CONFIG_HOME="$TEST_TMPDIR/config"
    export SCRIPTS_DIR="$TEST_TMPDIR/scripts"
    mkdir -p "$SCRIPTS_DIR"
}

# Add the scripts dir to rex config
configure_scripts_dir() {
    run "$REX_BIN" dirs add "$SCRIPTS_DIR"
}

# Create a fake executable script in a topic directory
# Usage: create_topic_script <topic> <script_name> [description] [extra_header_lines...]
create_topic_script() {
    local topic="$1"
    local script_name="$2"
    local description="${3:-}"
    shift 3 2>/dev/null || shift $#

    local dir="$SCRIPTS_DIR/$topic"
    mkdir -p "$dir"

    local script_path="$dir/$script_name"
    {
        echo "#!/bin/bash"
        if [[ -n "$description" ]]; then
            echo "# Description: $description"
        fi
        for line in "$@"; do
            echo "$line"
        done
        echo 'echo "executed: $0 $*"'
    } > "$script_path"
    chmod +x "$script_path"
    echo "$script_path"
}

# Create a fake standalone executable script
# Usage: create_standalone_script <script_name> [description] [extra_header_lines...]
create_standalone_script() {
    local script_name="$1"
    local description="${2:-}"
    shift 2 2>/dev/null || shift $#

    local script_path="$SCRIPTS_DIR/$script_name"
    {
        echo "#!/bin/bash"
        if [[ -n "$description" ]]; then
            echo "# Description: $description"
        fi
        for line in "$@"; do
            echo "$line"
        done
        echo 'echo "executed: $0 $*"'
    } > "$script_path"
    chmod +x "$script_path"
    echo "$script_path"
}

# Create a second scripts directory for multi-dir tests
create_second_scripts_dir() {
    export SCRIPTS_DIR2="$TEST_TMPDIR/scripts2"
    mkdir -p "$SCRIPTS_DIR2"
    run "$REX_BIN" dirs add "$SCRIPTS_DIR2"
}
