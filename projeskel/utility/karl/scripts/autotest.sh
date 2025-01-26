cmd="cmake --build build-debug && ctest --test-dir build-debug/tests -V --stop-on-failure tests" #  && gdb main -q --command=gdbcmd"
find . -name "*.cc" -o -name "*.h" -o -name "*.txt" -not -path "./build" -not -path "./build-debug"| entr -s "$cmd"
