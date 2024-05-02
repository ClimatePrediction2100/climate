FROM jenkins/jenkins:alpine3.19-jdk21

CMD ["java", "-jar", "/usr/share/jenkins/jenkins.war"]