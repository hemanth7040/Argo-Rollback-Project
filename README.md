# AWS DevOps Project – End-to-End CI/CD on Amazon EKS

## Project Overview

This project is an end-to-end AWS DevOps implementation focused on automating infrastructure provisioning, application deployment, progressive delivery, and Kubernetes monitoring.

The goal was to bring together commonly used DevOps tools and understand how they work together in a practical deployment workflow.

Rather than provisioning infrastructure, building Docker images, deploying applications, and monitoring everything manually, I wanted to automate the complete process as much as possible.

### Technologies Used

- **AWS:** VPC, EC2, IAM, EKS, ECR, NAT Gateway
- **Infrastructure as Code:** Terraform
- **Containerization:** Docker
- **CI:** GitHub Actions
- **Authentication:** GitHub Actions OIDC and IRSA
- **GitOps:** Argo CD
- **Image Automation:** Argo CD Image Updater
- **Kubernetes Configuration:** Kustomize
- **Progressive Delivery:** Argo Rollouts
- **Package Management:** Helm
- **Monitoring:** Prometheus and Grafana
- **Alerting:** Alertmanager
- **Endpoint Monitoring:** Blackbox Exporter

---

# 1. AWS Infrastructure Provisioning – Terraform

### Why Terraform?

Before deploying an application, we need infrastructure to run it.

Creating VPCs, subnets, route tables, security groups, IAM roles, and EKS manually through the AWS Console takes time and makes it difficult to reproduce the same environment.

I used Terraform to define and provision AWS infrastructure as code.

### What I provisioned

**VPC**

Created a dedicated Virtual Private Cloud to isolate the project's AWS resources.

**Public and Private Subnets**

Created public and private subnets across Availability Zones.

- Public subnets are used for internet-facing resources.
- Private subnets are used for resources that should not be directly exposed to the internet.

**Internet Gateway**

Provides internet connectivity to resources in public subnets.

**NAT Gateway**

Allows resources in private subnets to initiate outbound internet connections without exposing them directly to the internet.

**Route Tables**

Configured routing rules to control traffic between subnets and external networks.

**Security Groups**

Configured network-level access rules to control inbound and outbound traffic.

**IAM Roles and Policies**

Created the IAM permissions required by AWS services and the EKS environment.

**Amazon EKS**

Provisioned an Amazon Elastic Kubernetes Service cluster to run containerized applications.

**EKS Node Groups**

Configured worker nodes to provide compute capacity for Kubernetes workloads.

### Why this approach?

Terraform makes infrastructure repeatable, version-controlled, and easier to maintain. It also reduces the need to manually recreate resources.

---

# 2. Docker – Application Containerization

### Why Docker?

An application needs a consistent runtime environment.

Without containerization, differences between development, testing, and production environments can lead to compatibility issues.

I used Docker to package the application and its required dependencies into a container image.

### How it works

1. Application source code is maintained in GitHub.
2. A Dockerfile defines how the application image is built.
3. Docker packages the application and its dependencies.
4. The resulting image is ready to be pushed to Amazon ECR.
5. Kubernetes uses this image to run application containers.

### Why this approach?

Docker provides a consistent application package that can run across different environments, provided the container runtime and architecture are compatible.

---

# 3. Amazon ECR – Container Image Registry

### Why Amazon ECR?

After building a Docker image, we need a place to store it so Kubernetes can pull it during deployment.

I used Amazon Elastic Container Registry (ECR) as the private container image registry.

### How it works

1. GitHub Actions builds the Docker image.
2. The workflow authenticates with Amazon ECR.
3. The image is tagged using the Git commit SHA.
4. The image is pushed to the ECR repository.
5. EKS workloads can pull the image from ECR.

### Why use Git SHA as the image tag?

Using a Git commit SHA gives each image a traceable identifier. It helps identify which source-code revision was used to build a particular image and avoids relying only on mutable tags such as `latest`.

---

# 4. GitHub Actions – CI Automation

### Why GitHub Actions?

Building and pushing Docker images manually after every code change is repetitive.

I used GitHub Actions to automate the image build and push process.

### Workflow execution

1. A code change is pushed to the `main` branch.
2. GitHub Actions detects changes in the application directory or workflow file.
3. The workflow checks out the repository.
4. AWS credentials are configured using OIDC.
5. The workflow verifies the AWS identity.
6. It authenticates with Amazon ECR.
7. Docker Buildx builds the application image.
8. The image is pushed to Amazon ECR with the Git commit SHA as its tag.

