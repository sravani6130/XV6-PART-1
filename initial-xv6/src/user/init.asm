
user/_init:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:

char *argv[] = { "sh", 0 };

int
main(void)
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	e04a                	sd	s2,0(sp)
   a:	1000                	addi	s0,sp,32
  int pid, wpid;

  if(open("console", O_RDWR) < 0){
   c:	4589                	li	a1,2
   e:	00001517          	auipc	a0,0x1
  12:	8c250513          	addi	a0,a0,-1854 # 8d0 <malloc+0x102>
  16:	00000097          	auipc	ra,0x0
  1a:	3a8080e7          	jalr	936(ra) # 3be <open>
  1e:	06054363          	bltz	a0,84 <main+0x84>
    mknod("console", CONSOLE, 0);
    open("console", O_RDWR);
  }
  dup(0);  // stdout
  22:	4501                	li	a0,0
  24:	00000097          	auipc	ra,0x0
  28:	3d2080e7          	jalr	978(ra) # 3f6 <dup>
  dup(0);  // stderr
  2c:	4501                	li	a0,0
  2e:	00000097          	auipc	ra,0x0
  32:	3c8080e7          	jalr	968(ra) # 3f6 <dup>

  for(;;){
    printf("init: starting sh\n");
  36:	00001917          	auipc	s2,0x1
  3a:	8a290913          	addi	s2,s2,-1886 # 8d8 <malloc+0x10a>
  3e:	854a                	mv	a0,s2
  40:	00000097          	auipc	ra,0x0
  44:	6d6080e7          	jalr	1750(ra) # 716 <printf>
    pid = fork();
  48:	00000097          	auipc	ra,0x0
  4c:	32e080e7          	jalr	814(ra) # 376 <fork>
  50:	84aa                	mv	s1,a0
    if(pid < 0){
  52:	04054d63          	bltz	a0,ac <main+0xac>
      printf("init: fork failed\n");
      exit(1);
    }
    if(pid == 0){
  56:	c925                	beqz	a0,c6 <main+0xc6>
    }

    for(;;){
      // this call to wait() returns if the shell exits,
      // or if a parentless process exits.
      wpid = wait((int *) 0);
  58:	4501                	li	a0,0
  5a:	00000097          	auipc	ra,0x0
  5e:	32c080e7          	jalr	812(ra) # 386 <wait>
      if(wpid == pid){
  62:	fca48ee3          	beq	s1,a0,3e <main+0x3e>
        // the shell exited; restart it.
        break;
      } else if(wpid < 0){
  66:	fe0559e3          	bgez	a0,58 <main+0x58>
        printf("init: wait returned an error\n");
  6a:	00001517          	auipc	a0,0x1
  6e:	8be50513          	addi	a0,a0,-1858 # 928 <malloc+0x15a>
  72:	00000097          	auipc	ra,0x0
  76:	6a4080e7          	jalr	1700(ra) # 716 <printf>
        exit(1);
  7a:	4505                	li	a0,1
  7c:	00000097          	auipc	ra,0x0
  80:	302080e7          	jalr	770(ra) # 37e <exit>
    mknod("console", CONSOLE, 0);
  84:	4601                	li	a2,0
  86:	4585                	li	a1,1
  88:	00001517          	auipc	a0,0x1
  8c:	84850513          	addi	a0,a0,-1976 # 8d0 <malloc+0x102>
  90:	00000097          	auipc	ra,0x0
  94:	336080e7          	jalr	822(ra) # 3c6 <mknod>
    open("console", O_RDWR);
  98:	4589                	li	a1,2
  9a:	00001517          	auipc	a0,0x1
  9e:	83650513          	addi	a0,a0,-1994 # 8d0 <malloc+0x102>
  a2:	00000097          	auipc	ra,0x0
  a6:	31c080e7          	jalr	796(ra) # 3be <open>
  aa:	bfa5                	j	22 <main+0x22>
      printf("init: fork failed\n");
  ac:	00001517          	auipc	a0,0x1
  b0:	84450513          	addi	a0,a0,-1980 # 8f0 <malloc+0x122>
  b4:	00000097          	auipc	ra,0x0
  b8:	662080e7          	jalr	1634(ra) # 716 <printf>
      exit(1);
  bc:	4505                	li	a0,1
  be:	00000097          	auipc	ra,0x0
  c2:	2c0080e7          	jalr	704(ra) # 37e <exit>
      exec("sh", argv);
  c6:	00001597          	auipc	a1,0x1
  ca:	f3a58593          	addi	a1,a1,-198 # 1000 <argv>
  ce:	00001517          	auipc	a0,0x1
  d2:	83a50513          	addi	a0,a0,-1990 # 908 <malloc+0x13a>
  d6:	00000097          	auipc	ra,0x0
  da:	2e0080e7          	jalr	736(ra) # 3b6 <exec>
      printf("init: exec sh failed\n");
  de:	00001517          	auipc	a0,0x1
  e2:	83250513          	addi	a0,a0,-1998 # 910 <malloc+0x142>
  e6:	00000097          	auipc	ra,0x0
  ea:	630080e7          	jalr	1584(ra) # 716 <printf>
      exit(1);
  ee:	4505                	li	a0,1
  f0:	00000097          	auipc	ra,0x0
  f4:	28e080e7          	jalr	654(ra) # 37e <exit>

00000000000000f8 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
  f8:	1141                	addi	sp,sp,-16
  fa:	e406                	sd	ra,8(sp)
  fc:	e022                	sd	s0,0(sp)
  fe:	0800                	addi	s0,sp,16
  extern int main();
  main();
 100:	00000097          	auipc	ra,0x0
 104:	f00080e7          	jalr	-256(ra) # 0 <main>
  exit(0);
 108:	4501                	li	a0,0
 10a:	00000097          	auipc	ra,0x0
 10e:	274080e7          	jalr	628(ra) # 37e <exit>

0000000000000112 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 112:	1141                	addi	sp,sp,-16
 114:	e422                	sd	s0,8(sp)
 116:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 118:	87aa                	mv	a5,a0
 11a:	0585                	addi	a1,a1,1
 11c:	0785                	addi	a5,a5,1
 11e:	fff5c703          	lbu	a4,-1(a1)
 122:	fee78fa3          	sb	a4,-1(a5)
 126:	fb75                	bnez	a4,11a <strcpy+0x8>
    ;
  return os;
}
 128:	6422                	ld	s0,8(sp)
 12a:	0141                	addi	sp,sp,16
 12c:	8082                	ret

000000000000012e <strcmp>:

int
strcmp(const char *p, const char *q)
{
 12e:	1141                	addi	sp,sp,-16
 130:	e422                	sd	s0,8(sp)
 132:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 134:	00054783          	lbu	a5,0(a0)
 138:	cb91                	beqz	a5,14c <strcmp+0x1e>
 13a:	0005c703          	lbu	a4,0(a1)
 13e:	00f71763          	bne	a4,a5,14c <strcmp+0x1e>
    p++, q++;
 142:	0505                	addi	a0,a0,1
 144:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 146:	00054783          	lbu	a5,0(a0)
 14a:	fbe5                	bnez	a5,13a <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 14c:	0005c503          	lbu	a0,0(a1)
}
 150:	40a7853b          	subw	a0,a5,a0
 154:	6422                	ld	s0,8(sp)
 156:	0141                	addi	sp,sp,16
 158:	8082                	ret

000000000000015a <strlen>:

uint
strlen(const char *s)
{
 15a:	1141                	addi	sp,sp,-16
 15c:	e422                	sd	s0,8(sp)
 15e:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 160:	00054783          	lbu	a5,0(a0)
 164:	cf91                	beqz	a5,180 <strlen+0x26>
 166:	0505                	addi	a0,a0,1
 168:	87aa                	mv	a5,a0
 16a:	86be                	mv	a3,a5
 16c:	0785                	addi	a5,a5,1
 16e:	fff7c703          	lbu	a4,-1(a5)
 172:	ff65                	bnez	a4,16a <strlen+0x10>
 174:	40a6853b          	subw	a0,a3,a0
 178:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 17a:	6422                	ld	s0,8(sp)
 17c:	0141                	addi	sp,sp,16
 17e:	8082                	ret
  for(n = 0; s[n]; n++)
 180:	4501                	li	a0,0
 182:	bfe5                	j	17a <strlen+0x20>

0000000000000184 <memset>:

void*
memset(void *dst, int c, uint n)
{
 184:	1141                	addi	sp,sp,-16
 186:	e422                	sd	s0,8(sp)
 188:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 18a:	ca19                	beqz	a2,1a0 <memset+0x1c>
 18c:	87aa                	mv	a5,a0
 18e:	1602                	slli	a2,a2,0x20
 190:	9201                	srli	a2,a2,0x20
 192:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 196:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 19a:	0785                	addi	a5,a5,1
 19c:	fee79de3          	bne	a5,a4,196 <memset+0x12>
  }
  return dst;
}
 1a0:	6422                	ld	s0,8(sp)
 1a2:	0141                	addi	sp,sp,16
 1a4:	8082                	ret

00000000000001a6 <strchr>:

char*
strchr(const char *s, char c)
{
 1a6:	1141                	addi	sp,sp,-16
 1a8:	e422                	sd	s0,8(sp)
 1aa:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1ac:	00054783          	lbu	a5,0(a0)
 1b0:	cb99                	beqz	a5,1c6 <strchr+0x20>
    if(*s == c)
 1b2:	00f58763          	beq	a1,a5,1c0 <strchr+0x1a>
  for(; *s; s++)
 1b6:	0505                	addi	a0,a0,1
 1b8:	00054783          	lbu	a5,0(a0)
 1bc:	fbfd                	bnez	a5,1b2 <strchr+0xc>
      return (char*)s;
  return 0;
 1be:	4501                	li	a0,0
}
 1c0:	6422                	ld	s0,8(sp)
 1c2:	0141                	addi	sp,sp,16
 1c4:	8082                	ret
  return 0;
 1c6:	4501                	li	a0,0
 1c8:	bfe5                	j	1c0 <strchr+0x1a>

00000000000001ca <gets>:

char*
gets(char *buf, int max)
{
 1ca:	711d                	addi	sp,sp,-96
 1cc:	ec86                	sd	ra,88(sp)
 1ce:	e8a2                	sd	s0,80(sp)
 1d0:	e4a6                	sd	s1,72(sp)
 1d2:	e0ca                	sd	s2,64(sp)
 1d4:	fc4e                	sd	s3,56(sp)
 1d6:	f852                	sd	s4,48(sp)
 1d8:	f456                	sd	s5,40(sp)
 1da:	f05a                	sd	s6,32(sp)
 1dc:	ec5e                	sd	s7,24(sp)
 1de:	1080                	addi	s0,sp,96
 1e0:	8baa                	mv	s7,a0
 1e2:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1e4:	892a                	mv	s2,a0
 1e6:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1e8:	4aa9                	li	s5,10
 1ea:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1ec:	89a6                	mv	s3,s1
 1ee:	2485                	addiw	s1,s1,1
 1f0:	0344d863          	bge	s1,s4,220 <gets+0x56>
    cc = read(0, &c, 1);
 1f4:	4605                	li	a2,1
 1f6:	faf40593          	addi	a1,s0,-81
 1fa:	4501                	li	a0,0
 1fc:	00000097          	auipc	ra,0x0
 200:	19a080e7          	jalr	410(ra) # 396 <read>
    if(cc < 1)
 204:	00a05e63          	blez	a0,220 <gets+0x56>
    buf[i++] = c;
 208:	faf44783          	lbu	a5,-81(s0)
 20c:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 210:	01578763          	beq	a5,s5,21e <gets+0x54>
 214:	0905                	addi	s2,s2,1
 216:	fd679be3          	bne	a5,s6,1ec <gets+0x22>
    buf[i++] = c;
 21a:	89a6                	mv	s3,s1
 21c:	a011                	j	220 <gets+0x56>
 21e:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 220:	99de                	add	s3,s3,s7
 222:	00098023          	sb	zero,0(s3)
  return buf;
}
 226:	855e                	mv	a0,s7
 228:	60e6                	ld	ra,88(sp)
 22a:	6446                	ld	s0,80(sp)
 22c:	64a6                	ld	s1,72(sp)
 22e:	6906                	ld	s2,64(sp)
 230:	79e2                	ld	s3,56(sp)
 232:	7a42                	ld	s4,48(sp)
 234:	7aa2                	ld	s5,40(sp)
 236:	7b02                	ld	s6,32(sp)
 238:	6be2                	ld	s7,24(sp)
 23a:	6125                	addi	sp,sp,96
 23c:	8082                	ret

000000000000023e <stat>:

int
stat(const char *n, struct stat *st)
{
 23e:	1101                	addi	sp,sp,-32
 240:	ec06                	sd	ra,24(sp)
 242:	e822                	sd	s0,16(sp)
 244:	e04a                	sd	s2,0(sp)
 246:	1000                	addi	s0,sp,32
 248:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 24a:	4581                	li	a1,0
 24c:	00000097          	auipc	ra,0x0
 250:	172080e7          	jalr	370(ra) # 3be <open>
  if(fd < 0)
 254:	02054663          	bltz	a0,280 <stat+0x42>
 258:	e426                	sd	s1,8(sp)
 25a:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 25c:	85ca                	mv	a1,s2
 25e:	00000097          	auipc	ra,0x0
 262:	178080e7          	jalr	376(ra) # 3d6 <fstat>
 266:	892a                	mv	s2,a0
  close(fd);
 268:	8526                	mv	a0,s1
 26a:	00000097          	auipc	ra,0x0
 26e:	13c080e7          	jalr	316(ra) # 3a6 <close>
  return r;
 272:	64a2                	ld	s1,8(sp)
}
 274:	854a                	mv	a0,s2
 276:	60e2                	ld	ra,24(sp)
 278:	6442                	ld	s0,16(sp)
 27a:	6902                	ld	s2,0(sp)
 27c:	6105                	addi	sp,sp,32
 27e:	8082                	ret
    return -1;
 280:	597d                	li	s2,-1
 282:	bfcd                	j	274 <stat+0x36>

0000000000000284 <atoi>:

int
atoi(const char *s)
{
 284:	1141                	addi	sp,sp,-16
 286:	e422                	sd	s0,8(sp)
 288:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 28a:	00054683          	lbu	a3,0(a0)
 28e:	fd06879b          	addiw	a5,a3,-48
 292:	0ff7f793          	zext.b	a5,a5
 296:	4625                	li	a2,9
 298:	02f66863          	bltu	a2,a5,2c8 <atoi+0x44>
 29c:	872a                	mv	a4,a0
  n = 0;
 29e:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 2a0:	0705                	addi	a4,a4,1
 2a2:	0025179b          	slliw	a5,a0,0x2
 2a6:	9fa9                	addw	a5,a5,a0
 2a8:	0017979b          	slliw	a5,a5,0x1
 2ac:	9fb5                	addw	a5,a5,a3
 2ae:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2b2:	00074683          	lbu	a3,0(a4)
 2b6:	fd06879b          	addiw	a5,a3,-48
 2ba:	0ff7f793          	zext.b	a5,a5
 2be:	fef671e3          	bgeu	a2,a5,2a0 <atoi+0x1c>
  return n;
}
 2c2:	6422                	ld	s0,8(sp)
 2c4:	0141                	addi	sp,sp,16
 2c6:	8082                	ret
  n = 0;
 2c8:	4501                	li	a0,0
 2ca:	bfe5                	j	2c2 <atoi+0x3e>

00000000000002cc <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2cc:	1141                	addi	sp,sp,-16
 2ce:	e422                	sd	s0,8(sp)
 2d0:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2d2:	02b57463          	bgeu	a0,a1,2fa <memmove+0x2e>
    while(n-- > 0)
 2d6:	00c05f63          	blez	a2,2f4 <memmove+0x28>
 2da:	1602                	slli	a2,a2,0x20
 2dc:	9201                	srli	a2,a2,0x20
 2de:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2e2:	872a                	mv	a4,a0
      *dst++ = *src++;
 2e4:	0585                	addi	a1,a1,1
 2e6:	0705                	addi	a4,a4,1
 2e8:	fff5c683          	lbu	a3,-1(a1)
 2ec:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2f0:	fef71ae3          	bne	a4,a5,2e4 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2f4:	6422                	ld	s0,8(sp)
 2f6:	0141                	addi	sp,sp,16
 2f8:	8082                	ret
    dst += n;
 2fa:	00c50733          	add	a4,a0,a2
    src += n;
 2fe:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 300:	fec05ae3          	blez	a2,2f4 <memmove+0x28>
 304:	fff6079b          	addiw	a5,a2,-1
 308:	1782                	slli	a5,a5,0x20
 30a:	9381                	srli	a5,a5,0x20
 30c:	fff7c793          	not	a5,a5
 310:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 312:	15fd                	addi	a1,a1,-1
 314:	177d                	addi	a4,a4,-1
 316:	0005c683          	lbu	a3,0(a1)
 31a:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 31e:	fee79ae3          	bne	a5,a4,312 <memmove+0x46>
 322:	bfc9                	j	2f4 <memmove+0x28>

0000000000000324 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 324:	1141                	addi	sp,sp,-16
 326:	e422                	sd	s0,8(sp)
 328:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 32a:	ca05                	beqz	a2,35a <memcmp+0x36>
 32c:	fff6069b          	addiw	a3,a2,-1
 330:	1682                	slli	a3,a3,0x20
 332:	9281                	srli	a3,a3,0x20
 334:	0685                	addi	a3,a3,1
 336:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 338:	00054783          	lbu	a5,0(a0)
 33c:	0005c703          	lbu	a4,0(a1)
 340:	00e79863          	bne	a5,a4,350 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 344:	0505                	addi	a0,a0,1
    p2++;
 346:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 348:	fed518e3          	bne	a0,a3,338 <memcmp+0x14>
  }
  return 0;
 34c:	4501                	li	a0,0
 34e:	a019                	j	354 <memcmp+0x30>
      return *p1 - *p2;
 350:	40e7853b          	subw	a0,a5,a4
}
 354:	6422                	ld	s0,8(sp)
 356:	0141                	addi	sp,sp,16
 358:	8082                	ret
  return 0;
 35a:	4501                	li	a0,0
 35c:	bfe5                	j	354 <memcmp+0x30>

