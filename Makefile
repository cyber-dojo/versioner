

# These all require credentials and can run only in the CI workflow

publish_service_images:
	@${PWD}/sh/publish_service_images.sh

json_files:
	@${PWD}/sh/make_json_files.sh

dot_env_file:
	@${PWD}/sh/make_dot_env_file.sh

dot_env_md_file:
	@${PWD}/sh/make_dot_env_md_file.sh

service_image_tests:
	@${PWD}/test/service_image_tests.sh

build_versioner_image:
	@${PWD}/sh/build_image.sh

