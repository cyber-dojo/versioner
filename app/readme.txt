
The .env file contains the current env-vars for a cyber-dojo deployment.

It contains DIGEST entries, eg
CYBER_DOJO_CUSTOM_START_POINTS_DIGEST=d843afb875821b609342c2a1a04d3b8989fb15f3880fabde1756e51158d2da91

These are not correct.
They are the digests for the images on the private ECR registry.
They need to be the digests for the public images on dockerhub.
This will get fixed at some point.

One possibility is to use a workflow to:
- get Kosli snapshot of aws-prod
- docker tag each image ready for dockerhub push
- do docker push for each image and collect the digest
- create a local (inside the workflow) .env file
- create a versioner image containing the .env file
- push the versioner image to dockerhub
