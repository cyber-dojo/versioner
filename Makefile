
refresh_env:
	@${PWD}/sh/refresh-env.sh

build_image:
	@${PWD}/sh/build_image.sh

run_tests:
	@${PWD}/test/run_all.sh

publish_service_images:
	@${PWD}/sh/publish_service_images.sh

publish_versioner_image:
	@${PWD}/sh/publish_versioner_image.sh
