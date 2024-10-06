# Activewave/Elasticsearch Container

## Container Registry

https://ap-northeast-1.console.aws.amazon.com/ecr/repositories/private/188950198779/activewave/elasticsearch?region=ap-northeast-1


## How to run tests

```
$ source .venv/bin/activate
(.venv) $ pip install -r test_requirements.txt
(.venv) $ pytest
```

## How to build and push a new image

Pushing to dockerhub:
```
$ sh scripts/deploy_image_to_dockerhub.sh TAG
```

Pushing to AWS ECR:
```
$ sh scripts/deploy_image_to_ecr.sh TAG
```

Example:
```
$ scripts/deploy_image_to_dockerhub.sh 2.0.0
```


