#!/bin/sh

today=$(date '+%d-%m-%Y')

date="$today"
if [ -n "$1" ]; then
  date="$1"
fi

cd $(dirname $0)
url="http://wetten.overheid.nl/BWBR0004627/geldigheidsdatum_$date/opslaan_in_ascii"
curl -m120 -fsS "$url" > temp_$date.zip
if [ "$?" = "22" ]; then
  rm -f temp_$date.zip
  echo "error fetching law at $url"
  exit 1
fi

unzip -qo temp_$date.zip

diff=$(git diff --numstat -- Kieswet.txt)
if [ -n "$diff" -a "$diff" != "1	1	Kieswet.txt" ]; then
  git diff -- Kieswet.txt
else
  echo "no changes"
  rm -f temp_$date.zip
fi
