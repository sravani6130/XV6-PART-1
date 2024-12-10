
user/_grind:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <do_rand>:
#include "kernel/riscv.h"

// from FreeBSD.
int
do_rand(unsigned long *ctx)
{
       0:	1141                	addi	sp,sp,-16
       2:	e422                	sd	s0,8(sp)
       4:	0800                	addi	s0,sp,16
 * October 1988, p. 1195.
 */
    long hi, lo, x;

    /* Transform to [1, 0x7ffffffe] range. */
    x = (*ctx % 0x7ffffffe) + 1;
       6:	611c                	ld	a5,0(a0)
       8:	80000737          	lui	a4,0x80000
       c:	ffe74713          	xori	a4,a4,-2
      10:	02e7f7b3          	remu	a5,a5,a4
      14:	0785                	addi	a5,a5,1
    hi = x / 127773;
    lo = x % 127773;
      16:	66fd                	lui	a3,0x1f
      18:	31d68693          	addi	a3,a3,797 # 1f31d <base+0x1cf15>
      1c:	02d7e733          	rem	a4,a5,a3
    x = 16807 * lo - 2836 * hi;
      20:	6611                	lui	a2,0x4
      22:	1a760613          	addi	a2,a2,423 # 41a7 <base+0x1d9f>
      26:	02c70733          	mul	a4,a4,a2
    hi = x / 127773;
      2a:	02d7c7b3          	div	a5,a5,a3
    x = 16807 * lo - 2836 * hi;
      2e:	76fd                	lui	a3,0xfffff
      30:	4ec68693          	addi	a3,a3,1260 # fffffffffffff4ec <base+0xffffffffffffd0e4>
      34:	02d787b3          	mul	a5,a5,a3
      38:	97ba                	add	a5,a5,a4
    if (x < 0)
      3a:	0007c963          	bltz	a5,4c <do_rand+0x4c>
        x += 0x7fffffff;
    /* Transform to [0, 0x7ffffffd] range. */
    x--;
      3e:	17fd                	addi	a5,a5,-1
    *ctx = x;
      40:	e11c                	sd	a5,0(a0)
    return (x);
}
      42:	0007851b          	sext.w	a0,a5
      46:	6422                	ld	s0,8(sp)
      48:	0141                	addi	sp,sp,16
      4a:	8082                	ret
        x += 0x7fffffff;
      4c:	80000737          	lui	a4,0x80000
      50:	fff74713          	not	a4,a4
      54:	97ba                	add	a5,a5,a4
      56:	b7e5                	j	3e <do_rand+0x3e>

0000000000000058 <rand>:

unsigned long rand_next = 1;

int
rand(void)
{
      58:	1141                	addi	sp,sp,-16
      5a:	e406                	sd	ra,8(sp)
      5c:	e022                	sd	s0,0(sp)
      5e:	0800                	addi	s0,sp,16
    return (do_rand(&rand_next));
      60:	00002517          	auipc	a0,0x2
      64:	fa050513          	addi	a0,a0,-96 # 2000 <rand_next>
      68:	00000097          	auipc	ra,0x0
      6c:	f98080e7          	jalr	-104(ra) # 0 <do_rand>
}
      70:	60a2                	ld	ra,8(sp)
      72:	6402                	ld	s0,0(sp)
      74:	0141                	addi	sp,sp,16
      76:	8082                	ret

0000000000000078 <go>:

