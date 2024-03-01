# TFTP-client-Program
Socket programming about Network layer TCP/UDP application, experiment of computer network in HUST-CSE
## Windows Socket 1.1 
- 流类型（Stream Sockets） 
流式套接字提供了一种可靠的、面向连接的数据传输方法，使用传输控制协议TCP。 
- 数据报类型（Datagram Sockets）
数据报套接字提供了一种不可靠的、非连接的数据包传输方式，使用用户数据报协议UDP。
## Socket function
- `int WSAStartup (WORD wVersionRequested, LPWSADATA  lpWSAData  )`
- `SOCKET socket(int af, int type, int protocol) `
- `int bind(SOCKET s, const struct sockaddr FAR* name, int namelen)`
- `int listen (SOCKET s,  int backlog)`
- `int connect (SOCKET s, const struct sockaddr FAR* name, int namelen)`
-  `int send (SOCKET s, char * buf, int len ,int flags)`
- `int recv (SOCKET s, char * buf, int len ,int flags) `
- `int recvfrom (SOCKET s, char * buf, int len ,int flags, struct sockaddr_in * from, int * fromlen)`
## Upload and Download
- 通过sendto和recvfrom函数的返回值判断是否发送或则接收数据成功，并且根据接收报文的形式判断该包是否是预料中的报文，以及每次接受目标包后下一个包的num参数要实现加一，如果没有发送成功，在for循环中要进行ack_wait加上设置的秒数，在没有超过设置的最大超时时间的范围中，只要接受到预期中的包，也就是满足上述的要求后，进行当前状态的记录，写入日志文件并跳出超时for循环。
- 在超时检测for循环外再加上一个for循环用来判断是否超过设置的最大重传次数就可以实现重传的目的，如果发包成功既要跳出超时的循环也要跳出重传的for循环。
