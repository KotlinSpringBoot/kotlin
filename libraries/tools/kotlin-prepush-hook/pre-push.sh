#!/bin/sh

targetRepo="$2"

remoteRefs=""

javacPath="$JAVA_HOME/bin/javac"
javaPath="$JAVA_HOME/bin/java"

if [[ ! -f "./libraries/tools/kotlin-prepush-hook/src/KotlinPrePushHook.java" ]]; then
    echo "Pre-commit hook .java file was not found in current branch, pre-push hook is disabled"
    exit 0
fi

if [[ ! -f $javaPath ]]; then
    echo "'java' ($javaPath) was not found, pre-push hook is disabled"
    exit 0
fi

if [[ ! -f $javacPath ]]; then
    echo "'javac' ($javacPath) was not found, pre-push hook is disabled"
    exit 0
fi

while read localRef localSha remoteRef remoteSha
do
    if [[ $remoteRef == "refs/heads/rr/"* || $remoteRef == "refs/heads/rrr/"* ]]; then
        continue
    fi

    if [ -z $remoteRefs ]; then
        remoteRefs="$remoteRef"
    else
        remoteRefs="$remoteRefs,$remoteRef"
    fi
done

if [[ -z $remoteRefs ]]; then
    exit 0
fi

echo $remoteRefs

mkdir -p ./build/prePushHook
javac -d ./build/prePushHook ./libraries/tools/kotlin-prepush-hook/src/KotlinPrePushHook.java
cd ./build/prePushHook

java KotlinPrePushHook $remoteRefs $targetRepo
returnCode=$?

cd ../..

exit $returnCode