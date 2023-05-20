{exec, ...}: {
  unsafeEvalTimeDecryptAsString = key: file: exec ["bash" "-c" ''rage --decrypt -i ${key} ${file} | awk '{ print "\""$0"\""}' ''];
}
