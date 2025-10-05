# ---- Stage 1: Build với Ant ----
FROM openjdk:8-jdk AS build

WORKDIR /app

RUN apt-get update && apt-get install -y ant wget && rm -rf /var/lib/apt/lists/*

# CopyLibs task cho Ant
RUN wget -O /usr/share/ant/lib/org-netbeans-modules-java-j2seproject-copylibstask.jar \
    https://repo1.maven.org/maven2/org/netbeans/modules/org-netbeans-modules-java-j2seproject-copylibstask/1.0/org-netbeans-modules-java-j2seproject-copylibstask-1.0.jar

# Copy source
COPY . /app

# Tạo libs cho build (chỉ dùng khi compile)
RUN mkdir -p /app/libs && \
    wget -O /app/libs/servlet-api.jar https://repo1.maven.org/maven2/javax/servlet/javax.servlet-api/4.0.1/javax.servlet-api-4.0.1.jar && \
    wget -O /app/libs/jstl.jar https://repo1.maven.org/maven2/javax/servlet/jstl/1.2/jstl-1.2.jar

# Build từng project
WORKDIR /app/ch08_ex1_email
RUN ant clean dist

WORKDIR /app/ch09_ex1_download
RUN ant clean dist

WORKDIR /app/ch09_ex2_cart
RUN ant clean dist


# ---- Stage 2: Run với Tomcat 9 ----
FROM tomcat:9-jdk11-openjdk

# Copy WAR vào Tomcat
COPY --from=build /app/ch08_ex1_email/dist/*.war /usr/local/tomcat/webapps/ch08_email.war
COPY --from=build /app/ch09_ex1_download/dist/*.war /usr/local/tomcat/webapps/ch09_download.war
COPY --from=build /app/ch09_ex2_cart/dist/*.war /usr/local/tomcat/webapps/ch09_cart.war

# Copy JSTL (không copy servlet-api vì Tomcat có sẵn)
COPY --from=build /app/libs/jstl.jar /usr/local/tomcat/lib/

EXPOSE 8080
CMD ["catalina.sh", "run"]
