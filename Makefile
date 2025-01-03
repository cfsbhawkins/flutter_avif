upgrade_all:
	cd flutter_avif; flutter pub upgrade --major-versions
	cd flutter_avif_linux; flutter pub upgrade --major-versions
	cd flutter_avif_macos; flutter pub upgrade --major-versions
	cd flutter_avif_windows; flutter pub upgrade --major-versions
	cd flutter_avif_platform_interface; flutter pub upgrade --major-versions

	melos bootstrap

upgrade_all_minors:
	cd flutter_avif; flutter pub upgrade
	cd flutter_avif_linux; flutter pub upgrade
	cd flutter_avif_macos; flutter pub upgrade
	cd flutter_avif_windows; flutter pub upgrade
	cd flutter_avif_platform_interface; flutter pub upgrade

	melos bootstrap