void
go(int which_child)
{
      78:	7159                	addi	sp,sp,-112
      7a:	f486                	sd	ra,104(sp)
      7c:	f0a2                	sd	s0,96(sp)
      7e:	eca6                	sd	s1,88(sp)
      80:	fc56                	sd	s5,56(sp)
      82:	1880                	addi	s0,sp,112
      84:	84aa                	mv	s1,a0
  int fd = -1;
  static char buf[999];
  char *break0 = sbrk(0);
      86:	4501                	li	a0,0
      88:	00001097          	auipc	ra,0x1
      8c:	e40080e7          	jalr	-448(ra) # ec8 <sbrk>
      90:	8aaa                	mv	s5,a0
  uint64 iters = 0;

  mkdir("grindir");
      92:	00001517          	auipc	a0,0x1
      96:	2fe50513          	addi	a0,a0,766 # 1390 <malloc+0x100>
      9a:	00001097          	auipc	ra,0x1
      9e:	e0e080e7          	jalr	-498(ra) # ea8 <mkdir>
  if(chdir("grindir") != 0){
      a2:	00001517          	auipc	a0,0x1
      a6:	2ee50513          	addi	a0,a0,750 # 1390 <malloc+0x100>
      aa:	00001097          	auipc	ra,0x1
      ae:	e06080e7          	jalr	-506(ra) # eb0 <chdir>
      b2:	c115                	beqz	a0,d6 <go+0x5e>
      b4:	e8ca                	sd	s2,80(sp)
      b6:	e4ce                	sd	s3,72(sp)
      b8:	e0d2                	sd	s4,64(sp)
      ba:	f85a                	sd	s6,48(sp)
    printf("grind: chdir grindir failed\n");
      bc:	00001517          	auipc	a0,0x1
      c0:	2dc50513          	addi	a0,a0,732 # 1398 <malloc+0x108>
      c4:	00001097          	auipc	ra,0x1
      c8:	114080e7          	jalr	276(ra) # 11d8 <printf>
    exit(1);
      cc:	4505                	li	a0,1
      ce:	00001097          	auipc	ra,0x1
      d2:	d72080e7          	jalr	-654(ra) # e40 <exit>
      d6:	e8ca                	sd	s2,80(sp)
      d8:	e4ce                	sd	s3,72(sp)
      da:	e0d2                	sd	s4,64(sp)
      dc:	f85a                	sd	s6,48(sp)
  }
  chdir("/");
      de:	00001517          	auipc	a0,0x1
      e2:	2e250513          	addi	a0,a0,738 # 13c0 <malloc+0x130>
      e6:	00001097          	auipc	ra,0x1
      ea:	dca080e7          	jalr	-566(ra) # eb0 <chdir>
      ee:	00001997          	auipc	s3,0x1
      f2:	2e298993          	addi	s3,s3,738 # 13d0 <malloc+0x140>
      f6:	c489                	beqz	s1,100 <go+0x88>
      f8:	00001997          	auipc	s3,0x1
      fc:	2d098993          	addi	s3,s3,720 # 13c8 <malloc+0x138>
  uint64 iters = 0;
     100:	4481                	li	s1,0
  int fd = -1;
     102:	5a7d                	li	s4,-1
     104:	00001917          	auipc	s2,0x1
     108:	59c90913          	addi	s2,s2,1436 # 16a0 <malloc+0x410>
     10c:	a839                	j	12a <go+0xb2>
    iters++;
    if((iters % 500) == 0)
      write(1, which_child?"B":"A", 1);
    int what = rand() % 23;
    if(what == 1){
      close(open("grindir/../a", O_CREATE|O_RDWR));
     10e:	20200593          	li	a1,514
     112:	00001517          	auipc	a0,0x1
     116:	2c650513          	addi	a0,a0,710 # 13d8 <malloc+0x148>
     11a:	00001097          	auipc	ra,0x1
     11e:	d66080e7          	jalr	-666(ra) # e80 <open>
     122:	00001097          	auipc	ra,0x1
     126:	d46080e7          	jalr	-698(ra) # e68 <close>
    iters++;
     12a:	0485                	addi	s1,s1,1
    if((iters % 500) == 0)
     12c:	1f400793          	li	a5,500
     130:	02f4f7b3          	remu	a5,s1,a5
     134:	eb81                	bnez	a5,144 <go+0xcc>
      write(1, which_child?"B":"A", 1);
     136:	4605                	li	a2,1
     138:	85ce                	mv	a1,s3
     13a:	4505                	li	a0,1
     13c:	00001097          	auipc	ra,0x1
     140:	d24080e7          	jalr	-732(ra) # e60 <write>
    int what = rand() % 23;
     144:	00000097          	auipc	ra,0x0
     148:	f14080e7          	jalr	-236(ra) # 58 <rand>
     14c:	47dd                	li	a5,23
     14e:	02f5653b          	remw	a0,a0,a5
     152:	0005071b          	sext.w	a4,a0
     156:	47d9                	li	a5,22
     158:	fce7e9e3          	bltu	a5,a4,12a <go+0xb2>
     15c:	02051793          	slli	a5,a0,0x20
     160:	01e7d513          	srli	a0,a5,0x1e
     164:	954a                	add	a0,a0,s2
     166:	411c                	lw	a5,0(a0)
     168:	97ca                	add	a5,a5,s2
     16a:	8782                	jr	a5
    } else if(what == 2){
      close(open("grindir/../grindir/../b", O_CREATE|O_RDWR));
     16c:	20200593          	li	a1,514
     170:	00001517          	auipc	a0,0x1
     174:	27850513          	addi	a0,a0,632 # 13e8 <malloc+0x158>
     178:	00001097          	auipc	ra,0x1
     17c:	d08080e7          	jalr	-760(ra) # e80 <open>
     180:	00001097          	auipc	ra,0x1
     184:	ce8080e7          	jalr	-792(ra) # e68 <close>
     188:	b74d                	j	12a <go+0xb2>
    } else if(what == 3){
      unlink("grindir/../a");
     18a:	00001517          	auipc	a0,0x1
     18e:	24e50513          	addi	a0,a0,590 # 13d8 <malloc+0x148>
     192:	00001097          	auipc	ra,0x1
     196:	cfe080e7          	jalr	-770(ra) # e90 <unlink>
     19a:	bf41                	j	12a <go+0xb2>
    } else if(what == 4){
      if(chdir("grindir") != 0){
     19c:	00001517          	auipc	a0,0x1
     1a0:	1f450513          	addi	a0,a0,500 # 1390 <malloc+0x100>
     1a4:	00001097          	auipc	ra,0x1
     1a8:	d0c080e7          	jalr	-756(ra) # eb0 <chdir>
     1ac:	e115                	bnez	a0,1d0 <go+0x158>
        printf("grind: chdir grindir failed\n");
        exit(1);
      }
      unlink("../b");
     1ae:	00001517          	auipc	a0,0x1
     1b2:	25250513          	addi	a0,a0,594 # 1400 <malloc+0x170>
     1b6:	00001097          	auipc	ra,0x1
     1ba:	cda080e7          	jalr	-806(ra) # e90 <unlink>
      chdir("/");
     1be:	00001517          	auipc	a0,0x1
     1c2:	20250513          	addi	a0,a0,514 # 13c0 <malloc+0x130>
     1c6:	00001097          	auipc	ra,0x1
     1ca:	cea080e7          	jalr	-790(ra) # eb0 <chdir>
     1ce:	bfb1                	j	12a <go+0xb2>
        printf("grind: chdir grindir failed\n");
     1d0:	00001517          	auipc	a0,0x1
     1d4:	1c850513          	addi	a0,a0,456 # 1398 <malloc+0x108>
     1d8:	00001097          	auipc	ra,0x1
     1dc:	000080e7          	jalr	ra # 11d8 <printf>
        exit(1);
     1e0:	4505                	li	a0,1
     1e2:	00001097          	auipc	ra,0x1
     1e6:	c5e080e7          	jalr	-930(ra) # e40 <exit>
    } else if(what == 5){
      close(fd);
     1ea:	8552                	mv	a0,s4
     1ec:	00001097          	auipc	ra,0x1
     1f0:	c7c080e7          	jalr	-900(ra) # e68 <close>
      fd = open("/grindir/../a", O_CREATE|O_RDWR);
     1f4:	20200593          	li	a1,514
     1f8:	00001517          	auipc	a0,0x1
     1fc:	21050513          	addi	a0,a0,528 # 1408 <malloc+0x178>
     200:	00001097          	auipc	ra,0x1
     204:	c80080e7          	jalr	-896(ra) # e80 <open>
     208:	8a2a                	mv	s4,a0
     20a:	b705                	j	12a <go+0xb2>
    } else if(what == 6){
      close(fd);
     20c:	8552                	mv	a0,s4
     20e:	00001097          	auipc	ra,0x1
     212:	c5a080e7          	jalr	-934(ra) # e68 <close>
      fd = open("/./grindir/./../b", O_CREATE|O_RDWR);
     216:	20200593          	li	a1,514
     21a:	00001517          	auipc	a0,0x1
     21e:	1fe50513          	addi	a0,a0,510 # 1418 <malloc+0x188>
     222:	00001097          	auipc	ra,0x1
     226:	c5e080e7          	jalr	-930(ra) # e80 <open>
     22a:	8a2a                	mv	s4,a0
     22c:	bdfd                	j	12a <go+0xb2>
    } else if(what == 7){
      write(fd, buf, sizeof(buf));
     22e:	3e700613          	li	a2,999
     232:	00002597          	auipc	a1,0x2
     236:	dee58593          	addi	a1,a1,-530 # 2020 <buf.0>
     23a:	8552                	mv	a0,s4
     23c:	00001097          	auipc	ra,0x1
     240:	c24080e7          	jalr	-988(ra) # e60 <write>
     244:	b5dd                	j	12a <go+0xb2>
    } else if(what == 8){
      read(fd, buf, sizeof(buf));
     246:	3e700613          	li	a2,999
     24a:	00002597          	auipc	a1,0x2
     24e:	dd658593          	addi	a1,a1,-554 # 2020 <buf.0>
     252:	8552                	mv	a0,s4
     254:	00001097          	auipc	ra,0x1
     258:	c04080e7          	jalr	-1020(ra) # e58 <read>
     25c:	b5f9                	j	12a <go+0xb2>
    } else if(what == 9){
      mkdir("grindir/../a");
     25e:	00001517          	auipc	a0,0x1
     262:	17a50513          	addi	a0,a0,378 # 13d8 <malloc+0x148>
     266:	00001097          	auipc	ra,0x1
     26a:	c42080e7          	jalr	-958(ra) # ea8 <mkdir>
      close(open("a/../a/./a", O_CREATE|O_RDWR));
     26e:	20200593          	li	a1,514
     272:	00001517          	auipc	a0,0x1
     276:	1be50513          	addi	a0,a0,446 # 1430 <malloc+0x1a0>
     27a:	00001097          	auipc	ra,0x1
     27e:	c06080e7          	jalr	-1018(ra) # e80 <open>
     282:	00001097          	auipc	ra,0x1
     286:	be6080e7          	jalr	-1050(ra) # e68 <close>
      unlink("a/a");
     28a:	00001517          	auipc	a0,0x1
     28e:	1b650513          	addi	a0,a0,438 # 1440 <malloc+0x1b0>
     292:	00001097          	auipc	ra,0x1
     296:	bfe080e7          	jalr	-1026(ra) # e90 <unlink>
     29a:	bd41                	j	12a <go+0xb2>
    } else if(what == 10){
      mkdir("/../b");
     29c:	00001517          	auipc	a0,0x1
     2a0:	1ac50513          	addi	a0,a0,428 # 1448 <malloc+0x1b8>
     2a4:	00001097          	auipc	ra,0x1
     2a8:	c04080e7          	jalr	-1020(ra) # ea8 <mkdir>
      close(open("grindir/../b/b", O_CREATE|O_RDWR));
     2ac:	20200593          	li	a1,514
     2b0:	00001517          	auipc	a0,0x1
     2b4:	1a050513          	addi	a0,a0,416 # 1450 <malloc+0x1c0>
     2b8:	00001097          	auipc	ra,0x1
     2bc:	bc8080e7          	jalr	-1080(ra) # e80 <open>
     2c0:	00001097          	auipc	ra,0x1
     2c4:	ba8080e7          	jalr	-1112(ra) # e68 <close>
      unlink("b/b");
     2c8:	00001517          	auipc	a0,0x1
     2cc:	19850513          	addi	a0,a0,408 # 1460 <malloc+0x1d0>
     2d0:	00001097          	auipc	ra,0x1
     2d4:	bc0080e7          	jalr	-1088(ra) # e90 <unlink>
     2d8:	bd89                	j	12a <go+0xb2>
    } else if(what == 11){
      unlink("b");
     2da:	00001517          	auipc	a0,0x1
     2de:	18e50513          	addi	a0,a0,398 # 1468 <malloc+0x1d8>
     2e2:	00001097          	auipc	ra,0x1
     2e6:	bae080e7          	jalr	-1106(ra) # e90 <unlink>
      link("../grindir/./../a", "../b");
     2ea:	00001597          	auipc	a1,0x1
     2ee:	11658593          	addi	a1,a1,278 # 1400 <malloc+0x170>
     2f2:	00001517          	auipc	a0,0x1
     2f6:	17e50513          	addi	a0,a0,382 # 1470 <malloc+0x1e0>
     2fa:	00001097          	auipc	ra,0x1
     2fe:	ba6080e7          	jalr	-1114(ra) # ea0 <link>
     302:	b525                	j	12a <go+0xb2>
    } else if(what == 12){
      unlink("../grindir/../a");
     304:	00001517          	auipc	a0,0x1
     308:	18450513          	addi	a0,a0,388 # 1488 <malloc+0x1f8>
     30c:	00001097          	auipc	ra,0x1
     310:	b84080e7          	jalr	-1148(ra) # e90 <unlink>
      link(".././b", "/grindir/../a");
     314:	00001597          	auipc	a1,0x1
     318:	0f458593          	addi	a1,a1,244 # 1408 <malloc+0x178>
     31c:	00001517          	auipc	a0,0x1
     320:	17c50513          	addi	a0,a0,380 # 1498 <malloc+0x208>
     324:	00001097          	auipc	ra,0x1
     328:	b7c080e7          	jalr	-1156(ra) # ea0 <link>
     32c:	bbfd                	j	12a <go+0xb2>
    } else if(what == 13){
      int pid = fork();
     32e:	00001097          	auipc	ra,0x1
     332:	b0a080e7          	jalr	-1270(ra) # e38 <fork>
      if(pid == 0){
     336:	c909                	beqz	a0,348 <go+0x2d0>
        exit(0);
      } else if(pid < 0){
     338:	00054c63          	bltz	a0,350 <go+0x2d8>
        printf("grind: fork failed\n");
        exit(1);
      }
      wait(0);
     33c:	4501                	li	a0,0
     33e:	00001097          	auipc	ra,0x1
     342:	b0a080e7          	jalr	-1270(ra) # e48 <wait>
     346:	b3d5                	j	12a <go+0xb2>
        exit(0);
     348:	00001097          	auipc	ra,0x1
     34c:	af8080e7          	jalr	-1288(ra) # e40 <exit>
        printf("grind: fork failed\n");
     350:	00001517          	auipc	a0,0x1
     354:	15050513          	addi	a0,a0,336 # 14a0 <malloc+0x210>
     358:	00001097          	auipc	ra,0x1
     35c:	e80080e7          	jalr	-384(ra) # 11d8 <printf>
        exit(1);
     360:	4505                	li	a0,1
     362:	00001097          	auipc	ra,0x1
     366:	ade080e7          	jalr	-1314(ra) # e40 <exit>
    } else if(what == 14){
      int pid = fork();
     36a:	00001097          	auipc	ra,0x1
     36e:	ace080e7          	jalr	-1330(ra) # e38 <fork>
      if(pid == 0){
     372:	c909                	beqz	a0,384 <go+0x30c>
        fork();
        fork();
        exit(0);
      } else if(pid < 0){
     374:	02054563          	bltz	a0,39e <go+0x326>
        printf("grind: fork failed\n");
        exit(1);
      }
      wait(0);
     378:	4501                	li	a0,0
     37a:	00001097          	auipc	ra,0x1
     37e:	ace080e7          	jalr	-1330(ra) # e48 <wait>
     382:	b365                	j	12a <go+0xb2>
        fork();
     384:	00001097          	auipc	ra,0x1
     388:	ab4080e7          	jalr	-1356(ra) # e38 <fork>
        fork();
     38c:	00001097          	auipc	ra,0x1
     390:	aac080e7          	jalr	-1364(ra) # e38 <fork>
        exit(0);
     394:	4501                	li	a0,0
     396:	00001097          	auipc	ra,0x1
     39a:	aaa080e7          	jalr	-1366(ra) # e40 <exit>
        printf("grind: fork failed\n");
     39e:	00001517          	auipc	a0,0x1
     3a2:	10250513          	addi	a0,a0,258 # 14a0 <malloc+0x210>
     3a6:	00001097          	auipc	ra,0x1
     3aa:	e32080e7          	jalr	-462(ra) # 11d8 <printf>
        exit(1);
     3ae:	4505                	li	a0,1
     3b0:	00001097          	auipc	ra,0x1
     3b4:	a90080e7          	jalr	-1392(ra) # e40 <exit>
    } else if(what == 15){
      sbrk(6011);
     3b8:	6505                	lui	a0,0x1
     3ba:	77b50513          	addi	a0,a0,1915 # 177b <digits+0x23>
     3be:	00001097          	auipc	ra,0x1
     3c2:	b0a080e7          	jalr	-1270(ra) # ec8 <sbrk>
     3c6:	b395                	j	12a <go+0xb2>
    } else if(what == 16){
      if(sbrk(0) > break0)
     3c8:	4501                	li	a0,0
     3ca:	00001097          	auipc	ra,0x1
     3ce:	afe080e7          	jalr	-1282(ra) # ec8 <sbrk>
     3d2:	d4aafce3          	bgeu	s5,a0,12a <go+0xb2>
        sbrk(-(sbrk(0) - break0));
     3d6:	4501                	li	a0,0
     3d8:	00001097          	auipc	ra,0x1
     3dc:	af0080e7          	jalr	-1296(ra) # ec8 <sbrk>
     3e0:	40aa853b          	subw	a0,s5,a0
     3e4:	00001097          	auipc	ra,0x1
     3e8:	ae4080e7          	jalr	-1308(ra) # ec8 <sbrk>
     3ec:	bb3d                	j	12a <go+0xb2>
    } else if(what == 17){
      int pid = fork();
     3ee:	00001097          	auipc	ra,0x1
     3f2:	a4a080e7          	jalr	-1462(ra) # e38 <fork>
     3f6:	8b2a                	mv	s6,a0
      if(pid == 0){
     3f8:	c51d                	beqz	a0,426 <go+0x3ae>
        close(open("a", O_CREATE|O_RDWR));
        exit(0);
      } else if(pid < 0){
     3fa:	04054963          	bltz	a0,44c <go+0x3d4>
        printf("grind: fork failed\n");
        exit(1);
      }
      if(chdir("../grindir/..") != 0){
     3fe:	00001517          	auipc	a0,0x1
     402:	0c250513          	addi	a0,a0,194 # 14c0 <malloc+0x230>
     406:	00001097          	auipc	ra,0x1
     40a:	aaa080e7          	jalr	-1366(ra) # eb0 <chdir>
     40e:	ed21                	bnez	a0,466 <go+0x3ee>
        printf("grind: chdir failed\n");
        exit(1);
      }
      kill(pid);
     410:	855a                	mv	a0,s6
     412:	00001097          	auipc	ra,0x1
     416:	a5e080e7          	jalr	-1442(ra) # e70 <kill>
      wait(0);
     41a:	4501                	li	a0,0
     41c:	00001097          	auipc	ra,0x1
     420:	a2c080e7          	jalr	-1492(ra) # e48 <wait>
     424:	b319                	j	12a <go+0xb2>
        close(open("a", O_CREATE|O_RDWR));
     426:	20200593          	li	a1,514
     42a:	00001517          	auipc	a0,0x1
     42e:	08e50513          	addi	a0,a0,142 # 14b8 <malloc+0x228>
     432:	00001097          	auipc	ra,0x1
     436:	a4e080e7          	jalr	-1458(ra) # e80 <open>
     43a:	00001097          	auipc	ra,0x1
     43e:	a2e080e7          	jalr	-1490(ra) # e68 <close>
        exit(0);
     442:	4501                	li	a0,0
     444:	00001097          	auipc	ra,0x1
     448:	9fc080e7          	jalr	-1540(ra) # e40 <exit>
        printf("grind: fork failed\n");
     44c:	00001517          	auipc	a0,0x1
     450:	05450513          	addi	a0,a0,84 # 14a0 <malloc+0x210>
     454:	00001097          	auipc	ra,0x1
     458:	d84080e7          	jalr	-636(ra) # 11d8 <printf>
        exit(1);
     45c:	4505                	li	a0,1
     45e:	00001097          	auipc	ra,0x1
     462:	9e2080e7          	jalr	-1566(ra) # e40 <exit>
        printf("grind: chdir failed\n");
     466:	00001517          	auipc	a0,0x1
     46a:	06a50513          	addi	a0,a0,106 # 14d0 <malloc+0x240>
     46e:	00001097          	auipc	ra,0x1
     472:	d6a080e7          	jalr	-662(ra) # 11d8 <printf>
        exit(1);
     476:	4505                	li	a0,1
     478:	00001097          	auipc	ra,0x1
     47c:	9c8080e7          	jalr	-1592(ra) # e40 <exit>
    } else if(what == 18){
      int pid = fork();
     480:	00001097          	auipc	ra,0x1
     484:	9b8080e7          	jalr	-1608(ra) # e38 <fork>
      if(pid == 0){
     488:	c909                	beqz	a0,49a <go+0x422>
        kill(getpid());
        exit(0);
      } else if(pid < 0){
     48a:	02054563          	bltz	a0,4b4 <go+0x43c>
        printf("grind: fork failed\n");
        exit(1);
      }
      wait(0);
     48e:	4501                	li	a0,0
     490:	00001097          	auipc	ra,0x1
     494:	9b8080e7          	jalr	-1608(ra) # e48 <wait>
     498:	b949                	j	12a <go+0xb2>
        kill(getpid());
     49a:	00001097          	auipc	ra,0x1
     49e:	a26080e7          	jalr	-1498(ra) # ec0 <getpid>
     4a2:	00001097          	auipc	ra,0x1
     4a6:	9ce080e7          	jalr	-1586(ra) # e70 <kill>
        exit(0);
     4aa:	4501                	li	a0,0
     4ac:	00001097          	auipc	ra,0x1
     4b0:	994080e7          	jalr	-1644(ra) # e40 <exit>
        printf("grind: fork failed\n");
     4b4:	00001517          	auipc	a0,0x1
     4b8:	fec50513          	addi	a0,a0,-20 # 14a0 <malloc+0x210>
     4bc:	00001097          	auipc	ra,0x1
     4c0:	d1c080e7          	jalr	-740(ra) # 11d8 <printf>
        exit(1);
     4c4:	4505                	li	a0,1
     4c6:	00001097          	auipc	ra,0x1
     4ca:	97a080e7          	jalr	-1670(ra) # e40 <exit>
    } else if(what == 19){
      int fds[2];
      if(pipe(fds) < 0){
     4ce:	fa840513          	addi	a0,s0,-88
     4d2:	00001097          	auipc	ra,0x1
     4d6:	97e080e7          	jalr	-1666(ra) # e50 <pipe>
     4da:	02054b63          	bltz	a0,510 <go+0x498>
        printf("grind: pipe failed\n");
        exit(1);
      }
      int pid = fork();
     4de:	00001097          	auipc	ra,0x1
     4e2:	95a080e7          	jalr	-1702(ra) # e38 <fork>
      if(pid == 0){
     4e6:	c131                	beqz	a0,52a <go+0x4b2>
          printf("grind: pipe write failed\n");
        char c;
        if(read(fds[0], &c, 1) != 1)
          printf("grind: pipe read failed\n");
        exit(0);
      } else if(pid < 0){
     4e8:	0a054a63          	bltz	a0,59c <go+0x524>
        printf("grind: fork failed\n");
        exit(1);
      }
      close(fds[0]);
     4ec:	fa842503          	lw	a0,-88(s0)
     4f0:	00001097          	auipc	ra,0x1
     4f4:	978080e7          	jalr	-1672(ra) # e68 <close>
      close(fds[1]);
     4f8:	fac42503          	lw	a0,-84(s0)
     4fc:	00001097          	auipc	ra,0x1
     500:	96c080e7          	jalr	-1684(ra) # e68 <close>
      wait(0);
     504:	4501                	li	a0,0
     506:	00001097          	auipc	ra,0x1
     50a:	942080e7          	jalr	-1726(ra) # e48 <wait>
     50e:	b931                	j	12a <go+0xb2>
        printf("grind: pipe failed\n");
     510:	00001517          	auipc	a0,0x1
     514:	fd850513          	addi	a0,a0,-40 # 14e8 <malloc+0x258>
     518:	00001097          	auipc	ra,0x1
     51c:	cc0080e7          	jalr	-832(ra) # 11d8 <printf>
        exit(1);
     520:	4505                	li	a0,1
     522:	00001097          	auipc	ra,0x1
     526:	91e080e7          	jalr	-1762(ra) # e40 <exit>
        fork();
     52a:	00001097          	auipc	ra,0x1
     52e:	90e080e7          	jalr	-1778(ra) # e38 <fork>
        fork();
     532:	00001097          	auipc	ra,0x1
     536:	906080e7          	jalr	-1786(ra) # e38 <fork>
        if(write(fds[1], "x", 1) != 1)
     53a:	4605                	li	a2,1
     53c:	00001597          	auipc	a1,0x1
     540:	fc458593          	addi	a1,a1,-60 # 1500 <malloc+0x270>
     544:	fac42503          	lw	a0,-84(s0)
     548:	00001097          	auipc	ra,0x1
     54c:	918080e7          	jalr	-1768(ra) # e60 <write>
     550:	4785                	li	a5,1
     552:	02f51363          	bne	a0,a5,578 <go+0x500>
        if(read(fds[0], &c, 1) != 1)
     556:	4605                	li	a2,1
     558:	fa040593          	addi	a1,s0,-96
     55c:	fa842503          	lw	a0,-88(s0)
     560:	00001097          	auipc	ra,0x1
     564:	8f8080e7          	jalr	-1800(ra) # e58 <read>
     568:	4785                	li	a5,1
     56a:	02f51063          	bne	a0,a5,58a <go+0x512>
        exit(0);
     56e:	4501                	li	a0,0
     570:	00001097          	auipc	ra,0x1
     574:	8d0080e7          	jalr	-1840(ra) # e40 <exit>
          printf("grind: pipe write failed\n");
     578:	00001517          	auipc	a0,0x1
     57c:	f9050513          	addi	a0,a0,-112 # 1508 <malloc+0x278>
     580:	00001097          	auipc	ra,0x1
     584:	c58080e7          	jalr	-936(ra) # 11d8 <printf>
     588:	b7f9                	j	556 <go+0x4de>
          printf("grind: pipe read failed\n");
     58a:	00001517          	auipc	a0,0x1
     58e:	f9e50513          	addi	a0,a0,-98 # 1528 <malloc+0x298>
     592:	00001097          	auipc	ra,0x1
     596:	c46080e7          	jalr	-954(ra) # 11d8 <printf>
     59a:	bfd1                	j	56e <go+0x4f6>
        printf("grind: fork failed\n");
     59c:	00001517          	auipc	a0,0x1
     5a0:	f0450513          	addi	a0,a0,-252 # 14a0 <malloc+0x210>
     5a4:	00001097          	auipc	ra,0x1
     5a8:	c34080e7          	jalr	-972(ra) # 11d8 <printf>
        exit(1);
     5ac:	4505                	li	a0,1
     5ae:	00001097          	auipc	ra,0x1
     5b2:	892080e7          	jalr	-1902(ra) # e40 <exit>
    } else if(what == 20){
      int pid = fork();
     5b6:	00001097          	auipc	ra,0x1
     5ba:	882080e7          	jalr	-1918(ra) # e38 <fork>
      if(pid == 0){
     5be:	c909                	beqz	a0,5d0 <go+0x558>
        chdir("a");
        unlink("../a");
        fd = open("x", O_CREATE|O_RDWR);
        unlink("x");
        exit(0);
      } else if(pid < 0){
     5c0:	06054f63          	bltz	a0,63e <go+0x5c6>
        printf("grind: fork failed\n");
        exit(1);
      }
      wait(0);
     5c4:	4501                	li	a0,0
     5c6:	00001097          	auipc	ra,0x1
     5ca:	882080e7          	jalr	-1918(ra) # e48 <wait>
     5ce:	beb1                	j	12a <go+0xb2>
        unlink("a");
     5d0:	00001517          	auipc	a0,0x1
     5d4:	ee850513          	addi	a0,a0,-280 # 14b8 <malloc+0x228>
     5d8:	00001097          	auipc	ra,0x1
     5dc:	8b8080e7          	jalr	-1864(ra) # e90 <unlink>
        mkdir("a");
     5e0:	00001517          	auipc	a0,0x1
     5e4:	ed850513          	addi	a0,a0,-296 # 14b8 <malloc+0x228>
     5e8:	00001097          	auipc	ra,0x1
     5ec:	8c0080e7          	jalr	-1856(ra) # ea8 <mkdir>
        chdir("a");
     5f0:	00001517          	auipc	a0,0x1
     5f4:	ec850513          	addi	a0,a0,-312 # 14b8 <malloc+0x228>
     5f8:	00001097          	auipc	ra,0x1
     5fc:	8b8080e7          	jalr	-1864(ra) # eb0 <chdir>
        unlink("../a");
     600:	00001517          	auipc	a0,0x1
     604:	f4850513          	addi	a0,a0,-184 # 1548 <malloc+0x2b8>
     608:	00001097          	auipc	ra,0x1
     60c:	888080e7          	jalr	-1912(ra) # e90 <unlink>
        fd = open("x", O_CREATE|O_RDWR);
     610:	20200593          	li	a1,514
     614:	00001517          	auipc	a0,0x1
     618:	eec50513          	addi	a0,a0,-276 # 1500 <malloc+0x270>
     61c:	00001097          	auipc	ra,0x1
     620:	864080e7          	jalr	-1948(ra) # e80 <open>
        unlink("x");
     624:	00001517          	auipc	a0,0x1
     628:	edc50513          	addi	a0,a0,-292 # 1500 <malloc+0x270>
     62c:	00001097          	auipc	ra,0x1
     630:	864080e7          	jalr	-1948(ra) # e90 <unlink>
        exit(0);
     634:	4501                	li	a0,0
     636:	00001097          	auipc	ra,0x1
     63a:	80a080e7          	jalr	-2038(ra) # e40 <exit>
        printf("grind: fork failed\n");
     63e:	00001517          	auipc	a0,0x1
     642:	e6250513          	addi	a0,a0,-414 # 14a0 <malloc+0x210>
     646:	00001097          	auipc	ra,0x1
     64a:	b92080e7          	jalr	-1134(ra) # 11d8 <printf>
        exit(1);
     64e:	4505                	li	a0,1
     650:	00000097          	auipc	ra,0x0
     654:	7f0080e7          	jalr	2032(ra) # e40 <exit>
    } else if(what == 21){
      unlink("c");
     658:	00001517          	auipc	a0,0x1
     65c:	ef850513          	addi	a0,a0,-264 # 1550 <malloc+0x2c0>
     660:	00001097          	auipc	ra,0x1
     664:	830080e7          	jalr	-2000(ra) # e90 <unlink>
      // should always succeed. check that there are free i-nodes,
      // file descriptors, blocks.
      int fd1 = open("c", O_CREATE|O_RDWR);
     668:	20200593          	li	a1,514
     66c:	00001517          	auipc	a0,0x1
     670:	ee450513          	addi	a0,a0,-284 # 1550 <malloc+0x2c0>
     674:	00001097          	auipc	ra,0x1
     678:	80c080e7          	jalr	-2036(ra) # e80 <open>
     67c:	8b2a                	mv	s6,a0
      if(fd1 < 0){
     67e:	04054f63          	bltz	a0,6dc <go+0x664>
        printf("grind: create c failed\n");
        exit(1);
      }
      if(write(fd1, "x", 1) != 1){
     682:	4605                	li	a2,1
     684:	00001597          	auipc	a1,0x1
     688:	e7c58593          	addi	a1,a1,-388 # 1500 <malloc+0x270>
     68c:	00000097          	auipc	ra,0x0
     690:	7d4080e7          	jalr	2004(ra) # e60 <write>
     694:	4785                	li	a5,1
     696:	06f51063          	bne	a0,a5,6f6 <go+0x67e>
        printf("grind: write c failed\n");
        exit(1);
      }
      struct stat st;
      if(fstat(fd1, &st) != 0){
     69a:	fa840593          	addi	a1,s0,-88
     69e:	855a                	mv	a0,s6
     6a0:	00000097          	auipc	ra,0x0
     6a4:	7f8080e7          	jalr	2040(ra) # e98 <fstat>
     6a8:	e525                	bnez	a0,710 <go+0x698>
        printf("grind: fstat failed\n");
        exit(1);
      }
      if(st.size != 1){
     6aa:	fb843583          	ld	a1,-72(s0)
     6ae:	4785                	li	a5,1
     6b0:	06f59d63          	bne	a1,a5,72a <go+0x6b2>
        printf("grind: fstat reports wrong size %d\n", (int)st.size);
        exit(1);
      }
      if(st.ino > 200){
     6b4:	fac42583          	lw	a1,-84(s0)
     6b8:	0c800793          	li	a5,200
     6bc:	08b7e563          	bltu	a5,a1,746 <go+0x6ce>
        printf("grind: fstat reports crazy i-number %d\n", st.ino);
        exit(1);
      }
      close(fd1);
     6c0:	855a                	mv	a0,s6
     6c2:	00000097          	auipc	ra,0x0
     6c6:	7a6080e7          	jalr	1958(ra) # e68 <close>
      unlink("c");
     6ca:	00001517          	auipc	a0,0x1
     6ce:	e8650513          	addi	a0,a0,-378 # 1550 <malloc+0x2c0>
     6d2:	00000097          	auipc	ra,0x0
     6d6:	7be080e7          	jalr	1982(ra) # e90 <unlink>
     6da:	bc81                	j	12a <go+0xb2>
        printf("grind: create c failed\n");
     6dc:	00001517          	auipc	a0,0x1
     6e0:	e7c50513          	addi	a0,a0,-388 # 1558 <malloc+0x2c8>
     6e4:	00001097          	auipc	ra,0x1
     6e8:	af4080e7          	jalr	-1292(ra) # 11d8 <printf>
        exit(1);
     6ec:	4505                	li	a0,1
     6ee:	00000097          	auipc	ra,0x0
     6f2:	752080e7          	jalr	1874(ra) # e40 <exit>
        printf("grind: write c failed\n");
     6f6:	00001517          	auipc	a0,0x1
     6fa:	e7a50513          	addi	a0,a0,-390 # 1570 <malloc+0x2e0>
     6fe:	00001097          	auipc	ra,0x1
     702:	ada080e7          	jalr	-1318(ra) # 11d8 <printf>
        exit(1);
     706:	4505                	li	a0,1
     708:	00000097          	auipc	ra,0x0
     70c:	738080e7          	jalr	1848(ra) # e40 <exit>
        printf("grind: fstat failed\n");
     710:	00001517          	auipc	a0,0x1
     714:	e7850513          	addi	a0,a0,-392 # 1588 <malloc+0x2f8>
     718:	00001097          	auipc	ra,0x1
     71c:	ac0080e7          	jalr	-1344(ra) # 11d8 <printf>
        exit(1);
     720:	4505                	li	a0,1
     722:	00000097          	auipc	ra,0x0
     726:	71e080e7          	jalr	1822(ra) # e40 <exit>
        printf("grind: fstat reports wrong size %d\n", (int)st.size);
     72a:	2581                	sext.w	a1,a1
     72c:	00001517          	auipc	a0,0x1
     730:	e7450513          	addi	a0,a0,-396 # 15a0 <malloc+0x310>
     734:	00001097          	auipc	ra,0x1
     738:	aa4080e7          	jalr	-1372(ra) # 11d8 <printf>
        exit(1);
     73c:	4505                	li	a0,1
     73e:	00000097          	auipc	ra,0x0
     742:	702080e7          	jalr	1794(ra) # e40 <exit>
        printf("grind: fstat reports crazy i-number %d\n", st.ino);
     746:	00001517          	auipc	a0,0x1
     74a:	e8250513          	addi	a0,a0,-382 # 15c8 <malloc+0x338>
     74e:	00001097          	auipc	ra,0x1
     752:	a8a080e7          	jalr	-1398(ra) # 11d8 <printf>
        exit(1);
     756:	4505                	li	a0,1
     758:	00000097          	auipc	ra,0x0
     75c:	6e8080e7          	jalr	1768(ra) # e40 <exit>
    } else if(what == 22){
      // echo hi | cat
      int aa[2], bb[2];
      if(pipe(aa) < 0){
     760:	f9840513          	addi	a0,s0,-104
     764:	00000097          	auipc	ra,0x0
     768:	6ec080e7          	jalr	1772(ra) # e50 <pipe>
     76c:	10054063          	bltz	a0,86c <go+0x7f4>
        fprintf(2, "grind: pipe failed\n");
        exit(1);
      }
      if(pipe(bb) < 0){
     770:	fa040513          	addi	a0,s0,-96
     774:	00000097          	auipc	ra,0x0
     778:	6dc080e7          	jalr	1756(ra) # e50 <pipe>
     77c:	10054663          	bltz	a0,888 <go+0x810>
        fprintf(2, "grind: pipe failed\n");
        exit(1);
      }
      int pid1 = fork();
     780:	00000097          	auipc	ra,0x0
     784:	6b8080e7          	jalr	1720(ra) # e38 <fork>
      if(pid1 == 0){
     788:	10050e63          	beqz	a0,8a4 <go+0x82c>
        close(aa[1]);
        char *args[3] = { "echo", "hi", 0 };
        exec("grindir/../echo", args);
        fprintf(2, "grind: echo: not found\n");
        exit(2);
      } else if(pid1 < 0){
     78c:	1c054663          	bltz	a0,958 <go+0x8e0>
        fprintf(2, "grind: fork failed\n");
        exit(3);
      }
      int pid2 = fork();
     790:	00000097          	auipc	ra,0x0
     794:	6a8080e7          	jalr	1704(ra) # e38 <fork>
      if(pid2 == 0){
     798:	1c050e63          	beqz	a0,974 <go+0x8fc>
        close(bb[1]);
        char *args[2] = { "cat", 0 };
        exec("/cat", args);
        fprintf(2, "grind: cat: not found\n");
        exit(6);
      } else if(pid2 < 0){
     79c:	2a054a63          	bltz	a0,a50 <go+0x9d8>
        fprintf(2, "grind: fork failed\n");
        exit(7);
      }
      close(aa[0]);
     7a0:	f9842503          	lw	a0,-104(s0)
     7a4:	00000097          	auipc	ra,0x0
     7a8:	6c4080e7          	jalr	1732(ra) # e68 <close>
      close(aa[1]);
     7ac:	f9c42503          	lw	a0,-100(s0)
     7b0:	00000097          	auipc	ra,0x0
     7b4:	6b8080e7          	jalr	1720(ra) # e68 <close>
      close(bb[1]);
     7b8:	fa442503          	lw	a0,-92(s0)
     7bc:	00000097          	auipc	ra,0x0
     7c0:	6ac080e7          	jalr	1708(ra) # e68 <close>
      char buf[4] = { 0, 0, 0, 0 };
     7c4:	f8042823          	sw	zero,-112(s0)
      read(bb[0], buf+0, 1);
     7c8:	4605                	li	a2,1
     7ca:	f9040593          	addi	a1,s0,-112
     7ce:	fa042503          	lw	a0,-96(s0)
     7d2:	00000097          	auipc	ra,0x0
     7d6:	686080e7          	jalr	1670(ra) # e58 <read>
      read(bb[0], buf+1, 1);
     7da:	4605                	li	a2,1
     7dc:	f9140593          	addi	a1,s0,-111
     7e0:	fa042503          	lw	a0,-96(s0)
     7e4:	00000097          	auipc	ra,0x0
     7e8:	674080e7          	jalr	1652(ra) # e58 <read>
      read(bb[0], buf+2, 1);
     7ec:	4605                	li	a2,1
     7ee:	f9240593          	addi	a1,s0,-110
     7f2:	fa042503          	lw	a0,-96(s0)
     7f6:	00000097          	auipc	ra,0x0
     7fa:	662080e7          	jalr	1634(ra) # e58 <read>
      close(bb[0]);
     7fe:	fa042503          	lw	a0,-96(s0)
     802:	00000097          	auipc	ra,0x0
     806:	666080e7          	jalr	1638(ra) # e68 <close>
      int st1, st2;
      wait(&st1);
     80a:	f9440513          	addi	a0,s0,-108
     80e:	00000097          	auipc	ra,0x0
     812:	63a080e7          	jalr	1594(ra) # e48 <wait>
      wait(&st2);
     816:	fa840513          	addi	a0,s0,-88
     81a:	00000097          	auipc	ra,0x0
     81e:	62e080e7          	jalr	1582(ra) # e48 <wait>
      if(st1 != 0 || st2 != 0 || strcmp(buf, "hi\n") != 0){
     822:	f9442783          	lw	a5,-108(s0)
     826:	fa842703          	lw	a4,-88(s0)
     82a:	8fd9                	or	a5,a5,a4
     82c:	ef89                	bnez	a5,846 <go+0x7ce>
     82e:	00001597          	auipc	a1,0x1
     832:	e3a58593          	addi	a1,a1,-454 # 1668 <malloc+0x3d8>
     836:	f9040513          	addi	a0,s0,-112
     83a:	00000097          	auipc	ra,0x0
     83e:	3b6080e7          	jalr	950(ra) # bf0 <strcmp>
     842:	8e0504e3          	beqz	a0,12a <go+0xb2>
        printf("grind: exec pipeline failed %d %d \"%s\"\n", st1, st2, buf);
     846:	f9040693          	addi	a3,s0,-112
     84a:	fa842603          	lw	a2,-88(s0)
     84e:	f9442583          	lw	a1,-108(s0)
     852:	00001517          	auipc	a0,0x1
     856:	e1e50513          	addi	a0,a0,-482 # 1670 <malloc+0x3e0>
     85a:	00001097          	auipc	ra,0x1
     85e:	97e080e7          	jalr	-1666(ra) # 11d8 <printf>
        exit(1);
     862:	4505                	li	a0,1
     864:	00000097          	auipc	ra,0x0
     868:	5dc080e7          	jalr	1500(ra) # e40 <exit>
        fprintf(2, "grind: pipe failed\n");
     86c:	00001597          	auipc	a1,0x1
     870:	c7c58593          	addi	a1,a1,-900 # 14e8 <malloc+0x258>
     874:	4509                	li	a0,2
     876:	00001097          	auipc	ra,0x1
     87a:	934080e7          	jalr	-1740(ra) # 11aa <fprintf>
        exit(1);
     87e:	4505                	li	a0,1
     880:	00000097          	auipc	ra,0x0
     884:	5c0080e7          	jalr	1472(ra) # e40 <exit>
        fprintf(2, "grind: pipe failed\n");
     888:	00001597          	auipc	a1,0x1
     88c:	c6058593          	addi	a1,a1,-928 # 14e8 <malloc+0x258>
     890:	4509                	li	a0,2
     892:	00001097          	auipc	ra,0x1
     896:	918080e7          	jalr	-1768(ra) # 11aa <fprintf>
        exit(1);
     89a:	4505                	li	a0,1
     89c:	00000097          	auipc	ra,0x0
     8a0:	5a4080e7          	jalr	1444(ra) # e40 <exit>
        close(bb[0]);
     8a4:	fa042503          	lw	a0,-96(s0)
     8a8:	00000097          	auipc	ra,0x0
     8ac:	5c0080e7          	jalr	1472(ra) # e68 <close>
        close(bb[1]);
     8b0:	fa442503          	lw	a0,-92(s0)
     8b4:	00000097          	auipc	ra,0x0
     8b8:	5b4080e7          	jalr	1460(ra) # e68 <close>
        close(aa[0]);
     8bc:	f9842503          	lw	a0,-104(s0)
     8c0:	00000097          	auipc	ra,0x0
     8c4:	5a8080e7          	jalr	1448(ra) # e68 <close>
        close(1);
     8c8:	4505                	li	a0,1
     8ca:	00000097          	auipc	ra,0x0
     8ce:	59e080e7          	jalr	1438(ra) # e68 <close>
        if(dup(aa[1]) != 1){
     8d2:	f9c42503          	lw	a0,-100(s0)
     8d6:	00000097          	auipc	ra,0x0
     8da:	5e2080e7          	jalr	1506(ra) # eb8 <dup>
     8de:	4785                	li	a5,1
     8e0:	02f50063          	beq	a0,a5,900 <go+0x888>
          fprintf(2, "grind: dup failed\n");
     8e4:	00001597          	auipc	a1,0x1
     8e8:	d0c58593          	addi	a1,a1,-756 # 15f0 <malloc+0x360>
     8ec:	4509                	li	a0,2
     8ee:	00001097          	auipc	ra,0x1
     8f2:	8bc080e7          	jalr	-1860(ra) # 11aa <fprintf>
          exit(1);
     8f6:	4505                	li	a0,1
     8f8:	00000097          	auipc	ra,0x0
     8fc:	548080e7          	jalr	1352(ra) # e40 <exit>
        close(aa[1]);
     900:	f9c42503          	lw	a0,-100(s0)
     904:	00000097          	auipc	ra,0x0
     908:	564080e7          	jalr	1380(ra) # e68 <close>
        char *args[3] = { "echo", "hi", 0 };
     90c:	00001797          	auipc	a5,0x1
     910:	cfc78793          	addi	a5,a5,-772 # 1608 <malloc+0x378>
     914:	faf43423          	sd	a5,-88(s0)
     918:	00001797          	auipc	a5,0x1
     91c:	cf878793          	addi	a5,a5,-776 # 1610 <malloc+0x380>
     920:	faf43823          	sd	a5,-80(s0)
     924:	fa043c23          	sd	zero,-72(s0)
        exec("grindir/../echo", args);
     928:	fa840593          	addi	a1,s0,-88
     92c:	00001517          	auipc	a0,0x1
     930:	cec50513          	addi	a0,a0,-788 # 1618 <malloc+0x388>
     934:	00000097          	auipc	ra,0x0
     938:	544080e7          	jalr	1348(ra) # e78 <exec>
        fprintf(2, "grind: echo: not found\n");
     93c:	00001597          	auipc	a1,0x1
     940:	cec58593          	addi	a1,a1,-788 # 1628 <malloc+0x398>
     944:	4509                	li	a0,2
     946:	00001097          	auipc	ra,0x1
     94a:	864080e7          	jalr	-1948(ra) # 11aa <fprintf>
        exit(2);
     94e:	4509                	li	a0,2
     950:	00000097          	auipc	ra,0x0
     954:	4f0080e7          	jalr	1264(ra) # e40 <exit>
        fprintf(2, "grind: fork failed\n");
     958:	00001597          	auipc	a1,0x1
     95c:	b4858593          	addi	a1,a1,-1208 # 14a0 <malloc+0x210>
     960:	4509                	li	a0,2
     962:	00001097          	auipc	ra,0x1
     966:	848080e7          	jalr	-1976(ra) # 11aa <fprintf>
        exit(3);
     96a:	450d                	li	a0,3
     96c:	00000097          	auipc	ra,0x0
     970:	4d4080e7          	jalr	1236(ra) # e40 <exit>
        close(aa[1]);
     974:	f9c42503          	lw	a0,-100(s0)
     978:	00000097          	auipc	ra,0x0
     97c:	4f0080e7          	jalr	1264(ra) # e68 <close>
        close(bb[0]);
     980:	fa042503          	lw	a0,-96(s0)
     984:	00000097          	auipc	ra,0x0
     988:	4e4080e7          	jalr	1252(ra) # e68 <close>
        close(0);
     98c:	4501                	li	a0,0
     98e:	00000097          	auipc	ra,0x0
     992:	4da080e7          	jalr	1242(ra) # e68 <close>
        if(dup(aa[0]) != 0){
     996:	f9842503          	lw	a0,-104(s0)
     99a:	00000097          	auipc	ra,0x0
     99e:	51e080e7          	jalr	1310(ra) # eb8 <dup>
     9a2:	cd19                	beqz	a0,9c0 <go+0x948>
          fprintf(2, "grind: dup failed\n");
     9a4:	00001597          	auipc	a1,0x1
     9a8:	c4c58593          	addi	a1,a1,-948 # 15f0 <malloc+0x360>
     9ac:	4509                	li	a0,2
     9ae:	00000097          	auipc	ra,0x0
     9b2:	7fc080e7          	jalr	2044(ra) # 11aa <fprintf>
          exit(4);
     9b6:	4511                	li	a0,4
     9b8:	00000097          	auipc	ra,0x0
     9bc:	488080e7          	jalr	1160(ra) # e40 <exit>
        close(aa[0]);
     9c0:	f9842503          	lw	a0,-104(s0)
     9c4:	00000097          	auipc	ra,0x0
     9c8:	4a4080e7          	jalr	1188(ra) # e68 <close>
        close(1);
     9cc:	4505                	li	a0,1
     9ce:	00000097          	auipc	ra,0x0
     9d2:	49a080e7          	jalr	1178(ra) # e68 <close>
        if(dup(bb[1]) != 1){
     9d6:	fa442503          	lw	a0,-92(s0)
     9da:	00000097          	auipc	ra,0x0
     9de:	4de080e7          	jalr	1246(ra) # eb8 <dup>
     9e2:	4785                	li	a5,1
     9e4:	02f50063          	beq	a0,a5,a04 <go+0x98c>
          fprintf(2, "grind: dup failed\n");
     9e8:	00001597          	auipc	a1,0x1
     9ec:	c0858593          	addi	a1,a1,-1016 # 15f0 <malloc+0x360>
     9f0:	4509                	li	a0,2
     9f2:	00000097          	auipc	ra,0x0
     9f6:	7b8080e7          	jalr	1976(ra) # 11aa <fprintf>
          exit(5);
     9fa:	4515                	li	a0,5
     9fc:	00000097          	auipc	ra,0x0
     a00:	444080e7          	jalr	1092(ra) # e40 <exit>
        close(bb[1]);
     a04:	fa442503          	lw	a0,-92(s0)
     a08:	00000097          	auipc	ra,0x0
     a0c:	460080e7          	jalr	1120(ra) # e68 <close>
        char *args[2] = { "cat", 0 };
     a10:	00001797          	auipc	a5,0x1
     a14:	c3078793          	addi	a5,a5,-976 # 1640 <malloc+0x3b0>
     a18:	faf43423          	sd	a5,-88(s0)
     a1c:	fa043823          	sd	zero,-80(s0)
        exec("/cat", args);
     a20:	fa840593          	addi	a1,s0,-88
     a24:	00001517          	auipc	a0,0x1
     a28:	c2450513          	addi	a0,a0,-988 # 1648 <malloc+0x3b8>
     a2c:	00000097          	auipc	ra,0x0
     a30:	44c080e7          	jalr	1100(ra) # e78 <exec>
        fprintf(2, "grind: cat: not found\n");
     a34:	00001597          	auipc	a1,0x1
     a38:	c1c58593          	addi	a1,a1,-996 # 1650 <malloc+0x3c0>
     a3c:	4509                	li	a0,2
     a3e:	00000097          	auipc	ra,0x0
     a42:	76c080e7          	jalr	1900(ra) # 11aa <fprintf>
        exit(6);
     a46:	4519                	li	a0,6
     a48:	00000097          	auipc	ra,0x0
     a4c:	3f8080e7          	jalr	1016(ra) # e40 <exit>
        fprintf(2, "grind: fork failed\n");
     a50:	00001597          	auipc	a1,0x1
     a54:	a5058593          	addi	a1,a1,-1456 # 14a0 <malloc+0x210>
     a58:	4509                	li	a0,2
     a5a:	00000097          	auipc	ra,0x0
     a5e:	750080e7          	jalr	1872(ra) # 11aa <fprintf>
        exit(7);
     a62:	451d                	li	a0,7
     a64:	00000097          	auipc	ra,0x0
     a68:	3dc080e7          	jalr	988(ra) # e40 <exit>

0000000000000a6c <iter>:
  }
}

void
iter()
{
     a6c:	7179                	addi	sp,sp,-48
     a6e:	f406                	sd	ra,40(sp)
     a70:	f022                	sd	s0,32(sp)
     a72:	1800                	addi	s0,sp,48
  unlink("a");
     a74:	00001517          	auipc	a0,0x1
     a78:	a4450513          	addi	a0,a0,-1468 # 14b8 <malloc+0x228>
     a7c:	00000097          	auipc	ra,0x0
     a80:	414080e7          	jalr	1044(ra) # e90 <unlink>
  unlink("b");
     a84:	00001517          	auipc	a0,0x1
     a88:	9e450513          	addi	a0,a0,-1564 # 1468 <malloc+0x1d8>
     a8c:	00000097          	auipc	ra,0x0
     a90:	404080e7          	jalr	1028(ra) # e90 <unlink>
  
  int pid1 = fork();
     a94:	00000097          	auipc	ra,0x0
     a98:	3a4080e7          	jalr	932(ra) # e38 <fork>
  if(pid1 < 0){
     a9c:	02054363          	bltz	a0,ac2 <iter+0x56>
     aa0:	ec26                	sd	s1,24(sp)
     aa2:	84aa                	mv	s1,a0
    printf("grind: fork failed\n");
    exit(1);
  }
  if(pid1 == 0){
     aa4:	ed15                	bnez	a0,ae0 <iter+0x74>
     aa6:	e84a                	sd	s2,16(sp)
    rand_next ^= 31;
     aa8:	00001717          	auipc	a4,0x1
     aac:	55870713          	addi	a4,a4,1368 # 2000 <rand_next>
     ab0:	631c                	ld	a5,0(a4)
     ab2:	01f7c793          	xori	a5,a5,31
     ab6:	e31c                	sd	a5,0(a4)
    go(0);
     ab8:	4501                	li	a0,0
     aba:	fffff097          	auipc	ra,0xfffff
     abe:	5be080e7          	jalr	1470(ra) # 78 <go>
     ac2:	ec26                	sd	s1,24(sp)
     ac4:	e84a                	sd	s2,16(sp)
    printf("grind: fork failed\n");
     ac6:	00001517          	auipc	a0,0x1
     aca:	9da50513          	addi	a0,a0,-1574 # 14a0 <malloc+0x210>
     ace:	00000097          	auipc	ra,0x0
     ad2:	70a080e7          	jalr	1802(ra) # 11d8 <printf>
    exit(1);
     ad6:	4505                	li	a0,1
     ad8:	00000097          	auipc	ra,0x0
     adc:	368080e7          	jalr	872(ra) # e40 <exit>
     ae0:	e84a                	sd	s2,16(sp)
    exit(0);
  }

  int pid2 = fork();
     ae2:	00000097          	auipc	ra,0x0
     ae6:	356080e7          	jalr	854(ra) # e38 <fork>
     aea:	892a                	mv	s2,a0
  if(pid2 < 0){
     aec:	02054263          	bltz	a0,b10 <iter+0xa4>
    printf("grind: fork failed\n");
    exit(1);
  }
  if(pid2 == 0){
     af0:	ed0d                	bnez	a0,b2a <iter+0xbe>
    rand_next ^= 7177;
     af2:	00001697          	auipc	a3,0x1
     af6:	50e68693          	addi	a3,a3,1294 # 2000 <rand_next>
     afa:	629c                	ld	a5,0(a3)
     afc:	6709                	lui	a4,0x2
     afe:	c0970713          	addi	a4,a4,-1015 # 1c09 <digits+0x4b1>
     b02:	8fb9                	xor	a5,a5,a4
     b04:	e29c                	sd	a5,0(a3)
    go(1);
     b06:	4505                	li	a0,1
     b08:	fffff097          	auipc	ra,0xfffff
     b0c:	570080e7          	jalr	1392(ra) # 78 <go>
    printf("grind: fork failed\n");
     b10:	00001517          	auipc	a0,0x1
     b14:	99050513          	addi	a0,a0,-1648 # 14a0 <malloc+0x210>
     b18:	00000097          	auipc	ra,0x0
     b1c:	6c0080e7          	jalr	1728(ra) # 11d8 <printf>
    exit(1);
     b20:	4505                	li	a0,1
     b22:	00000097          	auipc	ra,0x0
     b26:	31e080e7          	jalr	798(ra) # e40 <exit>
    exit(0);
  }

  int st1 = -1;
     b2a:	57fd                	li	a5,-1
     b2c:	fcf42e23          	sw	a5,-36(s0)
  wait(&st1);
     b30:	fdc40513          	addi	a0,s0,-36
     b34:	00000097          	auipc	ra,0x0
     b38:	314080e7          	jalr	788(ra) # e48 <wait>
  if(st1 != 0){
     b3c:	fdc42783          	lw	a5,-36(s0)
     b40:	ef99                	bnez	a5,b5e <iter+0xf2>
    kill(pid1);
    kill(pid2);
  }
  int st2 = -1;
     b42:	57fd                	li	a5,-1
     b44:	fcf42c23          	sw	a5,-40(s0)
  wait(&st2);
     b48:	fd840513          	addi	a0,s0,-40
     b4c:	00000097          	auipc	ra,0x0
     b50:	2fc080e7          	jalr	764(ra) # e48 <wait>

  exit(0);
     b54:	4501                	li	a0,0
     b56:	00000097          	auipc	ra,0x0
     b5a:	2ea080e7          	jalr	746(ra) # e40 <exit>
    kill(pid1);
     b5e:	8526                	mv	a0,s1
     b60:	00000097          	auipc	ra,0x0
     b64:	310080e7          	jalr	784(ra) # e70 <kill>
    kill(pid2);
     b68:	854a                	mv	a0,s2
     b6a:	00000097          	auipc	ra,0x0
     b6e:	306080e7          	jalr	774(ra) # e70 <kill>
     b72:	bfc1                	j	b42 <iter+0xd6>

0000000000000b74 <main>:
}

int
main()
{
     b74:	1101                	addi	sp,sp,-32
     b76:	ec06                	sd	ra,24(sp)
     b78:	e822                	sd	s0,16(sp)
     b7a:	e426                	sd	s1,8(sp)
     b7c:	1000                	addi	s0,sp,32
    }
    if(pid > 0){
      wait(0);
    }
    sleep(20);
    rand_next += 1;
     b7e:	00001497          	auipc	s1,0x1
     b82:	48248493          	addi	s1,s1,1154 # 2000 <rand_next>
     b86:	a829                	j	ba0 <main+0x2c>
      iter();
     b88:	00000097          	auipc	ra,0x0
     b8c:	ee4080e7          	jalr	-284(ra) # a6c <iter>
    sleep(20);
     b90:	4551                	li	a0,20
     b92:	00000097          	auipc	ra,0x0
     b96:	33e080e7          	jalr	830(ra) # ed0 <sleep>
    rand_next += 1;
     b9a:	609c                	ld	a5,0(s1)
     b9c:	0785                	addi	a5,a5,1
     b9e:	e09c                	sd	a5,0(s1)
    int pid = fork();
     ba0:	00000097          	auipc	ra,0x0
     ba4:	298080e7          	jalr	664(ra) # e38 <fork>
    if(pid == 0){
     ba8:	d165                	beqz	a0,b88 <main+0x14>
    if(pid > 0){
     baa:	fea053e3          	blez	a0,b90 <main+0x1c>
      wait(0);
     bae:	4501                	li	a0,0
     bb0:	00000097          	auipc	ra,0x0
     bb4:	298080e7          	jalr	664(ra) # e48 <wait>
     bb8:	bfe1                	j	b90 <main+0x1c>

0000000000000bba <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
     bba:	1141                	addi	sp,sp,-16
     bbc:	e406                	sd	ra,8(sp)
     bbe:	e022                	sd	s0,0(sp)
     bc0:	0800                	addi	s0,sp,16
  extern int main();
  main();
     bc2:	00000097          	auipc	ra,0x0
     bc6:	fb2080e7          	jalr	-78(ra) # b74 <main>
  exit(0);
     bca:	4501                	li	a0,0
     bcc:	00000097          	auipc	ra,0x0
     bd0:	274080e7          	jalr	628(ra) # e40 <exit>

0000000000000bd4 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
     bd4:	1141                	addi	sp,sp,-16
     bd6:	e422                	sd	s0,8(sp)
     bd8:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
     bda:	87aa                	mv	a5,a0
     bdc:	0585                	addi	a1,a1,1
     bde:	0785                	addi	a5,a5,1
     be0:	fff5c703          	lbu	a4,-1(a1)
     be4:	fee78fa3          	sb	a4,-1(a5)
     be8:	fb75                	bnez	a4,bdc <strcpy+0x8>
    ;
  return os;
}
     bea:	6422                	ld	s0,8(sp)
     bec:	0141                	addi	sp,sp,16
     bee:	8082                	ret

0000000000000bf0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
     bf0:	1141                	addi	sp,sp,-16
     bf2:	e422                	sd	s0,8(sp)
     bf4:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
     bf6:	00054783          	lbu	a5,0(a0)
     bfa:	cb91                	beqz	a5,c0e <strcmp+0x1e>
     bfc:	0005c703          	lbu	a4,0(a1)
     c00:	00f71763          	bne	a4,a5,c0e <strcmp+0x1e>
    p++, q++;
     c04:	0505                	addi	a0,a0,1
     c06:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
     c08:	00054783          	lbu	a5,0(a0)
     c0c:	fbe5                	bnez	a5,bfc <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
     c0e:	0005c503          	lbu	a0,0(a1)
}
     c12:	40a7853b          	subw	a0,a5,a0
     c16:	6422                	ld	s0,8(sp)
     c18:	0141                	addi	sp,sp,16
     c1a:	8082                	ret

0000000000000c1c <strlen>:

uint
strlen(const char *s)
{
     c1c:	1141                	addi	sp,sp,-16
     c1e:	e422                	sd	s0,8(sp)
     c20:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
     c22:	00054783          	lbu	a5,0(a0)
     c26:	cf91                	beqz	a5,c42 <strlen+0x26>
     c28:	0505                	addi	a0,a0,1
     c2a:	87aa                	mv	a5,a0
     c2c:	86be                	mv	a3,a5
     c2e:	0785                	addi	a5,a5,1
     c30:	fff7c703          	lbu	a4,-1(a5)
     c34:	ff65                	bnez	a4,c2c <strlen+0x10>
     c36:	40a6853b          	subw	a0,a3,a0
     c3a:	2505                	addiw	a0,a0,1
    ;
  return n;
}
     c3c:	6422                	ld	s0,8(sp)
     c3e:	0141                	addi	sp,sp,16
     c40:	8082                	ret
  for(n = 0; s[n]; n++)
     c42:	4501                	li	a0,0
     c44:	bfe5                	j	c3c <strlen+0x20>

0000000000000c46 <memset>:

void*
memset(void *dst, int c, uint n)
{
     c46:	1141                	addi	sp,sp,-16
     c48:	e422                	sd	s0,8(sp)
     c4a:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
     c4c:	ca19                	beqz	a2,c62 <memset+0x1c>
     c4e:	87aa                	mv	a5,a0
     c50:	1602                	slli	a2,a2,0x20
     c52:	9201                	srli	a2,a2,0x20
     c54:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
     c58:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
     c5c:	0785                	addi	a5,a5,1
     c5e:	fee79de3          	bne	a5,a4,c58 <memset+0x12>
  }
  return dst;
}
     c62:	6422                	ld	s0,8(sp)
     c64:	0141                	addi	sp,sp,16
     c66:	8082                	ret

0000000000000c68 <strchr>:

char*
strchr(const char *s, char c)
{
     c68:	1141                	addi	sp,sp,-16
     c6a:	e422                	sd	s0,8(sp)
     c6c:	0800                	addi	s0,sp,16
  for(; *s; s++)
     c6e:	00054783          	lbu	a5,0(a0)
     c72:	cb99                	beqz	a5,c88 <strchr+0x20>
    if(*s == c)
     c74:	00f58763          	beq	a1,a5,c82 <strchr+0x1a>
  for(; *s; s++)
     c78:	0505                	addi	a0,a0,1
     c7a:	00054783          	lbu	a5,0(a0)
     c7e:	fbfd                	bnez	a5,c74 <strchr+0xc>
      return (char*)s;
  return 0;
     c80:	4501                	li	a0,0
}
     c82:	6422                	ld	s0,8(sp)
     c84:	0141                	addi	sp,sp,16
     c86:	8082                	ret
  return 0;
     c88:	4501                	li	a0,0
     c8a:	bfe5                	j	c82 <strchr+0x1a>

0000000000000c8c <gets>:

char*
gets(char *buf, int max)
{
     c8c:	711d                	addi	sp,sp,-96
     c8e:	ec86                	sd	ra,88(sp)
     c90:	e8a2                	sd	s0,80(sp)
     c92:	e4a6                	sd	s1,72(sp)
     c94:	e0ca                	sd	s2,64(sp)
     c96:	fc4e                	sd	s3,56(sp)
     c98:	f852                	sd	s4,48(sp)
     c9a:	f456                	sd	s5,40(sp)
     c9c:	f05a                	sd	s6,32(sp)
     c9e:	ec5e                	sd	s7,24(sp)
     ca0:	1080                	addi	s0,sp,96
     ca2:	8baa                	mv	s7,a0
     ca4:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     ca6:	892a                	mv	s2,a0
     ca8:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
     caa:	4aa9                	li	s5,10
     cac:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
     cae:	89a6                	mv	s3,s1
     cb0:	2485                	addiw	s1,s1,1
     cb2:	0344d863          	bge	s1,s4,ce2 <gets+0x56>
    cc = read(0, &c, 1);
     cb6:	4605                	li	a2,1
     cb8:	faf40593          	addi	a1,s0,-81
     cbc:	4501                	li	a0,0
     cbe:	00000097          	auipc	ra,0x0
     cc2:	19a080e7          	jalr	410(ra) # e58 <read>
    if(cc < 1)
     cc6:	00a05e63          	blez	a0,ce2 <gets+0x56>
    buf[i++] = c;
     cca:	faf44783          	lbu	a5,-81(s0)
     cce:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
     cd2:	01578763          	beq	a5,s5,ce0 <gets+0x54>
     cd6:	0905                	addi	s2,s2,1
     cd8:	fd679be3          	bne	a5,s6,cae <gets+0x22>
    buf[i++] = c;
     cdc:	89a6                	mv	s3,s1
     cde:	a011                	j	ce2 <gets+0x56>
     ce0:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
     ce2:	99de                	add	s3,s3,s7
     ce4:	00098023          	sb	zero,0(s3)
  return buf;
}
     ce8:	855e                	mv	a0,s7
     cea:	60e6                	ld	ra,88(sp)
     cec:	6446                	ld	s0,80(sp)
     cee:	64a6                	ld	s1,72(sp)
     cf0:	6906                	ld	s2,64(sp)
     cf2:	79e2                	ld	s3,56(sp)
     cf4:	7a42                	ld	s4,48(sp)
     cf6:	7aa2                	ld	s5,40(sp)
     cf8:	7b02                	ld	s6,32(sp)
     cfa:	6be2                	ld	s7,24(sp)
     cfc:	6125                	addi	sp,sp,96
     cfe:	8082                	ret

0000000000000d00 <stat>:

int
stat(const char *n, struct stat *st)
{
     d00:	1101                	addi	sp,sp,-32
     d02:	ec06                	sd	ra,24(sp)
     d04:	e822                	sd	s0,16(sp)
     d06:	e04a                	sd	s2,0(sp)
     d08:	1000                	addi	s0,sp,32
     d0a:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
     d0c:	4581                	li	a1,0
     d0e:	00000097          	auipc	ra,0x0
     d12:	172080e7          	jalr	370(ra) # e80 <open>
  if(fd < 0)
     d16:	02054663          	bltz	a0,d42 <stat+0x42>
     d1a:	e426                	sd	s1,8(sp)
     d1c:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
     d1e:	85ca                	mv	a1,s2
     d20:	00000097          	auipc	ra,0x0
     d24:	178080e7          	jalr	376(ra) # e98 <fstat>
     d28:	892a                	mv	s2,a0
  close(fd);
     d2a:	8526                	mv	a0,s1
     d2c:	00000097          	auipc	ra,0x0
     d30:	13c080e7          	jalr	316(ra) # e68 <close>
  return r;
     d34:	64a2                	ld	s1,8(sp)
}
     d36:	854a                	mv	a0,s2
     d38:	60e2                	ld	ra,24(sp)
     d3a:	6442                	ld	s0,16(sp)
     d3c:	6902                	ld	s2,0(sp)
     d3e:	6105                	addi	sp,sp,32
     d40:	8082                	ret
    return -1;
     d42:	597d                	li	s2,-1
     d44:	bfcd                	j	d36 <stat+0x36>

0000000000000d46 <atoi>:

int
atoi(const char *s)
{
     d46:	1141                	addi	sp,sp,-16
     d48:	e422                	sd	s0,8(sp)
     d4a:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
     d4c:	00054683          	lbu	a3,0(a0)
     d50:	fd06879b          	addiw	a5,a3,-48
     d54:	0ff7f793          	zext.b	a5,a5
     d58:	4625                	li	a2,9
     d5a:	02f66863          	bltu	a2,a5,d8a <atoi+0x44>
     d5e:	872a                	mv	a4,a0
  n = 0;
     d60:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
     d62:	0705                	addi	a4,a4,1
     d64:	0025179b          	slliw	a5,a0,0x2
     d68:	9fa9                	addw	a5,a5,a0
     d6a:	0017979b          	slliw	a5,a5,0x1
     d6e:	9fb5                	addw	a5,a5,a3
     d70:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
     d74:	00074683          	lbu	a3,0(a4)
     d78:	fd06879b          	addiw	a5,a3,-48
     d7c:	0ff7f793          	zext.b	a5,a5
     d80:	fef671e3          	bgeu	a2,a5,d62 <atoi+0x1c>
  return n;
}
     d84:	6422                	ld	s0,8(sp)
     d86:	0141                	addi	sp,sp,16
     d88:	8082                	ret
  n = 0;
     d8a:	4501                	li	a0,0
     d8c:	bfe5                	j	d84 <atoi+0x3e>

0000000000000d8e <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
     d8e:	1141                	addi	sp,sp,-16
     d90:	e422                	sd	s0,8(sp)
     d92:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
     d94:	02b57463          	bgeu	a0,a1,dbc <memmove+0x2e>
    while(n-- > 0)
     d98:	00c05f63          	blez	a2,db6 <memmove+0x28>
     d9c:	1602                	slli	a2,a2,0x20
     d9e:	9201                	srli	a2,a2,0x20
     da0:	00c507b3          	add	a5,a0,a2
  dst = vdst;
     da4:	872a                	mv	a4,a0
      *dst++ = *src++;
     da6:	0585                	addi	a1,a1,1
     da8:	0705                	addi	a4,a4,1
     daa:	fff5c683          	lbu	a3,-1(a1)
     dae:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
     db2:	fef71ae3          	bne	a4,a5,da6 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
     db6:	6422                	ld	s0,8(sp)
     db8:	0141                	addi	sp,sp,16
     dba:	8082                	ret
    dst += n;
     dbc:	00c50733          	add	a4,a0,a2
    src += n;
     dc0:	95b2                	add	a1,a1,a2
    while(n-- > 0)
     dc2:	fec05ae3          	blez	a2,db6 <memmove+0x28>
     dc6:	fff6079b          	addiw	a5,a2,-1
     dca:	1782                	slli	a5,a5,0x20
     dcc:	9381                	srli	a5,a5,0x20
     dce:	fff7c793          	not	a5,a5
     dd2:	97ba                	add	a5,a5,a4
      *--dst = *--src;
     dd4:	15fd                	addi	a1,a1,-1
     dd6:	177d                	addi	a4,a4,-1
     dd8:	0005c683          	lbu	a3,0(a1)
     ddc:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
     de0:	fee79ae3          	bne	a5,a4,dd4 <memmove+0x46>
     de4:	bfc9                	j	db6 <memmove+0x28>

0000000000000de6 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
     de6:	1141                	addi	sp,sp,-16
     de8:	e422                	sd	s0,8(sp)
     dea:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
     dec:	ca05                	beqz	a2,e1c <memcmp+0x36>
     dee:	fff6069b          	addiw	a3,a2,-1
     df2:	1682                	slli	a3,a3,0x20
     df4:	9281                	srli	a3,a3,0x20
     df6:	0685                	addi	a3,a3,1
     df8:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
     dfa:	00054783          	lbu	a5,0(a0)
     dfe:	0005c703          	lbu	a4,0(a1)
     e02:	00e79863          	bne	a5,a4,e12 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
     e06:	0505                	addi	a0,a0,1
    p2++;
     e08:	0585                	addi	a1,a1,1
  while (n-- > 0) {
     e0a:	fed518e3          	bne	a0,a3,dfa <memcmp+0x14>
  }
  return 0;
     e0e:	4501                	li	a0,0
     e10:	a019                	j	e16 <memcmp+0x30>
      return *p1 - *p2;
     e12:	40e7853b          	subw	a0,a5,a4
}
     e16:	6422                	ld	s0,8(sp)
     e18:	0141                	addi	sp,sp,16
     e1a:	8082                	ret
  return 0;
     e1c:	4501                	li	a0,0
     e1e:	bfe5                	j	e16 <memcmp+0x30>

0000000000000e20 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
     e20:	1141                	addi	sp,sp,-16
     e22:	e406                	sd	ra,8(sp)
     e24:	e022                	sd	s0,0(sp)
     e26:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
     e28:	00000097          	auipc	ra,0x0
     e2c:	f66080e7          	jalr	-154(ra) # d8e <memmove>
}
     e30:	60a2                	ld	ra,8(sp)
     e32:	6402                	ld	s0,0(sp)
     e34:	0141                	addi	sp,sp,16
     e36:	8082                	ret

0000000000000e38 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
     e38:	4885                	li	a7,1
 ecall
     e3a:	00000073          	ecall
 ret
     e3e:	8082                	ret

0000000000000e40 <exit>:
.global exit
exit:
 li a7, SYS_exit
     e40:	4889                	li	a7,2
 ecall
     e42:	00000073          	ecall
 ret
     e46:	8082                	ret

0000000000000e48 <wait>:
.global wait
wait:
 li a7, SYS_wait
     e48:	488d                	li	a7,3
 ecall
     e4a:	00000073          	ecall
 ret
     e4e:	8082                	ret

0000000000000e50 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
     e50:	4891                	li	a7,4
 ecall
     e52:	00000073          	ecall
 ret
     e56:	8082                	ret

0000000000000e58 <read>:
.global read
read:
 li a7, SYS_read
     e58:	4895                	li	a7,5
 ecall
     e5a:	00000073          	ecall
 ret
     e5e:	8082                	ret

0000000000000e60 <write>:
.global write
write:
 li a7, SYS_write
     e60:	48c1                	li	a7,16
 ecall
     e62:	00000073          	ecall
 ret
     e66:	8082                	ret

0000000000000e68 <close>:
.global close
close:
 li a7, SYS_close
     e68:	48d5                	li	a7,21
 ecall
     e6a:	00000073          	ecall
 ret
     e6e:	8082                	ret

0000000000000e70 <kill>:
.global kill
kill:
 li a7, SYS_kill
     e70:	4899                	li	a7,6
 ecall
     e72:	00000073          	ecall
 ret
     e76:	8082                	ret

0000000000000e78 <exec>:
.global exec
exec:
 li a7, SYS_exec
     e78:	489d                	li	a7,7
 ecall
     e7a:	00000073          	ecall
 ret
     e7e:	8082                	ret

0000000000000e80 <open>:
.global open
open:
 li a7, SYS_open
     e80:	48bd                	li	a7,15
 ecall
     e82:	00000073          	ecall
 ret
     e86:	8082                	ret

0000000000000e88 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
     e88:	48c5                	li	a7,17
 ecall
     e8a:	00000073          	ecall
 ret
     e8e:	8082                	ret

0000000000000e90 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
     e90:	48c9                	li	a7,18
 ecall
     e92:	00000073          	ecall
 ret
     e96:	8082                	ret

0000000000000e98 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
     e98:	48a1                	li	a7,8
 ecall
     e9a:	00000073          	ecall
 ret
     e9e:	8082                	ret

0000000000000ea0 <link>:
.global link
link:
 li a7, SYS_link
     ea0:	48cd                	li	a7,19
 ecall
     ea2:	00000073          	ecall
 ret
     ea6:	8082                	ret

0000000000000ea8 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
     ea8:	48d1                	li	a7,20
 ecall
     eaa:	00000073          	ecall
 ret
     eae:	8082                	ret

0000000000000eb0 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
     eb0:	48a5                	li	a7,9
 ecall
     eb2:	00000073          	ecall
 ret
     eb6:	8082                	ret

0000000000000eb8 <dup>:
.global dup
dup:
 li a7, SYS_dup
     eb8:	48a9                	li	a7,10
 ecall
     eba:	00000073          	ecall
 ret
     ebe:	8082                	ret

0000000000000ec0 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
     ec0:	48ad                	li	a7,11
 ecall
     ec2:	00000073          	ecall
 ret
     ec6:	8082                	ret

0000000000000ec8 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
     ec8:	48b1                	li	a7,12
 ecall
     eca:	00000073          	ecall
 ret
     ece:	8082                	ret

0000000000000ed0 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
     ed0:	48b5                	li	a7,13
 ecall
     ed2:	00000073          	ecall
 ret
     ed6:	8082                	ret

0000000000000ed8 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
     ed8:	48b9                	li	a7,14
 ecall
     eda:	00000073          	ecall
 ret
     ede:	8082                	ret

0000000000000ee0 <waitx>:
.global waitx
waitx:
 li a7, SYS_waitx
     ee0:	48d9                	li	a7,22
 ecall
     ee2:	00000073          	ecall
 ret
     ee6:	8082                	ret

0000000000000ee8 <getSysCount>:
.global getSysCount
getSysCount:
 li a7, SYS_getSysCount
     ee8:	48dd                	li	a7,23
 ecall
     eea:	00000073          	ecall
 ret
     eee:	8082                	ret

0000000000000ef0 <sigreturn>:
.global sigreturn
sigreturn:
 li a7, SYS_sigreturn
     ef0:	48e5                	li	a7,25
 ecall
     ef2:	00000073          	ecall
 ret
     ef6:	8082                	ret

0000000000000ef8 <sigalarm>:
.global sigalarm
sigalarm:
 li a7, SYS_sigalarm
     ef8:	48e1                	li	a7,24
 ecall
     efa:	00000073          	ecall
 ret
     efe:	8082                	ret

0000000000000f00 <settickets>:
.global settickets
settickets:
 li a7, SYS_settickets
     f00:	48e9                	li	a7,26
 ecall
     f02:	00000073          	ecall
 ret
     f06:	8082                	ret

0000000000000f08 <printlog>:
.global printlog
printlog:
 li a7, SYS_printlog
     f08:	48ed                	li	a7,27
 ecall
     f0a:	00000073          	ecall
 ret
     f0e:	8082                	ret

0000000000000f10 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
     f10:	1101                	addi	sp,sp,-32
     f12:	ec06                	sd	ra,24(sp)
     f14:	e822                	sd	s0,16(sp)
     f16:	1000                	addi	s0,sp,32
     f18:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
     f1c:	4605                	li	a2,1
     f1e:	fef40593          	addi	a1,s0,-17
     f22:	00000097          	auipc	ra,0x0
     f26:	f3e080e7          	jalr	-194(ra) # e60 <write>
}
     f2a:	60e2                	ld	ra,24(sp)
     f2c:	6442                	ld	s0,16(sp)
     f2e:	6105                	addi	sp,sp,32
     f30:	8082                	ret

