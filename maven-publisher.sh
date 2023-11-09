#!/bin/bash

GROUP_ID="nuvoola-auto-test"
 ARTIFACT_ID="nuvoola-uiauto"
 GITHUB_OWNER="nuvoola"
 GITHUB_REPO="nuv-mvn-test-packages"
 VERSION=1.0
 # Update FILE with actual.
 # FILE=/home/murali/workspace/nuvoola-uiauto/target/nuvoola-uiauto-1.0.jar
 PACKAGING=jar
 POM=/home/murali/workspace/nuvoola-uiauto/pom.xml
#
# Leave POM empty to use default.
# You can use POM to describe dependencies of your artifact.

TMP_REPO="$HOME/.git2m2/$GITHUB_OWNER/$GITHUB_REPO"
REPO="https://github.com/$GITHUB_OWNER/$GITHUB_REPO"

ensureLocalRepo()
{
    if [ -d "$TMP_REPO" ]; then
        echo "Pulling latest changed from $REPO into $TMP_REPO"
        pushd "$TMP_REPO"
        git pull
        popd
    else
        echo "Cloning from $REPO into $TMP_REPO"
        git clone "$REPO" "$TMP_REPO"
    fi
}

generateMavenArtifact()
{
    echo "Generating artifacts for $GROUP_ID/$ARTIFACT_ID/$VERSION from $FILE into $REPO"

    if [ -z "$POM" ]; then
        mvn deploy:deploy-file -DgroupId="$GROUP_ID" -DartifactId="$ARTIFACT_ID" \
            -Dversion="$VERSION" -Dfile="$FILE" -Dpackaging="$PACKAGING" -DgeneratePom=true -DcreateChecksum=true \
            -Durl="file:///$TMP_REPO/.m2" -e
    else 
        echo "Using POM file $POM:"
        cat "$POM"
        mvn deploy:deploy-file -DgroupId="$GROUP_ID" -DartifactId="$ARTIFACT_ID" \
            -Dversion="$VERSION" -Dfile="$FILE" -Dpackaging="$PACKAGING" -DgeneratePom=true -DcreateChecksum=true \
            -Durl="file:///$TMP_REPO/.m2" -DpomFile="$POM" -e
    fi
    echo "Maven artifact successfully generated"
}

commitAndPushChanges()
{
    pushd "$TMP_REPO"

    echo "Adding all changes to git"
    git add -A 
    git commit -m "Release $GROUP_ID/$ARTIFACT_ID version $VERSION"

    echo "Pushing to $REPO"
    git push

    popd
}

printRepoPath()
{
    echo "============================"
    echo "Your Maven URL is https://github.com/$GITHUB_OWNER/$GITHUB_REPO/tree/master/.m2"
    echo "============================"
}

set -e
ensureLocalRepo
generateMavenArtifact
commitAndPushChanges
printRepoPath
set +e
