
user/_zombie:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"

int
main(void)
{
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
  if(fork() > 0)
   8:	00000097          	auipc	ra,0x0
   c:	2a0080e7          	jalr	672(ra) # 2a8 <fork>
  10:	00a04763          	bgtz	a0,1e <main+0x1e>
    sleep(5);  // Let child exit before parent.
  exit(0);
  14:	4501                	li	a0,0
  16:	00000097          	auipc	ra,0x0
  1a:	29a080e7          	jalr	666(ra) # 2b0 <exit>
    sleep(5);  // Let child exit before parent.
  1e:	4515                	li	a0,5
  20:	00000097          	auipc	ra,0x0
  24:	320080e7          	jalr	800(ra) # 340 <sleep>
  28:	b7f5                	j	14 <main+0x14>

000000000000002a <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
  2a:	1141                	addi	sp,sp,-16
  2c:	e406                	sd	ra,8(sp)
  2e:	e022                	sd	s0,0(sp)
  30:	0800                	addi	s0,sp,16
  extern int main();
  main();
  32:	00000097          	auipc	ra,0x0
  36:	fce080e7          	jalr	-50(ra) # 0 <main>
  exit(0);
  3a:	4501                	li	a0,0
  3c:	00000097          	auipc	ra,0x0
  40:	274080e7          	jalr	628(ra) # 2b0 <exit>

0000000000000044 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  44:	1141                	addi	sp,sp,-16
  46:	e422                	sd	s0,8(sp)
  48:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  4a:	87aa                	mv	a5,a0
  4c:	0585                	addi	a1,a1,1
  4e:	0785                	addi	a5,a5,1
  50:	fff5c703          	lbu	a4,-1(a1)
  54:	fee78fa3          	sb	a4,-1(a5)
  58:	fb75                	bnez	a4,4c <strcpy+0x8>
    ;
  return os;
}
  5a:	6422                	ld	s0,8(sp)
  5c:	0141                	addi	sp,sp,16
  5e:	8082                	ret

0000000000000060 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  60:	1141                	addi	sp,sp,-16
  62:	e422                	sd	s0,8(sp)
  64:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  66:	00054783          	lbu	a5,0(a0)
  6a:	cb91                	beqz	a5,7e <strcmp+0x1e>
  6c:	0005c703          	lbu	a4,0(a1)
  70:	00f71763          	bne	a4,a5,7e <strcmp+0x1e>
    p++, q++;
  74:	0505                	addi	a0,a0,1
  76:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  78:	00054783          	lbu	a5,0(a0)
  7c:	fbe5                	bnez	a5,6c <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  7e:	0005c503          	lbu	a0,0(a1)
}
  82:	40a7853b          	subw	a0,a5,a0
  86:	6422                	ld	s0,8(sp)
  88:	0141                	addi	sp,sp,16
  8a:	8082                	ret

000000000000008c <strlen>:

uint
strlen(const char *s)
{
  8c:	1141                	addi	sp,sp,-16
  8e:	e422                	sd	s0,8(sp)
  90:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  92:	00054783          	lbu	a5,0(a0)
  96:	cf91                	beqz	a5,b2 <strlen+0x26>
  98:	0505                	addi	a0,a0,1
  9a:	87aa                	mv	a5,a0
  9c:	86be                	mv	a3,a5
  9e:	0785                	addi	a5,a5,1
  a0:	fff7c703          	lbu	a4,-1(a5)
  a4:	ff65                	bnez	a4,9c <strlen+0x10>
  a6:	40a6853b          	subw	a0,a3,a0
  aa:	2505                	addiw	a0,a0,1
    ;
  return n;
}
  ac:	6422                	ld	s0,8(sp)
  ae:	0141                	addi	sp,sp,16
  b0:	8082                	ret
  for(n = 0; s[n]; n++)
  b2:	4501                	li	a0,0
  b4:	bfe5                	j	ac <strlen+0x20>

00000000000000b6 <memset>:

void*
memset(void *dst, int c, uint n)
{
  b6:	1141                	addi	sp,sp,-16
  b8:	e422                	sd	s0,8(sp)
  ba:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  bc:	ca19                	beqz	a2,d2 <memset+0x1c>
  be:	87aa                	mv	a5,a0
  c0:	1602                	slli	a2,a2,0x20
  c2:	9201                	srli	a2,a2,0x20
  c4:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
  c8:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
  cc:	0785                	addi	a5,a5,1
  ce:	fee79de3          	bne	a5,a4,c8 <memset+0x12>
  }
  return dst;
}
  d2:	6422                	ld	s0,8(sp)
  d4:	0141                	addi	sp,sp,16
  d6:	8082                	ret

00000000000000d8 <strchr>:

char*
strchr(const char *s, char c)
{
  d8:	1141                	addi	sp,sp,-16
  da:	e422                	sd	s0,8(sp)
  dc:	0800                	addi	s0,sp,16
  for(; *s; s++)
  de:	00054783          	lbu	a5,0(a0)
  e2:	cb99                	beqz	a5,f8 <strchr+0x20>
    if(*s == c)
  e4:	00f58763          	beq	a1,a5,f2 <strchr+0x1a>
  for(; *s; s++)
  e8:	0505                	addi	a0,a0,1
  ea:	00054783          	lbu	a5,0(a0)
  ee:	fbfd                	bnez	a5,e4 <strchr+0xc>
      return (char*)s;
  return 0;
  f0:	4501                	li	a0,0
}
  f2:	6422                	ld	s0,8(sp)
  f4:	0141                	addi	sp,sp,16
  f6:	8082                	ret
  return 0;
  f8:	4501                	li	a0,0
  fa:	bfe5                	j	f2 <strchr+0x1a>

