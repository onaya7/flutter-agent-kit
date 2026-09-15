# Flavor run and build commands. `make help` lists every target.

.DEFAULT_GOAL := help

.PHONY: run-dev run-staging run-prod \
	build-dev-apk build-staging-apk build-prod-apk \
	build-dev-aab build-staging-aab build-prod-aab \
	build-dev-ipa build-staging-ipa build-prod-ipa \
	clean help

run-dev: ## Run the development flavor
	fvm flutter run -t lib/main_development.dart --flavor development

run-staging: ## Run the staging flavor
	fvm flutter run -t lib/main_staging.dart --flavor staging

run-prod: ## Run the production flavor
	fvm flutter run -t lib/main_production.dart --flavor production

build-dev-apk: ## Build a debug development APK
	fvm flutter build apk -t lib/main_development.dart --flavor development --debug

build-staging-apk: ## Build a release staging APK
	fvm flutter build apk -t lib/main_staging.dart --flavor staging --release

build-prod-apk: ## Build a release production APK
	fvm flutter build apk -t lib/main_production.dart --flavor production --release

build-dev-aab: ## Build a debug development app bundle
	fvm flutter build appbundle -t lib/main_development.dart --flavor development --debug

build-staging-aab: ## Build a release staging app bundle
	fvm flutter build appbundle -t lib/main_staging.dart --flavor staging --release

build-prod-aab: ## Build a release production app bundle
	fvm flutter build appbundle -t lib/main_production.dart --flavor production --release

build-dev-ipa: ## Build a development IPA
	fvm flutter build ipa -t lib/main_development.dart --flavor development --debug

build-staging-ipa: ## Build a release staging IPA
	fvm flutter build ipa -t lib/main_staging.dart --flavor staging --release

build-prod-ipa: ## Build a release production IPA
	fvm flutter build ipa -t lib/main_production.dart --flavor production --release

clean: ## Remove build output and fetch packages again
	fvm flutter clean && fvm flutter pub get

help: ## List the available targets
	@grep -E '^[a-zA-Z0-9_-]+:.*## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'
