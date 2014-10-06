#!/bin/sh

function cleanUpAndExit {
  if [ -f temp.zip ]; then
    rm temp.zip
  fi
  exit 1
}

today=$(date '+%d-%m-%Y')

date="$today"
if [ -n "$1" ]; then
  date="$1"
fi

cd $(dirname $0) &&
curl -m120 -fsS "http://wetten.overheid.nl/BWBR0004627/geldigheidsdatum_$date/opslaan_in_ascii" > temp.zip || cleanUpAndExit

unzip -qo temp.zip || cleanUpAndExit
rm temp.zip || exit 2

# load ssh agent, hopefully the agent is running and the key isn't expired
if [ -z "$SSH_AGENT_PID" ]; then
  source $HOME/.ssh/.ssh-socket >/dev/null
fi

diff=$(git diff --numstat -- Kieswet.txt)
if [ -n "$diff" -a "$diff" != "1	1	Kieswet.txt" ]; then
  git diff -- Kieswet.txt &&
  git commit Kieswet.txt -m "Kieswet geldend op $date" &&
  git push
fi