00000000000000fc <gets>:

char*
gets(char *buf, int max)
{
  fc:	711d                	addi	sp,sp,-96
  fe:	ec86                	sd	ra,88(sp)
 100:	e8a2                	sd	s0,80(sp)
 102:	e4a6                	sd	s1,72(sp)
 104:	e0ca                	sd	s2,64(sp)
 106:	fc4e                	sd	s3,56(sp)
 108:	f852                	sd	s4,48(sp)
 10a:	f456                	sd	s5,40(sp)
 10c:	f05a                	sd	s6,32(sp)
 10e:	ec5e                	sd	s7,24(sp)
 110:	1080                	addi	s0,sp,96
 112:	8baa                	mv	s7,a0
 114:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 116:	892a                	mv	s2,a0
 118:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 11a:	4aa9                	li	s5,10
 11c:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 11e:	89a6                	mv	s3,s1
 120:	2485                	addiw	s1,s1,1
 122:	0344d863          	bge	s1,s4,152 <gets+0x56>
    cc = read(0, &c, 1);
 126:	4605                	li	a2,1
 128:	faf40593          	addi	a1,s0,-81
 12c:	4501                	li	a0,0
 12e:	00000097          	auipc	ra,0x0
 132:	19a080e7          	jalr	410(ra) # 2c8 <read>
    if(cc < 1)
 136:	00a05e63          	blez	a0,152 <gets+0x56>
    buf[i++] = c;
 13a:	faf44783          	lbu	a5,-81(s0)
 13e:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 142:	01578763          	beq	a5,s5,150 <gets+0x54>
 146:	0905                	addi	s2,s2,1
 148:	fd679be3          	bne	a5,s6,11e <gets+0x22>
    buf[i++] = c;
 14c:	89a6                	mv	s3,s1
 14e:	a011                	j	152 <gets+0x56>
 150:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 152:	99de                	add	s3,s3,s7
 154:	00098023          	sb	zero,0(s3)
  return buf;
}
 158:	855e                	mv	a0,s7
 15a:	60e6                	ld	ra,88(sp)
 15c:	6446                	ld	s0,80(sp)
 15e:	64a6                	ld	s1,72(sp)
 160:	6906                	ld	s2,64(sp)
 162:	79e2                	ld	s3,56(sp)
 164:	7a42                	ld	s4,48(sp)
 166:	7aa2                	ld	s5,40(sp)
 168:	7b02                	ld	s6,32(sp)
 16a:	6be2                	ld	s7,24(sp)
 16c:	6125                	addi	sp,sp,96
 16e:	8082                	ret

0000000000000170 <stat>:

int
stat(const char *n, struct stat *st)
{
 170:	1101                	addi	sp,sp,-32
 172:	ec06                	sd	ra,24(sp)
 174:	e822                	sd	s0,16(sp)
 176:	e04a                	sd	s2,0(sp)
 178:	1000                	addi	s0,sp,32
 17a:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 17c:	4581                	li	a1,0
 17e:	00000097          	auipc	ra,0x0
 182:	172080e7          	jalr	370(ra) # 2f0 <open>
  if(fd < 0)
 186:	02054663          	bltz	a0,1b2 <stat+0x42>
 18a:	e426                	sd	s1,8(sp)
 18c:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 18e:	85ca                	mv	a1,s2
 190:	00000097          	auipc	ra,0x0
 194:	178080e7          	jalr	376(ra) # 308 <fstat>
 198:	892a                	mv	s2,a0
  close(fd);
 19a:	8526                	mv	a0,s1
 19c:	00000097          	auipc	ra,0x0
 1a0:	13c080e7          	jalr	316(ra) # 2d8 <close>
  return r;
 1a4:	64a2                	ld	s1,8(sp)
}
 1a6:	854a                	mv	a0,s2
 1a8:	60e2                	ld	ra,24(sp)
 1aa:	6442                	ld	s0,16(sp)
 1ac:	6902                	ld	s2,0(sp)
 1ae:	6105                	addi	sp,sp,32
 1b0:	8082                	ret
    return -1;
 1b2:	597d                	li	s2,-1
 1b4:	bfcd                	j	1a6 <stat+0x36>

00000000000001b6 <atoi>:

int
atoi(const char *s)
{
 1b6:	1141                	addi	sp,sp,-16
 1b8:	e422                	sd	s0,8(sp)
 1ba:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1bc:	00054683          	lbu	a3,0(a0)
 1c0:	fd06879b          	addiw	a5,a3,-48
 1c4:	0ff7f793          	zext.b	a5,a5
 1c8:	4625                	li	a2,9
 1ca:	02f66863          	bltu	a2,a5,1fa <atoi+0x44>
 1ce:	872a                	mv	a4,a0
  n = 0;
 1d0:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 1d2:	0705                	addi	a4,a4,1
 1d4:	0025179b          	slliw	a5,a0,0x2
 1d8:	9fa9                	addw	a5,a5,a0
 1da:	0017979b          	slliw	a5,a5,0x1
 1de:	9fb5                	addw	a5,a5,a3
 1e0:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 1e4:	00074683          	lbu	a3,0(a4)
 1e8:	fd06879b          	addiw	a5,a3,-48
 1ec:	0ff7f793          	zext.b	a5,a5
 1f0:	fef671e3          	bgeu	a2,a5,1d2 <atoi+0x1c>
  return n;
}
 1f4:	6422                	ld	s0,8(sp)
 1f6:	0141                	addi	sp,sp,16
 1f8:	8082                	ret
  n = 0;
 1fa:	4501                	li	a0,0
 1fc:	bfe5                	j	1f4 <atoi+0x3e>

