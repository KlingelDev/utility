cmd="cmake --build build-debug && lldb -s test.lldb build-debug/exec"
find . -name "*.cc" -o -name "*.h" -o -name "*.txt" -o -name "*.lldb" -not -path "./build" -not -path "./build-debug"| entr -s "$cmd"
