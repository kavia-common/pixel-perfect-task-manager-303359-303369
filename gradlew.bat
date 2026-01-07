@echo off
REM This workspace does not include an Android Gradle project.
REM Some CI pipelines attempt to run `gradlew` unconditionally; treat as no-op.
IF EXIST android\gradlew.bat (
  CALL android\gradlew.bat %*
  EXIT /B %ERRORLEVEL%
)
echo No Android Gradle project found in this workspace; skipping Gradle task: %*
EXIT /B 0
