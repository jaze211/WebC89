# ---- Stage 1: Build với Ant ----
FROM openjdk:8-jdk AS build

WORKDIR /app

# Cài Ant
RUN apt-get update && apt-get install -y ant && rm -rf /var/lib/apt/lists/*

# Copy toàn bộ source code (bao gồm cả libs/)
COPY . /app

# Copy CopyLibs.jar vào ant/lib (lấy từ thư mục libs trong project)
COPY libs/org-netbeans-modules-java-j2seproject-copylibstask.jar /usr/share/ant/lib/

# Build từng project
WORKDIR /app/ch08_ex1_email
RUN ant clean dist

WORKDIR /app/ch09_ex1_download
RUN ant clean dist

WORKDIR /app/ch09_ex2_cart
RUN ant clean dist


# ---- Stage 2: Run với Tomcat 9 ----
FROM tomcat:9-jdk11-openjdk

# Copy WAR sang Tomcat webapps
COPY --from=build /app/ch08_ex1_email/dist/*.war /usr/local/tomcat/webapps/ch08_email.war
COPY --from=build /app/ch09_ex1_download/dist/*.war /usr/local/tomcat/webapps/ch09_download.war
COPY --from=build /app/ch09_ex2_cart/dist/*.war /usr/local/tomcat/webapps/ch09_cart.war

# Copy các jar cần thiết vào Tomcat lib (JSTL + servlet-api)
COPY --from=build /app/libs/*.jar /usr/local/tomcat/lib/

EXPOSE 8080
CMD ["catalina.sh", "run"]
