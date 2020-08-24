# Android Docker image 
### Continous Integration (CI) for Android apps on GitLab
An image for building Android apps with support for multiple SDK Build Tools. This Docker image contains the Android SDK and most common packages necessary for building Android apps in a CI tool.

### Note
Please change the last line of Docker file whenever an update happen. The returned string used as tag name for uploaded registry image.

## Sample usages
### GitLab
*.gitlab-ci.yml*

```yml
image: chapp/android-ci:tag

before_script:
    - export GRADLE_USER_HOME=`pwd`/.gradle
    - chmod +x ./gradlew

cache:
  key: "$CI_COMMIT_REF_NAME"
  paths:
     - .gradle/

stages:
  - build

build:
  stage: build
  script:
     - ./gradlew assembleDebug
  artifacts:
    paths:
      - app/build/outputs/apk/
```