000000000000035e <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 35e:	1141                	addi	sp,sp,-16
 360:	e406                	sd	ra,8(sp)
 362:	e022                	sd	s0,0(sp)
 364:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 366:	00000097          	auipc	ra,0x0
 36a:	f66080e7          	jalr	-154(ra) # 2cc <memmove>
}
 36e:	60a2                	ld	ra,8(sp)
 370:	6402                	ld	s0,0(sp)
 372:	0141                	addi	sp,sp,16
 374:	8082                	ret

0000000000000376 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 376:	4885                	li	a7,1
 ecall
 378:	00000073          	ecall
 ret
 37c:	8082                	ret

000000000000037e <exit>:
.global exit
exit:
 li a7, SYS_exit
 37e:	4889                	li	a7,2
 ecall
 380:	00000073          	ecall
 ret
 384:	8082                	ret

0000000000000386 <wait>:
.global wait
wait:
 li a7, SYS_wait
 386:	488d                	li	a7,3
 ecall
 388:	00000073          	ecall
 ret
 38c:	8082                	ret

000000000000038e <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 38e:	4891                	li	a7,4
 ecall
 390:	00000073          	ecall
 ret
 394:	8082                	ret

0000000000000396 <read>:
.global read
read:
 li a7, SYS_read
 396:	4895                	li	a7,5
 ecall
 398:	00000073          	ecall
 ret
 39c:	8082                	ret

