# DevOps Pipeline Testing Project

A comprehensive DevOps project designed to test and demonstrate CI/CD pipelines, monitoring, and best practices for continuous integration and deployment.

## 🚀 Project Overview

This project serves as a practical testing environment for DevOps pipelines, featuring multiple HTML pages that simulate a real web application with different functionalities like dashboards, APIs, monitoring, and testing interfaces.

## 👨‍💻 Developer

**Alexsander Silveira** - DevOps Engineer & Full Stack Developer

This project was developed to demonstrate and test various DevOps practices, CI/CD pipelines, and monitoring solutions.

## 📋 Project Structure

```
├── index.html          # Main landing page
├── dashboard.html      # Application dashboard
├── test.html          # Testing interface
├── api.html           # API documentation
├── monitoring.html    # Monitoring dashboard
├── azure-pipelines.yml # Azure DevOps pipeline configuration
├── package.json       # Node.js dependencies and scripts
└── README.md         # Project documentation
```

## 🎯 Benefits of This Project

### 1. **Learning & Training**
- **Hands-on DevOps experience**: Real-world pipeline configuration and testing
- **CI/CD best practices**: Demonstrates proper pipeline structure with multiple stages
- **Self-hosted agent setup**: Learn to configure and manage Azure DevOps agents
- **Error troubleshooting**: Experience common pipeline issues and their solutions

### 2. **Testing & Validation**
- **Pipeline reliability**: Test pipeline configurations before applying to production
- **Agent compatibility**: Verify self-hosted agents work correctly
- **Environment consistency**: Ensure builds work across different environments
- **Automation validation**: Test automated deployment and monitoring processes

### 3. **Development Benefits**
- **Rapid iteration**: Quick feedback on pipeline changes
- **Risk mitigation**: Test changes safely before production deployment
- **Team collaboration**: Shared understanding of DevOps processes
- **Documentation**: Living example of DevOps practices

### 4. **Production Readiness**
- **Quality assurance**: Automated testing and validation
- **Monitoring setup**: Real-time application monitoring
- **Security scanning**: Automated security checks
- **Deployment automation**: Streamlined release processes

## 🔧 Technologies Used

- **Frontend**: HTML5, CSS3, JavaScript
- **CI/CD**: Azure DevOps Pipelines
- **Agent**: Self-hosted Azure DevOps Agent (ARM64)
- **Package Manager**: npm
- **Monitoring**: Custom monitoring dashboard
- **Testing**: Automated test scripts

## 🚀 Getting Started

### Prerequisites
- Azure DevOps account
- Self-hosted agent configured (see setup instructions below)
- Git repository access

### Quick Start
1. Clone this repository
2. Configure your Azure DevOps agent
3. Run the pipeline to test the setup

## 📊 Pipeline Stages

### 🔨 Build Stage
- **Install Dependencies**: npm ci/install
- **Build Application**: npm run build
- **Code Quality**: Linting and static analysis

### 🧪 Test Stage
- **Unit Tests**: npm test
- **E2E Tests**: npm run test:e2e
- **Code Coverage**: Automated coverage reporting

### 🚀 Deploy Stage
- **Deployment**: npm run deploy
- **Health Checks**: Application health validation
- **Rollback**: Automatic rollback on failure

### 📊 Monitor Stage
- **Performance Monitoring**: Real-time metrics
- **Error Tracking**: Automated error detection
- **Uptime Monitoring**: Service availability checks

### 🔒 Security Stage
- **Security Scan**: npm audit
- **Vulnerability Check**: Automated security validation
- **Compliance**: Security policy enforcement

### 📢 Notify Stage
- **Success Notifications**: Team communication
- **Failure Alerts**: Error reporting
- **Status Updates**: Pipeline status notifications

## 🤖 Self-Hosted Agent Setup

### Requirements
- macOS (ARM64/Intel)
- Node.js installed
- Azure DevOps Personal Access Token (PAT)

### Installation Steps
1. Download the Azure DevOps agent for macOS
2. Extract and configure the agent
3. Register with your Azure DevOps organization
4. Start the agent service

### Configuration
```bash
# Download agent
curl -O https://vstsagentpackage.azureedge.net/agent/4.258.1/vsts-agent-osx-arm64-4.258.1.tar.gz

# Extract and configure
tar zxvf vsts-agent-osx-arm64-4.258.1.tar.gz
./config.sh

# Start agent
./run.sh
```

## 📈 Monitoring & Analytics

The project includes a comprehensive monitoring dashboard that provides:
- **Real-time metrics**: Performance and usage statistics
- **Error tracking**: Automated error detection and reporting
- **Health checks**: Service availability monitoring
- **Custom alerts**: Configurable notification system

## 🔍 Testing Strategy

### Automated Testing
- **Unit Tests**: Component-level testing
- **Integration Tests**: API and service testing
- **E2E Tests**: End-to-end user journey testing
- **Performance Tests**: Load and stress testing

### Manual Testing
- **User Interface**: Visual and functional testing
- **Cross-browser**: Compatibility testing
- **Mobile Responsive**: Mobile device testing

## 🛡️ Security Features

- **Automated security scanning**: npm audit integration
- **Vulnerability detection**: Real-time security monitoring
- **Compliance checks**: Security policy enforcement
- **Access control**: Role-based permissions

## 📝 Best Practices Demonstrated

1. **Pipeline Structure**: Multi-stage pipeline with proper separation of concerns
2. **Error Handling**: Comprehensive error handling and recovery
3. **Monitoring**: Real-time monitoring and alerting
4. **Security**: Automated security scanning and compliance
5. **Documentation**: Clear and comprehensive documentation
6. **Testing**: Multiple testing strategies and automation

## 🤝 Contributing

This project serves as a learning and testing environment. Feel free to:
- Test different pipeline configurations
- Add new monitoring features
- Improve documentation
- Share best practices

## 📄 License

This project is developed by Alexsander Silveira for educational and testing purposes.

## 📞 Contact

**Alexsander Silveira**
- DevOps Engineer & Full Stack Developer
- Specialized in CI/CD, automation, and cloud infrastructure

---

*This project demonstrates real-world DevOps practices and serves as a practical testing environment for pipeline configurations and monitoring solutions.*

