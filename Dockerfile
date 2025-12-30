# 构建阶段：使用官方Golang镜像作为构建环境
FROM registry.cn-beijing.aliyuncs.com/sunwenbo-base/golang:1.22 AS builder

# 设置工作目录
WORKDIR /app

COPY . .

# 构建应用程序
RUN go build -o gochat


# 运行阶段：使用轻量级Alpine镜像
FROM alpine:latest

# 设置工作目录
WORKDIR /app

# 复制构建产物和配置文件
COPY --from=builder /app/gochat .
COPY --from=builder /app/config/mysql.json ./config/mysql.json

# 暴露应用端口（默认8081）
EXPOSE 8081

# 安装必要工具（用于后续可能的进程管理）
RUN apk add --no-cache tini

# 启动命令
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["./gochat", "server"]
