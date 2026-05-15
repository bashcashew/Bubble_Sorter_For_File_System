#!/bin/zsh

#' Function to implement bubble sort
bubble_sort() {
  local arr=("$@")
  local n=${#arr[@]}
  for ((i = 0; i < n; i++)); do
    for ((j = 0; j < n - i - 1; j++)); do
      if [[ "${arr[j]}" > "${arr[j+1]}" ]]; then
        temp="${arr[j]}"
        arr[j]="${arr[j+1]}"
        arr[j+1]="$temp"
      fi
    done
  done
  echo "${arr[@]}"
}

#' Function to rename files with a numbering system
rename_files() {
  echo "Renaming files..."

  #' List all files, excluding '.' and '..'
  files=($(ls -A | grep -vE "^\.$|^\.\.$"))

  #' Sort files using the bubble sort func.
  sorted_files=($(bubble_sort "${files[@]}"))

  #' Create an array to store the original file names + new names for an "undo"
  original_names=()
  renamed_files=()

  #' Rename files with numbering and store the original names
  counter=1
  for file in "${sorted_files[@]}"; do
    new_name="${counter}_$file"
    mv "$file" "$new_name"
    original_names+=("$file")
    renamed_files+=("$new_name")
    echo "Renamed '$file' to '$new_name'"
    ((counter++))
  done
}

#' Function to undo the renaming process
undo_rename() {
  echo "Undoing the renaming process..."

  #' Check if there are files to undo
  if [ ${#original_names[@]} -eq 0 ]; then
    echo "No files to undo."
    return
  fi

  #' Restore original names
  for i in "${!original_names[@]}"; do
    mv "${renamed_files[$i]}" "${original_names[$i]}"
    echo "Restored '${renamed_files[$i]}' to '${original_names[$i]}'"
  done

  original_names=()
  renamed_files=()
}

#' Displays pop-upfoe current directory + explicit consent Y/N
response=$(osascript <<EOF
tell application "System Events"
    display dialog "Check the current directory before proceeding.\n\nCurrent Directory:\n$(pwd)" buttons {"Decline", "Accept"} default button "Accept"
end tell
EOF
)

#' Checks for "Decline"
if [[ $response == *"Decline"* ]]; then
    echo "Operation cancelled. No files renamed."
    exit 0
fi

#' Rename files
rename_files

#' Prompts for an undo to the renaming process
read -p "Would you like to undo? (yes/no): " undo_response
if [[ $undo_response == "yes" || $undo_response == "y" ]]; then
    undo_rename
else
    echo "Renaming is successfull."
fi

echo "Exiting the script."
exit 0
