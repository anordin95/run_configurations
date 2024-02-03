man () {
    # must provide full-path to man binary, otherwise the function will recurse!
    /usr/bin/man $1 | less
}

# Helper-function (kind of like an alias) to compile,
# invoke and clean-up a C program.
c(){
  clang -std=gnu17 -o tmp_binary $1 
  # Only invoke and remove the binary if it's generated.
  if [ $? -eq 0 ]; then
    ./tmp_binary
    # Remove the binary, even if it crashes at run-time.
    rm tmp_binary
  fi
}

# On MacOS, the following binaries are all identical!
# /usr/bin/clang
# /usr/bin/clang++
# /usr/bin/c++
# /usr/bin/gcc
# The help page indicates they are all in-fact the clang compiler. 
# invoke and clean-up a C program.
# Despite their equality, my system fails to compile C++ files
# with the /usr/bin/clang compiler. 
c++(){
  clang++ --std=c++17 -o tmp_binary $1
  # Only invoke and remove the binary if it's generated.
  if [ $? -eq 0 ]; then
    ./tmp_binary
    # Remove the binary, even if it crashes at run-time.
    rm tmp_binary
  fi
}
