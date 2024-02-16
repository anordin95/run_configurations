man () {
    # must provide full-path to man binary, otherwise the function will recurse!
    /usr/bin/man $1 | less
}

# On MacOS, the following binaries are all identical!
# /usr/bin/clang
# /usr/bin/clang++
# /usr/bin/c++
# /usr/bin/gcc
# The man(ual) page for c++ re-directs to the man page of clang. Presumably, they are all clang.


# Compile, invoke, then remove the binary for a single-file C program.
c() {
  clang -std=gnu17 -o tmp_binary $1 
  # Only invoke and remove the binary if it's generated.
  if [ $? -eq 0 ]; then
    ./tmp_binary
    # Remove the binary, even if it crashes at run-time.
    rm tmp_binary
  fi
}

# Compile, invoke, then remove the binary for a single-file C++ program.
c++() {
  # Despite clang & clang++ being identical binaries, clang fails to run compile C++ programs. Puzzling!
  clang++ --std=c++17 -o tmp_binary $1
  # Only invoke and remove the binary if it's generated.
  if [ $? -eq 0 ]; then
    ./tmp_binary
    # Remove the binary, even if it crashes at run-time.
    rm tmp_binary
  fi
}

# Helper-function to determine if two binaries contain the same contents.
are_binaries_equal() {
  BINARY_PATH_ONE=$1
  BINARY_PATH_TWO=$2
  
  if [[ $(md5 -q ${BINARY_PATH_ONE}) == $(md5 -q ${BINARY_PATH_TWO}) ]];
    then echo 'Binaries are Equal!'
  else 
    echo 'Womp womp... Not Equal,'
  fi
}

convert_all_heic_files_to_jpeg() {
  magick mogrify -monitor -format jpeg *.HEIC && rm *.HEIC
}

delete_dir_if_small(){
  DIR_PATH=$1
  SMALL_DIR_THRESHOLD_KB=$2
  
  # If dir does not exist, exit the function gracefully.
  if [[ ! -d ${DIR_PATH} ]];
    then return 0
  fi

  DIR_SIZE_KB=$(du -sk ${DIR_PATH} | awk '{print $1}') 
  if [[ ${DIR_SIZE_KB} -le ${SMALL_DIR_THRESHOLD_KB} ]];
    then rm -rf ${DIR_PATH}
  fi
}