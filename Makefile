
refresh_env:
	@${PWD}/sh/refresh-env.sh

build_image:
	@${PWD}/sh/build_image.sh

run_tests:
	@${PWD}/test/run_all.sh

publish:
	@${PWD}/sh/publish_image.sh