0000000000000f32 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
     f32:	7139                	addi	sp,sp,-64
     f34:	fc06                	sd	ra,56(sp)
     f36:	f822                	sd	s0,48(sp)
     f38:	f426                	sd	s1,40(sp)
     f3a:	0080                	addi	s0,sp,64
     f3c:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
     f3e:	c299                	beqz	a3,f44 <printint+0x12>
     f40:	0805cb63          	bltz	a1,fd6 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
     f44:	2581                	sext.w	a1,a1
  neg = 0;
     f46:	4881                	li	a7,0
     f48:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
     f4c:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
     f4e:	2601                	sext.w	a2,a2
     f50:	00001517          	auipc	a0,0x1
     f54:	80850513          	addi	a0,a0,-2040 # 1758 <digits>
     f58:	883a                	mv	a6,a4
     f5a:	2705                	addiw	a4,a4,1
     f5c:	02c5f7bb          	remuw	a5,a1,a2
     f60:	1782                	slli	a5,a5,0x20
     f62:	9381                	srli	a5,a5,0x20
     f64:	97aa                	add	a5,a5,a0
     f66:	0007c783          	lbu	a5,0(a5)
     f6a:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
     f6e:	0005879b          	sext.w	a5,a1
     f72:	02c5d5bb          	divuw	a1,a1,a2
     f76:	0685                	addi	a3,a3,1
     f78:	fec7f0e3          	bgeu	a5,a2,f58 <printint+0x26>
  if(neg)
     f7c:	00088c63          	beqz	a7,f94 <printint+0x62>
    buf[i++] = '-';
     f80:	fd070793          	addi	a5,a4,-48
     f84:	00878733          	add	a4,a5,s0
     f88:	02d00793          	li	a5,45
     f8c:	fef70823          	sb	a5,-16(a4)
     f90:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
     f94:	02e05c63          	blez	a4,fcc <printint+0x9a>
     f98:	f04a                	sd	s2,32(sp)
     f9a:	ec4e                	sd	s3,24(sp)
     f9c:	fc040793          	addi	a5,s0,-64
     fa0:	00e78933          	add	s2,a5,a4
     fa4:	fff78993          	addi	s3,a5,-1
     fa8:	99ba                	add	s3,s3,a4
     faa:	377d                	addiw	a4,a4,-1
     fac:	1702                	slli	a4,a4,0x20
     fae:	9301                	srli	a4,a4,0x20
     fb0:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
     fb4:	fff94583          	lbu	a1,-1(s2)
     fb8:	8526                	mv	a0,s1
     fba:	00000097          	auipc	ra,0x0
     fbe:	f56080e7          	jalr	-170(ra) # f10 <putc>
  while(--i >= 0)
     fc2:	197d                	addi	s2,s2,-1
     fc4:	ff3918e3          	bne	s2,s3,fb4 <printint+0x82>
     fc8:	7902                	ld	s2,32(sp)
     fca:	69e2                	ld	s3,24(sp)
}
     fcc:	70e2                	ld	ra,56(sp)
     fce:	7442                	ld	s0,48(sp)
     fd0:	74a2                	ld	s1,40(sp)
     fd2:	6121                	addi	sp,sp,64
     fd4:	8082                	ret
    x = -xx;
     fd6:	40b005bb          	negw	a1,a1
    neg = 1;
     fda:	4885                	li	a7,1
    x = -xx;
     fdc:	b7b5                	j	f48 <printint+0x16>

