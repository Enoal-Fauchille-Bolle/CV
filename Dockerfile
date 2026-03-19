FROM nginx:alpine

COPY nginx.conf /etc/nginx/conf.d/default.conf

COPY ["resume.pdf", "/usr/share/nginx/html/cv.pdf"]
