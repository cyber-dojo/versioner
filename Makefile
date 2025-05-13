
# This requires credentials and can run only in a CI workflow
copy_prod_images_to_dockerhub:
	@${PWD}/sh/copy_prod_images_to_dockerhub.sh

json_files:
	@${PWD}/sh/make_json_files.sh

dot_env_file:
	@${PWD}/sh/make_dot_env_file.sh

dot_env_md_file:
	@${PWD}/sh/make_dot_env_md_file.sh

all_files: json_files dot_env_file dot_env_md_file

service_image_tests:
	@${PWD}/test/service_image_tests.sh

build_image:
	@${PWD}/sh/build_image.sh

publish_image:
	@${PWD}/sh/publish_image.sh