### Why this approach?

It reduces manual effort and provides a repeatable process for building and publishing application images.

---

# 5. GitHub Actions OIDC – Secure AWS Authentication

### Why OIDC instead of static AWS keys?

Storing permanent AWS Access Keys and Secret Access Keys in GitHub Secrets creates an additional credential-management responsibility.

I implemented OpenID Connect (OIDC) between GitHub Actions and AWS IAM.

### How it works

1. GitHub Actions starts a workflow.
2. GitHub generates an OIDC identity token for the workflow.
3. AWS IAM validates the token using the configured GitHub OIDC identity provider.
4. The IAM role trust policy checks the permitted repository and branch identity.
5. If the identity matches the trust policy, AWS STS allows the workflow to assume the IAM role.
6. GitHub Actions receives temporary AWS credentials.
7. The workflow uses those credentials to access permitted AWS resources, such as Amazon ECR.

### Why this approach?

- No need to store permanent AWS access keys in GitHub Secrets.
- Temporary credentials are used for the workflow.
- IAM trust policies restrict which GitHub repository and branch can assume the role.
- AWS permissions can be controlled through IAM policies.

This provides a more secure approach to CI/CD authentication.

---

# 6. IAM Roles for Service Accounts (IRSA)

### Why IRSA?

Applications running inside Kubernetes sometimes need to access AWS services.

Giving broad AWS permissions to worker nodes is not ideal because multiple workloads may share the same nodes.

I implemented IAM Roles for Service Accounts (IRSA) to provide AWS permissions to Kubernetes workloads through their associated service accounts.

### How IRSA works

1. An IAM OIDC identity provider is associated with the EKS cluster.
2. An IAM role is created with a trust policy that identifies the permitted Kubernetes service account.
3. The required AWS permissions are attached to the IAM role.
4. A Kubernetes service account is associated with that IAM role.
5. The application pod uses the service account.
6. The workload obtains temporary AWS credentials through the EKS identity integration.
7. The application can access only the AWS resources permitted by the IAM role.

### Why this approach?

- Avoids storing long-lived AWS credentials inside application containers.
- Provides workload-level IAM permissions.
- Supports the principle of least privilege.
- Separates application permissions from worker-node permissions.

**Important distinction:** GitHub Actions OIDC authenticates the CI/CD workflow to AWS. IRSA provides AWS permissions to workloads running inside EKS. They solve two different authentication requirements.

---

# 7. Argo CD – GitOps-Based Deployment

### Why Argo CD?

Once the Docker image is available in ECR, it needs to be deployed to Kubernetes.

I used Argo CD to implement GitOps-based continuous delivery.

Instead of manually applying Kubernetes manifests every time, Argo CD monitors the configured Git repository and compares the desired configuration with the actual Kubernetes state.

### How it works

1. Kubernetes deployment configuration is maintained in Git.
2. Argo CD is configured with the repository URL, branch, and manifest path.
3. Argo CD reads the Kubernetes configuration from Git.
4. It compares the desired state with the live state in EKS.
5. When a difference is detected, Argo CD can synchronize the cluster with the repository configuration according to its sync policy.
6. The application resources are deployed or updated in Kubernetes.

### Why Kustomize?

I used Kustomize to organize Kubernetes manifests and manage image configuration.

The `kustomization.yaml` file references the Kubernetes resource files and defines the image repository and tag.

Kustomize processes these files and generates the final Kubernetes manifests that Argo CD deploys.

### Why this approach?

- Keeps deployment configuration in Git.
- Provides visibility into application deployment status.
- Makes configuration changes traceable.
- Helps maintain consistency between Git and the Kubernetes environment.

---

# 8. Argo CD Image Updater – Automated Image Updates

### Why Argo CD Image Updater?

After GitHub Actions builds and pushes a new Docker image to ECR, Kubernetes needs to know which image version should be deployed.

Without an automated image update mechanism, we would need to manually update the image tag in the Kubernetes configuration stored in Git.

I used Argo CD Image Updater to automate this part of the deployment workflow.

### How it works

1. GitHub Actions builds the application Docker image.
2. The image is tagged with the Git commit SHA.
3. The new image is pushed to Amazon ECR.
4. Argo CD Image Updater checks the configured image repository for eligible new versions.
5. It identifies the relevant Argo CD Application using its application configuration.
6. Based on the configured image update strategy and application annotations, it determines whether an image update is required.
7. With Git write-back configured, Image Updater updates the image tag in the Kustomize configuration.
8. The updated `kustomization.yaml` is committed to the configured Git branch.
9. Argo CD detects the Git change.
10. Argo CD processes the updated Kustomize configuration and synchronizes the cluster.
11. EKS runs the updated application version.

