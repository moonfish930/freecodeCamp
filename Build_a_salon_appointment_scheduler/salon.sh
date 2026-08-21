#!/bin/bash

# 定义 psql 快捷命令，连接到 salon 数据库，静默输出（不显示表头和多余横线）
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~"
echo -e "\nWelcome to My Salon, how can I help you?\n"

MAIN_MENU() {
  # 如果传入了参数（通常是错误提示），先打印它
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  # 1. 从数据库获取并显示服务列表
  AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id;")
  
  # 格式化输出服务列表
  echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

  # 2. 读取用户选择的服务编号
  read SERVICE_ID_SELECTED

  # 校验输入是否为数字或服务是否存在
  # 查询该 service_id 是否在数据库中存在
  SERVICE_ID_RESULT=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED;")

  # 如果服务不存在，重新调用主菜单并带上提示信息
  if [[ -z $SERVICE_ID_RESULT ]]
  then
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    # 3. 获取客户手机号
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE

    # 检查客户是否已存在
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE';" | sed 's/ //g')

    # 如果客户不存在，要求输入姓名并写入数据库
    if [[ -z $CUSTOMER_NAME ]]
    then
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME

      # 插入新客户
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME');")
    fi

    # 获取当前客户的 customer_id
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE';" | sed 's/ //g')

    # 获取所选服务的名称（用于最终打印提示）
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED;" | sed 's/^ *//g' | sed 's/ *$//g')

    # 4. 获取预约时间
    echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
    read SERVICE_TIME

    # 5. 将预约写入 appointments 表
    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');")

    # 6. 输出最终成功提示
    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}

# 启动主菜单
MAIN_MENU