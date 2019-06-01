@test "checking process: gitea (gitea enabled by default)" {
  run docker exec gitea /bin/bash -c "ps aux | grep -v grep | grep '/usr/local/bin/gitea'"
  [ "$status" -eq 0 ]
}


@test "checking process: gitea (gitea disabled by DISABLE_GITEA)" {
  run docker exec gitea_no_gitea /bin/bash -c "ps aux | grep -v grep | grep '/usr/local/bin/gitea'"
  [ "$status" -eq 1 ]
}

@test "checking process: gitea (default)" {
  run docker exec gitea_default /bin/bash -c "ps aux | grep -v grep | grep '/usr/local/bin/gitea'"
  [ "$status" -eq 0 ]
}

