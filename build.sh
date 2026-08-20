#!/bin/bash
set -e

# TAG=$([ "$BRANCH" == "main" ] && echo "stable" || echo "latest")

# AWS_ECS_CLUSTER=$([ "$BRANCH" == "main" ] && echo "$AWS_ECS_CLUSTER_PROD" || echo "$AWS_ECS_CLUSTER_DEV")

# AWS_ECS_SERVICE=$([ "$BRANCH" == "main" ] && echo "$AWS_ECS_SERVICE_PROD" || echo "$AWS_ECS_SERVICE_DEV")

# echo "Building image for branch: $BRANCH with tag: $TAG"

# Set DRY_RUN=true to build, tag, and log in to ECR, and to run the
# read-only ECS lookups below, without pushing the image or touching any
# running tasks/services. Useful for confirming the image still builds and
# the AWS role has the permissions it needs, without deploying anything.
DRY_RUN=${DRY_RUN:-false}

TAG=latest

docker build \
       --platform linux/amd64 \
       --file Dockerfile \
       -t faux_oauth \
       .

echo "Logging in to AWS"
aws ecr get-login-password --region us-east-1 |
       docker login --username AWS --password-stdin 310867200447.dkr.ecr.us-east-1.amazonaws.com
echo "Logged in successfully"

echo "Tagging image with ${TAG}"
docker tag faux_oauth 310867200447.dkr.ecr.us-east-1.amazonaws.com/faux_oauth:latest

if [ "$DRY_RUN" = "true" ]; then
       echo "DRY_RUN set: skipping image push and any change to running tasks/services"
else
       echo "Pushing image"
       docker push 310867200447.dkr.ecr.us-east-1.amazonaws.com/faux_oauth:latest
fi

CLUSTER=faux_oauth
SERVICE=faux_oauth
REGION=us-east-1

echo "Looking up the service's current task definition and network config"
TASK_DEF=$(aws ecs describe-services --cluster "$CLUSTER" --services "$SERVICE" --region "$REGION" \
       --query 'services[0].taskDefinition' --output text)
NETWORK_CONFIG=$(aws ecs describe-services --cluster "$CLUSTER" --services "$SERVICE" --region "$REGION" \
       --query 'services[0].networkConfiguration' --output json)
CONTAINER_NAME=$(aws ecs describe-task-definition --task-definition "$TASK_DEF" --region "$REGION" \
       --query 'taskDefinition.containerDefinitions[0].name' --output text)

if [ "$DRY_RUN" = "true" ]; then
       echo "DRY_RUN set: skipping migration task and service deployment"
       exit 0
fi

echo "Running database migrations as a one-off task before deploying"
TASK_ARN=$(aws ecs run-task \
       --cluster "$CLUSTER" \
       --task-definition "$TASK_DEF" \
       --launch-type FARGATE \
       --network-configuration "$NETWORK_CONFIG" \
       --overrides "{\"containerOverrides\":[{\"name\":\"$CONTAINER_NAME\",\"command\":[\"bundle\",\"exec\",\"rake\",\"db:migrate\"]}]}" \
       --region "${REGION}" \
       --query 'tasks[0].taskArn' --output text)

echo "Waiting for migration task to finish: $TASK_ARN"
aws ecs wait tasks-stopped --cluster "$CLUSTER" --tasks "$TASK_ARN" --region "$REGION"

EXIT_CODE=$(aws ecs describe-tasks --cluster "$CLUSTER" --tasks "$TASK_ARN" --region "$REGION" \
       --query 'tasks[0].containers[0].exitCode' --output text)

if [ "$EXIT_CODE" != "0" ]; then
       echo "Migration task failed with exit code $EXIT_CODE. Aborting deploy."
       exit 1
fi

echo "Migrations succeeded"

echo "Force update service"
aws ecs update-service --cluster faux_oauth --service faux_oauth --force-new-deployment --region us-east-1