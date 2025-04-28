

# These all require credentials and can run only in the CI workflow

json_files:
	@${PWD}/sh/make_json_files.sh

dot_env_file:
	@${PWD}/sh/make_dot_env_file.sh

dot_env_md_file:
	@${PWD}/sh/make_dot_env_md_file.sh

service_image_tests:
	@${PWD}/test/service_image_tests.sh

build_image:
	@${PWD}/sh/build_image.sh

publish_image:
	@${PWD}/sh/publish_image.sh
