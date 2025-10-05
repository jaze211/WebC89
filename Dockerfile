# ---------------- Stage 1: Build all projects with Ant ----------------
FROM openjdk:8-jdk AS build

WORKDIR /app

# Cài Ant + wget
RUN apt-get update && apt-get install -y ant wget && rm -rf /var/lib/apt/lists/*

# Copy toàn bộ project và thư viện
COPY . /app

# Tạo thư mục lib cho Ant build, copy các jar cần thiết
RUN mkdir -p /app/lib
COPY libs/*.jar /app/lib/

# Set CLASSPATH để Ant compile không bị lỗi
ENV CLASSPATH=/app/lib/*

# Build từng project bằng Ant (tạo WAR trong dist/)
WORKDIR /app/ch08_ex1_email
RUN ant clean && ant dist

WORKDIR /app/ch09_ex1_download
RUN ant clean && ant dist

WORKDIR /app/ch09_ex2_cart
RUN ant clean && ant dist

# ---------------- Stage 2: Run với Tomcat ----------------
FROM tomcat:9-jdk11-openjdk

# Copy WAR đã build sang Tomcat
COPY --from=build /app/ch08_ex1_email/dist/*.war /usr/local/tomcat/webapps/c8_email.war
COPY --from=build /app/ch09_ex1_download/dist/*.war /usr/local/tomcat/webapps/c9_download.war
COPY --from=build /app/ch09_ex2_cart/dist/*.war /usr/local/tomcat/webapps/c9_cart.war

# Copy thư viện cần thiết vào Tomcat lib
COPY --from=build /app/lib/*.jar /usr/local/tomcat/lib/

# Expose port
EXPOSE 8080

# Run Tomcat
CMD ["catalina.sh", "run"]