00000000000001fe <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 1fe:	1141                	addi	sp,sp,-16
 200:	e422                	sd	s0,8(sp)
 202:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 204:	02b57463          	bgeu	a0,a1,22c <memmove+0x2e>
    while(n-- > 0)
 208:	00c05f63          	blez	a2,226 <memmove+0x28>
 20c:	1602                	slli	a2,a2,0x20
 20e:	9201                	srli	a2,a2,0x20
 210:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 214:	872a                	mv	a4,a0
      *dst++ = *src++;
 216:	0585                	addi	a1,a1,1
 218:	0705                	addi	a4,a4,1
 21a:	fff5c683          	lbu	a3,-1(a1)
 21e:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 222:	fef71ae3          	bne	a4,a5,216 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 226:	6422                	ld	s0,8(sp)
 228:	0141                	addi	sp,sp,16
 22a:	8082                	ret
    dst += n;
 22c:	00c50733          	add	a4,a0,a2
    src += n;
 230:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 232:	fec05ae3          	blez	a2,226 <memmove+0x28>
 236:	fff6079b          	addiw	a5,a2,-1
 23a:	1782                	slli	a5,a5,0x20
 23c:	9381                	srli	a5,a5,0x20
 23e:	fff7c793          	not	a5,a5
 242:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 244:	15fd                	addi	a1,a1,-1
 246:	177d                	addi	a4,a4,-1
 248:	0005c683          	lbu	a3,0(a1)
 24c:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 250:	fee79ae3          	bne	a5,a4,244 <memmove+0x46>
 254:	bfc9                	j	226 <memmove+0x28>

0000000000000256 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 256:	1141                	addi	sp,sp,-16
 258:	e422                	sd	s0,8(sp)
 25a:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 25c:	ca05                	beqz	a2,28c <memcmp+0x36>
 25e:	fff6069b          	addiw	a3,a2,-1
 262:	1682                	slli	a3,a3,0x20
 264:	9281                	srli	a3,a3,0x20
 266:	0685                	addi	a3,a3,1
 268:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 26a:	00054783          	lbu	a5,0(a0)
 26e:	0005c703          	lbu	a4,0(a1)
 272:	00e79863          	bne	a5,a4,282 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 276:	0505                	addi	a0,a0,1
    p2++;
 278:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 27a:	fed518e3          	bne	a0,a3,26a <memcmp+0x14>
  }
  return 0;
 27e:	4501                	li	a0,0
 280:	a019                	j	286 <memcmp+0x30>
      return *p1 - *p2;
 282:	40e7853b          	subw	a0,a5,a4
}
 286:	6422                	ld	s0,8(sp)
 288:	0141                	addi	sp,sp,16
 28a:	8082                	ret
  return 0;
 28c:	4501                	li	a0,0
 28e:	bfe5                	j	286 <memcmp+0x30>

0000000000000290 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 290:	1141                	addi	sp,sp,-16
 292:	e406                	sd	ra,8(sp)
 294:	e022                	sd	s0,0(sp)
 296:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 298:	00000097          	auipc	ra,0x0
 29c:	f66080e7          	jalr	-154(ra) # 1fe <memmove>
}
 2a0:	60a2                	ld	ra,8(sp)
 2a2:	6402                	ld	s0,0(sp)
 2a4:	0141                	addi	sp,sp,16
 2a6:	8082                	ret

00000000000002a8 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 2a8:	4885                	li	a7,1
 ecall
 2aa:	00000073          	ecall
 ret
 2ae:	8082                	ret

00000000000002b0 <exit>:
.global exit
exit:
 li a7, SYS_exit
 2b0:	4889                	li	a7,2
 ecall
 2b2:	00000073          	ecall
 ret
 2b6:	8082                	ret

00000000000002b8 <wait>:
.global wait
wait:
 li a7, SYS_wait
 2b8:	488d                	li	a7,3
 ecall
 2ba:	00000073          	ecall
 ret
 2be:	8082                	ret

00000000000002c0 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 2c0:	4891                	li	a7,4
 ecall
 2c2:	00000073          	ecall
 ret
 2c6:	8082                	ret

00000000000002c8 <read>:
.global read
read:
 li a7, SYS_read
 2c8:	4895                	li	a7,5
 ecall
 2ca:	00000073          	ecall
 ret
 2ce:	8082                	ret

00000000000002d0 <write>:
.global write
write:
 li a7, SYS_write
 2d0:	48c1                	li	a7,16
 ecall
 2d2:	00000073          	ecall
 ret
 2d6:	8082                	ret

00000000000002d8 <close>:
.global close
close:
 li a7, SYS_close
 2d8:	48d5                	li	a7,21
 ecall
 2da:	00000073          	ecall
 ret
 2de:	8082                	ret