000000000000039e <write>:
.global write
write:
 li a7, SYS_write
 39e:	48c1                	li	a7,16
 ecall
 3a0:	00000073          	ecall
 ret
 3a4:	8082                	ret

00000000000003a6 <close>:
.global close
close:
 li a7, SYS_close
 3a6:	48d5                	li	a7,21
 ecall
 3a8:	00000073          	ecall
 ret
 3ac:	8082                	ret

00000000000003ae <kill>:
.global kill
kill:
 li a7, SYS_kill
 3ae:	4899                	li	a7,6
 ecall
 3b0:	00000073          	ecall
 ret
 3b4:	8082                	ret

00000000000003b6 <exec>:
.global exec
exec:
 li a7, SYS_exec
 3b6:	489d                	li	a7,7
 ecall
 3b8:	00000073          	ecall
 ret
 3bc:	8082                	ret

00000000000003be <open>:
.global open
open:
 li a7, SYS_open
 3be:	48bd                	li	a7,15
 ecall
 3c0:	00000073          	ecall
 ret
 3c4:	8082                	ret

00000000000003c6 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3c6:	48c5                	li	a7,17
 ecall
 3c8:	00000073          	ecall
 ret
 3cc:	8082                	ret

00000000000003ce <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3ce:	48c9                	li	a7,18
 ecall
 3d0:	00000073          	ecall
 ret
 3d4:	8082                	ret

