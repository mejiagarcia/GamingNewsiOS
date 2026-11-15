#!/bin/bash

set -euo pipefail

VERBOSE=0
XCODEBUILD_VERBOSE_ARGS=()
ALTOOL_VERBOSE_ARGS=()

for argument in "$@"; do
	case "$argument" in
		--verbose|-v)
			VERBOSE=1
			;;
		--help|-h)
			printf 'Usage: %s [--verbose|-v]\n' "${0##*/}"
			printf 'Archive the app, export it, and upload it to TestFlight.\n'
			exit 0
			;;
		*)
			printf 'Unknown option: %s\nUsage: %s [--verbose|-v]\n' "$argument" "${0##*/}" >&2
			exit 2
			;;
	esac
done

if [[ "$VERBOSE" -eq 1 ]]; then
	XCODEBUILD_VERBOSE_ARGS=(-verbose)
	ALTOOL_VERBOSE_ARGS=(--verbose)
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT_PATH="$PROJECT_ROOT/GamingNews-26.xcodeproj"
SCHEME="GamingNews"
PROJECT_FILE="$PROJECT_PATH/project.xcproj"
EXPORT_OPTIONS="$SCRIPT_DIR/ExportOptions.plist"
ENV_FILE="$PROJECT_ROOT/.env"
BUILD_DIRECTORY="$PROJECT_ROOT/build/TestFlight"
ARCHIVE_PATH="$BUILD_DIRECTORY/GamingNews.xcarchive"
EXPORT_PATH="$BUILD_DIRECTORY/export"
PROJECT_RELATIVE_PATH="GamingNews-26.xcodeproj/project.xcproj"
GIT_ROOT="$(git -C "$PROJECT_ROOT" rev-parse --show-toplevel)"
RELEASE_PARENT="$(git -C "$PROJECT_ROOT" rev-parse HEAD)"

if [[ "$GIT_ROOT" != "$PROJECT_ROOT" ]]; then
	printf 'Expected the Xcode project to be at the Git repository root.\n' >&2
	exit 1
fi

if ! git -C "$PROJECT_ROOT" var GIT_AUTHOR_IDENT >/dev/null; then
	printf 'Configure your Git author name and email before creating a release commit.\n' >&2
	exit 1
fi

if [[ ! -f "$ENV_FILE" ]]; then
	printf 'Configuration file not found: %s (copy .env.example to .env and fill it in)\n' "$ENV_FILE" >&2
	exit 1
fi

set -a
# shellcheck disable=SC1090
source "$ENV_FILE"
set +a

required_variables=(
	ASC_API_KEY_ID
	ASC_ISSUER_ID
	ASC_API_PRIVATE_KEY_PATH
	IOS_PROVISIONING_PROFILE_PATH
)

for variable_name in "${required_variables[@]}"; do
	if [[ -z "${!variable_name:-}" ]]; then
		printf 'Missing required environment variable: %s\n' "$variable_name" >&2
		exit 1
	fi
done

for file_path_variable in ASC_API_PRIVATE_KEY_PATH IOS_PROVISIONING_PROFILE_PATH; do
	file_path="${!file_path_variable}"
	if [[ ! -f "$file_path" ]]; then
		printf 'File configured by %s does not exist: %s\n' "$file_path_variable" "$file_path" >&2
		exit 1
	fi
done

if [[ ! -f "$PROJECT_FILE" ]]; then
	printf 'Xcode project file not found: %s\n' "$PROJECT_FILE" >&2
	exit 1
fi

mkdir -p "$BUILD_DIRECTORY"

PROFILE_CONTENT="$BUILD_DIRECTORY/ProvisioningProfile.plist"
security cms -D -i "$IOS_PROVISIONING_PROFILE_PATH" > "$PROFILE_CONTENT"
PROFILE_UUID="$(/usr/libexec/PlistBuddy -c 'Print :UUID' "$PROFILE_CONTENT")"
PROFILE_TEAM_ID="$(/usr/libexec/PlistBuddy -c 'Print :TeamIdentifier:0' "$PROFILE_CONTENT")"

