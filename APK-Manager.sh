progress() {
  local w=80 p=$1;  shift
  printf -v dots "%*s" "$(( $p*$w/100 ))" ""; dots=${dots// /.};
  printf "\r\e[K|%-*s| %3d %% %s" "$w" "$dots" "$p" "$*";
}

function backup {
  printf "\033c"
  echo "Scanning for devices"
  $(adb wait-for-device)
  output=($(adb shell pm list packages))
  total=${#output[@]}
  echo "$total package found"
  read -rsp $'Press enter to continue...\n'

  $(mkdir -p packages)
  c=1
  t=${#output[@]}
  for package in ${output[@]}
  do

    progress "$((100 * c / t))" "($c of $t)"
    echo -en "\nDonwloading $package ($c of $t)\n"
    cpkg=${package:8} #substring
    c=$((c + 1))
    path=$(adb shell pm path $cpkg)
    command=$(adb pull ${path:8} "packages/$cpkg.apk")

    printf "\033c"
  done
  printf "\033c"
  echo "Backup complete for $total items"
}

function restore {
  printf "\033c"
  echo "Scanning for devices"
  $(adb wait-for-device)
  output=($(ls packages/*apk))
  total=${#output[@]}
  echo "$total package found"
  read -rsp $'Press enter to continue...\n'
  c=1
  t=${#output[@]}
  for i in packages/*.apk; do
    printf "\033c"
    progress "$((100 * c / t))" "($c of $t)"
    echo -en "\nInstalling $i ($c of $t)\n"
    c=$((c + 1))
    command=$(adb install $i)
  done
  printf "\033c"
  echo "Restore completed for $total items"
}

PS3='Select one option: '
options=("Backup" "Restore" "Quit")
select opt in "${options[@]}"
do
  case $opt in
    "Backup")
    backup
    break
    ;;
    "Restore")
    restore
    break
    ;;
    "Quit")
    break
    ;;
    *) echo invalid option;;
  esac
done