00000000000003d6 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3d6:	48a1                	li	a7,8
 ecall
 3d8:	00000073          	ecall
 ret
 3dc:	8082                	ret

00000000000003de <link>:
.global link
link:
 li a7, SYS_link
 3de:	48cd                	li	a7,19
 ecall
 3e0:	00000073          	ecall
 ret
 3e4:	8082                	ret

00000000000003e6 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3e6:	48d1                	li	a7,20
 ecall
 3e8:	00000073          	ecall
 ret
 3ec:	8082                	ret

00000000000003ee <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3ee:	48a5                	li	a7,9
 ecall
 3f0:	00000073          	ecall
 ret
 3f4:	8082                	ret

00000000000003f6 <dup>:
.global dup
dup:
 li a7, SYS_dup
 3f6:	48a9                	li	a7,10
 ecall
 3f8:	00000073          	ecall
 ret
 3fc:	8082                	ret

00000000000003fe <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3fe:	48ad                	li	a7,11
 ecall
 400:	00000073          	ecall
 ret
 404:	8082                	ret

0000000000000406 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 406:	48b1                	li	a7,12
 ecall
 408:	00000073          	ecall
 ret
 40c:	8082                	ret

000000000000040e <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 40e:	48b5                	li	a7,13
 ecall
 410:	00000073          	ecall
 ret
 414:	8082                	ret

0000000000000416 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 416:	48b9                	li	a7,14
 ecall
 418:	00000073          	ecall
 ret
 41c:	8082                	ret

000000000000041e <waitx>:
.global waitx
waitx:
 li a7, SYS_waitx
 41e:	48d9                	li	a7,22
 ecall
 420:	00000073          	ecall
 ret
 424:	8082                	ret

0000000000000426 <getSysCount>:
.global getSysCount
getSysCount:
 li a7, SYS_getSysCount
 426:	48dd                	li	a7,23
 ecall
 428:	00000073          	ecall
 ret
 42c:	8082                	ret

000000000000042e <sigreturn>:
.global sigreturn
sigreturn:
 li a7, SYS_sigreturn
 42e:	48e5                	li	a7,25
 ecall
 430:	00000073          	ecall
 ret
 434:	8082                	ret