### Git write-back configuration

The Image Updater configuration uses:

- Application: `devops-project-app`
- Namespace: `argocd`
- Write-back method: `git`
- Git branch: `main`

The objective is to keep the desired application image version in Git rather than changing the live Kubernetes resource manually.

### Why update `kustomization.yaml`?

Kustomize allows image repositories and tags to be managed centrally.

For example:

```yaml
images:
  - name: 298660929912.dkr.ecr.ap-south-2.amazonaws.com/devops-project-app
    newTag: <new-git-sha>
```

When Image Updater changes `newTag`, Kustomize uses that version when generating the final Kubernetes manifests.

The original Deployment manifest does not need to be manually edited for every image update, provided the image repository matches the Kustomize image transformer configuration.

### Why this approach?

- Reduces manual image-tag updates.
- Connects CI image publishing with GitOps deployment.
- Keeps image version changes traceable in Git.
- Allows Argo CD to deploy changes from the Git repository.
- Maintains Git as the source of truth for the desired application configuration.

**The important distinction:** GitHub Actions builds and pushes the image. Argo CD Image Updater updates the image reference in Git. Argo CD then synchronizes the updated configuration with EKS.

---

# 9. Argo Rollouts – Canary Deployment and Automated Rollback

### Why Argo Rollouts?

A normal Kubernetes Deployment generally replaces application pods according to its rollout strategy.

For this project, I wanted to explore progressive delivery and release a new application version gradually.

I used Argo Rollouts to implement canary deployment.

### What is a canary deployment?

Instead of sending all traffic to a new application version immediately, a small percentage of traffic is initially directed to the new version.

The deployment can then progress through predefined stages.

### How I implemented it

- Created an Argo Rollout resource for the application.
- Configured stable and canary Services.
- Used Gateway API integration through the Argo Rollouts Gateway API plugin.
- Configured canary traffic progression.
- Added pause steps between traffic changes.
- Created an AnalysisTemplate for deployment health analysis.

### Canary deployment flow

1. The existing application version serves traffic as the stable version.
2. A new application version is introduced as the canary.
3. A small percentage of traffic is directed to the canary.
4. The rollout pauses for observation.
5. An AnalysisTemplate performs the configured health checks.
6. If the analysis succeeds, the rollout progresses to the next traffic stage.
7. If the analysis fails, the rollout can abort and retain the previous stable version.

### My testing experience

I tested a failed canary deployment during the project.

The analysis check failed, and Argo Rollouts aborted the rollout. The previous stable application version was retained.

This helped me understand how progressive delivery can reduce the risk of releasing a faulty application version.

---

# 10. Helm – Monitoring Component Installation

### Why Helm?

Installing and maintaining multiple Kubernetes monitoring components using individual YAML files can become difficult.

I used Helm to install and manage monitoring components in the Kubernetes cluster.

### Components installed

- kube-prometheus-stack
- Blackbox Exporter

The kube-prometheus-stack installation provides several monitoring components, including Prometheus, Grafana, Alertmanager, Node Exporter, and kube-state-metrics.

### Why this approach?

Helm provides reusable charts, configurable values, and release management. It makes installing and upgrading monitoring components easier.

---

# 11. Prometheus – Metrics Collection

### Why Prometheus?

Running an application on Kubernetes is not enough. We also need visibility into the health and performance of the cluster.

I used Prometheus to collect and query metrics from the Kubernetes environment.

### What it monitors

- Kubernetes node metrics.
- Pod and container metrics.
- Application and cluster health metrics exposed by configured targets.
- Kubernetes object state metrics.
- Endpoint probe metrics from Blackbox Exporter.

### Important monitoring components

**Node Exporter**

Collects operating-system and node-level metrics such as CPU, memory, disk, and network statistics.

**kube-state-metrics**

Exposes metrics about the state of Kubernetes objects, such as pods, deployments, and nodes.

**cAdvisor / kubelet metrics**

Provides container resource usage metrics through the Kubernetes node monitoring interfaces.

### Why this approach?

Prometheus provides a centralized metrics collection and query system for understanding application and infrastructure health.

---

# 12. Grafana – Monitoring Dashboards

### Why Grafana?

Prometheus is useful for collecting and querying metrics, but dashboards make it easier to understand those metrics visually.

