#!/data/data/com.termux/files/usr/bin/bash
# setup_eli_full.sh
# ساخت پروژه ساده اندروید eli با یک صفحه و یک دکمه
# آماده برای GitHub Actions

set -e

PROJECT_DIR=~/eli

echo "📦 ساخت پوشه پروژه eli..."
mkdir -p $PROJECT_DIR/app/src/main/java/com/example/eli
mkdir -p $PROJECT_DIR/app/src/main/res/layout

echo "📝 ساخت فایل settings.gradle..."
cat > $PROJECT_DIR/settings.gradle <<EOL
rootProject.name = 'eli'
include ':app'
EOL

echo "📝 ساخت فایل gradle.properties..."
cat > $PROJECT_DIR/gradle.properties <<EOL
org.gradle.jvmargs=-Xmx1536m
EOL

echo "📝 ساخت فایل app/build.gradle..."
cat > $PROJECT_DIR/app/build.gradle <<EOL
plugins {
    id 'com.android.application' version '8.0.2' apply false
}

android {
    namespace 'com.example.eli'
    compileSdk 34

    defaultConfig {
        applicationId "com.example.eli"
        minSdk 21
        targetSdk 34
        versionCode 1
        versionName "1.0"
    }

    buildTypes {
        release {
            minifyEnabled false
        }
    }
}
EOL

echo "📝 ساخت AndroidManifest.xml..."
cat > $PROJECT_DIR/app/src/main/AndroidManifest.xml <<EOL
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.example.eli">

    <application
        android:allowBackup="true"
        android:label="eli"
        android:supportsRtl="true"
        android:theme="@android:style/Theme.Material.Light.NoActionBar">
        <activity android:name=".MainActivity"
            android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
    </application>

</manifest>
EOL

echo "📝 ساخت MainActivity.java..."
cat > $PROJECT_DIR/app/src/main/java/com/example/eli/MainActivity.java <<EOL
package com.example.eli;

import android.app.Activity;
import android.os.Bundle;
import android.widget.Button;
import android.widget.Toast;

public class MainActivity extends Activity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        Button btn = findViewById(R.id.button);
        btn.setOnClickListener(v -> Toast.makeText(this, "سلام Eli!", Toast.LENGTH_SHORT).show());
    }
}
EOL

echo "📝 ساخت activity_main.xml..."
cat > $PROJECT_DIR/app/src/main/res/layout/activity_main.xml <<EOL
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:orientation="vertical"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:gravity="center">

    <Button
        android:id="@+id/button"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:text="کلیک کن!" />
</LinearLayout>
EOL

echo "📦 ساخت Gradle Wrapper..."
# بدون استفاده از gradle نصب شده روی Termux
cd $PROJECT_DIR
mkdir -p gradle/wrapper
cat > gradle/wrapper/gradle-wrapper.properties <<EOL
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
distributionUrl=https\://services.gradle.org/distributions/gradle-8.2-bin.zip
EOL

# gradlew برای اجرای Wrapper
cat > gradlew <<'EOL'
#!/bin/sh
DIR="$(cd "$(dirname "$0")" && pwd)"
java -jar "$DIR/gradle/wrapper/gradle-wrapper.jar" "$@"
EOL
chmod +x gradlew

echo "📁 ساخت پوشه workflow و فایل android-build.yml..."
mkdir -p .github/workflows
cat > .github/workflows/android-build.yml <<EOL
name: Build APK

on:
  push:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout
      uses: actions/checkout@v4

    - name: Set up JDK
      uses: actions/setup-java@v3
      with:
        distribution: temurin
        java-version: 17

    - name: Build APK
      run: ./gradlew :app:assembleDebug
EOL

echo "✅ پروژه eli آماده و workflow ساخته شد."