0000000000000436 <sigalarm>:
.global sigalarm
sigalarm:
 li a7, SYS_sigalarm
 436:	48e1                	li	a7,24
 ecall
 438:	00000073          	ecall
 ret
 43c:	8082                	ret

000000000000043e <settickets>:
.global settickets
settickets:
 li a7, SYS_settickets
 43e:	48e9                	li	a7,26
 ecall
 440:	00000073          	ecall
 ret
 444:	8082                	ret

0000000000000446 <printlog>:
.global printlog
printlog:
 li a7, SYS_printlog
 446:	48ed                	li	a7,27
 ecall
 448:	00000073          	ecall
 ret
 44c:	8082                	ret

000000000000044e <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 44e:	1101                	addi	sp,sp,-32
 450:	ec06                	sd	ra,24(sp)
 452:	e822                	sd	s0,16(sp)
 454:	1000                	addi	s0,sp,32
 456:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 45a:	4605                	li	a2,1
 45c:	fef40593          	addi	a1,s0,-17
 460:	00000097          	auipc	ra,0x0
 464:	f3e080e7          	jalr	-194(ra) # 39e <write>
}
 468:	60e2                	ld	ra,24(sp)
 46a:	6442                	ld	s0,16(sp)
 46c:	6105                	addi	sp,sp,32
 46e:	8082                	ret

0000000000000470 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 470:	7139                	addi	sp,sp,-64
 472:	fc06                	sd	ra,56(sp)
 474:	f822                	sd	s0,48(sp)
 476:	f426                	sd	s1,40(sp)
 478:	0080                	addi	s0,sp,64
 47a:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 47c:	c299                	beqz	a3,482 <printint+0x12>
 47e:	0805cb63          	bltz	a1,514 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 482:	2581                	sext.w	a1,a1
  neg = 0;
 484:	4881                	li	a7,0
 486:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 48a:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 48c:	2601                	sext.w	a2,a2
 48e:	00000517          	auipc	a0,0x0
 492:	51a50513          	addi	a0,a0,1306 # 9a8 <digits>
 496:	883a                	mv	a6,a4
 498:	2705                	addiw	a4,a4,1
 49a:	02c5f7bb          	remuw	a5,a1,a2
 49e:	1782                	slli	a5,a5,0x20
 4a0:	9381                	srli	a5,a5,0x20
 4a2:	97aa                	add	a5,a5,a0
 4a4:	0007c783          	lbu	a5,0(a5)
 4a8:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 4ac:	0005879b          	sext.w	a5,a1
 4b0:	02c5d5bb          	divuw	a1,a1,a2
 4b4:	0685                	addi	a3,a3,1
 4b6:	fec7f0e3          	bgeu	a5,a2,496 <printint+0x26>
  if(neg)
 4ba:	00088c63          	beqz	a7,4d2 <printint+0x62>
    buf[i++] = '-';
 4be:	fd070793          	addi	a5,a4,-48
 4c2:	00878733          	add	a4,a5,s0
 4c6:	02d00793          	li	a5,45
 4ca:	fef70823          	sb	a5,-16(a4)
 4ce:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 4d2:	02e05c63          	blez	a4,50a <printint+0x9a>
 4d6:	f04a                	sd	s2,32(sp)
 4d8:	ec4e                	sd	s3,24(sp)
 4da:	fc040793          	addi	a5,s0,-64
 4de:	00e78933          	add	s2,a5,a4
 4e2:	fff78993          	addi	s3,a5,-1
 4e6:	99ba                	add	s3,s3,a4
 4e8:	377d                	addiw	a4,a4,-1
 4ea:	1702                	slli	a4,a4,0x20
 4ec:	9301                	srli	a4,a4,0x20
 4ee:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 4f2:	fff94583          	lbu	a1,-1(s2)
 4f6:	8526                	mv	a0,s1
 4f8:	00000097          	auipc	ra,0x0
 4fc:	f56080e7          	jalr	-170(ra) # 44e <putc>
  while(--i >= 0)
 500:	197d                	addi	s2,s2,-1
 502:	ff3918e3          	bne	s2,s3,4f2 <printint+0x82>
 506:	7902                	ld	s2,32(sp)
 508:	69e2                	ld	s3,24(sp)
}
 50a:	70e2                	ld	ra,56(sp)
 50c:	7442                	ld	s0,48(sp)
 50e:	74a2                	ld	s1,40(sp)
 510:	6121                	addi	sp,sp,64
 512:	8082                	ret
    x = -xx;
 514:	40b005bb          	negw	a1,a1
    neg = 1;
 518:	4885                	li	a7,1
    x = -xx;
 51a:	b7b5                	j	486 <printint+0x16>

