apk:
	flutter build apk --split-per-abi
apk1:
	flutter build apk --split-per-abi --obfuscate --split-debug-info=logs
apk2:
	flutter build appbundle --release --obfuscate --split-debug-info=logs
