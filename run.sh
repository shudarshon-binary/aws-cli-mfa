#!/usr/bin/env bash

iam_user="shudarshon"
declare -A aws_account=( \
    ["lt"]="112233445566" \
    ["qa"]="112233445500" \
    ["in"]="112233445588" \
    ["prod"]="112233445577" \
    )

echo -e "please specify the ( alphabetic code ) for specifying aws account:\n
    (lt) loadtesting
    (qa) qa
    (in) internal
    (prod) production\n"

read profile_code

case ${profile_code} in
    "lt")
        echo "****************Load Testing Account****************"
        echo 
        ;;
    "qa")
        echo "****************QA Account****************"
        echo 
        ;;
    "in")
        echo "****************Internal Account****************"
        echo 
        ;;
    "prod")
        echo "****************Production Account****************"
        echo 
        ;;
    *) echo "valid arguments are { lt , qa , in , prod }. exiting..."
        exit 1
        ;;
esac

aws_account=${aws_account[$profile_code]}
echo "enter MFA token to continue for assusming STS role: "
read mfa

if [ -z $mfa ]; then
        echo "token cannot be empty. exiting..."
        exit
else
    unset AWS_ACCESS_KEY_ID 
    unset AWS_SECRET_ACCESS_KEY 
    unset AWS_SESSION_TOKEN
    res=$(aws sts get-session-token --duration-seconds 129600 --serial-number arn:aws:iam::${aws_account}:mfa/${iam_user} --token-code $mfa --profile ${profile_code})
    export AWS_ACCESS_KEY_ID=$(echo $res | jq '.Credentials.AccessKeyId' | sed -e 's/^"//' -e 's/"$//') 
    export AWS_SECRET_ACCESS_KEY=$(echo $res | jq '.Credentials.SecretAccessKey' | sed -e 's/^"//' -e 's/"$//') 
    export AWS_SESSION_TOKEN=$(echo $res | jq '.Credentials.SessionToken' | sed -e 's/^"//' -e 's/"$//') 
    echo "Expire on: $(echo $res | jq '.Credentials.Expiration' | sed -e 's/^"//' -e 's/"$//')"
fi