I connected Grafana to Prometheus as its data source.

### What I monitored

- Node CPU utilization.
- Node memory utilization.
- Pod restarts.
- Kubernetes cluster metrics.
- Application and infrastructure health indicators.

### Why this approach?

Grafana provides a visual view of the monitoring data and helps identify resource usage patterns and potential issues.

---

# 13. Alertmanager – Email Notifications

### Why Alertmanager?

Monitoring is useful, but continuously checking dashboards is not practical.

I configured Alertmanager to send email notifications when selected Prometheus alert rules are triggered.

### What I configured

Created Prometheus alert rules for:

- PodCrashLoopBackOff
- ContainerRestartingFrequently
- KubernetesNodeNotReady
- HighNodeCPU
- HighNodeMemory

Configured Alertmanager with Gmail SMTP settings and a dedicated Kubernetes Secret for the SMTP app password.

### How it works

1. Prometheus evaluates configured alert rules.
2. When an alert condition is met, Prometheus sends the alert to Alertmanager.
3. Alertmanager processes the alert according to its routing configuration.
4. The configured receiver sends an email notification.
5. When the alert condition is resolved, the alert is marked as resolved.

### Why this approach?

It helps identify infrastructure and application issues without having to monitor dashboards continuously.

---

# 14. Blackbox Exporter – Endpoint Monitoring

### Why Blackbox Exporter?

A Kubernetes pod can be running while the application endpoint is unavailable.

Checking pod status alone does not guarantee that users can access the application.

I used Prometheus Blackbox Exporter to probe configured endpoints.

### What it does

Blackbox Exporter can perform checks such as:

- HTTP/HTTPS endpoint availability.
- TCP connectivity.
- DNS resolution.
- ICMP connectivity.

Prometheus collects the probe results and makes them available for monitoring.

### Why this approach?

It provides an additional way to check service availability from an external probing perspective, rather than relying only on Kubernetes pod status.

---

# 15. End-to-End Project Workflow

Here is how the major components fit together:

1. Terraform provisions AWS infrastructure.
2. Amazon EKS provides the Kubernetes environment.
3. Application source code is maintained in GitHub.
4. A code change triggers the GitHub Actions workflow.
5. GitHub Actions authenticates with AWS through OIDC.
6. Docker builds the application image.
7. The image is pushed to Amazon ECR with a Git SHA tag.
8. Argo CD Image Updater checks the configured ECR image repository for eligible updates.
9. Image Updater updates the image tag in `kustomization.yaml` using Git write-back.
10. The updated image tag is committed to the Git repository.
11. Argo CD detects the Git change.
12. Kustomize processes the Kubernetes manifests with the updated image tag.
13. Argo CD synchronizes the updated configuration with EKS.
14. Argo Rollouts manages the canary deployment.
15. Analysis checks determine whether the rollout can progress or should be aborted.
16. Prometheus collects Kubernetes and monitoring metrics.
17. Grafana displays the metrics in dashboards.
18. Alertmanager sends email notifications for configured alerts.
19. Blackbox Exporter checks configured application endpoints.

---

# 16. Key Things I Learned

Working on this project helped me understand how different DevOps tools fit into a complete delivery workflow.

Some important takeaways:

- Infrastructure as Code makes cloud infrastructure repeatable.
- OIDC provides a safer way for GitHub Actions to authenticate with AWS.
- IRSA provides workload-level AWS permissions inside EKS.
- Docker and ECR simplify application packaging and image distribution.
- Argo CD provides a GitOps-based deployment workflow.
- Argo CD Image Updater automates image-tag updates in Git.
- Kustomize manages Kubernetes manifests and image configuration.
- Argo Rollouts enables controlled application releases.
- Prometheus and Grafana provide visibility into Kubernetes infrastructure.
- Alertmanager helps notify teams when configured issues occur.
- Blackbox Exporter checks whether application endpoints are reachable.

Most importantly, troubleshooting the integration between these tools was a valuable part of the project.

---

# 17. Repository

**GitHub:**  
https://github.com/hemanth7040/Argo-Rollback-Project

The repository contains the project configuration and application deployment resources.

For the exact file layout and commands, refer to the repository itself, as the structure may evolve as the project is improved.

---

## Final Note

This project is a hands-on learning implementation focused on AWS, Terraform, Kubernetes, CI/CD, GitOps, progressive delivery, and monitoring.

It is not just about using individual tools. The goal was to understand why each tool is needed, what problem it solves, and how it integrates with the rest of the DevOps workflow.