00000000000002e0 <kill>:
.global kill
kill:
 li a7, SYS_kill
 2e0:	4899                	li	a7,6
 ecall
 2e2:	00000073          	ecall
 ret
 2e6:	8082                	ret

00000000000002e8 <exec>:
.global exec
exec:
 li a7, SYS_exec
 2e8:	489d                	li	a7,7
 ecall
 2ea:	00000073          	ecall
 ret
 2ee:	8082                	ret

00000000000002f0 <open>:
.global open
open:
 li a7, SYS_open
 2f0:	48bd                	li	a7,15
 ecall
 2f2:	00000073          	ecall
 ret
 2f6:	8082                	ret

00000000000002f8 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 2f8:	48c5                	li	a7,17
 ecall
 2fa:	00000073          	ecall
 ret
 2fe:	8082                	ret

0000000000000300 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 300:	48c9                	li	a7,18
 ecall
 302:	00000073          	ecall
 ret
 306:	8082                	ret

0000000000000308 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 308:	48a1                	li	a7,8
 ecall
 30a:	00000073          	ecall
 ret
 30e:	8082                	ret

0000000000000310 <link>:
.global link
link:
 li a7, SYS_link
 310:	48cd                	li	a7,19
 ecall
 312:	00000073          	ecall
 ret
 316:	8082                	ret

0000000000000318 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 318:	48d1                	li	a7,20
 ecall
 31a:	00000073          	ecall
 ret
 31e:	8082                	ret

0000000000000320 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 320:	48a5                	li	a7,9
 ecall
 322:	00000073          	ecall
 ret
 326:	8082                	ret

0000000000000328 <dup>:
.global dup
dup:
 li a7, SYS_dup
 328:	48a9                	li	a7,10
 ecall
 32a:	00000073          	ecall
 ret
 32e:	8082                	ret

0000000000000330 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 330:	48ad                	li	a7,11
 ecall
 332:	00000073          	ecall
 ret
 336:	8082                	ret

0000000000000338 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 338:	48b1                	li	a7,12
 ecall
 33a:	00000073          	ecall
 ret
 33e:	8082                	ret

0000000000000340 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 340:	48b5                	li	a7,13
 ecall
 342:	00000073          	ecall
 ret
 346:	8082                	ret

0000000000000348 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 348:	48b9                	li	a7,14
 ecall
 34a:	00000073          	ecall
 ret
 34e:	8082                	ret

0000000000000350 <waitx>:
.global waitx
waitx:
 li a7, SYS_waitx
 350:	48d9                	li	a7,22
 ecall
 352:	00000073          	ecall
 ret
 356:	8082                	ret

0000000000000358 <getSysCount>:
.global getSysCount
getSysCount:
 li a7, SYS_getSysCount
 358:	48dd                	li	a7,23
 ecall
 35a:	00000073          	ecall
 ret
 35e:	8082                	ret

0000000000000360 <sigreturn>:
.global sigreturn
sigreturn:
 li a7, SYS_sigreturn
 360:	48e5                	li	a7,25
 ecall
 362:	00000073          	ecall
 ret
 366:	8082                	ret

0000000000000368 <sigalarm>:
.global sigalarm
sigalarm:
 li a7, SYS_sigalarm
 368:	48e1                	li	a7,24
 ecall
 36a:	00000073          	ecall
 ret
 36e:	8082                	ret

0000000000000370 <settickets>:
.global settickets
settickets:
 li a7, SYS_settickets
 370:	48e9                	li	a7,26
 ecall
 372:	00000073          	ecall
 ret
 376:	8082                	ret

0000000000000378 <printlog>:
.global printlog
printlog:
 li a7, SYS_printlog
 378:	48ed                	li	a7,27
 ecall
 37a:	00000073          	ecall
 ret
 37e:	8082                	ret

0000000000000380 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 380:	1101                	addi	sp,sp,-32
 382:	ec06                	sd	ra,24(sp)
 384:	e822                	sd	s0,16(sp)
 386:	1000                	addi	s0,sp,32
 388:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 38c:	4605                	li	a2,1
 38e:	fef40593          	addi	a1,s0,-17
 392:	00000097          	auipc	ra,0x0
 396:	f3e080e7          	jalr	-194(ra) # 2d0 <write>
}
 39a:	60e2                	ld	ra,24(sp)
 39c:	6442                	ld	s0,16(sp)
 39e:	6105                	addi	sp,sp,32
 3a0:	8082                	ret