000000000000051c <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 51c:	715d                	addi	sp,sp,-80
 51e:	e486                	sd	ra,72(sp)
 520:	e0a2                	sd	s0,64(sp)
 522:	f84a                	sd	s2,48(sp)
 524:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 526:	0005c903          	lbu	s2,0(a1)
 52a:	1a090a63          	beqz	s2,6de <vprintf+0x1c2>
 52e:	fc26                	sd	s1,56(sp)
 530:	f44e                	sd	s3,40(sp)
 532:	f052                	sd	s4,32(sp)
 534:	ec56                	sd	s5,24(sp)
 536:	e85a                	sd	s6,16(sp)
 538:	e45e                	sd	s7,8(sp)
 53a:	8aaa                	mv	s5,a0
 53c:	8bb2                	mv	s7,a2
 53e:	00158493          	addi	s1,a1,1
  state = 0;
 542:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 544:	02500a13          	li	s4,37
 548:	4b55                	li	s6,21
 54a:	a839                	j	568 <vprintf+0x4c>
        putc(fd, c);
 54c:	85ca                	mv	a1,s2
 54e:	8556                	mv	a0,s5
 550:	00000097          	auipc	ra,0x0
 554:	efe080e7          	jalr	-258(ra) # 44e <putc>
 558:	a019                	j	55e <vprintf+0x42>
    } else if(state == '%'){
 55a:	01498d63          	beq	s3,s4,574 <vprintf+0x58>
  for(i = 0; fmt[i]; i++){
 55e:	0485                	addi	s1,s1,1
 560:	fff4c903          	lbu	s2,-1(s1)
 564:	16090763          	beqz	s2,6d2 <vprintf+0x1b6>
    if(state == 0){
 568:	fe0999e3          	bnez	s3,55a <vprintf+0x3e>
      if(c == '%'){
 56c:	ff4910e3          	bne	s2,s4,54c <vprintf+0x30>
        state = '%';
 570:	89d2                	mv	s3,s4
 572:	b7f5                	j	55e <vprintf+0x42>
      if(c == 'd'){
 574:	13490463          	beq	s2,s4,69c <vprintf+0x180>
 578:	f9d9079b          	addiw	a5,s2,-99
 57c:	0ff7f793          	zext.b	a5,a5
 580:	12fb6763          	bltu	s6,a5,6ae <vprintf+0x192>
 584:	f9d9079b          	addiw	a5,s2,-99
 588:	0ff7f713          	zext.b	a4,a5
 58c:	12eb6163          	bltu	s6,a4,6ae <vprintf+0x192>
 590:	00271793          	slli	a5,a4,0x2
 594:	00000717          	auipc	a4,0x0
 598:	3bc70713          	addi	a4,a4,956 # 950 <malloc+0x182>
 59c:	97ba                	add	a5,a5,a4
 59e:	439c                	lw	a5,0(a5)
 5a0:	97ba                	add	a5,a5,a4
 5a2:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 5a4:	008b8913          	addi	s2,s7,8
 5a8:	4685                	li	a3,1
 5aa:	4629                	li	a2,10
 5ac:	000ba583          	lw	a1,0(s7)
 5b0:	8556                	mv	a0,s5
 5b2:	00000097          	auipc	ra,0x0
 5b6:	ebe080e7          	jalr	-322(ra) # 470 <printint>
 5ba:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 5bc:	4981                	li	s3,0
 5be:	b745                	j	55e <vprintf+0x42>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5c0:	008b8913          	addi	s2,s7,8
 5c4:	4681                	li	a3,0
 5c6:	4629                	li	a2,10
 5c8:	000ba583          	lw	a1,0(s7)
 5cc:	8556                	mv	a0,s5
 5ce:	00000097          	auipc	ra,0x0
 5d2:	ea2080e7          	jalr	-350(ra) # 470 <printint>
 5d6:	8bca                	mv	s7,s2
      state = 0;
 5d8:	4981                	li	s3,0
 5da:	b751                	j	55e <vprintf+0x42>
        printint(fd, va_arg(ap, int), 16, 0);
 5dc:	008b8913          	addi	s2,s7,8
 5e0:	4681                	li	a3,0
 5e2:	4641                	li	a2,16
 5e4:	000ba583          	lw	a1,0(s7)
 5e8:	8556                	mv	a0,s5
 5ea:	00000097          	auipc	ra,0x0
 5ee:	e86080e7          	jalr	-378(ra) # 470 <printint>
 5f2:	8bca                	mv	s7,s2
      state = 0;
 5f4:	4981                	li	s3,0
 5f6:	b7a5                	j	55e <vprintf+0x42>
 5f8:	e062                	sd	s8,0(sp)
        printptr(fd, va_arg(ap, uint64));
 5fa:	008b8c13          	addi	s8,s7,8
 5fe:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 602:	03000593          	li	a1,48
 606:	8556                	mv	a0,s5
 608:	00000097          	auipc	ra,0x0
 60c:	e46080e7          	jalr	-442(ra) # 44e <putc>
  putc(fd, 'x');
 610:	07800593          	li	a1,120
 614:	8556                	mv	a0,s5
 616:	00000097          	auipc	ra,0x0
 61a:	e38080e7          	jalr	-456(ra) # 44e <putc>
 61e:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 620:	00000b97          	auipc	s7,0x0
 624:	388b8b93          	addi	s7,s7,904 # 9a8 <digits>
 628:	03c9d793          	srli	a5,s3,0x3c
 62c:	97de                	add	a5,a5,s7
 62e:	0007c583          	lbu	a1,0(a5)
 632:	8556                	mv	a0,s5
 634:	00000097          	auipc	ra,0x0
 638:	e1a080e7          	jalr	-486(ra) # 44e <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 63c:	0992                	slli	s3,s3,0x4
 63e:	397d                	addiw	s2,s2,-1
 640:	fe0914e3          	bnez	s2,628 <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 644:	8be2                	mv	s7,s8
      state = 0;
 646:	4981                	li	s3,0
 648:	6c02                	ld	s8,0(sp)
 64a:	bf11                	j	55e <vprintf+0x42>
        s = va_arg(ap, char*);
 64c:	008b8993          	addi	s3,s7,8
 650:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 654:	02090163          	beqz	s2,676 <vprintf+0x15a>
        while(*s != 0){
 658:	00094583          	lbu	a1,0(s2)
 65c:	c9a5                	beqz	a1,6cc <vprintf+0x1b0>
          putc(fd, *s);
 65e:	8556                	mv	a0,s5
 660:	00000097          	auipc	ra,0x0
 664:	dee080e7          	jalr	-530(ra) # 44e <putc>
          s++;
 668:	0905                	addi	s2,s2,1
        while(*s != 0){
 66a:	00094583          	lbu	a1,0(s2)
 66e:	f9e5                	bnez	a1,65e <vprintf+0x142>
        s = va_arg(ap, char*);
 670:	8bce                	mv	s7,s3
      state = 0;
 672:	4981                	li	s3,0
 674:	b5ed                	j	55e <vprintf+0x42>
          s = "(null)";
 676:	00000917          	auipc	s2,0x0
 67a:	2d290913          	addi	s2,s2,722 # 948 <malloc+0x17a>
        while(*s != 0){
 67e:	02800593          	li	a1,40
 682:	bff1                	j	65e <vprintf+0x142>
        putc(fd, va_arg(ap, uint));
 684:	008b8913          	addi	s2,s7,8
 688:	000bc583          	lbu	a1,0(s7)
 68c:	8556                	mv	a0,s5
 68e:	00000097          	auipc	ra,0x0
 692:	dc0080e7          	jalr	-576(ra) # 44e <putc>
 696:	8bca                	mv	s7,s2
      state = 0;
 698:	4981                	li	s3,0
 69a:	b5d1                	j	55e <vprintf+0x42>
        putc(fd, c);
 69c:	02500593          	li	a1,37
 6a0:	8556                	mv	a0,s5
 6a2:	00000097          	auipc	ra,0x0
 6a6:	dac080e7          	jalr	-596(ra) # 44e <putc>
      state = 0;
 6aa:	4981                	li	s3,0
 6ac:	bd4d                	j	55e <vprintf+0x42>
        putc(fd, '%');
 6ae:	02500593          	li	a1,37
 6b2:	8556                	mv	a0,s5
 6b4:	00000097          	auipc	ra,0x0
 6b8:	d9a080e7          	jalr	-614(ra) # 44e <putc>
        putc(fd, c);
 6bc:	85ca                	mv	a1,s2
 6be:	8556                	mv	a0,s5
 6c0:	00000097          	auipc	ra,0x0
 6c4:	d8e080e7          	jalr	-626(ra) # 44e <putc>
      state = 0;
 6c8:	4981                	li	s3,0
 6ca:	bd51                	j	55e <vprintf+0x42>
        s = va_arg(ap, char*);
 6cc:	8bce                	mv	s7,s3
      state = 0;
 6ce:	4981                	li	s3,0
 6d0:	b579                	j	55e <vprintf+0x42>
 6d2:	74e2                	ld	s1,56(sp)
 6d4:	79a2                	ld	s3,40(sp)
 6d6:	7a02                	ld	s4,32(sp)
 6d8:	6ae2                	ld	s5,24(sp)
 6da:	6b42                	ld	s6,16(sp)
 6dc:	6ba2                	ld	s7,8(sp)
    }
  }
}
 6de:	60a6                	ld	ra,72(sp)
 6e0:	6406                	ld	s0,64(sp)
 6e2:	7942                	ld	s2,48(sp)
 6e4:	6161                	addi	sp,sp,80
 6e6:	8082                	ret

00000000000006e8 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 6e8:	715d                	addi	sp,sp,-80
 6ea:	ec06                	sd	ra,24(sp)
 6ec:	e822                	sd	s0,16(sp)
 6ee:	1000                	addi	s0,sp,32
 6f0:	e010                	sd	a2,0(s0)
 6f2:	e414                	sd	a3,8(s0)
 6f4:	e818                	sd	a4,16(s0)
 6f6:	ec1c                	sd	a5,24(s0)
 6f8:	03043023          	sd	a6,32(s0)
 6fc:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 700:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 704:	8622                	mv	a2,s0
 706:	00000097          	auipc	ra,0x0
 70a:	e16080e7          	jalr	-490(ra) # 51c <vprintf>
}
 70e:	60e2                	ld	ra,24(sp)
 710:	6442                	ld	s0,16(sp)
 712:	6161                	addi	sp,sp,80
 714:	8082                	ret

0000000000000716 <printf>:

void
printf(const char *fmt, ...)
{
 716:	711d                	addi	sp,sp,-96
 718:	ec06                	sd	ra,24(sp)
 71a:	e822                	sd	s0,16(sp)
 71c:	1000                	addi	s0,sp,32
 71e:	e40c                	sd	a1,8(s0)
 720:	e810                	sd	a2,16(s0)
 722:	ec14                	sd	a3,24(s0)
 724:	f018                	sd	a4,32(s0)
 726:	f41c                	sd	a5,40(s0)
 728:	03043823          	sd	a6,48(s0)
 72c:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 730:	00840613          	addi	a2,s0,8
 734:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 738:	85aa                	mv	a1,a0
 73a:	4505                	li	a0,1
 73c:	00000097          	auipc	ra,0x0
 740:	de0080e7          	jalr	-544(ra) # 51c <vprintf>
}
 744:	60e2                	ld	ra,24(sp)
 746:	6442                	ld	s0,16(sp)
 748:	6125                	addi	sp,sp,96
 74a:	8082                	ret

000000000000074c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 74c:	1141                	addi	sp,sp,-16
 74e:	e422                	sd	s0,8(sp)
 750:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 752:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 756:	00001797          	auipc	a5,0x1
 75a:	8ba7b783          	ld	a5,-1862(a5) # 1010 <freep>
 75e:	a02d                	j	788 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 760:	4618                	lw	a4,8(a2)
 762:	9f2d                	addw	a4,a4,a1
 764:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 768:	6398                	ld	a4,0(a5)
 76a:	6310                	ld	a2,0(a4)
 76c:	a83d                	j	7aa <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 76e:	ff852703          	lw	a4,-8(a0)
 772:	9f31                	addw	a4,a4,a2
 774:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 776:	ff053683          	ld	a3,-16(a0)
 77a:	a091                	j	7be <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 77c:	6398                	ld	a4,0(a5)
 77e:	00e7e463          	bltu	a5,a4,786 <free+0x3a>
 782:	00e6ea63          	bltu	a3,a4,796 <free+0x4a>
{
 786:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 788:	fed7fae3          	bgeu	a5,a3,77c <free+0x30>
 78c:	6398                	ld	a4,0(a5)
 78e:	00e6e463          	bltu	a3,a4,796 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 792:	fee7eae3          	bltu	a5,a4,786 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 796:	ff852583          	lw	a1,-8(a0)
 79a:	6390                	ld	a2,0(a5)
 79c:	02059813          	slli	a6,a1,0x20
 7a0:	01c85713          	srli	a4,a6,0x1c
 7a4:	9736                	add	a4,a4,a3
 7a6:	fae60de3          	beq	a2,a4,760 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 7aa:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 7ae:	4790                	lw	a2,8(a5)
 7b0:	02061593          	slli	a1,a2,0x20
 7b4:	01c5d713          	srli	a4,a1,0x1c
 7b8:	973e                	add	a4,a4,a5
 7ba:	fae68ae3          	beq	a3,a4,76e <free+0x22>
    p->s.ptr = bp->s.ptr;
 7be:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 7c0:	00001717          	auipc	a4,0x1
 7c4:	84f73823          	sd	a5,-1968(a4) # 1010 <freep>
}
 7c8:	6422                	ld	s0,8(sp)
 7ca:	0141                	addi	sp,sp,16
 7cc:	8082                	ret

00000000000007ce <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 7ce:	7139                	addi	sp,sp,-64
 7d0:	fc06                	sd	ra,56(sp)
 7d2:	f822                	sd	s0,48(sp)
 7d4:	f426                	sd	s1,40(sp)
 7d6:	ec4e                	sd	s3,24(sp)
 7d8:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7da:	02051493          	slli	s1,a0,0x20
 7de:	9081                	srli	s1,s1,0x20
 7e0:	04bd                	addi	s1,s1,15
 7e2:	8091                	srli	s1,s1,0x4
 7e4:	0014899b          	addiw	s3,s1,1
 7e8:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 7ea:	00001517          	auipc	a0,0x1
 7ee:	82653503          	ld	a0,-2010(a0) # 1010 <freep>
 7f2:	c915                	beqz	a0,826 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7f4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7f6:	4798                	lw	a4,8(a5)
 7f8:	08977e63          	bgeu	a4,s1,894 <malloc+0xc6>
 7fc:	f04a                	sd	s2,32(sp)
 7fe:	e852                	sd	s4,16(sp)
 800:	e456                	sd	s5,8(sp)
 802:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 804:	8a4e                	mv	s4,s3
 806:	0009871b          	sext.w	a4,s3
 80a:	6685                	lui	a3,0x1
 80c:	00d77363          	bgeu	a4,a3,812 <malloc+0x44>
 810:	6a05                	lui	s4,0x1
 812:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 816:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 81a:	00000917          	auipc	s2,0x0
 81e:	7f690913          	addi	s2,s2,2038 # 1010 <freep>
  if(p == (char*)-1)
 822:	5afd                	li	s5,-1
 824:	a091                	j	868 <malloc+0x9a>
 826:	f04a                	sd	s2,32(sp)
 828:	e852                	sd	s4,16(sp)
 82a:	e456                	sd	s5,8(sp)
 82c:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 82e:	00000797          	auipc	a5,0x0
 832:	7f278793          	addi	a5,a5,2034 # 1020 <base>
 836:	00000717          	auipc	a4,0x0
 83a:	7cf73d23          	sd	a5,2010(a4) # 1010 <freep>
 83e:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 840:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 844:	b7c1                	j	804 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 846:	6398                	ld	a4,0(a5)
 848:	e118                	sd	a4,0(a0)
 84a:	a08d                	j	8ac <malloc+0xde>
  hp->s.size = nu;
 84c:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 850:	0541                	addi	a0,a0,16
 852:	00000097          	auipc	ra,0x0
 856:	efa080e7          	jalr	-262(ra) # 74c <free>
  return freep;
 85a:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 85e:	c13d                	beqz	a0,8c4 <malloc+0xf6>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 860:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 862:	4798                	lw	a4,8(a5)
 864:	02977463          	bgeu	a4,s1,88c <malloc+0xbe>
    if(p == freep)
 868:	00093703          	ld	a4,0(s2)
 86c:	853e                	mv	a0,a5
 86e:	fef719e3          	bne	a4,a5,860 <malloc+0x92>
  p = sbrk(nu * sizeof(Header));
 872:	8552                	mv	a0,s4
 874:	00000097          	auipc	ra,0x0
 878:	b92080e7          	jalr	-1134(ra) # 406 <sbrk>
  if(p == (char*)-1)
 87c:	fd5518e3          	bne	a0,s5,84c <malloc+0x7e>
        return 0;
 880:	4501                	li	a0,0
 882:	7902                	ld	s2,32(sp)
 884:	6a42                	ld	s4,16(sp)
 886:	6aa2                	ld	s5,8(sp)
 888:	6b02                	ld	s6,0(sp)
 88a:	a03d                	j	8b8 <malloc+0xea>
 88c:	7902                	ld	s2,32(sp)
 88e:	6a42                	ld	s4,16(sp)
 890:	6aa2                	ld	s5,8(sp)
 892:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 894:	fae489e3          	beq	s1,a4,846 <malloc+0x78>
        p->s.size -= nunits;
 898:	4137073b          	subw	a4,a4,s3
 89c:	c798                	sw	a4,8(a5)
        p += p->s.size;
 89e:	02071693          	slli	a3,a4,0x20
 8a2:	01c6d713          	srli	a4,a3,0x1c
 8a6:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8a8:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8ac:	00000717          	auipc	a4,0x0
 8b0:	76a73223          	sd	a0,1892(a4) # 1010 <freep>
      return (void*)(p + 1);
 8b4:	01078513          	addi	a0,a5,16
  }
}
 8b8:	70e2                	ld	ra,56(sp)
 8ba:	7442                	ld	s0,48(sp)
 8bc:	74a2                	ld	s1,40(sp)
 8be:	69e2                	ld	s3,24(sp)
 8c0:	6121                	addi	sp,sp,64
 8c2:	8082                	ret
 8c4:	7902                	ld	s2,32(sp)
 8c6:	6a42                	ld	s4,16(sp)
 8c8:	6aa2                	ld	s5,8(sp)
 8ca:	6b02                	ld	s6,0(sp)
 8cc:	b7f5                	j	8b8 <malloc+0xea>
