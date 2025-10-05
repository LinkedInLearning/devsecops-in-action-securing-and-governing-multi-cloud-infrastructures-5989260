In the .github/workflows/aws-terraform.yml code, change the account number on line 41 to match yours. 

Note the role name github-terraform-deploy, and change it if you used something else.

Then on VSCode’s terminal, run:

# Create an environment variables for the next command:
STORAGE_ACCOUNT_NAME=tfstate15619

# Create a bucket to store the remote state
aws s3api create-bucket \
  --bucket $STORAGE_ACCOUNT_NAME \
  --region us-east-1

# Allow State Locking with DynamoDB
aws dynamodb create-table \
  --table-name tfstate-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-east-1

terraform fmt

terraform init
