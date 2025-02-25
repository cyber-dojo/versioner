
# These can run locally, before commit and CI workflow run

refresh_env:
	@${PWD}/sh/refresh_env.sh

pre_service_image_tests:
	@${PWD}/test/pre_service_image_tests.sh

build_versioner_image:
	@${PWD}/sh/build_image.sh

all_local: refresh_env pre_service_image_tests build_versioner_image

# These require credentials and can run only in the CI workflow

publish_service_images:
	@${PWD}/sh/publish_service_images.sh

post_service_image_tests:
	@${PWD}/test/post_service_image_tests.sh

publish_versioner_image:
	@${PWD}/sh/publish_versioner_image.sh


