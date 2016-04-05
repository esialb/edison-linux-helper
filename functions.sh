#!/bin/bash

function eh_repo_root {
  echo -n "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
}

function eh_require_submodules {
  if [ ! -d "$(eh_repo_root)/edison-linux" ] || [ ! -d "$(eh_repo_root)/edison-bcm43340" ]; then
    git submodule update
  fi
}

function eh_kernel_release_version {
  echo -n $(cat "$(eh_repo_root)/edison-linux/include/generated/utsrelease.h" 2>/dev/null | awk '{print $3}' | perl -p -e 's/^"(.*)"$/$1/')
}

function eh_kernel_src {
  echo -n "$(eh_repo_root)/edison-linux"
}

function eh_bcm43340_src {
  echo -n "$(eh_repo_root)/edison-bcm43340"
}

function eh_collected_dir {
  echo -n "$(eh_repo_root)/collected/$(eh_kernel_release_version)"
}
