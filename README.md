# Cortex Cloud CaaS App-Embedded Demo

This repository provides a fully functioning demonstration environment to showcase **Cortex Cloud (Prisma Cloud) Container as a Service (CaaS)** security capabilities. It is designed to be deployed on **AWS Fargate** using the App-Embedded Defender method.

## 🎯 Capabilities Showcased

1. **Vulnerability Exploit & Prevention (Spring4Shell):** The base image runs a vulnerable version of Apache Tomcat and Spring Framework (CVE-2022-22965).
2. **Malware Prevention (ELF Execution):** Contains a custom UI endpoint to download and execute an arbitrary ELF file, which the Cortex runtime policy will detect and block.
3. **Secret Scanning:** Hardcoded dummy AWS credentials are injected during the build process to trigger CI/CD or registry compliance alerts.

---

## 📂 Repository Structure

* `app/`: Contains the Java Spring application source code and the `pom.xml`.
* `Dockerfile`: The **Base Dockerfile** used to generate the Cortex App-Embedded Defender.
* `dummy-aws-creds.txt`: A plain text file containing dummy AWS keys used for the secret scanning demonstration.

---

## 🛠️ Prerequisites

* **Java 11 & Maven:** Installed locally to compile the Spring application.
* **Docker:** To build the final augmented container image.
* **Cortex / Prisma Cloud Console Access:** To generate the App-Embedded Dockerfile and configure runtime policies.
* **AWS CLI & Account:** To push to Amazon ECR and deploy to ECS Fargate.

---

## 🚀 Setup & Deployment Guide

### 1. Build the Spring Application
Navigate to the `app/` directory and compile the project into a `.war` file:
```bash
cd app
mvn clean package

```

*This will generate the compiled application at `app/target/helloworld.war`.*

### 2. Generate the App-Embedded Defender

AWS Fargate requires the Cortex agent to be embedded directly into the container image.

1. Log into your Cortex Cloud console.
2. Navigate to **Manage > Defenders > Deploy > Manual Deploy**.
3. Select **Single Defender** > **Container Defender - App-Embedded Defender** > **Dockerfile**.
4. Upload the `Dockerfile` from the root of this repository.
5. Provide an **App ID** (e.g., `fargate-cortex-demo`).
6. Click **Create embedded ZIP** and download the package.

### 3. Build the Protected Docker Image

1. Extract the downloaded `.zip` file into the root of this repository. This will overwrite the original `Dockerfile` with the augmented version and add the necessary Cortex binaries (`twistlock_defender`).
2. Build the final image:

```bash
docker build -t your-ecr-repo-uri/cortex-fargate-demo:latest .

```

### 4. Push and Deploy

1. Push the image to your AWS Elastic Container Registry (ECR):

```bash
docker push your-ecr-repo-uri/cortex-fargate-demo:latest

```

2. Deploy the image as a standard **AWS ECS Fargate Task**. Ensure port `8080` is exposed in your Task Definition and Security Groups.

---

## 🧪 Testing the Defenses

Once the container is running in Fargate, you can demonstrate the following capabilities:

### Secret Scanning

* **How to verify:** Navigate to the Cortex Console > **Monitor > Vulnerabilities > Images**.
* **Expected Result:** Cortex will flag the image with a compliance violation for the exposed AWS Access Keys located at `/opt/secrets/aws-credentials.txt`.

### Malware Execution Prevention

* **How to verify:** Open your browser and navigate to the Fargate public IP or Load Balancer on port `8080`:
`http://<FARGATE_IP>:8080/malware-ui`
* Enter the URL of a test ELF malware sample and click **Download & Execute**.
* **Expected Result:** The web UI will show an execution error. Navigate to the Cortex Console under **Monitor > Events > App-Embedded Audits** to see the runtime block event triggered by the unauthorized ELF execution.