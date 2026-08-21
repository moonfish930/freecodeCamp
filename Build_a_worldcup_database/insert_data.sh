#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
declare -A TEAM_CACHE

# 读取 games.csv，跳过第一行标题行
cat games.csv | tail -n +2 | while IFS=',' read -r YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  # 处理 WINNER 球队
  if [[ -z "${TEAM_CACHE[$WINNER]}" ]]; then
    # 如果内存缓存中没有，先尝试插入（若已存在则直接返回或忽略，这里用子查询保证幂等/不报错）
    # 也可以直接查询获取
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER';")
    if [[ -z "$WINNER_ID" ]]; then
      $PSQL "INSERT INTO teams(name) VALUES('$WINNER');"
      WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER';")
    fi
    TEAM_CACHE[$WINNER]="$WINNER_ID"
  else
    WINNER_ID="${TEAM_CACHE[$WINNER]}"
  fi

  # 处理 OPPONENT 球队
  if [[ -z "${TEAM_CACHE[$OPPONENT]}" ]]; then
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT';")
    if [[ -z "$OPPONENT_ID" ]]; then
      $PSQL "INSERT INTO teams(name) VALUES('$OPPONENT');"
      OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT';")
    fi
    TEAM_CACHE[$OPPONENT]="$OPPONENT_ID"
  else
    OPPONENT_ID="${TEAM_CACHE[$OPPONENT]}"
  fi

  # 插入比赛记录
  $PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS);"
done