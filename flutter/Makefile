
FLUTTER_VERSION := $(shell (cat pubspec.yaml | grep 'flutter:' | head -n 1 | awk -F ": " '{print $$2}'))
setup:
	dart pub global activate fvm
	fvm install $(FLUTTER_VERSION)
	fvm use $(FLUTTER_VERSION)
	fvm flutter pub get
	fvm flutter precache --ios --android
	$(MAKE) clean

analyze:
	fvm flutter analyze

.PHONY: format 
format:
	fvm dart format lib/

.PHONY: format-analyze
format-analyze:
	fvm flutter format --dry-run lib/
	fvm flutter analyze

.PHONY: build-runner
build-runner:
	fvm flutter packages pub run build_runner build --delete-conflicting-outputs

w:
	fvm dart run build_runner watch --delete-conflicting-outputs

staging-apk:
	fvm flutter build apk --flavor staging --target lib/main_staging.dart $(if $(BITRISE_BUILD_NUMBER),--build-number $(BITRISE_BUILD_NUMBER),)

.PHONY: build-android-dev
development-apk:
	fvm flutter build apk --flavor development --target lib/main_development.dart --release

.PHONY: build-android-prd
production-apk:
	fvm flutter build apk --release --flavor production --target lib/main_production.dart

production-aab:
	fvm flutter build appbundle --release --flavor production --target lib/main_production.dart


development-adhoc:
	fvm flutter build ipa --export-options-plist $(PWD)/ios/export_options/development_release.plist -t lib/main_development.dart --flavor development $(if $(BITRISE_BUILD_NUMBER),--build-number $(BITRISE_BUILD_NUMBER),)

.PHONY: build-ios-staging
staging-adhoc:
	fvm flutter build ipa --export-options-plist ios/export_options/staging_release.plist --flavor staging --target lib/main_staging.dart $(if $(BITRISE_BUILD_NUMBER),--build-number $(BITRISE_BUILD_NUMBER),)


production-appstore:
	fvm flutter build ipa --export-options-plist ios/export_options/production_store.plist --flavor production --target lib/main_production.dart $(if $(BITRISE_BUILD_NUMBER),--build-number $(BITRISE_BUILD_NUMBER),)
production-adhoc:
	fvm flutter build ipa --export-options-plist ios/export_options/production_release.plist --flavor production --target lib/main_production.dart $(if $(BITRISE_BUILD_NUMBER),--build-number $(BITRISE_BUILD_NUMBER),)


create-splash:
	fvm flutter pub run flutter_native_splash:create

clean:
	rm ios/Podfile.lock | true
	rm -rf ios/Pods/ | true
	rm -rf ios/Runner.xcworkspace/ | true
	rm ios/Flutter/Flutter.podspec | true
	rm -rf ~/Library/Developer/Xcode/DerivedData/ | true
	rm pubspec.lock | true
	fvm flutter clean
	fvm flutter pub get
	unameOut=$$(uname -s); \
	if [ "$$unameOut" = "Darwin" ]; then \
	  cd ios && pod install; \
	fi

g:
	fvm flutter pub run easy_localization:generate --source-dir assets/translations -o ../gen/codegen_loader.g.dart
	fvm flutter pub run easy_localization:generate -S assets/translations -f keys -o ../gen/locale_keys.g.dart

c:
	fvm flutter clean
	fvm flutter pub get

get:
	fvm flutter pub get

icons:
    fvm flutter pub run flutter_launcher_icons:main -f flutter_launcher_icons.yaml