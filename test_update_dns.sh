#!/usr/bin/env bash

set -euo pipefail

test_failed=0

run_test() {
    local script_name="$1"
    local mock_file_exists="$2"
    local expected_exit_code="$3"

    echo "Running test for ${script_name} with mock_file_exists=${mock_file_exists}"

    # Create a temporary directory for mocks
    local mock_dir=$(mktemp -d)

    # Mock 'poetry' so it doesn't actually run octodns-sync
    cat << 'EOF' > "${mock_dir}/poetry"
#!/bin/sh
echo "mock poetry called with args: $*"
exit 0
EOF
    chmod +x "${mock_dir}/poetry"

    local test_script="./${script_name}"

    local mock_secret_path="${mock_dir}/mock_cloudflare_dns"
    export CLOUDFLARE_SECRET_PATH="${mock_secret_path}"

    if [ "$mock_file_exists" = "true" ]; then
        echo "fake-token" > "${mock_secret_path}"
    fi

    export PATH="${mock_dir}:${PATH}"

    set +e
    output=$("${test_script}" 2>&1)
    exit_code=$?
    set -e

    if [ $exit_code -eq $expected_exit_code ]; then
        echo "  [PASS] Exit code was $exit_code as expected."
        echo "         Output: $output"
    else
        echo "  [FAIL] Expected exit code $expected_exit_code, got $exit_code."
        echo "         Output: $output"
        test_failed=1
    fi

    rm -rf "${mock_dir}"
}

echo "Testing fake-update-dns.sh..."
run_test "fake-update-dns.sh" "false" 1
run_test "fake-update-dns.sh" "true" 0

echo "Testing update-dns.sh..."
run_test "update-dns.sh" "false" 1
run_test "update-dns.sh" "true" 0

if [ $test_failed -eq 0 ]; then
    echo "All tests passed!"
    exit 0
else
    echo "Some tests failed."
    exit 1
fi
