#!/bin/bash
REPO_DIR=$(dirname $(dirname "$(realpath "$0")"))
TIG_WORKER_PATH="$REPO_DIR/target/release/tig-worker"

if [ ! -f $TIG_WORKER_PATH ]; then
    echo "Error: tig-worker binary not found at ./target/release/tig-worker"
    echo "Run: cd $REPO_DIR && cargo build -p tig-worker --release"
    exit 1
fi

# Define algorithms and their corresponding .wasm files
declare -A wasm_files
wasm_files=( 
    ["c004_a026"]="optimax_gpu.wasm"
    ["c004_a029"]="gpu_manual_fastest.wasm"
    ["c004_a034"]="invector.wasm"
)

algorithms=("c004_a026" "c004_a029" "c004_a034")
CHALLENGE="vector_search"
CHALLENGE_ID="c004"
difficulty="[220,520]"
start_nonce=0
num_nonces=100000
num_workers=16
enable_debug=true

# Player and block IDs
player_id="0x86d057c91af3772dd2ebee01ab09fe639bf9a0d5"
block_id="572873635574a8611d10b9b75dcbeb4f"

get_closest_power_of_2() {
    local n=$1
    local p=1
    while [ $p -lt $n ]; do
        p=$((p * 2))
    done
    echo $p
}

for ALGORITHM in "${algorithms[@]}"; do
    wasm_file="${wasm_files[$ALGORITHM]}"  # Get the correct .wasm file for the algorithm
    if [ -z "$wasm_file" ]; then
        echo "Error: No wasm file found for algorithm $ALGORITHM"
        exit 1
    fi

    # Update SETTINGS with algorithm_id, player_id, and block_id
    SETTINGS="{\"challenge_id\":\"$CHALLENGE_ID\",\"difficulty\":$difficulty,\"algorithm_id\":\"$ALGORITHM\",\"player_id\":\"$player_id\",\"block_id\":\"$block_id\"}"
    num_solutions=0
    num_invalid=0
    total_ms=0

    echo "----------------------------------------------------------------------"
    echo "Testing performance of $CHALLENGE/$ALGORITHM"
    echo "Settings: $SETTINGS"
    echo "Starting nonce: $start_nonce"
    echo "Number of nonces: $num_nonces"
    echo "Number of workers: $num_workers"
    echo -ne ""

    remaining_nonces=$num_nonces
    current_nonce=$start_nonce

    while [ $remaining_nonces -gt 0 ]; do
        nonces_to_compute=$((num_workers < remaining_nonces ? num_workers : remaining_nonces))
        
        power_of_2_nonces=$(get_closest_power_of_2 $nonces_to_compute)

        start_time=$(date +%s%3N)
        stdout=$(mktemp)
        stderr=$(mktemp)

        # Prepare the command for output
        command="./home/bn/bench/tig-monorepo/target/release/tig-worker compute_batch \"$SETTINGS\" \"random_string\" $current_nonce $nonces_to_compute $power_of_2_nonces $REPO_DIR/tig-algorithms/wasm/$CHALLENGE/$wasm_file --workers $nonces_to_compute"

        # Output the command being executed
        #echo "Executing: $command"

        # Execute the command
        eval "$command >\"$stdout\" 2>\"$stderr\""
        
        exit_code=$?
        output_stdout=$(cat "$stdout")
        output_stderr=$(cat "$stderr")
        end_time=$(date +%s%3N)
        duration=$((end_time - start_time))
        total_ms=$((total_ms + (duration * nonces_to_compute)))

        if [ $exit_code -eq 0 ]; then
            solutions_count=$(echo "$output_stdout" | grep -o '"solution_nonces":\[.*\]' | sed 's/.*\[\(.*\)\].*/\1/' | awk -F',' '{print NF}')
            invalid_count=$((nonces_to_compute - solutions_count))
            num_solutions=$((num_solutions + solutions_count))
            num_invalid=$((num_invalid + invalid_count))
        fi

        if [ $num_solutions -eq 0 ]; then
            avg_ms_per_solution=0
        else
            avg_ms_per_solution=$((total_ms / num_solutions))
        fi

        if [[ $debug_mode == true ]]; then
            echo "    Current nonce: $current_nonce"
            echo "    Nonces computed: $nonces_to_compute"
            echo "    Exit code: $exit_code"
            echo "    Stdout: $output_stdout"
            echo "    Stderr: $output_stderr"
            echo "    Duration: $duration ms"
            echo "#instances: $((num_solutions + num_invalid)), #solutions: $num_solutions, #invalid: $num_invalid, average ms/solution: $avg_ms_per_solution"
        else
            echo -ne "#instances: $((num_solutions + num_invalid)), #solutions: $num_solutions, #invalid: $num_invalid, average ms/solution: $avg_ms_per_solution\033[K\r"
        fi

        current_nonce=$((current_nonce + nonces_to_compute))
        remaining_nonces=$((remaining_nonces - nonces_to_compute))
    done

    echo
    echo "----------------------------------------------------------------------"
    echo "To re-run this test, run the following commands:"
    echo "    git clone https://github.com/tig-foundation/tig-monorepo.git"
    echo "    cd tig-monorepo"
    echo "    git pull origin/$CHALLENGE/$ALGORITHM --no-edit"
    echo "    bash scripts/test_algorithm.sh"
    echo "----------------------------------------------------------------------"
    echo "Share your results on https://www.reddit.com/r/TheInnovationGame"
    echo "----------------------------------------------------------------------"
    rm "$stdout" "$stderr"
done
