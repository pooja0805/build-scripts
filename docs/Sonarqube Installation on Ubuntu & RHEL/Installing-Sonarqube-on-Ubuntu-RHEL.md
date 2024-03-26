# Installing SonarQube on Ubuntu & RHEL

The instructions provided below specify the steps to run [SonarQube](https://docs.sonarsource.com/sonarqube/latest/) 10.4.1 on IBM Power for:

* RHEL 
* Ubuntu 

### Step 1: Install SonarQube


#### 1.1) Install dependencies
  ```bash
  export HOME_DIR=$PWD
  ```
*  RHEL
    ```
    sudo yum install -y wget git unzip tar which net-tools curl gzip patch make gcc gcc-c++ java-17-openjdk-devel
    ```

*  Ubuntu
    ```
    sudo apt-get update
    sudo apt-get install -y wget git unzip tar net-tools xz-utils curl gzip patch locales make gcc g++ openjdk-17-jdk
    sudo locale-gen en_US.UTF-8
    ```

#### 1.2) Set JAVA_HOME & PATH environment variables
  ```bash
  export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-ppc64el
  export PATH=$JAVA_HOME/bin:$PATH
  java -version
  ```

### Step 2: Download and extract SonarQube and sonar-scanner-cli
```bash
cd $HOME_DIR
wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-10.4.1.88267.zip
unzip -q sonarqube-10.4.1.88267.zip
wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-5.0.1.3006-linux.zip
unzip -q sonar-scanner-cli-5.0.1.3006-linux.zip
```

### Step 3: Run SonarQube
```bash
sudo groupadd sonarqube      # If group is not already created
sudo usermod -aG sonarqube $(whoami)
sudo chown $(whoami):sonarqube -R $HOME_DIR/sonarqube-10.4.1.88267
export PATH=$PATH:$HOME_DIR/sonarqube-10.4.1.88267/bin/linux-x86-64
sonar.sh start
echo 'use `sonar.sh stop` to stop sonarqube'
```
_**Note:**_ SonarQube cannot be run as root on Unix-based systems, so create a dedicated user account to use for SonarQube if necessary which has standard permission rights, hence we have changed the owner in the above step. Click [here](https://docs.sonarqube.org/latest/setup/install-server/) to know more about configuration.

### Step 4: Testing SonarQube and sonar-scanner-cli

Modify `$HOME_DIR/sonar-scanner-5.0.1.3006-linux/bin/sonar-scanner` to use system JVM.
```bash
sed -i 's/use_embedded_jre=true/use_embedded_jre=false/g' $HOME_DIR/sonar-scanner-5.0.1.3006-linux/bin/sonar-scanner
```

Clone sample test cases
```bash
cd $HOME_DIR/
git clone https://github.com/SonarSource/sonar-scanning-examples.git
```

Scanner for java using gradle only needs sonarqube, The default username and password for sonarqube is `admin` and `admin`:
```
cd $HOME_DIR/sonar-scanning-examples/sonar-scanner-gradle/gradle-basic
./gradlew -Dsonar.host.url=http://localhost:9000 -Dsonar.login=<username> -Dsonar.password=<password> sonar

cd $HOME_DIR/sonar-scanning-examples/sonar-scanner-gradle/gradle-multimodule
./gradlew -Dsonar.host.url=http://localhost:9000 -Dsonar.login=<username> -Dsonar.password=<password> sonar

cd $HOME_DIR/sonar-scanning-examples/sonar-scanner-gradle/gradle-multimodule-coverage
./gradlew clean build codeCoverageReport -Dsonar.host.url=http://localhost:9000 -Dsonar.login=<username> -Dsonar.password=<password> sonar
```

For other languages, you can follow the following. For instance, for python, you can do:
```bash
cd $HOME_DIR/sonar-scanning-examples/sonar-scanner/src/python
$HOME_DIR/sonar-scanner-5.0.1.3006-linux/bin/sonar-scanner -Dsonar.projectKey=myproject -Dsonar.sources=. -Dsonar.login=<username> -Dsonar.password=<password>
```

Once the scanner completes, its analysis results will be posted to SonarQube server for viewing. Results can be accessed by pointing a supported browser to `http://<HOST_IP>:9000/`.

_**Note:**_
* _You can run scanner for JavaScript, PHP in the same way as above. Just make sure you are in the appropriate base directory of the project you are testing._
* _`nodejs` is required to run scanner for JavaScript, Download latest stable Node.js from [here](https://nodejs.org/en/download/current/)._

## References:
- https://docs.sonarsource.com/sonarqube/latest/
- https://docs.sonarsource.com/sonarqube/latest/analyzing-source-code/scanners/sonarscanner/
- https://docs.sonarsource.com/sonarqube/latest/analyzing-source-code/scanners/sonarscanner-for-gradle/
- https://docs.sonarsource.com/sonarqube/latest/analyzing-source-code/languages/javascript-typescript-css/