00000000000003a2 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3a2:	7139                	addi	sp,sp,-64
 3a4:	fc06                	sd	ra,56(sp)
 3a6:	f822                	sd	s0,48(sp)
 3a8:	f426                	sd	s1,40(sp)
 3aa:	0080                	addi	s0,sp,64
 3ac:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 3ae:	c299                	beqz	a3,3b4 <printint+0x12>
 3b0:	0805cb63          	bltz	a1,446 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 3b4:	2581                	sext.w	a1,a1
  neg = 0;
 3b6:	4881                	li	a7,0
 3b8:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 3bc:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 3be:	2601                	sext.w	a2,a2
 3c0:	00000517          	auipc	a0,0x0
 3c4:	4a050513          	addi	a0,a0,1184 # 860 <digits>
 3c8:	883a                	mv	a6,a4
 3ca:	2705                	addiw	a4,a4,1
 3cc:	02c5f7bb          	remuw	a5,a1,a2
 3d0:	1782                	slli	a5,a5,0x20
 3d2:	9381                	srli	a5,a5,0x20
 3d4:	97aa                	add	a5,a5,a0
 3d6:	0007c783          	lbu	a5,0(a5)
 3da:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 3de:	0005879b          	sext.w	a5,a1
 3e2:	02c5d5bb          	divuw	a1,a1,a2
 3e6:	0685                	addi	a3,a3,1
 3e8:	fec7f0e3          	bgeu	a5,a2,3c8 <printint+0x26>
  if(neg)
 3ec:	00088c63          	beqz	a7,404 <printint+0x62>
    buf[i++] = '-';
 3f0:	fd070793          	addi	a5,a4,-48
 3f4:	00878733          	add	a4,a5,s0
 3f8:	02d00793          	li	a5,45
 3fc:	fef70823          	sb	a5,-16(a4)
 400:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 404:	02e05c63          	blez	a4,43c <printint+0x9a>
 408:	f04a                	sd	s2,32(sp)
 40a:	ec4e                	sd	s3,24(sp)
 40c:	fc040793          	addi	a5,s0,-64
 410:	00e78933          	add	s2,a5,a4
 414:	fff78993          	addi	s3,a5,-1
 418:	99ba                	add	s3,s3,a4
 41a:	377d                	addiw	a4,a4,-1
 41c:	1702                	slli	a4,a4,0x20
 41e:	9301                	srli	a4,a4,0x20
 420:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 424:	fff94583          	lbu	a1,-1(s2)
 428:	8526                	mv	a0,s1
 42a:	00000097          	auipc	ra,0x0
 42e:	f56080e7          	jalr	-170(ra) # 380 <putc>
  while(--i >= 0)
 432:	197d                	addi	s2,s2,-1
 434:	ff3918e3          	bne	s2,s3,424 <printint+0x82>
 438:	7902                	ld	s2,32(sp)
 43a:	69e2                	ld	s3,24(sp)
}
 43c:	70e2                	ld	ra,56(sp)
 43e:	7442                	ld	s0,48(sp)
 440:	74a2                	ld	s1,40(sp)
 442:	6121                	addi	sp,sp,64
 444:	8082                	ret
    x = -xx;
 446:	40b005bb          	negw	a1,a1
    neg = 1;
 44a:	4885                	li	a7,1
    x = -xx;
 44c:	b7b5                	j	3b8 <printint+0x16>

