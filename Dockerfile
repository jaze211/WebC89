# ---- Stage 1: Build ----
FROM openjdk:8-jdk AS build

WORKDIR /app

# Cài Ant (nếu muốn dùng ant build)
RUN apt-get update && apt-get install -y ant && rm -rf /var/lib/apt/lists/*

# Copy toàn bộ source + libs
COPY . /app

# Tạo thư mục dist cho từng project
RUN mkdir -p /app/ch08_ex1_email/dist \
    /app/ch09_ex1_download/dist \
    /app/ch09_ex2_cart/dist

# Compile ch08_ex1_email
RUN mkdir -p /app/ch08_ex1_email/build/classes && \
    find ch08_ex1_email/src/java -name "*.java" > sources_ch08.txt && \
    javac -d ch08_ex1_email/build/classes -cp "libs/*" @sources_ch08.txt && \
    cp -r ch08_ex1_email/web/* ch08_ex1_email/build/classes/ && \
    cd ch08_ex1_email/build/classes && \
    jar cvf ../../dist/ch08_email.war *

# Compile ch09_ex1_download
RUN mkdir -p /app/ch09_ex1_download/build/classes && \
    find ch09_ex1_download/src/java -name "*.java" > sources_ch09d.txt && \
    javac -d ch09_ex1_download/build/classes -cp "libs/*" @sources_ch09d.txt && \
    cp -r ch09_ex1_download/web/* ch09_ex1_download/build/classes/ && \
    cd ch09_ex1_download/build/classes && \
    jar cvf ../../dist/ch09_download.war *

# Compile ch09_ex2_cart
RUN mkdir -p /app/ch09_ex2_cart/build/classes && \
    find ch09_ex2_cart/src/java -name "*.java" > sources_ch09c.txt && \
    javac -d ch09_ex2_cart/build/classes -cp "libs/*" @sources_ch09c.txt && \
    cp -r ch09_ex2_cart/web/* ch09_ex2_cart/build/classes/ && \
    cd ch09_ex2_cart/build/classes && \
    jar cvf ../../dist/ch09_cart.war *

# ---- Stage 2: Run ----
FROM tomcat:9-jdk11-openjdk

# Copy các WAR sang Tomcat webapps
COPY --from=build /app/ch08_ex1_email/dist/ch08_email.war /usr/local/tomcat/webapps/ch08_email.war
COPY --from=build /app/ch09_ex1_download/dist/ch09_download.war /usr/local/tomcat/webapps/ch09_download.war
COPY --from=build /app/ch09_ex2_cart/dist/ch09_cart.war /usr/local/tomcat/webapps/ch09_cart.war

# Copy libs cần thiết vào Tomcat lib (JSTL + mail + mysql + poi)
COPY --from=build /app/libs/*.jar /usr/local/tomcat/lib/

EXPOSE 8080
CMD ["catalina.sh", "run"]