0000000000000fde <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
     fde:	715d                	addi	sp,sp,-80
     fe0:	e486                	sd	ra,72(sp)
     fe2:	e0a2                	sd	s0,64(sp)
     fe4:	f84a                	sd	s2,48(sp)
     fe6:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
     fe8:	0005c903          	lbu	s2,0(a1)
     fec:	1a090a63          	beqz	s2,11a0 <vprintf+0x1c2>
     ff0:	fc26                	sd	s1,56(sp)
     ff2:	f44e                	sd	s3,40(sp)
     ff4:	f052                	sd	s4,32(sp)
     ff6:	ec56                	sd	s5,24(sp)
     ff8:	e85a                	sd	s6,16(sp)
     ffa:	e45e                	sd	s7,8(sp)
     ffc:	8aaa                	mv	s5,a0
     ffe:	8bb2                	mv	s7,a2
    1000:	00158493          	addi	s1,a1,1
  state = 0;
    1004:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
    1006:	02500a13          	li	s4,37
    100a:	4b55                	li	s6,21
    100c:	a839                	j	102a <vprintf+0x4c>
        putc(fd, c);
    100e:	85ca                	mv	a1,s2
    1010:	8556                	mv	a0,s5
    1012:	00000097          	auipc	ra,0x0
    1016:	efe080e7          	jalr	-258(ra) # f10 <putc>
    101a:	a019                	j	1020 <vprintf+0x42>
    } else if(state == '%'){
    101c:	01498d63          	beq	s3,s4,1036 <vprintf+0x58>
  for(i = 0; fmt[i]; i++){
    1020:	0485                	addi	s1,s1,1
    1022:	fff4c903          	lbu	s2,-1(s1)
    1026:	16090763          	beqz	s2,1194 <vprintf+0x1b6>
    if(state == 0){
    102a:	fe0999e3          	bnez	s3,101c <vprintf+0x3e>
      if(c == '%'){
    102e:	ff4910e3          	bne	s2,s4,100e <vprintf+0x30>
        state = '%';
    1032:	89d2                	mv	s3,s4
    1034:	b7f5                	j	1020 <vprintf+0x42>
      if(c == 'd'){
    1036:	13490463          	beq	s2,s4,115e <vprintf+0x180>
    103a:	f9d9079b          	addiw	a5,s2,-99
    103e:	0ff7f793          	zext.b	a5,a5
    1042:	12fb6763          	bltu	s6,a5,1170 <vprintf+0x192>
    1046:	f9d9079b          	addiw	a5,s2,-99
    104a:	0ff7f713          	zext.b	a4,a5
    104e:	12eb6163          	bltu	s6,a4,1170 <vprintf+0x192>
    1052:	00271793          	slli	a5,a4,0x2
    1056:	00000717          	auipc	a4,0x0
    105a:	6aa70713          	addi	a4,a4,1706 # 1700 <malloc+0x470>
    105e:	97ba                	add	a5,a5,a4
    1060:	439c                	lw	a5,0(a5)
    1062:	97ba                	add	a5,a5,a4
    1064:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
    1066:	008b8913          	addi	s2,s7,8
    106a:	4685                	li	a3,1
    106c:	4629                	li	a2,10
    106e:	000ba583          	lw	a1,0(s7)
    1072:	8556                	mv	a0,s5
    1074:	00000097          	auipc	ra,0x0
    1078:	ebe080e7          	jalr	-322(ra) # f32 <printint>
    107c:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
    107e:	4981                	li	s3,0
    1080:	b745                	j	1020 <vprintf+0x42>
        printint(fd, va_arg(ap, uint64), 10, 0);
    1082:	008b8913          	addi	s2,s7,8
    1086:	4681                	li	a3,0
    1088:	4629                	li	a2,10
    108a:	000ba583          	lw	a1,0(s7)
    108e:	8556                	mv	a0,s5
    1090:	00000097          	auipc	ra,0x0
    1094:	ea2080e7          	jalr	-350(ra) # f32 <printint>
    1098:	8bca                	mv	s7,s2
      state = 0;
    109a:	4981                	li	s3,0
    109c:	b751                	j	1020 <vprintf+0x42>
        printint(fd, va_arg(ap, int), 16, 0);
    109e:	008b8913          	addi	s2,s7,8
    10a2:	4681                	li	a3,0
    10a4:	4641                	li	a2,16
    10a6:	000ba583          	lw	a1,0(s7)
    10aa:	8556                	mv	a0,s5
    10ac:	00000097          	auipc	ra,0x0
    10b0:	e86080e7          	jalr	-378(ra) # f32 <printint>
    10b4:	8bca                	mv	s7,s2
      state = 0;
    10b6:	4981                	li	s3,0
    10b8:	b7a5                	j	1020 <vprintf+0x42>
    10ba:	e062                	sd	s8,0(sp)
        printptr(fd, va_arg(ap, uint64));
    10bc:	008b8c13          	addi	s8,s7,8
    10c0:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
    10c4:	03000593          	li	a1,48
    10c8:	8556                	mv	a0,s5
    10ca:	00000097          	auipc	ra,0x0
    10ce:	e46080e7          	jalr	-442(ra) # f10 <putc>
  putc(fd, 'x');
    10d2:	07800593          	li	a1,120
    10d6:	8556                	mv	a0,s5
    10d8:	00000097          	auipc	ra,0x0
    10dc:	e38080e7          	jalr	-456(ra) # f10 <putc>
    10e0:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    10e2:	00000b97          	auipc	s7,0x0
    10e6:	676b8b93          	addi	s7,s7,1654 # 1758 <digits>
    10ea:	03c9d793          	srli	a5,s3,0x3c
    10ee:	97de                	add	a5,a5,s7
    10f0:	0007c583          	lbu	a1,0(a5)
    10f4:	8556                	mv	a0,s5
    10f6:	00000097          	auipc	ra,0x0
    10fa:	e1a080e7          	jalr	-486(ra) # f10 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    10fe:	0992                	slli	s3,s3,0x4
    1100:	397d                	addiw	s2,s2,-1
    1102:	fe0914e3          	bnez	s2,10ea <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
    1106:	8be2                	mv	s7,s8
      state = 0;
    1108:	4981                	li	s3,0
    110a:	6c02                	ld	s8,0(sp)
    110c:	bf11                	j	1020 <vprintf+0x42>
        s = va_arg(ap, char*);
    110e:	008b8993          	addi	s3,s7,8
    1112:	000bb903          	ld	s2,0(s7)
        if(s == 0)
    1116:	02090163          	beqz	s2,1138 <vprintf+0x15a>
        while(*s != 0){
    111a:	00094583          	lbu	a1,0(s2)
    111e:	c9a5                	beqz	a1,118e <vprintf+0x1b0>
          putc(fd, *s);
    1120:	8556                	mv	a0,s5
    1122:	00000097          	auipc	ra,0x0
    1126:	dee080e7          	jalr	-530(ra) # f10 <putc>
          s++;
    112a:	0905                	addi	s2,s2,1
        while(*s != 0){
    112c:	00094583          	lbu	a1,0(s2)
    1130:	f9e5                	bnez	a1,1120 <vprintf+0x142>
        s = va_arg(ap, char*);
    1132:	8bce                	mv	s7,s3
      state = 0;
    1134:	4981                	li	s3,0
    1136:	b5ed                	j	1020 <vprintf+0x42>
          s = "(null)";
    1138:	00000917          	auipc	s2,0x0
    113c:	56090913          	addi	s2,s2,1376 # 1698 <malloc+0x408>
        while(*s != 0){
    1140:	02800593          	li	a1,40
    1144:	bff1                	j	1120 <vprintf+0x142>
        putc(fd, va_arg(ap, uint));
    1146:	008b8913          	addi	s2,s7,8
    114a:	000bc583          	lbu	a1,0(s7)
    114e:	8556                	mv	a0,s5
    1150:	00000097          	auipc	ra,0x0
    1154:	dc0080e7          	jalr	-576(ra) # f10 <putc>
    1158:	8bca                	mv	s7,s2
      state = 0;
    115a:	4981                	li	s3,0
    115c:	b5d1                	j	1020 <vprintf+0x42>
        putc(fd, c);
    115e:	02500593          	li	a1,37
    1162:	8556                	mv	a0,s5
    1164:	00000097          	auipc	ra,0x0
    1168:	dac080e7          	jalr	-596(ra) # f10 <putc>
      state = 0;
    116c:	4981                	li	s3,0
    116e:	bd4d                	j	1020 <vprintf+0x42>
        putc(fd, '%');
    1170:	02500593          	li	a1,37
    1174:	8556                	mv	a0,s5
    1176:	00000097          	auipc	ra,0x0
    117a:	d9a080e7          	jalr	-614(ra) # f10 <putc>
        putc(fd, c);
    117e:	85ca                	mv	a1,s2
    1180:	8556                	mv	a0,s5
    1182:	00000097          	auipc	ra,0x0
    1186:	d8e080e7          	jalr	-626(ra) # f10 <putc>
      state = 0;
    118a:	4981                	li	s3,0
    118c:	bd51                	j	1020 <vprintf+0x42>
        s = va_arg(ap, char*);
    118e:	8bce                	mv	s7,s3
      state = 0;
    1190:	4981                	li	s3,0
    1192:	b579                	j	1020 <vprintf+0x42>
    1194:	74e2                	ld	s1,56(sp)
    1196:	79a2                	ld	s3,40(sp)
    1198:	7a02                	ld	s4,32(sp)
    119a:	6ae2                	ld	s5,24(sp)
    119c:	6b42                	ld	s6,16(sp)
    119e:	6ba2                	ld	s7,8(sp)
    }
  }
}
    11a0:	60a6                	ld	ra,72(sp)
    11a2:	6406                	ld	s0,64(sp)
    11a4:	7942                	ld	s2,48(sp)
    11a6:	6161                	addi	sp,sp,80
    11a8:	8082                	ret

00000000000011aa <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
    11aa:	715d                	addi	sp,sp,-80
    11ac:	ec06                	sd	ra,24(sp)
    11ae:	e822                	sd	s0,16(sp)
    11b0:	1000                	addi	s0,sp,32
    11b2:	e010                	sd	a2,0(s0)
    11b4:	e414                	sd	a3,8(s0)
    11b6:	e818                	sd	a4,16(s0)
    11b8:	ec1c                	sd	a5,24(s0)
    11ba:	03043023          	sd	a6,32(s0)
    11be:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    11c2:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    11c6:	8622                	mv	a2,s0
    11c8:	00000097          	auipc	ra,0x0
    11cc:	e16080e7          	jalr	-490(ra) # fde <vprintf>
}
    11d0:	60e2                	ld	ra,24(sp)
    11d2:	6442                	ld	s0,16(sp)
    11d4:	6161                	addi	sp,sp,80
    11d6:	8082                	ret

00000000000011d8 <printf>:

void
printf(const char *fmt, ...)
{
    11d8:	711d                	addi	sp,sp,-96
    11da:	ec06                	sd	ra,24(sp)
    11dc:	e822                	sd	s0,16(sp)
    11de:	1000                	addi	s0,sp,32
    11e0:	e40c                	sd	a1,8(s0)
    11e2:	e810                	sd	a2,16(s0)
    11e4:	ec14                	sd	a3,24(s0)
    11e6:	f018                	sd	a4,32(s0)
    11e8:	f41c                	sd	a5,40(s0)
    11ea:	03043823          	sd	a6,48(s0)
    11ee:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    11f2:	00840613          	addi	a2,s0,8
    11f6:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    11fa:	85aa                	mv	a1,a0
    11fc:	4505                	li	a0,1
    11fe:	00000097          	auipc	ra,0x0
    1202:	de0080e7          	jalr	-544(ra) # fde <vprintf>
}
    1206:	60e2                	ld	ra,24(sp)
    1208:	6442                	ld	s0,16(sp)
    120a:	6125                	addi	sp,sp,96
    120c:	8082                	ret

000000000000120e <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    120e:	1141                	addi	sp,sp,-16
    1210:	e422                	sd	s0,8(sp)
    1212:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    1214:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    1218:	00001797          	auipc	a5,0x1
    121c:	df87b783          	ld	a5,-520(a5) # 2010 <freep>
    1220:	a02d                	j	124a <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    1222:	4618                	lw	a4,8(a2)
    1224:	9f2d                	addw	a4,a4,a1
    1226:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    122a:	6398                	ld	a4,0(a5)
    122c:	6310                	ld	a2,0(a4)
    122e:	a83d                	j	126c <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    1230:	ff852703          	lw	a4,-8(a0)
    1234:	9f31                	addw	a4,a4,a2
    1236:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
    1238:	ff053683          	ld	a3,-16(a0)
    123c:	a091                	j	1280 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    123e:	6398                	ld	a4,0(a5)
    1240:	00e7e463          	bltu	a5,a4,1248 <free+0x3a>
    1244:	00e6ea63          	bltu	a3,a4,1258 <free+0x4a>
{
    1248:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    124a:	fed7fae3          	bgeu	a5,a3,123e <free+0x30>
    124e:	6398                	ld	a4,0(a5)
    1250:	00e6e463          	bltu	a3,a4,1258 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    1254:	fee7eae3          	bltu	a5,a4,1248 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
    1258:	ff852583          	lw	a1,-8(a0)
    125c:	6390                	ld	a2,0(a5)
    125e:	02059813          	slli	a6,a1,0x20
    1262:	01c85713          	srli	a4,a6,0x1c
    1266:	9736                	add	a4,a4,a3
    1268:	fae60de3          	beq	a2,a4,1222 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
    126c:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    1270:	4790                	lw	a2,8(a5)
    1272:	02061593          	slli	a1,a2,0x20
    1276:	01c5d713          	srli	a4,a1,0x1c
    127a:	973e                	add	a4,a4,a5
    127c:	fae68ae3          	beq	a3,a4,1230 <free+0x22>
    p->s.ptr = bp->s.ptr;
    1280:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
    1282:	00001717          	auipc	a4,0x1
    1286:	d8f73723          	sd	a5,-626(a4) # 2010 <freep>
}
    128a:	6422                	ld	s0,8(sp)
    128c:	0141                	addi	sp,sp,16
    128e:	8082                	ret

0000000000001290 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    1290:	7139                	addi	sp,sp,-64
    1292:	fc06                	sd	ra,56(sp)
    1294:	f822                	sd	s0,48(sp)
    1296:	f426                	sd	s1,40(sp)
    1298:	ec4e                	sd	s3,24(sp)
    129a:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    129c:	02051493          	slli	s1,a0,0x20
    12a0:	9081                	srli	s1,s1,0x20
    12a2:	04bd                	addi	s1,s1,15
    12a4:	8091                	srli	s1,s1,0x4
    12a6:	0014899b          	addiw	s3,s1,1
    12aa:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
    12ac:	00001517          	auipc	a0,0x1
    12b0:	d6453503          	ld	a0,-668(a0) # 2010 <freep>
    12b4:	c915                	beqz	a0,12e8 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    12b6:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    12b8:	4798                	lw	a4,8(a5)
    12ba:	08977e63          	bgeu	a4,s1,1356 <malloc+0xc6>
    12be:	f04a                	sd	s2,32(sp)
    12c0:	e852                	sd	s4,16(sp)
    12c2:	e456                	sd	s5,8(sp)
    12c4:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
    12c6:	8a4e                	mv	s4,s3
    12c8:	0009871b          	sext.w	a4,s3
    12cc:	6685                	lui	a3,0x1
    12ce:	00d77363          	bgeu	a4,a3,12d4 <malloc+0x44>
    12d2:	6a05                	lui	s4,0x1
    12d4:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    12d8:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    12dc:	00001917          	auipc	s2,0x1
    12e0:	d3490913          	addi	s2,s2,-716 # 2010 <freep>
  if(p == (char*)-1)
    12e4:	5afd                	li	s5,-1
    12e6:	a091                	j	132a <malloc+0x9a>
    12e8:	f04a                	sd	s2,32(sp)
    12ea:	e852                	sd	s4,16(sp)
    12ec:	e456                	sd	s5,8(sp)
    12ee:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
    12f0:	00001797          	auipc	a5,0x1
    12f4:	11878793          	addi	a5,a5,280 # 2408 <base>
    12f8:	00001717          	auipc	a4,0x1
    12fc:	d0f73c23          	sd	a5,-744(a4) # 2010 <freep>
    1300:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    1302:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    1306:	b7c1                	j	12c6 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
    1308:	6398                	ld	a4,0(a5)
    130a:	e118                	sd	a4,0(a0)
    130c:	a08d                	j	136e <malloc+0xde>
  hp->s.size = nu;
    130e:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    1312:	0541                	addi	a0,a0,16
    1314:	00000097          	auipc	ra,0x0
    1318:	efa080e7          	jalr	-262(ra) # 120e <free>
  return freep;
    131c:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
    1320:	c13d                	beqz	a0,1386 <malloc+0xf6>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1322:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    1324:	4798                	lw	a4,8(a5)
    1326:	02977463          	bgeu	a4,s1,134e <malloc+0xbe>
    if(p == freep)
    132a:	00093703          	ld	a4,0(s2)
    132e:	853e                	mv	a0,a5
    1330:	fef719e3          	bne	a4,a5,1322 <malloc+0x92>
  p = sbrk(nu * sizeof(Header));
    1334:	8552                	mv	a0,s4
    1336:	00000097          	auipc	ra,0x0
    133a:	b92080e7          	jalr	-1134(ra) # ec8 <sbrk>
  if(p == (char*)-1)
    133e:	fd5518e3          	bne	a0,s5,130e <malloc+0x7e>
        return 0;
    1342:	4501                	li	a0,0
    1344:	7902                	ld	s2,32(sp)
    1346:	6a42                	ld	s4,16(sp)
    1348:	6aa2                	ld	s5,8(sp)
    134a:	6b02                	ld	s6,0(sp)
    134c:	a03d                	j	137a <malloc+0xea>
    134e:	7902                	ld	s2,32(sp)
    1350:	6a42                	ld	s4,16(sp)
    1352:	6aa2                	ld	s5,8(sp)
    1354:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
    1356:	fae489e3          	beq	s1,a4,1308 <malloc+0x78>
        p->s.size -= nunits;
    135a:	4137073b          	subw	a4,a4,s3
    135e:	c798                	sw	a4,8(a5)
        p += p->s.size;
    1360:	02071693          	slli	a3,a4,0x20
    1364:	01c6d713          	srli	a4,a3,0x1c
    1368:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    136a:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    136e:	00001717          	auipc	a4,0x1
    1372:	caa73123          	sd	a0,-862(a4) # 2010 <freep>
      return (void*)(p + 1);
    1376:	01078513          	addi	a0,a5,16
  }
}
    137a:	70e2                	ld	ra,56(sp)
    137c:	7442                	ld	s0,48(sp)
    137e:	74a2                	ld	s1,40(sp)
    1380:	69e2                	ld	s3,24(sp)
    1382:	6121                	addi	sp,sp,64
    1384:	8082                	ret
    1386:	7902                	ld	s2,32(sp)
    1388:	6a42                	ld	s4,16(sp)
    138a:	6aa2                	ld	s5,8(sp)
    138c:	6b02                	ld	s6,0(sp)
    138e:	b7f5                	j	137a <malloc+0xea>