000000000000044e <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 44e:	715d                	addi	sp,sp,-80
 450:	e486                	sd	ra,72(sp)
 452:	e0a2                	sd	s0,64(sp)
 454:	f84a                	sd	s2,48(sp)
 456:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 458:	0005c903          	lbu	s2,0(a1)
 45c:	1a090a63          	beqz	s2,610 <vprintf+0x1c2>
 460:	fc26                	sd	s1,56(sp)
 462:	f44e                	sd	s3,40(sp)
 464:	f052                	sd	s4,32(sp)
 466:	ec56                	sd	s5,24(sp)
 468:	e85a                	sd	s6,16(sp)
 46a:	e45e                	sd	s7,8(sp)
 46c:	8aaa                	mv	s5,a0
 46e:	8bb2                	mv	s7,a2
 470:	00158493          	addi	s1,a1,1
  state = 0;
 474:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 476:	02500a13          	li	s4,37
 47a:	4b55                	li	s6,21
 47c:	a839                	j	49a <vprintf+0x4c>
        putc(fd, c);
 47e:	85ca                	mv	a1,s2
 480:	8556                	mv	a0,s5
 482:	00000097          	auipc	ra,0x0
 486:	efe080e7          	jalr	-258(ra) # 380 <putc>
 48a:	a019                	j	490 <vprintf+0x42>
    } else if(state == '%'){
 48c:	01498d63          	beq	s3,s4,4a6 <vprintf+0x58>
  for(i = 0; fmt[i]; i++){
 490:	0485                	addi	s1,s1,1
 492:	fff4c903          	lbu	s2,-1(s1)
 496:	16090763          	beqz	s2,604 <vprintf+0x1b6>
    if(state == 0){
 49a:	fe0999e3          	bnez	s3,48c <vprintf+0x3e>
      if(c == '%'){
 49e:	ff4910e3          	bne	s2,s4,47e <vprintf+0x30>
        state = '%';
 4a2:	89d2                	mv	s3,s4
 4a4:	b7f5                	j	490 <vprintf+0x42>
      if(c == 'd'){
 4a6:	13490463          	beq	s2,s4,5ce <vprintf+0x180>
 4aa:	f9d9079b          	addiw	a5,s2,-99
 4ae:	0ff7f793          	zext.b	a5,a5
 4b2:	12fb6763          	bltu	s6,a5,5e0 <vprintf+0x192>
 4b6:	f9d9079b          	addiw	a5,s2,-99
 4ba:	0ff7f713          	zext.b	a4,a5
 4be:	12eb6163          	bltu	s6,a4,5e0 <vprintf+0x192>
 4c2:	00271793          	slli	a5,a4,0x2
 4c6:	00000717          	auipc	a4,0x0
 4ca:	34270713          	addi	a4,a4,834 # 808 <malloc+0x108>
 4ce:	97ba                	add	a5,a5,a4
 4d0:	439c                	lw	a5,0(a5)
 4d2:	97ba                	add	a5,a5,a4
 4d4:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 4d6:	008b8913          	addi	s2,s7,8
 4da:	4685                	li	a3,1
 4dc:	4629                	li	a2,10
 4de:	000ba583          	lw	a1,0(s7)
 4e2:	8556                	mv	a0,s5
 4e4:	00000097          	auipc	ra,0x0
 4e8:	ebe080e7          	jalr	-322(ra) # 3a2 <printint>
 4ec:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 4ee:	4981                	li	s3,0
 4f0:	b745                	j	490 <vprintf+0x42>
        printint(fd, va_arg(ap, uint64), 10, 0);
 4f2:	008b8913          	addi	s2,s7,8
 4f6:	4681                	li	a3,0
 4f8:	4629                	li	a2,10
 4fa:	000ba583          	lw	a1,0(s7)
 4fe:	8556                	mv	a0,s5
 500:	00000097          	auipc	ra,0x0
 504:	ea2080e7          	jalr	-350(ra) # 3a2 <printint>
 508:	8bca                	mv	s7,s2
      state = 0;
 50a:	4981                	li	s3,0
 50c:	b751                	j	490 <vprintf+0x42>
        printint(fd, va_arg(ap, int), 16, 0);
 50e:	008b8913          	addi	s2,s7,8
 512:	4681                	li	a3,0
 514:	4641                	li	a2,16
 516:	000ba583          	lw	a1,0(s7)
 51a:	8556                	mv	a0,s5
 51c:	00000097          	auipc	ra,0x0
 520:	e86080e7          	jalr	-378(ra) # 3a2 <printint>
 524:	8bca                	mv	s7,s2
      state = 0;
 526:	4981                	li	s3,0
 528:	b7a5                	j	490 <vprintf+0x42>
 52a:	e062                	sd	s8,0(sp)
        printptr(fd, va_arg(ap, uint64));
 52c:	008b8c13          	addi	s8,s7,8
 530:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 534:	03000593          	li	a1,48
 538:	8556                	mv	a0,s5
 53a:	00000097          	auipc	ra,0x0
 53e:	e46080e7          	jalr	-442(ra) # 380 <putc>
  putc(fd, 'x');
 542:	07800593          	li	a1,120
 546:	8556                	mv	a0,s5
 548:	00000097          	auipc	ra,0x0
 54c:	e38080e7          	jalr	-456(ra) # 380 <putc>
 550:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 552:	00000b97          	auipc	s7,0x0
 556:	30eb8b93          	addi	s7,s7,782 # 860 <digits>
 55a:	03c9d793          	srli	a5,s3,0x3c
 55e:	97de                	add	a5,a5,s7
 560:	0007c583          	lbu	a1,0(a5)
 564:	8556                	mv	a0,s5
 566:	00000097          	auipc	ra,0x0
 56a:	e1a080e7          	jalr	-486(ra) # 380 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 56e:	0992                	slli	s3,s3,0x4
 570:	397d                	addiw	s2,s2,-1
 572:	fe0914e3          	bnez	s2,55a <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 576:	8be2                	mv	s7,s8
      state = 0;
 578:	4981                	li	s3,0
 57a:	6c02                	ld	s8,0(sp)
 57c:	bf11                	j	490 <vprintf+0x42>
        s = va_arg(ap, char*);
 57e:	008b8993          	addi	s3,s7,8
 582:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 586:	02090163          	beqz	s2,5a8 <vprintf+0x15a>
        while(*s != 0){
 58a:	00094583          	lbu	a1,0(s2)
 58e:	c9a5                	beqz	a1,5fe <vprintf+0x1b0>
          putc(fd, *s);
 590:	8556                	mv	a0,s5
 592:	00000097          	auipc	ra,0x0
 596:	dee080e7          	jalr	-530(ra) # 380 <putc>
          s++;
 59a:	0905                	addi	s2,s2,1
        while(*s != 0){
 59c:	00094583          	lbu	a1,0(s2)
 5a0:	f9e5                	bnez	a1,590 <vprintf+0x142>
        s = va_arg(ap, char*);
 5a2:	8bce                	mv	s7,s3
      state = 0;
 5a4:	4981                	li	s3,0
 5a6:	b5ed                	j	490 <vprintf+0x42>
          s = "(null)";
 5a8:	00000917          	auipc	s2,0x0
 5ac:	25890913          	addi	s2,s2,600 # 800 <malloc+0x100>
        while(*s != 0){
 5b0:	02800593          	li	a1,40
 5b4:	bff1                	j	590 <vprintf+0x142>
        putc(fd, va_arg(ap, uint));
 5b6:	008b8913          	addi	s2,s7,8
 5ba:	000bc583          	lbu	a1,0(s7)
 5be:	8556                	mv	a0,s5
 5c0:	00000097          	auipc	ra,0x0
 5c4:	dc0080e7          	jalr	-576(ra) # 380 <putc>
 5c8:	8bca                	mv	s7,s2
      state = 0;
 5ca:	4981                	li	s3,0
 5cc:	b5d1                	j	490 <vprintf+0x42>
        putc(fd, c);
 5ce:	02500593          	li	a1,37
 5d2:	8556                	mv	a0,s5
 5d4:	00000097          	auipc	ra,0x0
 5d8:	dac080e7          	jalr	-596(ra) # 380 <putc>
      state = 0;
 5dc:	4981                	li	s3,0
 5de:	bd4d                	j	490 <vprintf+0x42>
        putc(fd, '%');
 5e0:	02500593          	li	a1,37
 5e4:	8556                	mv	a0,s5
 5e6:	00000097          	auipc	ra,0x0
 5ea:	d9a080e7          	jalr	-614(ra) # 380 <putc>
        putc(fd, c);
 5ee:	85ca                	mv	a1,s2
 5f0:	8556                	mv	a0,s5
 5f2:	00000097          	auipc	ra,0x0
 5f6:	d8e080e7          	jalr	-626(ra) # 380 <putc>
      state = 0;
 5fa:	4981                	li	s3,0
 5fc:	bd51                	j	490 <vprintf+0x42>
        s = va_arg(ap, char*);
 5fe:	8bce                	mv	s7,s3
      state = 0;
 600:	4981                	li	s3,0
 602:	b579                	j	490 <vprintf+0x42>
 604:	74e2                	ld	s1,56(sp)
 606:	79a2                	ld	s3,40(sp)
 608:	7a02                	ld	s4,32(sp)
 60a:	6ae2                	ld	s5,24(sp)
 60c:	6b42                	ld	s6,16(sp)
 60e:	6ba2                	ld	s7,8(sp)
    }
  }
}
 610:	60a6                	ld	ra,72(sp)
 612:	6406                	ld	s0,64(sp)
 614:	7942                	ld	s2,48(sp)
 616:	6161                	addi	sp,sp,80
 618:	8082                	ret

000000000000061a <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 61a:	715d                	addi	sp,sp,-80
 61c:	ec06                	sd	ra,24(sp)
 61e:	e822                	sd	s0,16(sp)
 620:	1000                	addi	s0,sp,32
 622:	e010                	sd	a2,0(s0)
 624:	e414                	sd	a3,8(s0)
 626:	e818                	sd	a4,16(s0)
 628:	ec1c                	sd	a5,24(s0)
 62a:	03043023          	sd	a6,32(s0)
 62e:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 632:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 636:	8622                	mv	a2,s0
 638:	00000097          	auipc	ra,0x0
 63c:	e16080e7          	jalr	-490(ra) # 44e <vprintf>
}
 640:	60e2                	ld	ra,24(sp)
 642:	6442                	ld	s0,16(sp)
 644:	6161                	addi	sp,sp,80
 646:	8082                	ret

0000000000000648 <printf>:

void
printf(const char *fmt, ...)
{
 648:	711d                	addi	sp,sp,-96
 64a:	ec06                	sd	ra,24(sp)
 64c:	e822                	sd	s0,16(sp)
 64e:	1000                	addi	s0,sp,32
 650:	e40c                	sd	a1,8(s0)
 652:	e810                	sd	a2,16(s0)
 654:	ec14                	sd	a3,24(s0)
 656:	f018                	sd	a4,32(s0)
 658:	f41c                	sd	a5,40(s0)
 65a:	03043823          	sd	a6,48(s0)
 65e:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 662:	00840613          	addi	a2,s0,8
 666:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 66a:	85aa                	mv	a1,a0
 66c:	4505                	li	a0,1
 66e:	00000097          	auipc	ra,0x0
 672:	de0080e7          	jalr	-544(ra) # 44e <vprintf>
}
 676:	60e2                	ld	ra,24(sp)
 678:	6442                	ld	s0,16(sp)
 67a:	6125                	addi	sp,sp,96
 67c:	8082                	ret

000000000000067e <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 67e:	1141                	addi	sp,sp,-16
 680:	e422                	sd	s0,8(sp)
 682:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 684:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 688:	00001797          	auipc	a5,0x1
 68c:	9787b783          	ld	a5,-1672(a5) # 1000 <freep>
 690:	a02d                	j	6ba <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 692:	4618                	lw	a4,8(a2)
 694:	9f2d                	addw	a4,a4,a1
 696:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 69a:	6398                	ld	a4,0(a5)
 69c:	6310                	ld	a2,0(a4)
 69e:	a83d                	j	6dc <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 6a0:	ff852703          	lw	a4,-8(a0)
 6a4:	9f31                	addw	a4,a4,a2
 6a6:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 6a8:	ff053683          	ld	a3,-16(a0)
 6ac:	a091                	j	6f0 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6ae:	6398                	ld	a4,0(a5)
 6b0:	00e7e463          	bltu	a5,a4,6b8 <free+0x3a>
 6b4:	00e6ea63          	bltu	a3,a4,6c8 <free+0x4a>
{
 6b8:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6ba:	fed7fae3          	bgeu	a5,a3,6ae <free+0x30>
 6be:	6398                	ld	a4,0(a5)
 6c0:	00e6e463          	bltu	a3,a4,6c8 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6c4:	fee7eae3          	bltu	a5,a4,6b8 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 6c8:	ff852583          	lw	a1,-8(a0)
 6cc:	6390                	ld	a2,0(a5)
 6ce:	02059813          	slli	a6,a1,0x20
 6d2:	01c85713          	srli	a4,a6,0x1c
 6d6:	9736                	add	a4,a4,a3
 6d8:	fae60de3          	beq	a2,a4,692 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 6dc:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 6e0:	4790                	lw	a2,8(a5)
 6e2:	02061593          	slli	a1,a2,0x20
 6e6:	01c5d713          	srli	a4,a1,0x1c
 6ea:	973e                	add	a4,a4,a5
 6ec:	fae68ae3          	beq	a3,a4,6a0 <free+0x22>
    p->s.ptr = bp->s.ptr;
 6f0:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 6f2:	00001717          	auipc	a4,0x1
 6f6:	90f73723          	sd	a5,-1778(a4) # 1000 <freep>
}
 6fa:	6422                	ld	s0,8(sp)
 6fc:	0141                	addi	sp,sp,16
 6fe:	8082                	ret

0000000000000700 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 700:	7139                	addi	sp,sp,-64
 702:	fc06                	sd	ra,56(sp)
 704:	f822                	sd	s0,48(sp)
 706:	f426                	sd	s1,40(sp)
 708:	ec4e                	sd	s3,24(sp)
 70a:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 70c:	02051493          	slli	s1,a0,0x20
 710:	9081                	srli	s1,s1,0x20
 712:	04bd                	addi	s1,s1,15
 714:	8091                	srli	s1,s1,0x4
 716:	0014899b          	addiw	s3,s1,1
 71a:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 71c:	00001517          	auipc	a0,0x1
 720:	8e453503          	ld	a0,-1820(a0) # 1000 <freep>
 724:	c915                	beqz	a0,758 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 726:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 728:	4798                	lw	a4,8(a5)
 72a:	08977e63          	bgeu	a4,s1,7c6 <malloc+0xc6>
 72e:	f04a                	sd	s2,32(sp)
 730:	e852                	sd	s4,16(sp)
 732:	e456                	sd	s5,8(sp)
 734:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 736:	8a4e                	mv	s4,s3
 738:	0009871b          	sext.w	a4,s3
 73c:	6685                	lui	a3,0x1
 73e:	00d77363          	bgeu	a4,a3,744 <malloc+0x44>
 742:	6a05                	lui	s4,0x1
 744:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 748:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 74c:	00001917          	auipc	s2,0x1
 750:	8b490913          	addi	s2,s2,-1868 # 1000 <freep>
  if(p == (char*)-1)
 754:	5afd                	li	s5,-1
 756:	a091                	j	79a <malloc+0x9a>
 758:	f04a                	sd	s2,32(sp)
 75a:	e852                	sd	s4,16(sp)
 75c:	e456                	sd	s5,8(sp)
 75e:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 760:	00001797          	auipc	a5,0x1
 764:	8b078793          	addi	a5,a5,-1872 # 1010 <base>
 768:	00001717          	auipc	a4,0x1
 76c:	88f73c23          	sd	a5,-1896(a4) # 1000 <freep>
 770:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 772:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 776:	b7c1                	j	736 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 778:	6398                	ld	a4,0(a5)
 77a:	e118                	sd	a4,0(a0)
 77c:	a08d                	j	7de <malloc+0xde>
  hp->s.size = nu;
 77e:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 782:	0541                	addi	a0,a0,16
 784:	00000097          	auipc	ra,0x0
 788:	efa080e7          	jalr	-262(ra) # 67e <free>
  return freep;
 78c:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 790:	c13d                	beqz	a0,7f6 <malloc+0xf6>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 792:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 794:	4798                	lw	a4,8(a5)
 796:	02977463          	bgeu	a4,s1,7be <malloc+0xbe>
    if(p == freep)
 79a:	00093703          	ld	a4,0(s2)
 79e:	853e                	mv	a0,a5
 7a0:	fef719e3          	bne	a4,a5,792 <malloc+0x92>
  p = sbrk(nu * sizeof(Header));
 7a4:	8552                	mv	a0,s4
 7a6:	00000097          	auipc	ra,0x0
 7aa:	b92080e7          	jalr	-1134(ra) # 338 <sbrk>
  if(p == (char*)-1)
 7ae:	fd5518e3          	bne	a0,s5,77e <malloc+0x7e>
        return 0;
 7b2:	4501                	li	a0,0
 7b4:	7902                	ld	s2,32(sp)
 7b6:	6a42                	ld	s4,16(sp)
 7b8:	6aa2                	ld	s5,8(sp)
 7ba:	6b02                	ld	s6,0(sp)
 7bc:	a03d                	j	7ea <malloc+0xea>
 7be:	7902                	ld	s2,32(sp)
 7c0:	6a42                	ld	s4,16(sp)
 7c2:	6aa2                	ld	s5,8(sp)
 7c4:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 7c6:	fae489e3          	beq	s1,a4,778 <malloc+0x78>
        p->s.size -= nunits;
 7ca:	4137073b          	subw	a4,a4,s3
 7ce:	c798                	sw	a4,8(a5)
        p += p->s.size;
 7d0:	02071693          	slli	a3,a4,0x20
 7d4:	01c6d713          	srli	a4,a3,0x1c
 7d8:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 7da:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 7de:	00001717          	auipc	a4,0x1
 7e2:	82a73123          	sd	a0,-2014(a4) # 1000 <freep>
      return (void*)(p + 1);
 7e6:	01078513          	addi	a0,a5,16
  }
}
 7ea:	70e2                	ld	ra,56(sp)
 7ec:	7442                	ld	s0,48(sp)
 7ee:	74a2                	ld	s1,40(sp)
 7f0:	69e2                	ld	s3,24(sp)
 7f2:	6121                	addi	sp,sp,64
 7f4:	8082                	ret
 7f6:	7902                	ld	s2,32(sp)
 7f8:	6a42                	ld	s4,16(sp)
 7fa:	6aa2                	ld	s5,8(sp)
 7fc:	6b02                	ld	s6,0(sp)
 7fe:	b7f5                	j	7ea <malloc+0xea>
