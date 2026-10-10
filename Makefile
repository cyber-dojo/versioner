
json_files:
	@${PWD}/bin/make_json_files.sh

dot_env_file:
	@${PWD}/bin/make_dot_env_file.sh

dot_env_md_file:
	@${PWD}/bin/make_dot_env_md_file.sh

all_files: json_files dot_env_file dot_env_md_file

service_image_tests:
	@${PWD}/test/service_image_tests.sh

build_image:
	@${PWD}/bin/build_image.sh

build_fake_image:
	@${PWD}/bin/build_fake_image.sh

# eg make push_platform_image arch=arm64
push_platform_image:
	@${PWD}/bin/push_platform_image.sh ${arch}

publish_image:
	@${PWD}/bin/publish_image.sh
