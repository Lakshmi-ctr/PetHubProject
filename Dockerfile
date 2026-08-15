FROM tomcat:10.1-jdk17-temurin-jammy

# Install required tools
RUN apt-get update && \
    apt-get install -y curl && \
    rm -rf /var/lib/apt/lists/*

# Download dependencies
RUN mkdir -p /tmp/libs && \
    curl -L -o /tmp/libs/jakarta.servlet-api.jar \
    https://repo1.maven.org/maven2/jakarta/servlet/jakarta.servlet-api/6.0.0/jakarta.servlet-api-6.0.0.jar && \
    curl -L -o /tmp/libs/mysql-connector-j.jar \
    https://repo1.maven.org/maven2/com/mysql/mysql-connector-j/8.0.33/mysql-connector-j-8.0.33.jar

# Copy PetHub JSP, HTML, CSS, JS, images, WEB-INF, etc.
COPY src/main/webapp/ /usr/local/tomcat/webapps/ROOT/

# Create required folders
RUN mkdir -p /usr/local/tomcat/webapps/ROOT/WEB-INF/classes \
    /usr/local/tomcat/webapps/ROOT/WEB-INF/lib

# Compile all PetHub Java source files
RUN javac \
    -cp "/tmp/libs/jakarta.servlet-api.jar:/tmp/libs/mysql-connector-j.jar" \
    -d /usr/local/tomcat/webapps/ROOT/WEB-INF/classes \
    $(find src/main/java -name "*.java")

# Add MySQL driver to the application
RUN cp /tmp/libs/mysql-connector-j.jar \
    /usr/local/tomcat/webapps/ROOT/WEB-INF/lib/

# Render uses port 10000
RUN sed -i 's/port="8080"/port="10000"/' \
    /usr/local/tomcat/conf/server.xml

EXPOSE 10000

CMD ["catalina.sh", "run"]