# Calendar

Calendar is a HarmonyOS sample app built with ArkTS.

## Features

- Month, week, and day calendar views
- Create, edit, view, and delete schedules
- Reminder support for events

## Project Structure

```text
calendar1/
|- AppScope/
|- entry/
|  |- src/main/ets/
|  |- src/main/resources/
|- hvigor/
|- build-profile.json5
```

## Development Environment

- DevEco Studio
- HarmonyOS SDK 6.0.0(20)

## Run Locally

1. Open the project in DevEco Studio.
2. Wait for dependency sync to finish.
3. Connect a HarmonyOS device or start an emulator.
4. Click `Run` to launch the app.

## Build

Use DevEco Studio:

```text
Build -> Build Hap(s)/APP(s) -> Build Hap(s)
```

Or use the helper scripts:

```bash
build.bat
```

```bash
chmod +x build.sh
./build.sh
```

Or use the command line:

```bash
hvigorw assembleHap --mode module -p product=default --analyze
```

```bash
hvigorw assembleHap --mode module -p product=default --analyze -p buildMode=release
```

## Output

- Debug: `entry/build/default/outputs/default/entry-default-debug.hap`
- Release: `entry/build/default/outputs/default/entry-default-release.hap`

## Notes

- Local generated folders such as `oh_modules`, `.hvigor`, `.idea`, and `build` are not intended for upload.
- The root `README.md` is included so the repository homepage shows a project overview.