INSTALLED_PROFILES_DIRECTORY="$HOME/Library/MobileDevice/Provisioning Profiles"
mkdir -p "$INSTALLED_PROFILES_DIRECTORY"
cp "$IOS_PROVISIONING_PROFILE_PATH" "$INSTALLED_PROFILES_DIRECTORY/$PROFILE_UUID.mobileprovision"

RESOLVED_EXPORT_OPTIONS="$BUILD_DIRECTORY/ExportOptions.plist"
sed \
	-e "s/__PROVISIONING_PROFILE_UUID__/$PROFILE_UUID/" \
	-e "s/__TEAM_ID__/$PROFILE_TEAM_ID/" \
	"$EXPORT_OPTIONS" > "$RESOLVED_EXPORT_OPTIONS"

read -r previous_build_number next_build_number marketing_version < <(
	python3 - "$PROJECT_FILE" <<'PY'
import re
import sys
from pathlib import Path

project_path = Path(sys.argv[1])
project_text = project_path.read_text()
app_target = re.search(
    r'("name": "GamingNews",.*?"build-settings": \{.*?"CURRENT_PROJECT_VERSION": ")([0-9]+)(")',
    project_text,
    re.DOTALL,
)
marketing_setting = re.search(
    r'("name": "GamingNews",.*?"build-settings": \{.*?"MARKETING_VERSION": ")([^"]+)(")',
    project_text,
    re.DOTALL,
)

if app_target is None or marketing_setting is None:
    raise SystemExit("Could not find the app version settings in project.xcproj")

previous = int(app_target.group(2))
next_number = previous + 1
updated_text = project_text[:app_target.start(2)] + str(next_number) + project_text[app_target.end(2):]
project_path.write_text(updated_text)
print(previous, next_number, marketing_setting.group(2))
PY
)

RELEASE_TAG="v${marketing_version}-build.${next_build_number}"
UPLOAD_SUCCEEDED=0

rollback_build_number() {
	exit_status=$?

	if [[ "$exit_status" -ne 0 ]]; then
		if [[ "$UPLOAD_SUCCEEDED" -eq 1 ]]; then
			printf 'Upload succeeded; keeping build %s despite the later Git operation failure.\n' "$next_build_number" >&2
		elif python3 - "$PROJECT_FILE" "$previous_build_number" "$next_build_number" <<'PY'
import re
import sys
from pathlib import Path

project_path = Path(sys.argv[1])
previous = sys.argv[2]
expected_current = sys.argv[3]
project_text = project_path.read_text()
app_target = re.search(
    r'("name": "GamingNews",.*?"build-settings": \{.*?"CURRENT_PROJECT_VERSION": ")([0-9]+)(")',
    project_text,
    re.DOTALL,
)

if app_target is None or app_target.group(2) != expected_current:
    raise SystemExit("Build number changed during the release; leaving it untouched")

restored_text = project_text[:app_target.start(2)] + previous + project_text[app_target.end(2):]
project_path.write_text(restored_text)
PY
		then
			printf 'Release failed; reverted build number to %s.\n' "$previous_build_number" >&2
		else
			printf 'Release failed; automatic build-number rollback failed.\n' >&2
		fi
	fi

	return "$exit_status"
}

trap rollback_build_number EXIT

if git -C "$PROJECT_ROOT" rev-parse --verify --quiet "refs/tags/$RELEASE_TAG" >/dev/null; then
	printf 'Release tag already exists: %s\n' "$RELEASE_TAG" >&2
	exit 1
fi

