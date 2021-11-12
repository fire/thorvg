#!/bin/bash

echo "Run Valgrind"
echo "valgrind --leak-check=yes ./tvgUnitTests"
cd ./build/test

valgrind --leak-check=yes ./tvgUnitTests > memcheck_valgrind.txt 2>&1


PAYLOAD_MEMCHECK=`cat memcheck_valgrind.txt`
COMMENTS_URL=$(cat $GITHUB_EVENT_PATH | jq -r .pull_request.comments_url)

echo $COMMENTS_URL
echo "MEMCHECK errors:"
echo $PAYLOAD_MEMCHECK

if [[ $PAYLOAD_MEMCHECK == *"definitely lost:"* || $PAYLOAD_MEMCHECK == *"Invalid read "* || $PAYLOAD_MEMCHECK == *"Invalid write "* ]]; then
  OUTPUT+=$'\n**MEMCHECK(VALGRIND) RESULT**:\n'
  OUTPUT+=$'\n`valgrind --leak-check=yes ./tvgUnitTests`\n'
  OUTPUT+=$'\n```\n'
  OUTPUT+="$PAYLOAD_MEMCHECK"
  OUTPUT+=$'\n```\n' 
fi

PAYLOAD=$(echo '{}' | jq --arg body "$OUTPUT" '.body = $body')

curl -s -S -H "Authorization: token $GITHUB_TOKEN" --header "Content-Type: application/vnd.github.VERSION.text+json" --data "$PAYLOAD" "$COMMENTS_URL"
