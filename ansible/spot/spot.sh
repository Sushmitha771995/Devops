
if [ -z "$1" ]; then
  echo "Provide input json file"
  exit 1
fi


aws ec2 request-spot-fleet --spot-fleet-request-config file://$1
aws ec2 describe-tags  --filters "Name=name,Values=s$1"