commit_release() (
	set -euo pipefail

	if [[ "$(git -C "$PROJECT_ROOT" rev-parse HEAD)" != "$RELEASE_PARENT" ]]; then
		printf 'HEAD changed during the release; refusing to create the release commit.\n' >&2
		exit 1
	fi

	TEMP_INDEX="$(mktemp "$BUILD_DIRECTORY/release-index.XXXXXX")"
	COMMIT_PROJECT_FILE="$BUILD_DIRECTORY/committed-project.xcproj"
	trap 'rm -f "$TEMP_INDEX" "$COMMIT_PROJECT_FILE"' EXIT

	git -C "$PROJECT_ROOT" show "$RELEASE_PARENT:$PROJECT_RELATIVE_PATH" > "$COMMIT_PROJECT_FILE"
	python3 - "$COMMIT_PROJECT_FILE" "$next_build_number" <<'PY'
import re
import sys
from pathlib import Path

project_path = Path(sys.argv[1])
next_build_number = sys.argv[2]
project_text = project_path.read_text()
app_target = re.search(
    r'("name": "GamingNews",.*?"build-settings": \{.*?"CURRENT_PROJECT_VERSION": ")([0-9]+)(")',
    project_text,
    re.DOTALL,
)

if app_target is None:
    raise SystemExit("Could not find the app build number in the parent commit")

updated_text = project_text[:app_target.start(2)] + next_build_number + project_text[app_target.end(2):]
project_path.write_text(updated_text)
PY

	PROJECT_BLOB="$(git -C "$PROJECT_ROOT" hash-object -w "$COMMIT_PROJECT_FILE")"
	rm -f "$TEMP_INDEX"
	GIT_INDEX_FILE="$TEMP_INDEX" git -C "$PROJECT_ROOT" read-tree "$RELEASE_PARENT"
	GIT_INDEX_FILE="$TEMP_INDEX" git -C "$PROJECT_ROOT" update-index --add --cacheinfo "100644,$PROJECT_BLOB,$PROJECT_RELATIVE_PATH"
	GIT_INDEX_FILE="$TEMP_INDEX" git -C "$PROJECT_ROOT" commit -m "chore: bump build number to $next_build_number"
	git -C "$PROJECT_ROOT" tag -a "$RELEASE_TAG" -m "TestFlight build $next_build_number"
)

printf 'Incremented build number: %s → %s\n' "$previous_build_number" "$next_build_number"

rm -rf "$ARCHIVE_PATH" "$EXPORT_PATH"

xcodebuild \
	"${XCODEBUILD_VERBOSE_ARGS[@]}" \
	-project "$PROJECT_PATH" \
	-scheme "$SCHEME" \
	-configuration Release \
	-destination 'generic/platform=iOS' \
	-archivePath "$ARCHIVE_PATH" \
	CODE_SIGN_STYLE=Manual \
	DEVELOPMENT_TEAM="$PROFILE_TEAM_ID" \
	PROVISIONING_PROFILE_SPECIFIER="$PROFILE_UUID" \
	GAMING_NEWS_IGDB_CLIENT_ID="${GAMING_NEWS_IGDB_CLIENT_ID:-}" \
	GAMING_NEWS_IGDB_CLIENT_SECRET="${GAMING_NEWS_IGDB_CLIENT_SECRET:-}" \
	archive

xcodebuild \
	"${XCODEBUILD_VERBOSE_ARGS[@]}" \
	-exportArchive \
	-archivePath "$ARCHIVE_PATH" \
	-exportPath "$EXPORT_PATH" \
	-exportOptionsPlist "$RESOLVED_EXPORT_OPTIONS"

IPA_PATH="$EXPORT_PATH/GamingNews.ipa"

if [[ ! -f "$IPA_PATH" ]]; then
	printf 'Export did not produce the expected IPA: %s\n' "$IPA_PATH" >&2
	exit 1
fi

xcrun altool \
	"${ALTOOL_VERBOSE_ARGS[@]}" \
	--upload-app \
	--type ios \
	--file "$IPA_PATH" \
	--apiKey "$ASC_API_KEY_ID" \
	--apiIssuer "$ASC_ISSUER_ID" \
	--p8-file-path "$ASC_API_PRIVATE_KEY_PATH"

UPLOAD_SUCCEEDED=1
printf 'Uploaded build %s to TestFlight.\n' "$next_build_number"

commit_release

printf 'Created release commit and tag %s.\n' "$RELEASE_TAG"
