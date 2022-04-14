#!/usr/bin/env bash

echo ""

workspace_url="$1"

if [ -z "$workspace_url" ]; then
  echo "Usage $0 <workspace_url>"
  echo "" 
  exit
fi

clusters=($(ls clusters))
job_list=$(curl -s -n -X GET $workspace_url/api/2.1/jobs/list | jq -r '.jobs[].job_id')

for j in $job_list; do
  job_json=$(curl -s -n -X GET $workspace_url/api/2.1/jobs/get\?job_id=$j)
  job_name=$(echo $job_json | jq '.settings.name')
  tasks=$(echo $job_json | jq '.settings.tasks[].task_key')

  echo "Job name: $job_name"
  echo "Job id: $j"
  echo "$job_json" > "job_${j}.json" 
  echo ""

  DOCUMENT="
  { \"job_id\": $j, 
    \"new_settings\": {
      \"tasks\": [ 
  "

  read -p "Use same cluster for all tasks in $j job? [y/n]" use_same_cluster
  echo    # (optional) move to a new line
  if [[ $use_same_cluster =~ ^[Yy]$ ]]
  then
    echo "Here are the available clusters:"

    for p in $(seq 1 $(( ${#clusters[@]}  ))); do
      echo "$p. ${clusters[$((p-1))]}"
      done
    echo ""
    read -p "Please assign a cluster for ALL OF YOUR tasks in $j job: " main_selection
    read -p "You have selected <<< ${clusters[$((main_selection-1))]} >>>. Please press ENTER to confirm" confirmation
      
  fi

  TASKS=""
  for t in $tasks; do
    echo "#############################################"
    echo "GENERATING NEW SETTINGS FOR TASK: $t"
    echo "#############################################"
    echo ""

    TASKS="${TASKS}{\"task_key\":$t"
    
    echo "Here are the available clusters:"

    for p in $(seq 1 $(( ${#clusters[@]}  ))); do
      echo "$p. ${clusters[$((p-1))]}"
      done
    echo ""

    if [[ ! $use_same_cluster =~ ^[Yy]$ ]]
    then
      read -p "Please assign a cluster for your task $t: " selection
      read -p "You have selected <<< ${clusters[$((selection-1))]} >>>. Please press ENTER to confirm" confirmation

      if [ ${#confirmation} -eq 0 ]; then
        echo "Enter was hit"
      fi 

      NEW_CLUSTER=`cat clusters/${clusters[$((selection-1))]}`
      TASKS="${TASKS},\"new_cluster\":$NEW_CLUSTER"
    else
      NEW_CLUSTER=`cat clusters/${clusters[$((main_selection-1))]}`
      TASKS="${TASKS},\"new_cluster\":$NEW_CLUSTER"
    fi

    TASKS="${TASKS}},"
    echo ""

    done

  TASKS=$( echo $TASKS | sed 's/.$//')
  FINAL_DOC="${DOCUMENT}${TASKS}]}}"
  echo "$FINAL_DOC" | jq > "update_${j}.json"
  echo $FINAL_DOC | jq
  
  read -p "Please review and press any key to update job..." -n 1 -r 
  
  curl -n -X POST $workspace_url/api/2.1/jobs/update --data @update_${j}.json
  
  echo 
  done
