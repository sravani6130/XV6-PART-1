
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	c6010113          	addi	sp,sp,-928 # 80008c60 <stack0>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	076000ef          	jal	8000008c <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80000026:	0007859b          	sext.w	a1,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037979b          	slliw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	1761                	addi	a4,a4,-8 # 200bff8 <_entry-0x7dff4008>
    8000003a:	6318                	ld	a4,0(a4)
    8000003c:	000f4637          	lui	a2,0xf4
    80000040:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	9732                	add	a4,a4,a2
    80000046:	e398                	sd	a4,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00259693          	slli	a3,a1,0x2
    8000004c:	96ae                	add	a3,a3,a1
    8000004e:	068e                	slli	a3,a3,0x3
    80000050:	00009717          	auipc	a4,0x9
    80000054:	ad070713          	addi	a4,a4,-1328 # 80008b20 <timer_scratch>
    80000058:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    8000005a:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000005c:	f310                	sd	a2,32(a4)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    8000005e:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000062:	00006797          	auipc	a5,0x6
    80000066:	37e78793          	addi	a5,a5,894 # 800063e0 <timervec>
    8000006a:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000006e:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000072:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000076:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007a:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    8000007e:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000082:	30479073          	csrw	mie,a5
}
    80000086:	6422                	ld	s0,8(sp)
    80000088:	0141                	addi	sp,sp,16
    8000008a:	8082                	ret

000000008000008c <start>:
{
    8000008c:	1141                	addi	sp,sp,-16
    8000008e:	e406                	sd	ra,8(sp)
    80000090:	e022                	sd	s0,0(sp)
    80000092:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000094:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000098:	7779                	lui	a4,0xffffe
    8000009a:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffb1cdf>
    8000009e:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a0:	6705                	lui	a4,0x1
    800000a2:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a6:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000a8:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ac:	00001797          	auipc	a5,0x1
    800000b0:	e2678793          	addi	a5,a5,-474 # 80000ed2 <main>
    800000b4:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000b8:	4781                	li	a5,0
    800000ba:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000be:	67c1                	lui	a5,0x10
    800000c0:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    800000c2:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c6:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000ca:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000ce:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d2:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000d6:	57fd                	li	a5,-1
    800000d8:	83a9                	srli	a5,a5,0xa
    800000da:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000de:	47bd                	li	a5,15
    800000e0:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000e4:	00000097          	auipc	ra,0x0
    800000e8:	f38080e7          	jalr	-200(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000ec:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000f0:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000f2:	823e                	mv	tp,a5
  asm volatile("mret");
    800000f4:	30200073          	mret
}
    800000f8:	60a2                	ld	ra,8(sp)
    800000fa:	6402                	ld	s0,0(sp)
    800000fc:	0141                	addi	sp,sp,16
    800000fe:	8082                	ret

0000000080000100 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    80000100:	715d                	addi	sp,sp,-80
    80000102:	e486                	sd	ra,72(sp)
    80000104:	e0a2                	sd	s0,64(sp)
    80000106:	f84a                	sd	s2,48(sp)
    80000108:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    8000010a:	04c05663          	blez	a2,80000156 <consolewrite+0x56>
    8000010e:	fc26                	sd	s1,56(sp)
    80000110:	f44e                	sd	s3,40(sp)
    80000112:	f052                	sd	s4,32(sp)
    80000114:	ec56                	sd	s5,24(sp)
    80000116:	8a2a                	mv	s4,a0
    80000118:	84ae                	mv	s1,a1
    8000011a:	89b2                	mv	s3,a2
    8000011c:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    8000011e:	5afd                	li	s5,-1
    80000120:	4685                	li	a3,1
    80000122:	8626                	mv	a2,s1
    80000124:	85d2                	mv	a1,s4
    80000126:	fbf40513          	addi	a0,s0,-65
    8000012a:	00002097          	auipc	ra,0x2
    8000012e:	66e080e7          	jalr	1646(ra) # 80002798 <either_copyin>
    80000132:	03550463          	beq	a0,s5,8000015a <consolewrite+0x5a>
      break;
    uartputc(c);
    80000136:	fbf44503          	lbu	a0,-65(s0)
    8000013a:	00000097          	auipc	ra,0x0
    8000013e:	7e4080e7          	jalr	2020(ra) # 8000091e <uartputc>
  for(i = 0; i < n; i++){
    80000142:	2905                	addiw	s2,s2,1
    80000144:	0485                	addi	s1,s1,1
    80000146:	fd299de3          	bne	s3,s2,80000120 <consolewrite+0x20>
    8000014a:	894e                	mv	s2,s3
    8000014c:	74e2                	ld	s1,56(sp)
    8000014e:	79a2                	ld	s3,40(sp)
    80000150:	7a02                	ld	s4,32(sp)
    80000152:	6ae2                	ld	s5,24(sp)
    80000154:	a039                	j	80000162 <consolewrite+0x62>
    80000156:	4901                	li	s2,0
    80000158:	a029                	j	80000162 <consolewrite+0x62>
    8000015a:	74e2                	ld	s1,56(sp)
    8000015c:	79a2                	ld	s3,40(sp)
    8000015e:	7a02                	ld	s4,32(sp)
    80000160:	6ae2                	ld	s5,24(sp)
  }

  return i;
}
    80000162:	854a                	mv	a0,s2
    80000164:	60a6                	ld	ra,72(sp)
    80000166:	6406                	ld	s0,64(sp)
    80000168:	7942                	ld	s2,48(sp)
    8000016a:	6161                	addi	sp,sp,80
    8000016c:	8082                	ret

000000008000016e <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    8000016e:	711d                	addi	sp,sp,-96
    80000170:	ec86                	sd	ra,88(sp)
    80000172:	e8a2                	sd	s0,80(sp)
    80000174:	e4a6                	sd	s1,72(sp)
    80000176:	e0ca                	sd	s2,64(sp)
    80000178:	fc4e                	sd	s3,56(sp)
    8000017a:	f852                	sd	s4,48(sp)
    8000017c:	f456                	sd	s5,40(sp)
    8000017e:	f05a                	sd	s6,32(sp)
    80000180:	1080                	addi	s0,sp,96
    80000182:	8aaa                	mv	s5,a0
    80000184:	8a2e                	mv	s4,a1
    80000186:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000188:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    8000018c:	00011517          	auipc	a0,0x11
    80000190:	ad450513          	addi	a0,a0,-1324 # 80010c60 <cons>
    80000194:	00001097          	auipc	ra,0x1
    80000198:	aa4080e7          	jalr	-1372(ra) # 80000c38 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000019c:	00011497          	auipc	s1,0x11
    800001a0:	ac448493          	addi	s1,s1,-1340 # 80010c60 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a4:	00011917          	auipc	s2,0x11
    800001a8:	b5490913          	addi	s2,s2,-1196 # 80010cf8 <cons+0x98>
  while(n > 0){
    800001ac:	0d305763          	blez	s3,8000027a <consoleread+0x10c>
    while(cons.r == cons.w){
    800001b0:	0984a783          	lw	a5,152(s1)
    800001b4:	09c4a703          	lw	a4,156(s1)
    800001b8:	0af71c63          	bne	a4,a5,80000270 <consoleread+0x102>
      if(killed(myproc())){
    800001bc:	00002097          	auipc	ra,0x2
    800001c0:	96e080e7          	jalr	-1682(ra) # 80001b2a <myproc>
    800001c4:	00002097          	auipc	ra,0x2
    800001c8:	41e080e7          	jalr	1054(ra) # 800025e2 <killed>
    800001cc:	e52d                	bnez	a0,80000236 <consoleread+0xc8>
      sleep(&cons.r, &cons.lock);
    800001ce:	85a6                	mv	a1,s1
    800001d0:	854a                	mv	a0,s2
    800001d2:	00002097          	auipc	ra,0x2
    800001d6:	0c2080e7          	jalr	194(ra) # 80002294 <sleep>
    while(cons.r == cons.w){
    800001da:	0984a783          	lw	a5,152(s1)
    800001de:	09c4a703          	lw	a4,156(s1)
    800001e2:	fcf70de3          	beq	a4,a5,800001bc <consoleread+0x4e>
    800001e6:	ec5e                	sd	s7,24(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001e8:	00011717          	auipc	a4,0x11
    800001ec:	a7870713          	addi	a4,a4,-1416 # 80010c60 <cons>
    800001f0:	0017869b          	addiw	a3,a5,1
    800001f4:	08d72c23          	sw	a3,152(a4)
    800001f8:	07f7f693          	andi	a3,a5,127
    800001fc:	9736                	add	a4,a4,a3
    800001fe:	01874703          	lbu	a4,24(a4)
    80000202:	00070b9b          	sext.w	s7,a4

    if(c == C('D')){  // end-of-file
    80000206:	4691                	li	a3,4
    80000208:	04db8a63          	beq	s7,a3,8000025c <consoleread+0xee>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    8000020c:	fae407a3          	sb	a4,-81(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000210:	4685                	li	a3,1
    80000212:	faf40613          	addi	a2,s0,-81
    80000216:	85d2                	mv	a1,s4
    80000218:	8556                	mv	a0,s5
    8000021a:	00002097          	auipc	ra,0x2
    8000021e:	528080e7          	jalr	1320(ra) # 80002742 <either_copyout>
    80000222:	57fd                	li	a5,-1
    80000224:	04f50a63          	beq	a0,a5,80000278 <consoleread+0x10a>
      break;

    dst++;
    80000228:	0a05                	addi	s4,s4,1
    --n;
    8000022a:	39fd                	addiw	s3,s3,-1

    if(c == '\n'){
    8000022c:	47a9                	li	a5,10
    8000022e:	06fb8163          	beq	s7,a5,80000290 <consoleread+0x122>
    80000232:	6be2                	ld	s7,24(sp)
    80000234:	bfa5                	j	800001ac <consoleread+0x3e>
        release(&cons.lock);
    80000236:	00011517          	auipc	a0,0x11
    8000023a:	a2a50513          	addi	a0,a0,-1494 # 80010c60 <cons>
    8000023e:	00001097          	auipc	ra,0x1
    80000242:	aae080e7          	jalr	-1362(ra) # 80000cec <release>
        return -1;
    80000246:	557d                	li	a0,-1
    }
  }
  release(&cons.lock);

  return target - n;
}
    80000248:	60e6                	ld	ra,88(sp)
    8000024a:	6446                	ld	s0,80(sp)
    8000024c:	64a6                	ld	s1,72(sp)
    8000024e:	6906                	ld	s2,64(sp)
    80000250:	79e2                	ld	s3,56(sp)
    80000252:	7a42                	ld	s4,48(sp)
    80000254:	7aa2                	ld	s5,40(sp)
    80000256:	7b02                	ld	s6,32(sp)
    80000258:	6125                	addi	sp,sp,96
    8000025a:	8082                	ret
      if(n < target){
    8000025c:	0009871b          	sext.w	a4,s3
    80000260:	01677a63          	bgeu	a4,s6,80000274 <consoleread+0x106>
        cons.r--;
    80000264:	00011717          	auipc	a4,0x11
    80000268:	a8f72a23          	sw	a5,-1388(a4) # 80010cf8 <cons+0x98>
    8000026c:	6be2                	ld	s7,24(sp)
    8000026e:	a031                	j	8000027a <consoleread+0x10c>
    80000270:	ec5e                	sd	s7,24(sp)
    80000272:	bf9d                	j	800001e8 <consoleread+0x7a>
    80000274:	6be2                	ld	s7,24(sp)
    80000276:	a011                	j	8000027a <consoleread+0x10c>
    80000278:	6be2                	ld	s7,24(sp)
  release(&cons.lock);
    8000027a:	00011517          	auipc	a0,0x11
    8000027e:	9e650513          	addi	a0,a0,-1562 # 80010c60 <cons>
    80000282:	00001097          	auipc	ra,0x1
    80000286:	a6a080e7          	jalr	-1430(ra) # 80000cec <release>
  return target - n;
    8000028a:	413b053b          	subw	a0,s6,s3
    8000028e:	bf6d                	j	80000248 <consoleread+0xda>
    80000290:	6be2                	ld	s7,24(sp)
    80000292:	b7e5                	j	8000027a <consoleread+0x10c>

0000000080000294 <consputc>:
{
    80000294:	1141                	addi	sp,sp,-16
    80000296:	e406                	sd	ra,8(sp)
    80000298:	e022                	sd	s0,0(sp)
    8000029a:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    8000029c:	10000793          	li	a5,256
    800002a0:	00f50a63          	beq	a0,a5,800002b4 <consputc+0x20>
    uartputc_sync(c);
    800002a4:	00000097          	auipc	ra,0x0
    800002a8:	59c080e7          	jalr	1436(ra) # 80000840 <uartputc_sync>
}
    800002ac:	60a2                	ld	ra,8(sp)
    800002ae:	6402                	ld	s0,0(sp)
    800002b0:	0141                	addi	sp,sp,16
    800002b2:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    800002b4:	4521                	li	a0,8
    800002b6:	00000097          	auipc	ra,0x0
    800002ba:	58a080e7          	jalr	1418(ra) # 80000840 <uartputc_sync>
    800002be:	02000513          	li	a0,32
    800002c2:	00000097          	auipc	ra,0x0
    800002c6:	57e080e7          	jalr	1406(ra) # 80000840 <uartputc_sync>
    800002ca:	4521                	li	a0,8
    800002cc:	00000097          	auipc	ra,0x0
    800002d0:	574080e7          	jalr	1396(ra) # 80000840 <uartputc_sync>
    800002d4:	bfe1                	j	800002ac <consputc+0x18>

00000000800002d6 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002d6:	1101                	addi	sp,sp,-32
    800002d8:	ec06                	sd	ra,24(sp)
    800002da:	e822                	sd	s0,16(sp)
    800002dc:	e426                	sd	s1,8(sp)
    800002de:	1000                	addi	s0,sp,32
    800002e0:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002e2:	00011517          	auipc	a0,0x11
    800002e6:	97e50513          	addi	a0,a0,-1666 # 80010c60 <cons>
    800002ea:	00001097          	auipc	ra,0x1
    800002ee:	94e080e7          	jalr	-1714(ra) # 80000c38 <acquire>

  switch(c){
    800002f2:	47d5                	li	a5,21
    800002f4:	0af48563          	beq	s1,a5,8000039e <consoleintr+0xc8>
    800002f8:	0297c963          	blt	a5,s1,8000032a <consoleintr+0x54>
    800002fc:	47a1                	li	a5,8
    800002fe:	0ef48c63          	beq	s1,a5,800003f6 <consoleintr+0x120>
    80000302:	47c1                	li	a5,16
    80000304:	10f49f63          	bne	s1,a5,80000422 <consoleintr+0x14c>
  case C('P'):  // Print process list.
    procdump();
    80000308:	00002097          	auipc	ra,0x2
    8000030c:	4e6080e7          	jalr	1254(ra) # 800027ee <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    80000310:	00011517          	auipc	a0,0x11
    80000314:	95050513          	addi	a0,a0,-1712 # 80010c60 <cons>
    80000318:	00001097          	auipc	ra,0x1
    8000031c:	9d4080e7          	jalr	-1580(ra) # 80000cec <release>
}
    80000320:	60e2                	ld	ra,24(sp)
    80000322:	6442                	ld	s0,16(sp)
    80000324:	64a2                	ld	s1,8(sp)
    80000326:	6105                	addi	sp,sp,32
    80000328:	8082                	ret
  switch(c){
    8000032a:	07f00793          	li	a5,127
    8000032e:	0cf48463          	beq	s1,a5,800003f6 <consoleintr+0x120>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    80000332:	00011717          	auipc	a4,0x11
    80000336:	92e70713          	addi	a4,a4,-1746 # 80010c60 <cons>
    8000033a:	0a072783          	lw	a5,160(a4)
    8000033e:	09872703          	lw	a4,152(a4)
    80000342:	9f99                	subw	a5,a5,a4
    80000344:	07f00713          	li	a4,127
    80000348:	fcf764e3          	bltu	a4,a5,80000310 <consoleintr+0x3a>
      c = (c == '\r') ? '\n' : c;
    8000034c:	47b5                	li	a5,13
    8000034e:	0cf48d63          	beq	s1,a5,80000428 <consoleintr+0x152>
      consputc(c);
    80000352:	8526                	mv	a0,s1
    80000354:	00000097          	auipc	ra,0x0
    80000358:	f40080e7          	jalr	-192(ra) # 80000294 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    8000035c:	00011797          	auipc	a5,0x11
    80000360:	90478793          	addi	a5,a5,-1788 # 80010c60 <cons>
    80000364:	0a07a683          	lw	a3,160(a5)
    80000368:	0016871b          	addiw	a4,a3,1
    8000036c:	0007061b          	sext.w	a2,a4
    80000370:	0ae7a023          	sw	a4,160(a5)
    80000374:	07f6f693          	andi	a3,a3,127
    80000378:	97b6                	add	a5,a5,a3
    8000037a:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    8000037e:	47a9                	li	a5,10
    80000380:	0cf48b63          	beq	s1,a5,80000456 <consoleintr+0x180>
    80000384:	4791                	li	a5,4
    80000386:	0cf48863          	beq	s1,a5,80000456 <consoleintr+0x180>
    8000038a:	00011797          	auipc	a5,0x11
    8000038e:	96e7a783          	lw	a5,-1682(a5) # 80010cf8 <cons+0x98>
    80000392:	9f1d                	subw	a4,a4,a5
    80000394:	08000793          	li	a5,128
    80000398:	f6f71ce3          	bne	a4,a5,80000310 <consoleintr+0x3a>
    8000039c:	a86d                	j	80000456 <consoleintr+0x180>
    8000039e:	e04a                	sd	s2,0(sp)
    while(cons.e != cons.w &&
    800003a0:	00011717          	auipc	a4,0x11
    800003a4:	8c070713          	addi	a4,a4,-1856 # 80010c60 <cons>
    800003a8:	0a072783          	lw	a5,160(a4)
    800003ac:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800003b0:	00011497          	auipc	s1,0x11
    800003b4:	8b048493          	addi	s1,s1,-1872 # 80010c60 <cons>
    while(cons.e != cons.w &&
    800003b8:	4929                	li	s2,10
    800003ba:	02f70a63          	beq	a4,a5,800003ee <consoleintr+0x118>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800003be:	37fd                	addiw	a5,a5,-1
    800003c0:	07f7f713          	andi	a4,a5,127
    800003c4:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003c6:	01874703          	lbu	a4,24(a4)
    800003ca:	03270463          	beq	a4,s2,800003f2 <consoleintr+0x11c>
      cons.e--;
    800003ce:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003d2:	10000513          	li	a0,256
    800003d6:	00000097          	auipc	ra,0x0
    800003da:	ebe080e7          	jalr	-322(ra) # 80000294 <consputc>
    while(cons.e != cons.w &&
    800003de:	0a04a783          	lw	a5,160(s1)
    800003e2:	09c4a703          	lw	a4,156(s1)
    800003e6:	fcf71ce3          	bne	a4,a5,800003be <consoleintr+0xe8>
    800003ea:	6902                	ld	s2,0(sp)
    800003ec:	b715                	j	80000310 <consoleintr+0x3a>
    800003ee:	6902                	ld	s2,0(sp)
    800003f0:	b705                	j	80000310 <consoleintr+0x3a>
    800003f2:	6902                	ld	s2,0(sp)
    800003f4:	bf31                	j	80000310 <consoleintr+0x3a>
    if(cons.e != cons.w){
    800003f6:	00011717          	auipc	a4,0x11
    800003fa:	86a70713          	addi	a4,a4,-1942 # 80010c60 <cons>
    800003fe:	0a072783          	lw	a5,160(a4)
    80000402:	09c72703          	lw	a4,156(a4)
    80000406:	f0f705e3          	beq	a4,a5,80000310 <consoleintr+0x3a>
      cons.e--;
    8000040a:	37fd                	addiw	a5,a5,-1
    8000040c:	00011717          	auipc	a4,0x11
    80000410:	8ef72a23          	sw	a5,-1804(a4) # 80010d00 <cons+0xa0>
      consputc(BACKSPACE);
    80000414:	10000513          	li	a0,256
    80000418:	00000097          	auipc	ra,0x0
    8000041c:	e7c080e7          	jalr	-388(ra) # 80000294 <consputc>
    80000420:	bdc5                	j	80000310 <consoleintr+0x3a>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    80000422:	ee0487e3          	beqz	s1,80000310 <consoleintr+0x3a>
    80000426:	b731                	j	80000332 <consoleintr+0x5c>
      consputc(c);
    80000428:	4529                	li	a0,10
    8000042a:	00000097          	auipc	ra,0x0
    8000042e:	e6a080e7          	jalr	-406(ra) # 80000294 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000432:	00011797          	auipc	a5,0x11
    80000436:	82e78793          	addi	a5,a5,-2002 # 80010c60 <cons>
    8000043a:	0a07a703          	lw	a4,160(a5)
    8000043e:	0017069b          	addiw	a3,a4,1
    80000442:	0006861b          	sext.w	a2,a3
    80000446:	0ad7a023          	sw	a3,160(a5)
    8000044a:	07f77713          	andi	a4,a4,127
    8000044e:	97ba                	add	a5,a5,a4
    80000450:	4729                	li	a4,10
    80000452:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000456:	00011797          	auipc	a5,0x11
    8000045a:	8ac7a323          	sw	a2,-1882(a5) # 80010cfc <cons+0x9c>
        wakeup(&cons.r);
    8000045e:	00011517          	auipc	a0,0x11
    80000462:	89a50513          	addi	a0,a0,-1894 # 80010cf8 <cons+0x98>
    80000466:	00002097          	auipc	ra,0x2
    8000046a:	e92080e7          	jalr	-366(ra) # 800022f8 <wakeup>
    8000046e:	b54d                	j	80000310 <consoleintr+0x3a>

0000000080000470 <consoleinit>:

void
consoleinit(void)
{
    80000470:	1141                	addi	sp,sp,-16
    80000472:	e406                	sd	ra,8(sp)
    80000474:	e022                	sd	s0,0(sp)
    80000476:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000478:	00008597          	auipc	a1,0x8
    8000047c:	b8858593          	addi	a1,a1,-1144 # 80008000 <etext>
    80000480:	00010517          	auipc	a0,0x10
    80000484:	7e050513          	addi	a0,a0,2016 # 80010c60 <cons>
    80000488:	00000097          	auipc	ra,0x0
    8000048c:	720080e7          	jalr	1824(ra) # 80000ba8 <initlock>

  uartinit();
    80000490:	00000097          	auipc	ra,0x0
    80000494:	354080e7          	jalr	852(ra) # 800007e4 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000498:	0004b797          	auipc	a5,0x4b
    8000049c:	4f078793          	addi	a5,a5,1264 # 8004b988 <devsw>
    800004a0:	00000717          	auipc	a4,0x0
    800004a4:	cce70713          	addi	a4,a4,-818 # 8000016e <consoleread>
    800004a8:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    800004aa:	00000717          	auipc	a4,0x0
    800004ae:	c5670713          	addi	a4,a4,-938 # 80000100 <consolewrite>
    800004b2:	ef98                	sd	a4,24(a5)
}
    800004b4:	60a2                	ld	ra,8(sp)
    800004b6:	6402                	ld	s0,0(sp)
    800004b8:	0141                	addi	sp,sp,16
    800004ba:	8082                	ret

00000000800004bc <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    800004bc:	7179                	addi	sp,sp,-48
    800004be:	f406                	sd	ra,40(sp)
    800004c0:	f022                	sd	s0,32(sp)
    800004c2:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004c4:	c219                	beqz	a2,800004ca <printint+0xe>
    800004c6:	08054963          	bltz	a0,80000558 <printint+0x9c>
    x = -xx;
  else
    x = xx;
    800004ca:	2501                	sext.w	a0,a0
    800004cc:	4881                	li	a7,0
    800004ce:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004d2:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004d4:	2581                	sext.w	a1,a1
    800004d6:	00008617          	auipc	a2,0x8
    800004da:	3da60613          	addi	a2,a2,986 # 800088b0 <digits>
    800004de:	883a                	mv	a6,a4
    800004e0:	2705                	addiw	a4,a4,1
    800004e2:	02b577bb          	remuw	a5,a0,a1
    800004e6:	1782                	slli	a5,a5,0x20
    800004e8:	9381                	srli	a5,a5,0x20
    800004ea:	97b2                	add	a5,a5,a2
    800004ec:	0007c783          	lbu	a5,0(a5)
    800004f0:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004f4:	0005079b          	sext.w	a5,a0
    800004f8:	02b5553b          	divuw	a0,a0,a1
    800004fc:	0685                	addi	a3,a3,1
    800004fe:	feb7f0e3          	bgeu	a5,a1,800004de <printint+0x22>

  if(sign)
    80000502:	00088c63          	beqz	a7,8000051a <printint+0x5e>
    buf[i++] = '-';
    80000506:	fe070793          	addi	a5,a4,-32
    8000050a:	00878733          	add	a4,a5,s0
    8000050e:	02d00793          	li	a5,45
    80000512:	fef70823          	sb	a5,-16(a4)
    80000516:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    8000051a:	02e05b63          	blez	a4,80000550 <printint+0x94>
    8000051e:	ec26                	sd	s1,24(sp)
    80000520:	e84a                	sd	s2,16(sp)
    80000522:	fd040793          	addi	a5,s0,-48
    80000526:	00e784b3          	add	s1,a5,a4
    8000052a:	fff78913          	addi	s2,a5,-1
    8000052e:	993a                	add	s2,s2,a4
    80000530:	377d                	addiw	a4,a4,-1
    80000532:	1702                	slli	a4,a4,0x20
    80000534:	9301                	srli	a4,a4,0x20
    80000536:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    8000053a:	fff4c503          	lbu	a0,-1(s1)
    8000053e:	00000097          	auipc	ra,0x0
    80000542:	d56080e7          	jalr	-682(ra) # 80000294 <consputc>
  while(--i >= 0)
    80000546:	14fd                	addi	s1,s1,-1
    80000548:	ff2499e3          	bne	s1,s2,8000053a <printint+0x7e>
    8000054c:	64e2                	ld	s1,24(sp)
    8000054e:	6942                	ld	s2,16(sp)
}
    80000550:	70a2                	ld	ra,40(sp)
    80000552:	7402                	ld	s0,32(sp)
    80000554:	6145                	addi	sp,sp,48
    80000556:	8082                	ret
    x = -xx;
    80000558:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    8000055c:	4885                	li	a7,1
    x = -xx;
    8000055e:	bf85                	j	800004ce <printint+0x12>

0000000080000560 <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    80000560:	1101                	addi	sp,sp,-32
    80000562:	ec06                	sd	ra,24(sp)
    80000564:	e822                	sd	s0,16(sp)
    80000566:	e426                	sd	s1,8(sp)
    80000568:	1000                	addi	s0,sp,32
    8000056a:	84aa                	mv	s1,a0
  pr.locking = 0;
    8000056c:	00010797          	auipc	a5,0x10
    80000570:	7a07aa23          	sw	zero,1972(a5) # 80010d20 <pr+0x18>
  printf("panic: ");
    80000574:	00008517          	auipc	a0,0x8
    80000578:	a9450513          	addi	a0,a0,-1388 # 80008008 <etext+0x8>
    8000057c:	00000097          	auipc	ra,0x0
    80000580:	02e080e7          	jalr	46(ra) # 800005aa <printf>
  printf(s);
    80000584:	8526                	mv	a0,s1
    80000586:	00000097          	auipc	ra,0x0
    8000058a:	024080e7          	jalr	36(ra) # 800005aa <printf>
  printf("\n");
    8000058e:	00008517          	auipc	a0,0x8
    80000592:	a8250513          	addi	a0,a0,-1406 # 80008010 <etext+0x10>
    80000596:	00000097          	auipc	ra,0x0
    8000059a:	014080e7          	jalr	20(ra) # 800005aa <printf>
  panicked = 1; // freeze uart output from other CPUs
    8000059e:	4785                	li	a5,1
    800005a0:	00008717          	auipc	a4,0x8
    800005a4:	54f72023          	sw	a5,1344(a4) # 80008ae0 <panicked>
  for(;;)
    800005a8:	a001                	j	800005a8 <panic+0x48>

00000000800005aa <printf>:
{
    800005aa:	7131                	addi	sp,sp,-192
    800005ac:	fc86                	sd	ra,120(sp)
    800005ae:	f8a2                	sd	s0,112(sp)
    800005b0:	e8d2                	sd	s4,80(sp)
    800005b2:	f06a                	sd	s10,32(sp)
    800005b4:	0100                	addi	s0,sp,128
    800005b6:	8a2a                	mv	s4,a0
    800005b8:	e40c                	sd	a1,8(s0)
    800005ba:	e810                	sd	a2,16(s0)
    800005bc:	ec14                	sd	a3,24(s0)
    800005be:	f018                	sd	a4,32(s0)
    800005c0:	f41c                	sd	a5,40(s0)
    800005c2:	03043823          	sd	a6,48(s0)
    800005c6:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005ca:	00010d17          	auipc	s10,0x10
    800005ce:	756d2d03          	lw	s10,1878(s10) # 80010d20 <pr+0x18>
  if(locking)
    800005d2:	040d1463          	bnez	s10,8000061a <printf+0x70>
  if (fmt == 0)
    800005d6:	040a0b63          	beqz	s4,8000062c <printf+0x82>
  va_start(ap, fmt);
    800005da:	00840793          	addi	a5,s0,8
    800005de:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005e2:	000a4503          	lbu	a0,0(s4)
    800005e6:	18050b63          	beqz	a0,8000077c <printf+0x1d2>
    800005ea:	f4a6                	sd	s1,104(sp)
    800005ec:	f0ca                	sd	s2,96(sp)
    800005ee:	ecce                	sd	s3,88(sp)
    800005f0:	e4d6                	sd	s5,72(sp)
    800005f2:	e0da                	sd	s6,64(sp)
    800005f4:	fc5e                	sd	s7,56(sp)
    800005f6:	f862                	sd	s8,48(sp)
    800005f8:	f466                	sd	s9,40(sp)
    800005fa:	ec6e                	sd	s11,24(sp)
    800005fc:	4981                	li	s3,0
    if(c != '%'){
    800005fe:	02500b13          	li	s6,37
    switch(c){
    80000602:	07000b93          	li	s7,112
  consputc('x');
    80000606:	4cc1                	li	s9,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    80000608:	00008a97          	auipc	s5,0x8
    8000060c:	2a8a8a93          	addi	s5,s5,680 # 800088b0 <digits>
    switch(c){
    80000610:	07300c13          	li	s8,115
    80000614:	06400d93          	li	s11,100
    80000618:	a0b1                	j	80000664 <printf+0xba>
    acquire(&pr.lock);
    8000061a:	00010517          	auipc	a0,0x10
    8000061e:	6ee50513          	addi	a0,a0,1774 # 80010d08 <pr>
    80000622:	00000097          	auipc	ra,0x0
    80000626:	616080e7          	jalr	1558(ra) # 80000c38 <acquire>
    8000062a:	b775                	j	800005d6 <printf+0x2c>
    8000062c:	f4a6                	sd	s1,104(sp)
    8000062e:	f0ca                	sd	s2,96(sp)
    80000630:	ecce                	sd	s3,88(sp)
    80000632:	e4d6                	sd	s5,72(sp)
    80000634:	e0da                	sd	s6,64(sp)
    80000636:	fc5e                	sd	s7,56(sp)
    80000638:	f862                	sd	s8,48(sp)
    8000063a:	f466                	sd	s9,40(sp)
    8000063c:	ec6e                	sd	s11,24(sp)
    panic("null fmt");
    8000063e:	00008517          	auipc	a0,0x8
    80000642:	9e250513          	addi	a0,a0,-1566 # 80008020 <etext+0x20>
    80000646:	00000097          	auipc	ra,0x0
    8000064a:	f1a080e7          	jalr	-230(ra) # 80000560 <panic>
      consputc(c);
    8000064e:	00000097          	auipc	ra,0x0
    80000652:	c46080e7          	jalr	-954(ra) # 80000294 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000656:	2985                	addiw	s3,s3,1
    80000658:	013a07b3          	add	a5,s4,s3
    8000065c:	0007c503          	lbu	a0,0(a5)
    80000660:	10050563          	beqz	a0,8000076a <printf+0x1c0>
    if(c != '%'){
    80000664:	ff6515e3          	bne	a0,s6,8000064e <printf+0xa4>
    c = fmt[++i] & 0xff;
    80000668:	2985                	addiw	s3,s3,1
    8000066a:	013a07b3          	add	a5,s4,s3
    8000066e:	0007c783          	lbu	a5,0(a5)
    80000672:	0007849b          	sext.w	s1,a5
    if(c == 0)
    80000676:	10078b63          	beqz	a5,8000078c <printf+0x1e2>
    switch(c){
    8000067a:	05778a63          	beq	a5,s7,800006ce <printf+0x124>
    8000067e:	02fbf663          	bgeu	s7,a5,800006aa <printf+0x100>
    80000682:	09878863          	beq	a5,s8,80000712 <printf+0x168>
    80000686:	07800713          	li	a4,120
    8000068a:	0ce79563          	bne	a5,a4,80000754 <printf+0x1aa>
      printint(va_arg(ap, int), 16, 1);
    8000068e:	f8843783          	ld	a5,-120(s0)
    80000692:	00878713          	addi	a4,a5,8
    80000696:	f8e43423          	sd	a4,-120(s0)
    8000069a:	4605                	li	a2,1
    8000069c:	85e6                	mv	a1,s9
    8000069e:	4388                	lw	a0,0(a5)
    800006a0:	00000097          	auipc	ra,0x0
    800006a4:	e1c080e7          	jalr	-484(ra) # 800004bc <printint>
      break;
    800006a8:	b77d                	j	80000656 <printf+0xac>
    switch(c){
    800006aa:	09678f63          	beq	a5,s6,80000748 <printf+0x19e>
    800006ae:	0bb79363          	bne	a5,s11,80000754 <printf+0x1aa>
      printint(va_arg(ap, int), 10, 1);
    800006b2:	f8843783          	ld	a5,-120(s0)
    800006b6:	00878713          	addi	a4,a5,8
    800006ba:	f8e43423          	sd	a4,-120(s0)
    800006be:	4605                	li	a2,1
    800006c0:	45a9                	li	a1,10
    800006c2:	4388                	lw	a0,0(a5)
    800006c4:	00000097          	auipc	ra,0x0
    800006c8:	df8080e7          	jalr	-520(ra) # 800004bc <printint>
      break;
    800006cc:	b769                	j	80000656 <printf+0xac>
      printptr(va_arg(ap, uint64));
    800006ce:	f8843783          	ld	a5,-120(s0)
    800006d2:	00878713          	addi	a4,a5,8
    800006d6:	f8e43423          	sd	a4,-120(s0)
    800006da:	0007b903          	ld	s2,0(a5)
  consputc('0');
    800006de:	03000513          	li	a0,48
    800006e2:	00000097          	auipc	ra,0x0
    800006e6:	bb2080e7          	jalr	-1102(ra) # 80000294 <consputc>
  consputc('x');
    800006ea:	07800513          	li	a0,120
    800006ee:	00000097          	auipc	ra,0x0
    800006f2:	ba6080e7          	jalr	-1114(ra) # 80000294 <consputc>
    800006f6:	84e6                	mv	s1,s9
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006f8:	03c95793          	srli	a5,s2,0x3c
    800006fc:	97d6                	add	a5,a5,s5
    800006fe:	0007c503          	lbu	a0,0(a5)
    80000702:	00000097          	auipc	ra,0x0
    80000706:	b92080e7          	jalr	-1134(ra) # 80000294 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    8000070a:	0912                	slli	s2,s2,0x4
    8000070c:	34fd                	addiw	s1,s1,-1
    8000070e:	f4ed                	bnez	s1,800006f8 <printf+0x14e>
    80000710:	b799                	j	80000656 <printf+0xac>
      if((s = va_arg(ap, char*)) == 0)
    80000712:	f8843783          	ld	a5,-120(s0)
    80000716:	00878713          	addi	a4,a5,8
    8000071a:	f8e43423          	sd	a4,-120(s0)
    8000071e:	6384                	ld	s1,0(a5)
    80000720:	cc89                	beqz	s1,8000073a <printf+0x190>
      for(; *s; s++)
    80000722:	0004c503          	lbu	a0,0(s1)
    80000726:	d905                	beqz	a0,80000656 <printf+0xac>
        consputc(*s);
    80000728:	00000097          	auipc	ra,0x0
    8000072c:	b6c080e7          	jalr	-1172(ra) # 80000294 <consputc>
      for(; *s; s++)
    80000730:	0485                	addi	s1,s1,1
    80000732:	0004c503          	lbu	a0,0(s1)
    80000736:	f96d                	bnez	a0,80000728 <printf+0x17e>
    80000738:	bf39                	j	80000656 <printf+0xac>
        s = "(null)";
    8000073a:	00008497          	auipc	s1,0x8
    8000073e:	8de48493          	addi	s1,s1,-1826 # 80008018 <etext+0x18>
      for(; *s; s++)
    80000742:	02800513          	li	a0,40
    80000746:	b7cd                	j	80000728 <printf+0x17e>
      consputc('%');
    80000748:	855a                	mv	a0,s6
    8000074a:	00000097          	auipc	ra,0x0
    8000074e:	b4a080e7          	jalr	-1206(ra) # 80000294 <consputc>
      break;
    80000752:	b711                	j	80000656 <printf+0xac>
      consputc('%');
    80000754:	855a                	mv	a0,s6
    80000756:	00000097          	auipc	ra,0x0
    8000075a:	b3e080e7          	jalr	-1218(ra) # 80000294 <consputc>
      consputc(c);
    8000075e:	8526                	mv	a0,s1
    80000760:	00000097          	auipc	ra,0x0
    80000764:	b34080e7          	jalr	-1228(ra) # 80000294 <consputc>
      break;
    80000768:	b5fd                	j	80000656 <printf+0xac>
    8000076a:	74a6                	ld	s1,104(sp)
    8000076c:	7906                	ld	s2,96(sp)
    8000076e:	69e6                	ld	s3,88(sp)
    80000770:	6aa6                	ld	s5,72(sp)
    80000772:	6b06                	ld	s6,64(sp)
    80000774:	7be2                	ld	s7,56(sp)
    80000776:	7c42                	ld	s8,48(sp)
    80000778:	7ca2                	ld	s9,40(sp)
    8000077a:	6de2                	ld	s11,24(sp)
  if(locking)
    8000077c:	020d1263          	bnez	s10,800007a0 <printf+0x1f6>
}
    80000780:	70e6                	ld	ra,120(sp)
    80000782:	7446                	ld	s0,112(sp)
    80000784:	6a46                	ld	s4,80(sp)
    80000786:	7d02                	ld	s10,32(sp)
    80000788:	6129                	addi	sp,sp,192
    8000078a:	8082                	ret
    8000078c:	74a6                	ld	s1,104(sp)
    8000078e:	7906                	ld	s2,96(sp)
    80000790:	69e6                	ld	s3,88(sp)
    80000792:	6aa6                	ld	s5,72(sp)
    80000794:	6b06                	ld	s6,64(sp)
    80000796:	7be2                	ld	s7,56(sp)
    80000798:	7c42                	ld	s8,48(sp)
    8000079a:	7ca2                	ld	s9,40(sp)
    8000079c:	6de2                	ld	s11,24(sp)
    8000079e:	bff9                	j	8000077c <printf+0x1d2>
    release(&pr.lock);
    800007a0:	00010517          	auipc	a0,0x10
    800007a4:	56850513          	addi	a0,a0,1384 # 80010d08 <pr>
    800007a8:	00000097          	auipc	ra,0x0
    800007ac:	544080e7          	jalr	1348(ra) # 80000cec <release>
}
    800007b0:	bfc1                	j	80000780 <printf+0x1d6>

00000000800007b2 <printfinit>:
    ;
}

void
printfinit(void)
{
    800007b2:	1101                	addi	sp,sp,-32
    800007b4:	ec06                	sd	ra,24(sp)
    800007b6:	e822                	sd	s0,16(sp)
    800007b8:	e426                	sd	s1,8(sp)
    800007ba:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    800007bc:	00010497          	auipc	s1,0x10
    800007c0:	54c48493          	addi	s1,s1,1356 # 80010d08 <pr>
    800007c4:	00008597          	auipc	a1,0x8
    800007c8:	86c58593          	addi	a1,a1,-1940 # 80008030 <etext+0x30>
    800007cc:	8526                	mv	a0,s1
    800007ce:	00000097          	auipc	ra,0x0
    800007d2:	3da080e7          	jalr	986(ra) # 80000ba8 <initlock>
  pr.locking = 1;
    800007d6:	4785                	li	a5,1
    800007d8:	cc9c                	sw	a5,24(s1)
}
    800007da:	60e2                	ld	ra,24(sp)
    800007dc:	6442                	ld	s0,16(sp)
    800007de:	64a2                	ld	s1,8(sp)
    800007e0:	6105                	addi	sp,sp,32
    800007e2:	8082                	ret

00000000800007e4 <uartinit>:

void uartstart();

void
uartinit(void)
{
    800007e4:	1141                	addi	sp,sp,-16
    800007e6:	e406                	sd	ra,8(sp)
    800007e8:	e022                	sd	s0,0(sp)
    800007ea:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007ec:	100007b7          	lui	a5,0x10000
    800007f0:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007f4:	10000737          	lui	a4,0x10000
    800007f8:	f8000693          	li	a3,-128
    800007fc:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    80000800:	468d                	li	a3,3
    80000802:	10000637          	lui	a2,0x10000
    80000806:	00d60023          	sb	a3,0(a2) # 10000000 <_entry-0x70000000>

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    8000080a:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    8000080e:	00d701a3          	sb	a3,3(a4)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    80000812:	10000737          	lui	a4,0x10000
    80000816:	461d                	li	a2,7
    80000818:	00c70123          	sb	a2,2(a4) # 10000002 <_entry-0x6ffffffe>

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    8000081c:	00d780a3          	sb	a3,1(a5)

  initlock(&uart_tx_lock, "uart");
    80000820:	00008597          	auipc	a1,0x8
    80000824:	81858593          	addi	a1,a1,-2024 # 80008038 <etext+0x38>
    80000828:	00010517          	auipc	a0,0x10
    8000082c:	50050513          	addi	a0,a0,1280 # 80010d28 <uart_tx_lock>
    80000830:	00000097          	auipc	ra,0x0
    80000834:	378080e7          	jalr	888(ra) # 80000ba8 <initlock>
}
    80000838:	60a2                	ld	ra,8(sp)
    8000083a:	6402                	ld	s0,0(sp)
    8000083c:	0141                	addi	sp,sp,16
    8000083e:	8082                	ret

0000000080000840 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    80000840:	1101                	addi	sp,sp,-32
    80000842:	ec06                	sd	ra,24(sp)
    80000844:	e822                	sd	s0,16(sp)
    80000846:	e426                	sd	s1,8(sp)
    80000848:	1000                	addi	s0,sp,32
    8000084a:	84aa                	mv	s1,a0
  push_off();
    8000084c:	00000097          	auipc	ra,0x0
    80000850:	3a0080e7          	jalr	928(ra) # 80000bec <push_off>

  if(panicked){
    80000854:	00008797          	auipc	a5,0x8
    80000858:	28c7a783          	lw	a5,652(a5) # 80008ae0 <panicked>
    8000085c:	eb85                	bnez	a5,8000088c <uartputc_sync+0x4c>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000085e:	10000737          	lui	a4,0x10000
    80000862:	0715                	addi	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    80000864:	00074783          	lbu	a5,0(a4)
    80000868:	0207f793          	andi	a5,a5,32
    8000086c:	dfe5                	beqz	a5,80000864 <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    8000086e:	0ff4f513          	zext.b	a0,s1
    80000872:	100007b7          	lui	a5,0x10000
    80000876:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    8000087a:	00000097          	auipc	ra,0x0
    8000087e:	412080e7          	jalr	1042(ra) # 80000c8c <pop_off>
}
    80000882:	60e2                	ld	ra,24(sp)
    80000884:	6442                	ld	s0,16(sp)
    80000886:	64a2                	ld	s1,8(sp)
    80000888:	6105                	addi	sp,sp,32
    8000088a:	8082                	ret
    for(;;)
    8000088c:	a001                	j	8000088c <uartputc_sync+0x4c>

000000008000088e <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    8000088e:	00008797          	auipc	a5,0x8
    80000892:	25a7b783          	ld	a5,602(a5) # 80008ae8 <uart_tx_r>
    80000896:	00008717          	auipc	a4,0x8
    8000089a:	25a73703          	ld	a4,602(a4) # 80008af0 <uart_tx_w>
    8000089e:	06f70f63          	beq	a4,a5,8000091c <uartstart+0x8e>
{
    800008a2:	7139                	addi	sp,sp,-64
    800008a4:	fc06                	sd	ra,56(sp)
    800008a6:	f822                	sd	s0,48(sp)
    800008a8:	f426                	sd	s1,40(sp)
    800008aa:	f04a                	sd	s2,32(sp)
    800008ac:	ec4e                	sd	s3,24(sp)
    800008ae:	e852                	sd	s4,16(sp)
    800008b0:	e456                	sd	s5,8(sp)
    800008b2:	e05a                	sd	s6,0(sp)
    800008b4:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800008b6:	10000937          	lui	s2,0x10000
    800008ba:	0915                	addi	s2,s2,5 # 10000005 <_entry-0x6ffffffb>
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800008bc:	00010a97          	auipc	s5,0x10
    800008c0:	46ca8a93          	addi	s5,s5,1132 # 80010d28 <uart_tx_lock>
    uart_tx_r += 1;
    800008c4:	00008497          	auipc	s1,0x8
    800008c8:	22448493          	addi	s1,s1,548 # 80008ae8 <uart_tx_r>
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    
    WriteReg(THR, c);
    800008cc:	10000a37          	lui	s4,0x10000
    if(uart_tx_w == uart_tx_r){
    800008d0:	00008997          	auipc	s3,0x8
    800008d4:	22098993          	addi	s3,s3,544 # 80008af0 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800008d8:	00094703          	lbu	a4,0(s2)
    800008dc:	02077713          	andi	a4,a4,32
    800008e0:	c705                	beqz	a4,80000908 <uartstart+0x7a>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800008e2:	01f7f713          	andi	a4,a5,31
    800008e6:	9756                	add	a4,a4,s5
    800008e8:	01874b03          	lbu	s6,24(a4)
    uart_tx_r += 1;
    800008ec:	0785                	addi	a5,a5,1
    800008ee:	e09c                	sd	a5,0(s1)
    wakeup(&uart_tx_r);
    800008f0:	8526                	mv	a0,s1
    800008f2:	00002097          	auipc	ra,0x2
    800008f6:	a06080e7          	jalr	-1530(ra) # 800022f8 <wakeup>
    WriteReg(THR, c);
    800008fa:	016a0023          	sb	s6,0(s4) # 10000000 <_entry-0x70000000>
    if(uart_tx_w == uart_tx_r){
    800008fe:	609c                	ld	a5,0(s1)
    80000900:	0009b703          	ld	a4,0(s3)
    80000904:	fcf71ae3          	bne	a4,a5,800008d8 <uartstart+0x4a>
  }
}
    80000908:	70e2                	ld	ra,56(sp)
    8000090a:	7442                	ld	s0,48(sp)
    8000090c:	74a2                	ld	s1,40(sp)
    8000090e:	7902                	ld	s2,32(sp)
    80000910:	69e2                	ld	s3,24(sp)
    80000912:	6a42                	ld	s4,16(sp)
    80000914:	6aa2                	ld	s5,8(sp)
    80000916:	6b02                	ld	s6,0(sp)
    80000918:	6121                	addi	sp,sp,64
    8000091a:	8082                	ret
    8000091c:	8082                	ret

000000008000091e <uartputc>:
{
    8000091e:	7179                	addi	sp,sp,-48
    80000920:	f406                	sd	ra,40(sp)
    80000922:	f022                	sd	s0,32(sp)
    80000924:	ec26                	sd	s1,24(sp)
    80000926:	e84a                	sd	s2,16(sp)
    80000928:	e44e                	sd	s3,8(sp)
    8000092a:	e052                	sd	s4,0(sp)
    8000092c:	1800                	addi	s0,sp,48
    8000092e:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    80000930:	00010517          	auipc	a0,0x10
    80000934:	3f850513          	addi	a0,a0,1016 # 80010d28 <uart_tx_lock>
    80000938:	00000097          	auipc	ra,0x0
    8000093c:	300080e7          	jalr	768(ra) # 80000c38 <acquire>
  if(panicked){
    80000940:	00008797          	auipc	a5,0x8
    80000944:	1a07a783          	lw	a5,416(a5) # 80008ae0 <panicked>
    80000948:	e7c9                	bnez	a5,800009d2 <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000094a:	00008717          	auipc	a4,0x8
    8000094e:	1a673703          	ld	a4,422(a4) # 80008af0 <uart_tx_w>
    80000952:	00008797          	auipc	a5,0x8
    80000956:	1967b783          	ld	a5,406(a5) # 80008ae8 <uart_tx_r>
    8000095a:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    8000095e:	00010997          	auipc	s3,0x10
    80000962:	3ca98993          	addi	s3,s3,970 # 80010d28 <uart_tx_lock>
    80000966:	00008497          	auipc	s1,0x8
    8000096a:	18248493          	addi	s1,s1,386 # 80008ae8 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000096e:	00008917          	auipc	s2,0x8
    80000972:	18290913          	addi	s2,s2,386 # 80008af0 <uart_tx_w>
    80000976:	00e79f63          	bne	a5,a4,80000994 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    8000097a:	85ce                	mv	a1,s3
    8000097c:	8526                	mv	a0,s1
    8000097e:	00002097          	auipc	ra,0x2
    80000982:	916080e7          	jalr	-1770(ra) # 80002294 <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000986:	00093703          	ld	a4,0(s2)
    8000098a:	609c                	ld	a5,0(s1)
    8000098c:	02078793          	addi	a5,a5,32
    80000990:	fee785e3          	beq	a5,a4,8000097a <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000994:	00010497          	auipc	s1,0x10
    80000998:	39448493          	addi	s1,s1,916 # 80010d28 <uart_tx_lock>
    8000099c:	01f77793          	andi	a5,a4,31
    800009a0:	97a6                	add	a5,a5,s1
    800009a2:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    800009a6:	0705                	addi	a4,a4,1
    800009a8:	00008797          	auipc	a5,0x8
    800009ac:	14e7b423          	sd	a4,328(a5) # 80008af0 <uart_tx_w>
  uartstart();
    800009b0:	00000097          	auipc	ra,0x0
    800009b4:	ede080e7          	jalr	-290(ra) # 8000088e <uartstart>
  release(&uart_tx_lock);
    800009b8:	8526                	mv	a0,s1
    800009ba:	00000097          	auipc	ra,0x0
    800009be:	332080e7          	jalr	818(ra) # 80000cec <release>
}
    800009c2:	70a2                	ld	ra,40(sp)
    800009c4:	7402                	ld	s0,32(sp)
    800009c6:	64e2                	ld	s1,24(sp)
    800009c8:	6942                	ld	s2,16(sp)
    800009ca:	69a2                	ld	s3,8(sp)
    800009cc:	6a02                	ld	s4,0(sp)
    800009ce:	6145                	addi	sp,sp,48
    800009d0:	8082                	ret
    for(;;)
    800009d2:	a001                	j	800009d2 <uartputc+0xb4>

00000000800009d4 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    800009d4:	1141                	addi	sp,sp,-16
    800009d6:	e422                	sd	s0,8(sp)
    800009d8:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    800009da:	100007b7          	lui	a5,0x10000
    800009de:	0795                	addi	a5,a5,5 # 10000005 <_entry-0x6ffffffb>
    800009e0:	0007c783          	lbu	a5,0(a5)
    800009e4:	8b85                	andi	a5,a5,1
    800009e6:	cb81                	beqz	a5,800009f6 <uartgetc+0x22>
    // input data is ready.
    return ReadReg(RHR);
    800009e8:	100007b7          	lui	a5,0x10000
    800009ec:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    800009f0:	6422                	ld	s0,8(sp)
    800009f2:	0141                	addi	sp,sp,16
    800009f4:	8082                	ret
    return -1;
    800009f6:	557d                	li	a0,-1
    800009f8:	bfe5                	j	800009f0 <uartgetc+0x1c>

00000000800009fa <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    800009fa:	1101                	addi	sp,sp,-32
    800009fc:	ec06                	sd	ra,24(sp)
    800009fe:	e822                	sd	s0,16(sp)
    80000a00:	e426                	sd	s1,8(sp)
    80000a02:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    80000a04:	54fd                	li	s1,-1
    80000a06:	a029                	j	80000a10 <uartintr+0x16>
      break;
    consoleintr(c);
    80000a08:	00000097          	auipc	ra,0x0
    80000a0c:	8ce080e7          	jalr	-1842(ra) # 800002d6 <consoleintr>
    int c = uartgetc();
    80000a10:	00000097          	auipc	ra,0x0
    80000a14:	fc4080e7          	jalr	-60(ra) # 800009d4 <uartgetc>
    if(c == -1)
    80000a18:	fe9518e3          	bne	a0,s1,80000a08 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    80000a1c:	00010497          	auipc	s1,0x10
    80000a20:	30c48493          	addi	s1,s1,780 # 80010d28 <uart_tx_lock>
    80000a24:	8526                	mv	a0,s1
    80000a26:	00000097          	auipc	ra,0x0
    80000a2a:	212080e7          	jalr	530(ra) # 80000c38 <acquire>
  uartstart();
    80000a2e:	00000097          	auipc	ra,0x0
    80000a32:	e60080e7          	jalr	-416(ra) # 8000088e <uartstart>
  release(&uart_tx_lock);
    80000a36:	8526                	mv	a0,s1
    80000a38:	00000097          	auipc	ra,0x0
    80000a3c:	2b4080e7          	jalr	692(ra) # 80000cec <release>
}
    80000a40:	60e2                	ld	ra,24(sp)
    80000a42:	6442                	ld	s0,16(sp)
    80000a44:	64a2                	ld	s1,8(sp)
    80000a46:	6105                	addi	sp,sp,32
    80000a48:	8082                	ret

0000000080000a4a <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000a4a:	1101                	addi	sp,sp,-32
    80000a4c:	ec06                	sd	ra,24(sp)
    80000a4e:	e822                	sd	s0,16(sp)
    80000a50:	e426                	sd	s1,8(sp)
    80000a52:	e04a                	sd	s2,0(sp)
    80000a54:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a56:	03451793          	slli	a5,a0,0x34
    80000a5a:	ebb9                	bnez	a5,80000ab0 <kfree+0x66>
    80000a5c:	84aa                	mv	s1,a0
    80000a5e:	0004c797          	auipc	a5,0x4c
    80000a62:	0c278793          	addi	a5,a5,194 # 8004cb20 <end>
    80000a66:	04f56563          	bltu	a0,a5,80000ab0 <kfree+0x66>
    80000a6a:	47c5                	li	a5,17
    80000a6c:	07ee                	slli	a5,a5,0x1b
    80000a6e:	04f57163          	bgeu	a0,a5,80000ab0 <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a72:	6605                	lui	a2,0x1
    80000a74:	4585                	li	a1,1
    80000a76:	00000097          	auipc	ra,0x0
    80000a7a:	2be080e7          	jalr	702(ra) # 80000d34 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a7e:	00010917          	auipc	s2,0x10
    80000a82:	2e290913          	addi	s2,s2,738 # 80010d60 <kmem>
    80000a86:	854a                	mv	a0,s2
    80000a88:	00000097          	auipc	ra,0x0
    80000a8c:	1b0080e7          	jalr	432(ra) # 80000c38 <acquire>
  r->next = kmem.freelist;
    80000a90:	01893783          	ld	a5,24(s2)
    80000a94:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a96:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a9a:	854a                	mv	a0,s2
    80000a9c:	00000097          	auipc	ra,0x0
    80000aa0:	250080e7          	jalr	592(ra) # 80000cec <release>
}
    80000aa4:	60e2                	ld	ra,24(sp)
    80000aa6:	6442                	ld	s0,16(sp)
    80000aa8:	64a2                	ld	s1,8(sp)
    80000aaa:	6902                	ld	s2,0(sp)
    80000aac:	6105                	addi	sp,sp,32
    80000aae:	8082                	ret
    panic("kfree");
    80000ab0:	00007517          	auipc	a0,0x7
    80000ab4:	59050513          	addi	a0,a0,1424 # 80008040 <etext+0x40>
    80000ab8:	00000097          	auipc	ra,0x0
    80000abc:	aa8080e7          	jalr	-1368(ra) # 80000560 <panic>

0000000080000ac0 <freerange>:
{
    80000ac0:	7179                	addi	sp,sp,-48
    80000ac2:	f406                	sd	ra,40(sp)
    80000ac4:	f022                	sd	s0,32(sp)
    80000ac6:	ec26                	sd	s1,24(sp)
    80000ac8:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000aca:	6785                	lui	a5,0x1
    80000acc:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000ad0:	00e504b3          	add	s1,a0,a4
    80000ad4:	777d                	lui	a4,0xfffff
    80000ad6:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ad8:	94be                	add	s1,s1,a5
    80000ada:	0295e463          	bltu	a1,s1,80000b02 <freerange+0x42>
    80000ade:	e84a                	sd	s2,16(sp)
    80000ae0:	e44e                	sd	s3,8(sp)
    80000ae2:	e052                	sd	s4,0(sp)
    80000ae4:	892e                	mv	s2,a1
    kfree(p);
    80000ae6:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ae8:	6985                	lui	s3,0x1
    kfree(p);
    80000aea:	01448533          	add	a0,s1,s4
    80000aee:	00000097          	auipc	ra,0x0
    80000af2:	f5c080e7          	jalr	-164(ra) # 80000a4a <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000af6:	94ce                	add	s1,s1,s3
    80000af8:	fe9979e3          	bgeu	s2,s1,80000aea <freerange+0x2a>
    80000afc:	6942                	ld	s2,16(sp)
    80000afe:	69a2                	ld	s3,8(sp)
    80000b00:	6a02                	ld	s4,0(sp)
}
    80000b02:	70a2                	ld	ra,40(sp)
    80000b04:	7402                	ld	s0,32(sp)
    80000b06:	64e2                	ld	s1,24(sp)
    80000b08:	6145                	addi	sp,sp,48
    80000b0a:	8082                	ret

0000000080000b0c <kinit>:
{
    80000b0c:	1141                	addi	sp,sp,-16
    80000b0e:	e406                	sd	ra,8(sp)
    80000b10:	e022                	sd	s0,0(sp)
    80000b12:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000b14:	00007597          	auipc	a1,0x7
    80000b18:	53458593          	addi	a1,a1,1332 # 80008048 <etext+0x48>
    80000b1c:	00010517          	auipc	a0,0x10
    80000b20:	24450513          	addi	a0,a0,580 # 80010d60 <kmem>
    80000b24:	00000097          	auipc	ra,0x0
    80000b28:	084080e7          	jalr	132(ra) # 80000ba8 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b2c:	45c5                	li	a1,17
    80000b2e:	05ee                	slli	a1,a1,0x1b
    80000b30:	0004c517          	auipc	a0,0x4c
    80000b34:	ff050513          	addi	a0,a0,-16 # 8004cb20 <end>
    80000b38:	00000097          	auipc	ra,0x0
    80000b3c:	f88080e7          	jalr	-120(ra) # 80000ac0 <freerange>
}
    80000b40:	60a2                	ld	ra,8(sp)
    80000b42:	6402                	ld	s0,0(sp)
    80000b44:	0141                	addi	sp,sp,16
    80000b46:	8082                	ret

0000000080000b48 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000b48:	1101                	addi	sp,sp,-32
    80000b4a:	ec06                	sd	ra,24(sp)
    80000b4c:	e822                	sd	s0,16(sp)
    80000b4e:	e426                	sd	s1,8(sp)
    80000b50:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000b52:	00010497          	auipc	s1,0x10
    80000b56:	20e48493          	addi	s1,s1,526 # 80010d60 <kmem>
    80000b5a:	8526                	mv	a0,s1
    80000b5c:	00000097          	auipc	ra,0x0
    80000b60:	0dc080e7          	jalr	220(ra) # 80000c38 <acquire>
  r = kmem.freelist;
    80000b64:	6c84                	ld	s1,24(s1)
  if(r)
    80000b66:	c885                	beqz	s1,80000b96 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000b68:	609c                	ld	a5,0(s1)
    80000b6a:	00010517          	auipc	a0,0x10
    80000b6e:	1f650513          	addi	a0,a0,502 # 80010d60 <kmem>
    80000b72:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b74:	00000097          	auipc	ra,0x0
    80000b78:	178080e7          	jalr	376(ra) # 80000cec <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b7c:	6605                	lui	a2,0x1
    80000b7e:	4595                	li	a1,5
    80000b80:	8526                	mv	a0,s1
    80000b82:	00000097          	auipc	ra,0x0
    80000b86:	1b2080e7          	jalr	434(ra) # 80000d34 <memset>
  return (void*)r;
}
    80000b8a:	8526                	mv	a0,s1
    80000b8c:	60e2                	ld	ra,24(sp)
    80000b8e:	6442                	ld	s0,16(sp)
    80000b90:	64a2                	ld	s1,8(sp)
    80000b92:	6105                	addi	sp,sp,32
    80000b94:	8082                	ret
  release(&kmem.lock);
    80000b96:	00010517          	auipc	a0,0x10
    80000b9a:	1ca50513          	addi	a0,a0,458 # 80010d60 <kmem>
    80000b9e:	00000097          	auipc	ra,0x0
    80000ba2:	14e080e7          	jalr	334(ra) # 80000cec <release>
  if(r)
    80000ba6:	b7d5                	j	80000b8a <kalloc+0x42>

0000000080000ba8 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000ba8:	1141                	addi	sp,sp,-16
    80000baa:	e422                	sd	s0,8(sp)
    80000bac:	0800                	addi	s0,sp,16
  lk->name = name;
    80000bae:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000bb0:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000bb4:	00053823          	sd	zero,16(a0)
}
    80000bb8:	6422                	ld	s0,8(sp)
    80000bba:	0141                	addi	sp,sp,16
    80000bbc:	8082                	ret

0000000080000bbe <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000bbe:	411c                	lw	a5,0(a0)
    80000bc0:	e399                	bnez	a5,80000bc6 <holding+0x8>
    80000bc2:	4501                	li	a0,0
  return r;
}
    80000bc4:	8082                	ret
{
    80000bc6:	1101                	addi	sp,sp,-32
    80000bc8:	ec06                	sd	ra,24(sp)
    80000bca:	e822                	sd	s0,16(sp)
    80000bcc:	e426                	sd	s1,8(sp)
    80000bce:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000bd0:	6904                	ld	s1,16(a0)
    80000bd2:	00001097          	auipc	ra,0x1
    80000bd6:	f3c080e7          	jalr	-196(ra) # 80001b0e <mycpu>
    80000bda:	40a48533          	sub	a0,s1,a0
    80000bde:	00153513          	seqz	a0,a0
}
    80000be2:	60e2                	ld	ra,24(sp)
    80000be4:	6442                	ld	s0,16(sp)
    80000be6:	64a2                	ld	s1,8(sp)
    80000be8:	6105                	addi	sp,sp,32
    80000bea:	8082                	ret

0000000080000bec <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000bec:	1101                	addi	sp,sp,-32
    80000bee:	ec06                	sd	ra,24(sp)
    80000bf0:	e822                	sd	s0,16(sp)
    80000bf2:	e426                	sd	s1,8(sp)
    80000bf4:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000bf6:	100024f3          	csrr	s1,sstatus
    80000bfa:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000bfe:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c00:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000c04:	00001097          	auipc	ra,0x1
    80000c08:	f0a080e7          	jalr	-246(ra) # 80001b0e <mycpu>
    80000c0c:	5d3c                	lw	a5,120(a0)
    80000c0e:	cf89                	beqz	a5,80000c28 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000c10:	00001097          	auipc	ra,0x1
    80000c14:	efe080e7          	jalr	-258(ra) # 80001b0e <mycpu>
    80000c18:	5d3c                	lw	a5,120(a0)
    80000c1a:	2785                	addiw	a5,a5,1
    80000c1c:	dd3c                	sw	a5,120(a0)
}
    80000c1e:	60e2                	ld	ra,24(sp)
    80000c20:	6442                	ld	s0,16(sp)
    80000c22:	64a2                	ld	s1,8(sp)
    80000c24:	6105                	addi	sp,sp,32
    80000c26:	8082                	ret
    mycpu()->intena = old;
    80000c28:	00001097          	auipc	ra,0x1
    80000c2c:	ee6080e7          	jalr	-282(ra) # 80001b0e <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000c30:	8085                	srli	s1,s1,0x1
    80000c32:	8885                	andi	s1,s1,1
    80000c34:	dd64                	sw	s1,124(a0)
    80000c36:	bfe9                	j	80000c10 <push_off+0x24>

0000000080000c38 <acquire>:
{
    80000c38:	1101                	addi	sp,sp,-32
    80000c3a:	ec06                	sd	ra,24(sp)
    80000c3c:	e822                	sd	s0,16(sp)
    80000c3e:	e426                	sd	s1,8(sp)
    80000c40:	1000                	addi	s0,sp,32
    80000c42:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000c44:	00000097          	auipc	ra,0x0
    80000c48:	fa8080e7          	jalr	-88(ra) # 80000bec <push_off>
  if(holding(lk))
    80000c4c:	8526                	mv	a0,s1
    80000c4e:	00000097          	auipc	ra,0x0
    80000c52:	f70080e7          	jalr	-144(ra) # 80000bbe <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c56:	4705                	li	a4,1
  if(holding(lk))
    80000c58:	e115                	bnez	a0,80000c7c <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c5a:	87ba                	mv	a5,a4
    80000c5c:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000c60:	2781                	sext.w	a5,a5
    80000c62:	ffe5                	bnez	a5,80000c5a <acquire+0x22>
  __sync_synchronize();
    80000c64:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c68:	00001097          	auipc	ra,0x1
    80000c6c:	ea6080e7          	jalr	-346(ra) # 80001b0e <mycpu>
    80000c70:	e888                	sd	a0,16(s1)
}
    80000c72:	60e2                	ld	ra,24(sp)
    80000c74:	6442                	ld	s0,16(sp)
    80000c76:	64a2                	ld	s1,8(sp)
    80000c78:	6105                	addi	sp,sp,32
    80000c7a:	8082                	ret
    panic("acquire");
    80000c7c:	00007517          	auipc	a0,0x7
    80000c80:	3d450513          	addi	a0,a0,980 # 80008050 <etext+0x50>
    80000c84:	00000097          	auipc	ra,0x0
    80000c88:	8dc080e7          	jalr	-1828(ra) # 80000560 <panic>

0000000080000c8c <pop_off>:

void
pop_off(void)
{
    80000c8c:	1141                	addi	sp,sp,-16
    80000c8e:	e406                	sd	ra,8(sp)
    80000c90:	e022                	sd	s0,0(sp)
    80000c92:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c94:	00001097          	auipc	ra,0x1
    80000c98:	e7a080e7          	jalr	-390(ra) # 80001b0e <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c9c:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000ca0:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000ca2:	e78d                	bnez	a5,80000ccc <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000ca4:	5d3c                	lw	a5,120(a0)
    80000ca6:	02f05b63          	blez	a5,80000cdc <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000caa:	37fd                	addiw	a5,a5,-1
    80000cac:	0007871b          	sext.w	a4,a5
    80000cb0:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000cb2:	eb09                	bnez	a4,80000cc4 <pop_off+0x38>
    80000cb4:	5d7c                	lw	a5,124(a0)
    80000cb6:	c799                	beqz	a5,80000cc4 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000cb8:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000cbc:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000cc0:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000cc4:	60a2                	ld	ra,8(sp)
    80000cc6:	6402                	ld	s0,0(sp)
    80000cc8:	0141                	addi	sp,sp,16
    80000cca:	8082                	ret
    panic("pop_off - interruptible");
    80000ccc:	00007517          	auipc	a0,0x7
    80000cd0:	38c50513          	addi	a0,a0,908 # 80008058 <etext+0x58>
    80000cd4:	00000097          	auipc	ra,0x0
    80000cd8:	88c080e7          	jalr	-1908(ra) # 80000560 <panic>
    panic("pop_off");
    80000cdc:	00007517          	auipc	a0,0x7
    80000ce0:	39450513          	addi	a0,a0,916 # 80008070 <etext+0x70>
    80000ce4:	00000097          	auipc	ra,0x0
    80000ce8:	87c080e7          	jalr	-1924(ra) # 80000560 <panic>

0000000080000cec <release>:
{
    80000cec:	1101                	addi	sp,sp,-32
    80000cee:	ec06                	sd	ra,24(sp)
    80000cf0:	e822                	sd	s0,16(sp)
    80000cf2:	e426                	sd	s1,8(sp)
    80000cf4:	1000                	addi	s0,sp,32
    80000cf6:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000cf8:	00000097          	auipc	ra,0x0
    80000cfc:	ec6080e7          	jalr	-314(ra) # 80000bbe <holding>
    80000d00:	c115                	beqz	a0,80000d24 <release+0x38>
  lk->cpu = 0;
    80000d02:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000d06:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000d0a:	0f50000f          	fence	iorw,ow
    80000d0e:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000d12:	00000097          	auipc	ra,0x0
    80000d16:	f7a080e7          	jalr	-134(ra) # 80000c8c <pop_off>
}
    80000d1a:	60e2                	ld	ra,24(sp)
    80000d1c:	6442                	ld	s0,16(sp)
    80000d1e:	64a2                	ld	s1,8(sp)
    80000d20:	6105                	addi	sp,sp,32
    80000d22:	8082                	ret
    panic("release");
    80000d24:	00007517          	auipc	a0,0x7
    80000d28:	35450513          	addi	a0,a0,852 # 80008078 <etext+0x78>
    80000d2c:	00000097          	auipc	ra,0x0
    80000d30:	834080e7          	jalr	-1996(ra) # 80000560 <panic>

0000000080000d34 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000d34:	1141                	addi	sp,sp,-16
    80000d36:	e422                	sd	s0,8(sp)
    80000d38:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000d3a:	ca19                	beqz	a2,80000d50 <memset+0x1c>
    80000d3c:	87aa                	mv	a5,a0
    80000d3e:	1602                	slli	a2,a2,0x20
    80000d40:	9201                	srli	a2,a2,0x20
    80000d42:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000d46:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000d4a:	0785                	addi	a5,a5,1
    80000d4c:	fee79de3          	bne	a5,a4,80000d46 <memset+0x12>
  }
  return dst;
}
    80000d50:	6422                	ld	s0,8(sp)
    80000d52:	0141                	addi	sp,sp,16
    80000d54:	8082                	ret

0000000080000d56 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000d56:	1141                	addi	sp,sp,-16
    80000d58:	e422                	sd	s0,8(sp)
    80000d5a:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000d5c:	ca05                	beqz	a2,80000d8c <memcmp+0x36>
    80000d5e:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000d62:	1682                	slli	a3,a3,0x20
    80000d64:	9281                	srli	a3,a3,0x20
    80000d66:	0685                	addi	a3,a3,1
    80000d68:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d6a:	00054783          	lbu	a5,0(a0)
    80000d6e:	0005c703          	lbu	a4,0(a1)
    80000d72:	00e79863          	bne	a5,a4,80000d82 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d76:	0505                	addi	a0,a0,1
    80000d78:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d7a:	fed518e3          	bne	a0,a3,80000d6a <memcmp+0x14>
  }

  return 0;
    80000d7e:	4501                	li	a0,0
    80000d80:	a019                	j	80000d86 <memcmp+0x30>
      return *s1 - *s2;
    80000d82:	40e7853b          	subw	a0,a5,a4
}
    80000d86:	6422                	ld	s0,8(sp)
    80000d88:	0141                	addi	sp,sp,16
    80000d8a:	8082                	ret
  return 0;
    80000d8c:	4501                	li	a0,0
    80000d8e:	bfe5                	j	80000d86 <memcmp+0x30>

0000000080000d90 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d90:	1141                	addi	sp,sp,-16
    80000d92:	e422                	sd	s0,8(sp)
    80000d94:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d96:	c205                	beqz	a2,80000db6 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d98:	02a5e263          	bltu	a1,a0,80000dbc <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d9c:	1602                	slli	a2,a2,0x20
    80000d9e:	9201                	srli	a2,a2,0x20
    80000da0:	00c587b3          	add	a5,a1,a2
{
    80000da4:	872a                	mv	a4,a0
      *d++ = *s++;
    80000da6:	0585                	addi	a1,a1,1
    80000da8:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffb24e1>
    80000daa:	fff5c683          	lbu	a3,-1(a1)
    80000dae:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000db2:	feb79ae3          	bne	a5,a1,80000da6 <memmove+0x16>

  return dst;
}
    80000db6:	6422                	ld	s0,8(sp)
    80000db8:	0141                	addi	sp,sp,16
    80000dba:	8082                	ret
  if(s < d && s + n > d){
    80000dbc:	02061693          	slli	a3,a2,0x20
    80000dc0:	9281                	srli	a3,a3,0x20
    80000dc2:	00d58733          	add	a4,a1,a3
    80000dc6:	fce57be3          	bgeu	a0,a4,80000d9c <memmove+0xc>
    d += n;
    80000dca:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000dcc:	fff6079b          	addiw	a5,a2,-1
    80000dd0:	1782                	slli	a5,a5,0x20
    80000dd2:	9381                	srli	a5,a5,0x20
    80000dd4:	fff7c793          	not	a5,a5
    80000dd8:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000dda:	177d                	addi	a4,a4,-1
    80000ddc:	16fd                	addi	a3,a3,-1
    80000dde:	00074603          	lbu	a2,0(a4)
    80000de2:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000de6:	fef71ae3          	bne	a4,a5,80000dda <memmove+0x4a>
    80000dea:	b7f1                	j	80000db6 <memmove+0x26>

0000000080000dec <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000dec:	1141                	addi	sp,sp,-16
    80000dee:	e406                	sd	ra,8(sp)
    80000df0:	e022                	sd	s0,0(sp)
    80000df2:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000df4:	00000097          	auipc	ra,0x0
    80000df8:	f9c080e7          	jalr	-100(ra) # 80000d90 <memmove>
}
    80000dfc:	60a2                	ld	ra,8(sp)
    80000dfe:	6402                	ld	s0,0(sp)
    80000e00:	0141                	addi	sp,sp,16
    80000e02:	8082                	ret

0000000080000e04 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000e04:	1141                	addi	sp,sp,-16
    80000e06:	e422                	sd	s0,8(sp)
    80000e08:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000e0a:	ce11                	beqz	a2,80000e26 <strncmp+0x22>
    80000e0c:	00054783          	lbu	a5,0(a0)
    80000e10:	cf89                	beqz	a5,80000e2a <strncmp+0x26>
    80000e12:	0005c703          	lbu	a4,0(a1)
    80000e16:	00f71a63          	bne	a4,a5,80000e2a <strncmp+0x26>
    n--, p++, q++;
    80000e1a:	367d                	addiw	a2,a2,-1
    80000e1c:	0505                	addi	a0,a0,1
    80000e1e:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000e20:	f675                	bnez	a2,80000e0c <strncmp+0x8>
  if(n == 0)
    return 0;
    80000e22:	4501                	li	a0,0
    80000e24:	a801                	j	80000e34 <strncmp+0x30>
    80000e26:	4501                	li	a0,0
    80000e28:	a031                	j	80000e34 <strncmp+0x30>
  return (uchar)*p - (uchar)*q;
    80000e2a:	00054503          	lbu	a0,0(a0)
    80000e2e:	0005c783          	lbu	a5,0(a1)
    80000e32:	9d1d                	subw	a0,a0,a5
}
    80000e34:	6422                	ld	s0,8(sp)
    80000e36:	0141                	addi	sp,sp,16
    80000e38:	8082                	ret

0000000080000e3a <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000e3a:	1141                	addi	sp,sp,-16
    80000e3c:	e422                	sd	s0,8(sp)
    80000e3e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000e40:	87aa                	mv	a5,a0
    80000e42:	86b2                	mv	a3,a2
    80000e44:	367d                	addiw	a2,a2,-1
    80000e46:	02d05563          	blez	a3,80000e70 <strncpy+0x36>
    80000e4a:	0785                	addi	a5,a5,1
    80000e4c:	0005c703          	lbu	a4,0(a1)
    80000e50:	fee78fa3          	sb	a4,-1(a5)
    80000e54:	0585                	addi	a1,a1,1
    80000e56:	f775                	bnez	a4,80000e42 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000e58:	873e                	mv	a4,a5
    80000e5a:	9fb5                	addw	a5,a5,a3
    80000e5c:	37fd                	addiw	a5,a5,-1
    80000e5e:	00c05963          	blez	a2,80000e70 <strncpy+0x36>
    *s++ = 0;
    80000e62:	0705                	addi	a4,a4,1
    80000e64:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    80000e68:	40e786bb          	subw	a3,a5,a4
    80000e6c:	fed04be3          	bgtz	a3,80000e62 <strncpy+0x28>
  return os;
}
    80000e70:	6422                	ld	s0,8(sp)
    80000e72:	0141                	addi	sp,sp,16
    80000e74:	8082                	ret

0000000080000e76 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e76:	1141                	addi	sp,sp,-16
    80000e78:	e422                	sd	s0,8(sp)
    80000e7a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e7c:	02c05363          	blez	a2,80000ea2 <safestrcpy+0x2c>
    80000e80:	fff6069b          	addiw	a3,a2,-1
    80000e84:	1682                	slli	a3,a3,0x20
    80000e86:	9281                	srli	a3,a3,0x20
    80000e88:	96ae                	add	a3,a3,a1
    80000e8a:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e8c:	00d58963          	beq	a1,a3,80000e9e <safestrcpy+0x28>
    80000e90:	0585                	addi	a1,a1,1
    80000e92:	0785                	addi	a5,a5,1
    80000e94:	fff5c703          	lbu	a4,-1(a1)
    80000e98:	fee78fa3          	sb	a4,-1(a5)
    80000e9c:	fb65                	bnez	a4,80000e8c <safestrcpy+0x16>
    ;
  *s = 0;
    80000e9e:	00078023          	sb	zero,0(a5)
  return os;
}
    80000ea2:	6422                	ld	s0,8(sp)
    80000ea4:	0141                	addi	sp,sp,16
    80000ea6:	8082                	ret

0000000080000ea8 <strlen>:

int
strlen(const char *s)
{
    80000ea8:	1141                	addi	sp,sp,-16
    80000eaa:	e422                	sd	s0,8(sp)
    80000eac:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000eae:	00054783          	lbu	a5,0(a0)
    80000eb2:	cf91                	beqz	a5,80000ece <strlen+0x26>
    80000eb4:	0505                	addi	a0,a0,1
    80000eb6:	87aa                	mv	a5,a0
    80000eb8:	86be                	mv	a3,a5
    80000eba:	0785                	addi	a5,a5,1
    80000ebc:	fff7c703          	lbu	a4,-1(a5)
    80000ec0:	ff65                	bnez	a4,80000eb8 <strlen+0x10>
    80000ec2:	40a6853b          	subw	a0,a3,a0
    80000ec6:	2505                	addiw	a0,a0,1
    ;
  return n;
}
    80000ec8:	6422                	ld	s0,8(sp)
    80000eca:	0141                	addi	sp,sp,16
    80000ecc:	8082                	ret
  for(n = 0; s[n]; n++)
    80000ece:	4501                	li	a0,0
    80000ed0:	bfe5                	j	80000ec8 <strlen+0x20>

0000000080000ed2 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000ed2:	1141                	addi	sp,sp,-16
    80000ed4:	e406                	sd	ra,8(sp)
    80000ed6:	e022                	sd	s0,0(sp)
    80000ed8:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000eda:	00001097          	auipc	ra,0x1
    80000ede:	c24080e7          	jalr	-988(ra) # 80001afe <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000ee2:	00008717          	auipc	a4,0x8
    80000ee6:	c1670713          	addi	a4,a4,-1002 # 80008af8 <started>
  if(cpuid() == 0){
    80000eea:	c139                	beqz	a0,80000f30 <main+0x5e>
    while(started == 0)
    80000eec:	431c                	lw	a5,0(a4)
    80000eee:	2781                	sext.w	a5,a5
    80000ef0:	dff5                	beqz	a5,80000eec <main+0x1a>
      ;
    __sync_synchronize();
    80000ef2:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000ef6:	00001097          	auipc	ra,0x1
    80000efa:	c08080e7          	jalr	-1016(ra) # 80001afe <cpuid>
    80000efe:	85aa                	mv	a1,a0
    80000f00:	00007517          	auipc	a0,0x7
    80000f04:	19850513          	addi	a0,a0,408 # 80008098 <etext+0x98>
    80000f08:	fffff097          	auipc	ra,0xfffff
    80000f0c:	6a2080e7          	jalr	1698(ra) # 800005aa <printf>
    kvminithart();    // turn on paging
    80000f10:	00000097          	auipc	ra,0x0
    80000f14:	0d8080e7          	jalr	216(ra) # 80000fe8 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000f18:	00002097          	auipc	ra,0x2
    80000f1c:	c72080e7          	jalr	-910(ra) # 80002b8a <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000f20:	00005097          	auipc	ra,0x5
    80000f24:	504080e7          	jalr	1284(ra) # 80006424 <plicinithart>
  }

  scheduler();        
    80000f28:	00001097          	auipc	ra,0x1
    80000f2c:	172080e7          	jalr	370(ra) # 8000209a <scheduler>
    consoleinit();
    80000f30:	fffff097          	auipc	ra,0xfffff
    80000f34:	540080e7          	jalr	1344(ra) # 80000470 <consoleinit>
    printfinit();
    80000f38:	00000097          	auipc	ra,0x0
    80000f3c:	87a080e7          	jalr	-1926(ra) # 800007b2 <printfinit>
    printf("\n");
    80000f40:	00007517          	auipc	a0,0x7
    80000f44:	0d050513          	addi	a0,a0,208 # 80008010 <etext+0x10>
    80000f48:	fffff097          	auipc	ra,0xfffff
    80000f4c:	662080e7          	jalr	1634(ra) # 800005aa <printf>
    printf("xv6 kernel is booting\n");
    80000f50:	00007517          	auipc	a0,0x7
    80000f54:	13050513          	addi	a0,a0,304 # 80008080 <etext+0x80>
    80000f58:	fffff097          	auipc	ra,0xfffff
    80000f5c:	652080e7          	jalr	1618(ra) # 800005aa <printf>
    printf("\n");
    80000f60:	00007517          	auipc	a0,0x7
    80000f64:	0b050513          	addi	a0,a0,176 # 80008010 <etext+0x10>
    80000f68:	fffff097          	auipc	ra,0xfffff
    80000f6c:	642080e7          	jalr	1602(ra) # 800005aa <printf>
    kinit();         // physical page allocator
    80000f70:	00000097          	auipc	ra,0x0
    80000f74:	b9c080e7          	jalr	-1124(ra) # 80000b0c <kinit>
    kvminit();       // create kernel page table
    80000f78:	00000097          	auipc	ra,0x0
    80000f7c:	326080e7          	jalr	806(ra) # 8000129e <kvminit>
    kvminithart();   // turn on paging
    80000f80:	00000097          	auipc	ra,0x0
    80000f84:	068080e7          	jalr	104(ra) # 80000fe8 <kvminithart>
    procinit();      // process table
    80000f88:	00001097          	auipc	ra,0x1
    80000f8c:	ab4080e7          	jalr	-1356(ra) # 80001a3c <procinit>
    trapinit();      // trap vectors
    80000f90:	00002097          	auipc	ra,0x2
    80000f94:	bd2080e7          	jalr	-1070(ra) # 80002b62 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f98:	00002097          	auipc	ra,0x2
    80000f9c:	bf2080e7          	jalr	-1038(ra) # 80002b8a <trapinithart>
    plicinit();      // set up interrupt controller
    80000fa0:	00005097          	auipc	ra,0x5
    80000fa4:	46a080e7          	jalr	1130(ra) # 8000640a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000fa8:	00005097          	auipc	ra,0x5
    80000fac:	47c080e7          	jalr	1148(ra) # 80006424 <plicinithart>
    binit();         // buffer cache
    80000fb0:	00002097          	auipc	ra,0x2
    80000fb4:	548080e7          	jalr	1352(ra) # 800034f8 <binit>
    iinit();         // inode table
    80000fb8:	00003097          	auipc	ra,0x3
    80000fbc:	bfe080e7          	jalr	-1026(ra) # 80003bb6 <iinit>
    fileinit();      // file table
    80000fc0:	00004097          	auipc	ra,0x4
    80000fc4:	bae080e7          	jalr	-1106(ra) # 80004b6e <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000fc8:	00005097          	auipc	ra,0x5
    80000fcc:	564080e7          	jalr	1380(ra) # 8000652c <virtio_disk_init>
    userinit();      // first user process
    80000fd0:	00001097          	auipc	ra,0x1
    80000fd4:	e9a080e7          	jalr	-358(ra) # 80001e6a <userinit>
    __sync_synchronize();
    80000fd8:	0ff0000f          	fence
    started = 1;
    80000fdc:	4785                	li	a5,1
    80000fde:	00008717          	auipc	a4,0x8
    80000fe2:	b0f72d23          	sw	a5,-1254(a4) # 80008af8 <started>
    80000fe6:	b789                	j	80000f28 <main+0x56>

0000000080000fe8 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000fe8:	1141                	addi	sp,sp,-16
    80000fea:	e422                	sd	s0,8(sp)
    80000fec:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000fee:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000ff2:	00008797          	auipc	a5,0x8
    80000ff6:	b0e7b783          	ld	a5,-1266(a5) # 80008b00 <kernel_pagetable>
    80000ffa:	83b1                	srli	a5,a5,0xc
    80000ffc:	577d                	li	a4,-1
    80000ffe:	177e                	slli	a4,a4,0x3f
    80001000:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80001002:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80001006:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    8000100a:	6422                	ld	s0,8(sp)
    8000100c:	0141                	addi	sp,sp,16
    8000100e:	8082                	ret

0000000080001010 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80001010:	7139                	addi	sp,sp,-64
    80001012:	fc06                	sd	ra,56(sp)
    80001014:	f822                	sd	s0,48(sp)
    80001016:	f426                	sd	s1,40(sp)
    80001018:	f04a                	sd	s2,32(sp)
    8000101a:	ec4e                	sd	s3,24(sp)
    8000101c:	e852                	sd	s4,16(sp)
    8000101e:	e456                	sd	s5,8(sp)
    80001020:	e05a                	sd	s6,0(sp)
    80001022:	0080                	addi	s0,sp,64
    80001024:	84aa                	mv	s1,a0
    80001026:	89ae                	mv	s3,a1
    80001028:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    8000102a:	57fd                	li	a5,-1
    8000102c:	83e9                	srli	a5,a5,0x1a
    8000102e:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80001030:	4b31                	li	s6,12
  if(va >= MAXVA)
    80001032:	04b7f263          	bgeu	a5,a1,80001076 <walk+0x66>
    panic("walk");
    80001036:	00007517          	auipc	a0,0x7
    8000103a:	07a50513          	addi	a0,a0,122 # 800080b0 <etext+0xb0>
    8000103e:	fffff097          	auipc	ra,0xfffff
    80001042:	522080e7          	jalr	1314(ra) # 80000560 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80001046:	060a8663          	beqz	s5,800010b2 <walk+0xa2>
    8000104a:	00000097          	auipc	ra,0x0
    8000104e:	afe080e7          	jalr	-1282(ra) # 80000b48 <kalloc>
    80001052:	84aa                	mv	s1,a0
    80001054:	c529                	beqz	a0,8000109e <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80001056:	6605                	lui	a2,0x1
    80001058:	4581                	li	a1,0
    8000105a:	00000097          	auipc	ra,0x0
    8000105e:	cda080e7          	jalr	-806(ra) # 80000d34 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001062:	00c4d793          	srli	a5,s1,0xc
    80001066:	07aa                	slli	a5,a5,0xa
    80001068:	0017e793          	ori	a5,a5,1
    8000106c:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001070:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffb24d7>
    80001072:	036a0063          	beq	s4,s6,80001092 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    80001076:	0149d933          	srl	s2,s3,s4
    8000107a:	1ff97913          	andi	s2,s2,511
    8000107e:	090e                	slli	s2,s2,0x3
    80001080:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001082:	00093483          	ld	s1,0(s2)
    80001086:	0014f793          	andi	a5,s1,1
    8000108a:	dfd5                	beqz	a5,80001046 <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    8000108c:	80a9                	srli	s1,s1,0xa
    8000108e:	04b2                	slli	s1,s1,0xc
    80001090:	b7c5                	j	80001070 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001092:	00c9d513          	srli	a0,s3,0xc
    80001096:	1ff57513          	andi	a0,a0,511
    8000109a:	050e                	slli	a0,a0,0x3
    8000109c:	9526                	add	a0,a0,s1
}
    8000109e:	70e2                	ld	ra,56(sp)
    800010a0:	7442                	ld	s0,48(sp)
    800010a2:	74a2                	ld	s1,40(sp)
    800010a4:	7902                	ld	s2,32(sp)
    800010a6:	69e2                	ld	s3,24(sp)
    800010a8:	6a42                	ld	s4,16(sp)
    800010aa:	6aa2                	ld	s5,8(sp)
    800010ac:	6b02                	ld	s6,0(sp)
    800010ae:	6121                	addi	sp,sp,64
    800010b0:	8082                	ret
        return 0;
    800010b2:	4501                	li	a0,0
    800010b4:	b7ed                	j	8000109e <walk+0x8e>

00000000800010b6 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    800010b6:	57fd                	li	a5,-1
    800010b8:	83e9                	srli	a5,a5,0x1a
    800010ba:	00b7f463          	bgeu	a5,a1,800010c2 <walkaddr+0xc>
    return 0;
    800010be:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    800010c0:	8082                	ret
{
    800010c2:	1141                	addi	sp,sp,-16
    800010c4:	e406                	sd	ra,8(sp)
    800010c6:	e022                	sd	s0,0(sp)
    800010c8:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    800010ca:	4601                	li	a2,0
    800010cc:	00000097          	auipc	ra,0x0
    800010d0:	f44080e7          	jalr	-188(ra) # 80001010 <walk>
  if(pte == 0)
    800010d4:	c105                	beqz	a0,800010f4 <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    800010d6:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    800010d8:	0117f693          	andi	a3,a5,17
    800010dc:	4745                	li	a4,17
    return 0;
    800010de:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    800010e0:	00e68663          	beq	a3,a4,800010ec <walkaddr+0x36>
}
    800010e4:	60a2                	ld	ra,8(sp)
    800010e6:	6402                	ld	s0,0(sp)
    800010e8:	0141                	addi	sp,sp,16
    800010ea:	8082                	ret
  pa = PTE2PA(*pte);
    800010ec:	83a9                	srli	a5,a5,0xa
    800010ee:	00c79513          	slli	a0,a5,0xc
  return pa;
    800010f2:	bfcd                	j	800010e4 <walkaddr+0x2e>
    return 0;
    800010f4:	4501                	li	a0,0
    800010f6:	b7fd                	j	800010e4 <walkaddr+0x2e>

00000000800010f8 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    800010f8:	715d                	addi	sp,sp,-80
    800010fa:	e486                	sd	ra,72(sp)
    800010fc:	e0a2                	sd	s0,64(sp)
    800010fe:	fc26                	sd	s1,56(sp)
    80001100:	f84a                	sd	s2,48(sp)
    80001102:	f44e                	sd	s3,40(sp)
    80001104:	f052                	sd	s4,32(sp)
    80001106:	ec56                	sd	s5,24(sp)
    80001108:	e85a                	sd	s6,16(sp)
    8000110a:	e45e                	sd	s7,8(sp)
    8000110c:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    8000110e:	c639                	beqz	a2,8000115c <mappages+0x64>
    80001110:	8aaa                	mv	s5,a0
    80001112:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    80001114:	777d                	lui	a4,0xfffff
    80001116:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    8000111a:	fff58993          	addi	s3,a1,-1
    8000111e:	99b2                	add	s3,s3,a2
    80001120:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    80001124:	893e                	mv	s2,a5
    80001126:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    8000112a:	6b85                	lui	s7,0x1
    8000112c:	014904b3          	add	s1,s2,s4
    if((pte = walk(pagetable, a, 1)) == 0)
    80001130:	4605                	li	a2,1
    80001132:	85ca                	mv	a1,s2
    80001134:	8556                	mv	a0,s5
    80001136:	00000097          	auipc	ra,0x0
    8000113a:	eda080e7          	jalr	-294(ra) # 80001010 <walk>
    8000113e:	cd1d                	beqz	a0,8000117c <mappages+0x84>
    if(*pte & PTE_V)
    80001140:	611c                	ld	a5,0(a0)
    80001142:	8b85                	andi	a5,a5,1
    80001144:	e785                	bnez	a5,8000116c <mappages+0x74>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001146:	80b1                	srli	s1,s1,0xc
    80001148:	04aa                	slli	s1,s1,0xa
    8000114a:	0164e4b3          	or	s1,s1,s6
    8000114e:	0014e493          	ori	s1,s1,1
    80001152:	e104                	sd	s1,0(a0)
    if(a == last)
    80001154:	05390063          	beq	s2,s3,80001194 <mappages+0x9c>
    a += PGSIZE;
    80001158:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    8000115a:	bfc9                	j	8000112c <mappages+0x34>
    panic("mappages: size");
    8000115c:	00007517          	auipc	a0,0x7
    80001160:	f5c50513          	addi	a0,a0,-164 # 800080b8 <etext+0xb8>
    80001164:	fffff097          	auipc	ra,0xfffff
    80001168:	3fc080e7          	jalr	1020(ra) # 80000560 <panic>
      panic("mappages: remap");
    8000116c:	00007517          	auipc	a0,0x7
    80001170:	f5c50513          	addi	a0,a0,-164 # 800080c8 <etext+0xc8>
    80001174:	fffff097          	auipc	ra,0xfffff
    80001178:	3ec080e7          	jalr	1004(ra) # 80000560 <panic>
      return -1;
    8000117c:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    8000117e:	60a6                	ld	ra,72(sp)
    80001180:	6406                	ld	s0,64(sp)
    80001182:	74e2                	ld	s1,56(sp)
    80001184:	7942                	ld	s2,48(sp)
    80001186:	79a2                	ld	s3,40(sp)
    80001188:	7a02                	ld	s4,32(sp)
    8000118a:	6ae2                	ld	s5,24(sp)
    8000118c:	6b42                	ld	s6,16(sp)
    8000118e:	6ba2                	ld	s7,8(sp)
    80001190:	6161                	addi	sp,sp,80
    80001192:	8082                	ret
  return 0;
    80001194:	4501                	li	a0,0
    80001196:	b7e5                	j	8000117e <mappages+0x86>

0000000080001198 <kvmmap>:
{
    80001198:	1141                	addi	sp,sp,-16
    8000119a:	e406                	sd	ra,8(sp)
    8000119c:	e022                	sd	s0,0(sp)
    8000119e:	0800                	addi	s0,sp,16
    800011a0:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    800011a2:	86b2                	mv	a3,a2
    800011a4:	863e                	mv	a2,a5
    800011a6:	00000097          	auipc	ra,0x0
    800011aa:	f52080e7          	jalr	-174(ra) # 800010f8 <mappages>
    800011ae:	e509                	bnez	a0,800011b8 <kvmmap+0x20>
}
    800011b0:	60a2                	ld	ra,8(sp)
    800011b2:	6402                	ld	s0,0(sp)
    800011b4:	0141                	addi	sp,sp,16
    800011b6:	8082                	ret
    panic("kvmmap");
    800011b8:	00007517          	auipc	a0,0x7
    800011bc:	f2050513          	addi	a0,a0,-224 # 800080d8 <etext+0xd8>
    800011c0:	fffff097          	auipc	ra,0xfffff
    800011c4:	3a0080e7          	jalr	928(ra) # 80000560 <panic>

00000000800011c8 <kvmmake>:
{
    800011c8:	1101                	addi	sp,sp,-32
    800011ca:	ec06                	sd	ra,24(sp)
    800011cc:	e822                	sd	s0,16(sp)
    800011ce:	e426                	sd	s1,8(sp)
    800011d0:	e04a                	sd	s2,0(sp)
    800011d2:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    800011d4:	00000097          	auipc	ra,0x0
    800011d8:	974080e7          	jalr	-1676(ra) # 80000b48 <kalloc>
    800011dc:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    800011de:	6605                	lui	a2,0x1
    800011e0:	4581                	li	a1,0
    800011e2:	00000097          	auipc	ra,0x0
    800011e6:	b52080e7          	jalr	-1198(ra) # 80000d34 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800011ea:	4719                	li	a4,6
    800011ec:	6685                	lui	a3,0x1
    800011ee:	10000637          	lui	a2,0x10000
    800011f2:	100005b7          	lui	a1,0x10000
    800011f6:	8526                	mv	a0,s1
    800011f8:	00000097          	auipc	ra,0x0
    800011fc:	fa0080e7          	jalr	-96(ra) # 80001198 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80001200:	4719                	li	a4,6
    80001202:	6685                	lui	a3,0x1
    80001204:	10001637          	lui	a2,0x10001
    80001208:	100015b7          	lui	a1,0x10001
    8000120c:	8526                	mv	a0,s1
    8000120e:	00000097          	auipc	ra,0x0
    80001212:	f8a080e7          	jalr	-118(ra) # 80001198 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    80001216:	4719                	li	a4,6
    80001218:	004006b7          	lui	a3,0x400
    8000121c:	0c000637          	lui	a2,0xc000
    80001220:	0c0005b7          	lui	a1,0xc000
    80001224:	8526                	mv	a0,s1
    80001226:	00000097          	auipc	ra,0x0
    8000122a:	f72080e7          	jalr	-142(ra) # 80001198 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    8000122e:	00007917          	auipc	s2,0x7
    80001232:	dd290913          	addi	s2,s2,-558 # 80008000 <etext>
    80001236:	4729                	li	a4,10
    80001238:	80007697          	auipc	a3,0x80007
    8000123c:	dc868693          	addi	a3,a3,-568 # 8000 <_entry-0x7fff8000>
    80001240:	4605                	li	a2,1
    80001242:	067e                	slli	a2,a2,0x1f
    80001244:	85b2                	mv	a1,a2
    80001246:	8526                	mv	a0,s1
    80001248:	00000097          	auipc	ra,0x0
    8000124c:	f50080e7          	jalr	-176(ra) # 80001198 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001250:	46c5                	li	a3,17
    80001252:	06ee                	slli	a3,a3,0x1b
    80001254:	4719                	li	a4,6
    80001256:	412686b3          	sub	a3,a3,s2
    8000125a:	864a                	mv	a2,s2
    8000125c:	85ca                	mv	a1,s2
    8000125e:	8526                	mv	a0,s1
    80001260:	00000097          	auipc	ra,0x0
    80001264:	f38080e7          	jalr	-200(ra) # 80001198 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001268:	4729                	li	a4,10
    8000126a:	6685                	lui	a3,0x1
    8000126c:	00006617          	auipc	a2,0x6
    80001270:	d9460613          	addi	a2,a2,-620 # 80007000 <_trampoline>
    80001274:	040005b7          	lui	a1,0x4000
    80001278:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    8000127a:	05b2                	slli	a1,a1,0xc
    8000127c:	8526                	mv	a0,s1
    8000127e:	00000097          	auipc	ra,0x0
    80001282:	f1a080e7          	jalr	-230(ra) # 80001198 <kvmmap>
  proc_mapstacks(kpgtbl);
    80001286:	8526                	mv	a0,s1
    80001288:	00000097          	auipc	ra,0x0
    8000128c:	710080e7          	jalr	1808(ra) # 80001998 <proc_mapstacks>
}
    80001290:	8526                	mv	a0,s1
    80001292:	60e2                	ld	ra,24(sp)
    80001294:	6442                	ld	s0,16(sp)
    80001296:	64a2                	ld	s1,8(sp)
    80001298:	6902                	ld	s2,0(sp)
    8000129a:	6105                	addi	sp,sp,32
    8000129c:	8082                	ret

000000008000129e <kvminit>:
{
    8000129e:	1141                	addi	sp,sp,-16
    800012a0:	e406                	sd	ra,8(sp)
    800012a2:	e022                	sd	s0,0(sp)
    800012a4:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    800012a6:	00000097          	auipc	ra,0x0
    800012aa:	f22080e7          	jalr	-222(ra) # 800011c8 <kvmmake>
    800012ae:	00008797          	auipc	a5,0x8
    800012b2:	84a7b923          	sd	a0,-1966(a5) # 80008b00 <kernel_pagetable>
}
    800012b6:	60a2                	ld	ra,8(sp)
    800012b8:	6402                	ld	s0,0(sp)
    800012ba:	0141                	addi	sp,sp,16
    800012bc:	8082                	ret

00000000800012be <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    800012be:	715d                	addi	sp,sp,-80
    800012c0:	e486                	sd	ra,72(sp)
    800012c2:	e0a2                	sd	s0,64(sp)
    800012c4:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800012c6:	03459793          	slli	a5,a1,0x34
    800012ca:	e39d                	bnez	a5,800012f0 <uvmunmap+0x32>
    800012cc:	f84a                	sd	s2,48(sp)
    800012ce:	f44e                	sd	s3,40(sp)
    800012d0:	f052                	sd	s4,32(sp)
    800012d2:	ec56                	sd	s5,24(sp)
    800012d4:	e85a                	sd	s6,16(sp)
    800012d6:	e45e                	sd	s7,8(sp)
    800012d8:	8a2a                	mv	s4,a0
    800012da:	892e                	mv	s2,a1
    800012dc:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012de:	0632                	slli	a2,a2,0xc
    800012e0:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    800012e4:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012e6:	6b05                	lui	s6,0x1
    800012e8:	0935fb63          	bgeu	a1,s3,8000137e <uvmunmap+0xc0>
    800012ec:	fc26                	sd	s1,56(sp)
    800012ee:	a8a9                	j	80001348 <uvmunmap+0x8a>
    800012f0:	fc26                	sd	s1,56(sp)
    800012f2:	f84a                	sd	s2,48(sp)
    800012f4:	f44e                	sd	s3,40(sp)
    800012f6:	f052                	sd	s4,32(sp)
    800012f8:	ec56                	sd	s5,24(sp)
    800012fa:	e85a                	sd	s6,16(sp)
    800012fc:	e45e                	sd	s7,8(sp)
    panic("uvmunmap: not aligned");
    800012fe:	00007517          	auipc	a0,0x7
    80001302:	de250513          	addi	a0,a0,-542 # 800080e0 <etext+0xe0>
    80001306:	fffff097          	auipc	ra,0xfffff
    8000130a:	25a080e7          	jalr	602(ra) # 80000560 <panic>
      panic("uvmunmap: walk");
    8000130e:	00007517          	auipc	a0,0x7
    80001312:	dea50513          	addi	a0,a0,-534 # 800080f8 <etext+0xf8>
    80001316:	fffff097          	auipc	ra,0xfffff
    8000131a:	24a080e7          	jalr	586(ra) # 80000560 <panic>
      panic("uvmunmap: not mapped");
    8000131e:	00007517          	auipc	a0,0x7
    80001322:	dea50513          	addi	a0,a0,-534 # 80008108 <etext+0x108>
    80001326:	fffff097          	auipc	ra,0xfffff
    8000132a:	23a080e7          	jalr	570(ra) # 80000560 <panic>
      panic("uvmunmap: not a leaf");
    8000132e:	00007517          	auipc	a0,0x7
    80001332:	df250513          	addi	a0,a0,-526 # 80008120 <etext+0x120>
    80001336:	fffff097          	auipc	ra,0xfffff
    8000133a:	22a080e7          	jalr	554(ra) # 80000560 <panic>
    if(do_free){
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
    8000133e:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001342:	995a                	add	s2,s2,s6
    80001344:	03397c63          	bgeu	s2,s3,8000137c <uvmunmap+0xbe>
    if((pte = walk(pagetable, a, 0)) == 0)
    80001348:	4601                	li	a2,0
    8000134a:	85ca                	mv	a1,s2
    8000134c:	8552                	mv	a0,s4
    8000134e:	00000097          	auipc	ra,0x0
    80001352:	cc2080e7          	jalr	-830(ra) # 80001010 <walk>
    80001356:	84aa                	mv	s1,a0
    80001358:	d95d                	beqz	a0,8000130e <uvmunmap+0x50>
    if((*pte & PTE_V) == 0)
    8000135a:	6108                	ld	a0,0(a0)
    8000135c:	00157793          	andi	a5,a0,1
    80001360:	dfdd                	beqz	a5,8000131e <uvmunmap+0x60>
    if(PTE_FLAGS(*pte) == PTE_V)
    80001362:	3ff57793          	andi	a5,a0,1023
    80001366:	fd7784e3          	beq	a5,s7,8000132e <uvmunmap+0x70>
    if(do_free){
    8000136a:	fc0a8ae3          	beqz	s5,8000133e <uvmunmap+0x80>
      uint64 pa = PTE2PA(*pte);
    8000136e:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    80001370:	0532                	slli	a0,a0,0xc
    80001372:	fffff097          	auipc	ra,0xfffff
    80001376:	6d8080e7          	jalr	1752(ra) # 80000a4a <kfree>
    8000137a:	b7d1                	j	8000133e <uvmunmap+0x80>
    8000137c:	74e2                	ld	s1,56(sp)
    8000137e:	7942                	ld	s2,48(sp)
    80001380:	79a2                	ld	s3,40(sp)
    80001382:	7a02                	ld	s4,32(sp)
    80001384:	6ae2                	ld	s5,24(sp)
    80001386:	6b42                	ld	s6,16(sp)
    80001388:	6ba2                	ld	s7,8(sp)
  }
}
    8000138a:	60a6                	ld	ra,72(sp)
    8000138c:	6406                	ld	s0,64(sp)
    8000138e:	6161                	addi	sp,sp,80
    80001390:	8082                	ret

0000000080001392 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001392:	1101                	addi	sp,sp,-32
    80001394:	ec06                	sd	ra,24(sp)
    80001396:	e822                	sd	s0,16(sp)
    80001398:	e426                	sd	s1,8(sp)
    8000139a:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    8000139c:	fffff097          	auipc	ra,0xfffff
    800013a0:	7ac080e7          	jalr	1964(ra) # 80000b48 <kalloc>
    800013a4:	84aa                	mv	s1,a0
  if(pagetable == 0)
    800013a6:	c519                	beqz	a0,800013b4 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    800013a8:	6605                	lui	a2,0x1
    800013aa:	4581                	li	a1,0
    800013ac:	00000097          	auipc	ra,0x0
    800013b0:	988080e7          	jalr	-1656(ra) # 80000d34 <memset>
  return pagetable;
}
    800013b4:	8526                	mv	a0,s1
    800013b6:	60e2                	ld	ra,24(sp)
    800013b8:	6442                	ld	s0,16(sp)
    800013ba:	64a2                	ld	s1,8(sp)
    800013bc:	6105                	addi	sp,sp,32
    800013be:	8082                	ret

00000000800013c0 <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    800013c0:	7179                	addi	sp,sp,-48
    800013c2:	f406                	sd	ra,40(sp)
    800013c4:	f022                	sd	s0,32(sp)
    800013c6:	ec26                	sd	s1,24(sp)
    800013c8:	e84a                	sd	s2,16(sp)
    800013ca:	e44e                	sd	s3,8(sp)
    800013cc:	e052                	sd	s4,0(sp)
    800013ce:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    800013d0:	6785                	lui	a5,0x1
    800013d2:	04f67863          	bgeu	a2,a5,80001422 <uvmfirst+0x62>
    800013d6:	8a2a                	mv	s4,a0
    800013d8:	89ae                	mv	s3,a1
    800013da:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    800013dc:	fffff097          	auipc	ra,0xfffff
    800013e0:	76c080e7          	jalr	1900(ra) # 80000b48 <kalloc>
    800013e4:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    800013e6:	6605                	lui	a2,0x1
    800013e8:	4581                	li	a1,0
    800013ea:	00000097          	auipc	ra,0x0
    800013ee:	94a080e7          	jalr	-1718(ra) # 80000d34 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    800013f2:	4779                	li	a4,30
    800013f4:	86ca                	mv	a3,s2
    800013f6:	6605                	lui	a2,0x1
    800013f8:	4581                	li	a1,0
    800013fa:	8552                	mv	a0,s4
    800013fc:	00000097          	auipc	ra,0x0
    80001400:	cfc080e7          	jalr	-772(ra) # 800010f8 <mappages>
  memmove(mem, src, sz);
    80001404:	8626                	mv	a2,s1
    80001406:	85ce                	mv	a1,s3
    80001408:	854a                	mv	a0,s2
    8000140a:	00000097          	auipc	ra,0x0
    8000140e:	986080e7          	jalr	-1658(ra) # 80000d90 <memmove>
}
    80001412:	70a2                	ld	ra,40(sp)
    80001414:	7402                	ld	s0,32(sp)
    80001416:	64e2                	ld	s1,24(sp)
    80001418:	6942                	ld	s2,16(sp)
    8000141a:	69a2                	ld	s3,8(sp)
    8000141c:	6a02                	ld	s4,0(sp)
    8000141e:	6145                	addi	sp,sp,48
    80001420:	8082                	ret
    panic("uvmfirst: more than a page");
    80001422:	00007517          	auipc	a0,0x7
    80001426:	d1650513          	addi	a0,a0,-746 # 80008138 <etext+0x138>
    8000142a:	fffff097          	auipc	ra,0xfffff
    8000142e:	136080e7          	jalr	310(ra) # 80000560 <panic>

0000000080001432 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    80001432:	1101                	addi	sp,sp,-32
    80001434:	ec06                	sd	ra,24(sp)
    80001436:	e822                	sd	s0,16(sp)
    80001438:	e426                	sd	s1,8(sp)
    8000143a:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    8000143c:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    8000143e:	00b67d63          	bgeu	a2,a1,80001458 <uvmdealloc+0x26>
    80001442:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    80001444:	6785                	lui	a5,0x1
    80001446:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001448:	00f60733          	add	a4,a2,a5
    8000144c:	76fd                	lui	a3,0xfffff
    8000144e:	8f75                	and	a4,a4,a3
    80001450:	97ae                	add	a5,a5,a1
    80001452:	8ff5                	and	a5,a5,a3
    80001454:	00f76863          	bltu	a4,a5,80001464 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80001458:	8526                	mv	a0,s1
    8000145a:	60e2                	ld	ra,24(sp)
    8000145c:	6442                	ld	s0,16(sp)
    8000145e:	64a2                	ld	s1,8(sp)
    80001460:	6105                	addi	sp,sp,32
    80001462:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    80001464:	8f99                	sub	a5,a5,a4
    80001466:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001468:	4685                	li	a3,1
    8000146a:	0007861b          	sext.w	a2,a5
    8000146e:	85ba                	mv	a1,a4
    80001470:	00000097          	auipc	ra,0x0
    80001474:	e4e080e7          	jalr	-434(ra) # 800012be <uvmunmap>
    80001478:	b7c5                	j	80001458 <uvmdealloc+0x26>

000000008000147a <uvmalloc>:
  if(newsz < oldsz)
    8000147a:	0ab66b63          	bltu	a2,a1,80001530 <uvmalloc+0xb6>
{
    8000147e:	7139                	addi	sp,sp,-64
    80001480:	fc06                	sd	ra,56(sp)
    80001482:	f822                	sd	s0,48(sp)
    80001484:	ec4e                	sd	s3,24(sp)
    80001486:	e852                	sd	s4,16(sp)
    80001488:	e456                	sd	s5,8(sp)
    8000148a:	0080                	addi	s0,sp,64
    8000148c:	8aaa                	mv	s5,a0
    8000148e:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001490:	6785                	lui	a5,0x1
    80001492:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001494:	95be                	add	a1,a1,a5
    80001496:	77fd                	lui	a5,0xfffff
    80001498:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000149c:	08c9fc63          	bgeu	s3,a2,80001534 <uvmalloc+0xba>
    800014a0:	f426                	sd	s1,40(sp)
    800014a2:	f04a                	sd	s2,32(sp)
    800014a4:	e05a                	sd	s6,0(sp)
    800014a6:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    800014a8:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    800014ac:	fffff097          	auipc	ra,0xfffff
    800014b0:	69c080e7          	jalr	1692(ra) # 80000b48 <kalloc>
    800014b4:	84aa                	mv	s1,a0
    if(mem == 0){
    800014b6:	c915                	beqz	a0,800014ea <uvmalloc+0x70>
    memset(mem, 0, PGSIZE);
    800014b8:	6605                	lui	a2,0x1
    800014ba:	4581                	li	a1,0
    800014bc:	00000097          	auipc	ra,0x0
    800014c0:	878080e7          	jalr	-1928(ra) # 80000d34 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    800014c4:	875a                	mv	a4,s6
    800014c6:	86a6                	mv	a3,s1
    800014c8:	6605                	lui	a2,0x1
    800014ca:	85ca                	mv	a1,s2
    800014cc:	8556                	mv	a0,s5
    800014ce:	00000097          	auipc	ra,0x0
    800014d2:	c2a080e7          	jalr	-982(ra) # 800010f8 <mappages>
    800014d6:	ed05                	bnez	a0,8000150e <uvmalloc+0x94>
  for(a = oldsz; a < newsz; a += PGSIZE){
    800014d8:	6785                	lui	a5,0x1
    800014da:	993e                	add	s2,s2,a5
    800014dc:	fd4968e3          	bltu	s2,s4,800014ac <uvmalloc+0x32>
  return newsz;
    800014e0:	8552                	mv	a0,s4
    800014e2:	74a2                	ld	s1,40(sp)
    800014e4:	7902                	ld	s2,32(sp)
    800014e6:	6b02                	ld	s6,0(sp)
    800014e8:	a821                	j	80001500 <uvmalloc+0x86>
      uvmdealloc(pagetable, a, oldsz);
    800014ea:	864e                	mv	a2,s3
    800014ec:	85ca                	mv	a1,s2
    800014ee:	8556                	mv	a0,s5
    800014f0:	00000097          	auipc	ra,0x0
    800014f4:	f42080e7          	jalr	-190(ra) # 80001432 <uvmdealloc>
      return 0;
    800014f8:	4501                	li	a0,0
    800014fa:	74a2                	ld	s1,40(sp)
    800014fc:	7902                	ld	s2,32(sp)
    800014fe:	6b02                	ld	s6,0(sp)
}
    80001500:	70e2                	ld	ra,56(sp)
    80001502:	7442                	ld	s0,48(sp)
    80001504:	69e2                	ld	s3,24(sp)
    80001506:	6a42                	ld	s4,16(sp)
    80001508:	6aa2                	ld	s5,8(sp)
    8000150a:	6121                	addi	sp,sp,64
    8000150c:	8082                	ret
      kfree(mem);
    8000150e:	8526                	mv	a0,s1
    80001510:	fffff097          	auipc	ra,0xfffff
    80001514:	53a080e7          	jalr	1338(ra) # 80000a4a <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80001518:	864e                	mv	a2,s3
    8000151a:	85ca                	mv	a1,s2
    8000151c:	8556                	mv	a0,s5
    8000151e:	00000097          	auipc	ra,0x0
    80001522:	f14080e7          	jalr	-236(ra) # 80001432 <uvmdealloc>
      return 0;
    80001526:	4501                	li	a0,0
    80001528:	74a2                	ld	s1,40(sp)
    8000152a:	7902                	ld	s2,32(sp)
    8000152c:	6b02                	ld	s6,0(sp)
    8000152e:	bfc9                	j	80001500 <uvmalloc+0x86>
    return oldsz;
    80001530:	852e                	mv	a0,a1
}
    80001532:	8082                	ret
  return newsz;
    80001534:	8532                	mv	a0,a2
    80001536:	b7e9                	j	80001500 <uvmalloc+0x86>

0000000080001538 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    80001538:	7179                	addi	sp,sp,-48
    8000153a:	f406                	sd	ra,40(sp)
    8000153c:	f022                	sd	s0,32(sp)
    8000153e:	ec26                	sd	s1,24(sp)
    80001540:	e84a                	sd	s2,16(sp)
    80001542:	e44e                	sd	s3,8(sp)
    80001544:	e052                	sd	s4,0(sp)
    80001546:	1800                	addi	s0,sp,48
    80001548:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    8000154a:	84aa                	mv	s1,a0
    8000154c:	6905                	lui	s2,0x1
    8000154e:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001550:	4985                	li	s3,1
    80001552:	a829                	j	8000156c <freewalk+0x34>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    80001554:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    80001556:	00c79513          	slli	a0,a5,0xc
    8000155a:	00000097          	auipc	ra,0x0
    8000155e:	fde080e7          	jalr	-34(ra) # 80001538 <freewalk>
      pagetable[i] = 0;
    80001562:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    80001566:	04a1                	addi	s1,s1,8
    80001568:	03248163          	beq	s1,s2,8000158a <freewalk+0x52>
    pte_t pte = pagetable[i];
    8000156c:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    8000156e:	00f7f713          	andi	a4,a5,15
    80001572:	ff3701e3          	beq	a4,s3,80001554 <freewalk+0x1c>
    } else if(pte & PTE_V){
    80001576:	8b85                	andi	a5,a5,1
    80001578:	d7fd                	beqz	a5,80001566 <freewalk+0x2e>
      panic("freewalk: leaf");
    8000157a:	00007517          	auipc	a0,0x7
    8000157e:	bde50513          	addi	a0,a0,-1058 # 80008158 <etext+0x158>
    80001582:	fffff097          	auipc	ra,0xfffff
    80001586:	fde080e7          	jalr	-34(ra) # 80000560 <panic>
    }
  }
  kfree((void*)pagetable);
    8000158a:	8552                	mv	a0,s4
    8000158c:	fffff097          	auipc	ra,0xfffff
    80001590:	4be080e7          	jalr	1214(ra) # 80000a4a <kfree>
}
    80001594:	70a2                	ld	ra,40(sp)
    80001596:	7402                	ld	s0,32(sp)
    80001598:	64e2                	ld	s1,24(sp)
    8000159a:	6942                	ld	s2,16(sp)
    8000159c:	69a2                	ld	s3,8(sp)
    8000159e:	6a02                	ld	s4,0(sp)
    800015a0:	6145                	addi	sp,sp,48
    800015a2:	8082                	ret

00000000800015a4 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    800015a4:	1101                	addi	sp,sp,-32
    800015a6:	ec06                	sd	ra,24(sp)
    800015a8:	e822                	sd	s0,16(sp)
    800015aa:	e426                	sd	s1,8(sp)
    800015ac:	1000                	addi	s0,sp,32
    800015ae:	84aa                	mv	s1,a0
  if(sz > 0)
    800015b0:	e999                	bnez	a1,800015c6 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    800015b2:	8526                	mv	a0,s1
    800015b4:	00000097          	auipc	ra,0x0
    800015b8:	f84080e7          	jalr	-124(ra) # 80001538 <freewalk>
}
    800015bc:	60e2                	ld	ra,24(sp)
    800015be:	6442                	ld	s0,16(sp)
    800015c0:	64a2                	ld	s1,8(sp)
    800015c2:	6105                	addi	sp,sp,32
    800015c4:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    800015c6:	6785                	lui	a5,0x1
    800015c8:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800015ca:	95be                	add	a1,a1,a5
    800015cc:	4685                	li	a3,1
    800015ce:	00c5d613          	srli	a2,a1,0xc
    800015d2:	4581                	li	a1,0
    800015d4:	00000097          	auipc	ra,0x0
    800015d8:	cea080e7          	jalr	-790(ra) # 800012be <uvmunmap>
    800015dc:	bfd9                	j	800015b2 <uvmfree+0xe>

00000000800015de <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    800015de:	c679                	beqz	a2,800016ac <uvmcopy+0xce>
{
    800015e0:	715d                	addi	sp,sp,-80
    800015e2:	e486                	sd	ra,72(sp)
    800015e4:	e0a2                	sd	s0,64(sp)
    800015e6:	fc26                	sd	s1,56(sp)
    800015e8:	f84a                	sd	s2,48(sp)
    800015ea:	f44e                	sd	s3,40(sp)
    800015ec:	f052                	sd	s4,32(sp)
    800015ee:	ec56                	sd	s5,24(sp)
    800015f0:	e85a                	sd	s6,16(sp)
    800015f2:	e45e                	sd	s7,8(sp)
    800015f4:	0880                	addi	s0,sp,80
    800015f6:	8b2a                	mv	s6,a0
    800015f8:	8aae                	mv	s5,a1
    800015fa:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    800015fc:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    800015fe:	4601                	li	a2,0
    80001600:	85ce                	mv	a1,s3
    80001602:	855a                	mv	a0,s6
    80001604:	00000097          	auipc	ra,0x0
    80001608:	a0c080e7          	jalr	-1524(ra) # 80001010 <walk>
    8000160c:	c531                	beqz	a0,80001658 <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    8000160e:	6118                	ld	a4,0(a0)
    80001610:	00177793          	andi	a5,a4,1
    80001614:	cbb1                	beqz	a5,80001668 <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    80001616:	00a75593          	srli	a1,a4,0xa
    8000161a:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    8000161e:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    80001622:	fffff097          	auipc	ra,0xfffff
    80001626:	526080e7          	jalr	1318(ra) # 80000b48 <kalloc>
    8000162a:	892a                	mv	s2,a0
    8000162c:	c939                	beqz	a0,80001682 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    8000162e:	6605                	lui	a2,0x1
    80001630:	85de                	mv	a1,s7
    80001632:	fffff097          	auipc	ra,0xfffff
    80001636:	75e080e7          	jalr	1886(ra) # 80000d90 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    8000163a:	8726                	mv	a4,s1
    8000163c:	86ca                	mv	a3,s2
    8000163e:	6605                	lui	a2,0x1
    80001640:	85ce                	mv	a1,s3
    80001642:	8556                	mv	a0,s5
    80001644:	00000097          	auipc	ra,0x0
    80001648:	ab4080e7          	jalr	-1356(ra) # 800010f8 <mappages>
    8000164c:	e515                	bnez	a0,80001678 <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    8000164e:	6785                	lui	a5,0x1
    80001650:	99be                	add	s3,s3,a5
    80001652:	fb49e6e3          	bltu	s3,s4,800015fe <uvmcopy+0x20>
    80001656:	a081                	j	80001696 <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    80001658:	00007517          	auipc	a0,0x7
    8000165c:	b1050513          	addi	a0,a0,-1264 # 80008168 <etext+0x168>
    80001660:	fffff097          	auipc	ra,0xfffff
    80001664:	f00080e7          	jalr	-256(ra) # 80000560 <panic>
      panic("uvmcopy: page not present");
    80001668:	00007517          	auipc	a0,0x7
    8000166c:	b2050513          	addi	a0,a0,-1248 # 80008188 <etext+0x188>
    80001670:	fffff097          	auipc	ra,0xfffff
    80001674:	ef0080e7          	jalr	-272(ra) # 80000560 <panic>
      kfree(mem);
    80001678:	854a                	mv	a0,s2
    8000167a:	fffff097          	auipc	ra,0xfffff
    8000167e:	3d0080e7          	jalr	976(ra) # 80000a4a <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001682:	4685                	li	a3,1
    80001684:	00c9d613          	srli	a2,s3,0xc
    80001688:	4581                	li	a1,0
    8000168a:	8556                	mv	a0,s5
    8000168c:	00000097          	auipc	ra,0x0
    80001690:	c32080e7          	jalr	-974(ra) # 800012be <uvmunmap>
  return -1;
    80001694:	557d                	li	a0,-1
}
    80001696:	60a6                	ld	ra,72(sp)
    80001698:	6406                	ld	s0,64(sp)
    8000169a:	74e2                	ld	s1,56(sp)
    8000169c:	7942                	ld	s2,48(sp)
    8000169e:	79a2                	ld	s3,40(sp)
    800016a0:	7a02                	ld	s4,32(sp)
    800016a2:	6ae2                	ld	s5,24(sp)
    800016a4:	6b42                	ld	s6,16(sp)
    800016a6:	6ba2                	ld	s7,8(sp)
    800016a8:	6161                	addi	sp,sp,80
    800016aa:	8082                	ret
  return 0;
    800016ac:	4501                	li	a0,0
}
    800016ae:	8082                	ret

00000000800016b0 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    800016b0:	1141                	addi	sp,sp,-16
    800016b2:	e406                	sd	ra,8(sp)
    800016b4:	e022                	sd	s0,0(sp)
    800016b6:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    800016b8:	4601                	li	a2,0
    800016ba:	00000097          	auipc	ra,0x0
    800016be:	956080e7          	jalr	-1706(ra) # 80001010 <walk>
  if(pte == 0)
    800016c2:	c901                	beqz	a0,800016d2 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    800016c4:	611c                	ld	a5,0(a0)
    800016c6:	9bbd                	andi	a5,a5,-17
    800016c8:	e11c                	sd	a5,0(a0)
}
    800016ca:	60a2                	ld	ra,8(sp)
    800016cc:	6402                	ld	s0,0(sp)
    800016ce:	0141                	addi	sp,sp,16
    800016d0:	8082                	ret
    panic("uvmclear");
    800016d2:	00007517          	auipc	a0,0x7
    800016d6:	ad650513          	addi	a0,a0,-1322 # 800081a8 <etext+0x1a8>
    800016da:	fffff097          	auipc	ra,0xfffff
    800016de:	e86080e7          	jalr	-378(ra) # 80000560 <panic>

00000000800016e2 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800016e2:	c6bd                	beqz	a3,80001750 <copyout+0x6e>
{
    800016e4:	715d                	addi	sp,sp,-80
    800016e6:	e486                	sd	ra,72(sp)
    800016e8:	e0a2                	sd	s0,64(sp)
    800016ea:	fc26                	sd	s1,56(sp)
    800016ec:	f84a                	sd	s2,48(sp)
    800016ee:	f44e                	sd	s3,40(sp)
    800016f0:	f052                	sd	s4,32(sp)
    800016f2:	ec56                	sd	s5,24(sp)
    800016f4:	e85a                	sd	s6,16(sp)
    800016f6:	e45e                	sd	s7,8(sp)
    800016f8:	e062                	sd	s8,0(sp)
    800016fa:	0880                	addi	s0,sp,80
    800016fc:	8b2a                	mv	s6,a0
    800016fe:	8c2e                	mv	s8,a1
    80001700:	8a32                	mv	s4,a2
    80001702:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80001704:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    80001706:	6a85                	lui	s5,0x1
    80001708:	a015                	j	8000172c <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    8000170a:	9562                	add	a0,a0,s8
    8000170c:	0004861b          	sext.w	a2,s1
    80001710:	85d2                	mv	a1,s4
    80001712:	41250533          	sub	a0,a0,s2
    80001716:	fffff097          	auipc	ra,0xfffff
    8000171a:	67a080e7          	jalr	1658(ra) # 80000d90 <memmove>

    len -= n;
    8000171e:	409989b3          	sub	s3,s3,s1
    src += n;
    80001722:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    80001724:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001728:	02098263          	beqz	s3,8000174c <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    8000172c:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001730:	85ca                	mv	a1,s2
    80001732:	855a                	mv	a0,s6
    80001734:	00000097          	auipc	ra,0x0
    80001738:	982080e7          	jalr	-1662(ra) # 800010b6 <walkaddr>
    if(pa0 == 0)
    8000173c:	cd01                	beqz	a0,80001754 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    8000173e:	418904b3          	sub	s1,s2,s8
    80001742:	94d6                	add	s1,s1,s5
    if(n > len)
    80001744:	fc99f3e3          	bgeu	s3,s1,8000170a <copyout+0x28>
    80001748:	84ce                	mv	s1,s3
    8000174a:	b7c1                	j	8000170a <copyout+0x28>
  }
  return 0;
    8000174c:	4501                	li	a0,0
    8000174e:	a021                	j	80001756 <copyout+0x74>
    80001750:	4501                	li	a0,0
}
    80001752:	8082                	ret
      return -1;
    80001754:	557d                	li	a0,-1
}
    80001756:	60a6                	ld	ra,72(sp)
    80001758:	6406                	ld	s0,64(sp)
    8000175a:	74e2                	ld	s1,56(sp)
    8000175c:	7942                	ld	s2,48(sp)
    8000175e:	79a2                	ld	s3,40(sp)
    80001760:	7a02                	ld	s4,32(sp)
    80001762:	6ae2                	ld	s5,24(sp)
    80001764:	6b42                	ld	s6,16(sp)
    80001766:	6ba2                	ld	s7,8(sp)
    80001768:	6c02                	ld	s8,0(sp)
    8000176a:	6161                	addi	sp,sp,80
    8000176c:	8082                	ret

000000008000176e <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    8000176e:	caa5                	beqz	a3,800017de <copyin+0x70>
{
    80001770:	715d                	addi	sp,sp,-80
    80001772:	e486                	sd	ra,72(sp)
    80001774:	e0a2                	sd	s0,64(sp)
    80001776:	fc26                	sd	s1,56(sp)
    80001778:	f84a                	sd	s2,48(sp)
    8000177a:	f44e                	sd	s3,40(sp)
    8000177c:	f052                	sd	s4,32(sp)
    8000177e:	ec56                	sd	s5,24(sp)
    80001780:	e85a                	sd	s6,16(sp)
    80001782:	e45e                	sd	s7,8(sp)
    80001784:	e062                	sd	s8,0(sp)
    80001786:	0880                	addi	s0,sp,80
    80001788:	8b2a                	mv	s6,a0
    8000178a:	8a2e                	mv	s4,a1
    8000178c:	8c32                	mv	s8,a2
    8000178e:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001790:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001792:	6a85                	lui	s5,0x1
    80001794:	a01d                	j	800017ba <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001796:	018505b3          	add	a1,a0,s8
    8000179a:	0004861b          	sext.w	a2,s1
    8000179e:	412585b3          	sub	a1,a1,s2
    800017a2:	8552                	mv	a0,s4
    800017a4:	fffff097          	auipc	ra,0xfffff
    800017a8:	5ec080e7          	jalr	1516(ra) # 80000d90 <memmove>

    len -= n;
    800017ac:	409989b3          	sub	s3,s3,s1
    dst += n;
    800017b0:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    800017b2:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800017b6:	02098263          	beqz	s3,800017da <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    800017ba:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800017be:	85ca                	mv	a1,s2
    800017c0:	855a                	mv	a0,s6
    800017c2:	00000097          	auipc	ra,0x0
    800017c6:	8f4080e7          	jalr	-1804(ra) # 800010b6 <walkaddr>
    if(pa0 == 0)
    800017ca:	cd01                	beqz	a0,800017e2 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    800017cc:	418904b3          	sub	s1,s2,s8
    800017d0:	94d6                	add	s1,s1,s5
    if(n > len)
    800017d2:	fc99f2e3          	bgeu	s3,s1,80001796 <copyin+0x28>
    800017d6:	84ce                	mv	s1,s3
    800017d8:	bf7d                	j	80001796 <copyin+0x28>
  }
  return 0;
    800017da:	4501                	li	a0,0
    800017dc:	a021                	j	800017e4 <copyin+0x76>
    800017de:	4501                	li	a0,0
}
    800017e0:	8082                	ret
      return -1;
    800017e2:	557d                	li	a0,-1
}
    800017e4:	60a6                	ld	ra,72(sp)
    800017e6:	6406                	ld	s0,64(sp)
    800017e8:	74e2                	ld	s1,56(sp)
    800017ea:	7942                	ld	s2,48(sp)
    800017ec:	79a2                	ld	s3,40(sp)
    800017ee:	7a02                	ld	s4,32(sp)
    800017f0:	6ae2                	ld	s5,24(sp)
    800017f2:	6b42                	ld	s6,16(sp)
    800017f4:	6ba2                	ld	s7,8(sp)
    800017f6:	6c02                	ld	s8,0(sp)
    800017f8:	6161                	addi	sp,sp,80
    800017fa:	8082                	ret

00000000800017fc <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    800017fc:	cacd                	beqz	a3,800018ae <copyinstr+0xb2>
{
    800017fe:	715d                	addi	sp,sp,-80
    80001800:	e486                	sd	ra,72(sp)
    80001802:	e0a2                	sd	s0,64(sp)
    80001804:	fc26                	sd	s1,56(sp)
    80001806:	f84a                	sd	s2,48(sp)
    80001808:	f44e                	sd	s3,40(sp)
    8000180a:	f052                	sd	s4,32(sp)
    8000180c:	ec56                	sd	s5,24(sp)
    8000180e:	e85a                	sd	s6,16(sp)
    80001810:	e45e                	sd	s7,8(sp)
    80001812:	0880                	addi	s0,sp,80
    80001814:	8a2a                	mv	s4,a0
    80001816:	8b2e                	mv	s6,a1
    80001818:	8bb2                	mv	s7,a2
    8000181a:	8936                	mv	s2,a3
    va0 = PGROUNDDOWN(srcva);
    8000181c:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000181e:	6985                	lui	s3,0x1
    80001820:	a825                	j	80001858 <copyinstr+0x5c>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80001822:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80001826:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80001828:	37fd                	addiw	a5,a5,-1
    8000182a:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    8000182e:	60a6                	ld	ra,72(sp)
    80001830:	6406                	ld	s0,64(sp)
    80001832:	74e2                	ld	s1,56(sp)
    80001834:	7942                	ld	s2,48(sp)
    80001836:	79a2                	ld	s3,40(sp)
    80001838:	7a02                	ld	s4,32(sp)
    8000183a:	6ae2                	ld	s5,24(sp)
    8000183c:	6b42                	ld	s6,16(sp)
    8000183e:	6ba2                	ld	s7,8(sp)
    80001840:	6161                	addi	sp,sp,80
    80001842:	8082                	ret
    80001844:	fff90713          	addi	a4,s2,-1 # fff <_entry-0x7ffff001>
    80001848:	9742                	add	a4,a4,a6
      --max;
    8000184a:	40b70933          	sub	s2,a4,a1
    srcva = va0 + PGSIZE;
    8000184e:	01348bb3          	add	s7,s1,s3
  while(got_null == 0 && max > 0){
    80001852:	04e58663          	beq	a1,a4,8000189e <copyinstr+0xa2>
{
    80001856:	8b3e                	mv	s6,a5
    va0 = PGROUNDDOWN(srcva);
    80001858:	015bf4b3          	and	s1,s7,s5
    pa0 = walkaddr(pagetable, va0);
    8000185c:	85a6                	mv	a1,s1
    8000185e:	8552                	mv	a0,s4
    80001860:	00000097          	auipc	ra,0x0
    80001864:	856080e7          	jalr	-1962(ra) # 800010b6 <walkaddr>
    if(pa0 == 0)
    80001868:	cd0d                	beqz	a0,800018a2 <copyinstr+0xa6>
    n = PGSIZE - (srcva - va0);
    8000186a:	417486b3          	sub	a3,s1,s7
    8000186e:	96ce                	add	a3,a3,s3
    if(n > max)
    80001870:	00d97363          	bgeu	s2,a3,80001876 <copyinstr+0x7a>
    80001874:	86ca                	mv	a3,s2
    char *p = (char *) (pa0 + (srcva - va0));
    80001876:	955e                	add	a0,a0,s7
    80001878:	8d05                	sub	a0,a0,s1
    while(n > 0){
    8000187a:	c695                	beqz	a3,800018a6 <copyinstr+0xaa>
    8000187c:	87da                	mv	a5,s6
    8000187e:	885a                	mv	a6,s6
      if(*p == '\0'){
    80001880:	41650633          	sub	a2,a0,s6
    while(n > 0){
    80001884:	96da                	add	a3,a3,s6
    80001886:	85be                	mv	a1,a5
      if(*p == '\0'){
    80001888:	00f60733          	add	a4,a2,a5
    8000188c:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffb24e0>
    80001890:	db49                	beqz	a4,80001822 <copyinstr+0x26>
        *dst = *p;
    80001892:	00e78023          	sb	a4,0(a5)
      dst++;
    80001896:	0785                	addi	a5,a5,1
    while(n > 0){
    80001898:	fed797e3          	bne	a5,a3,80001886 <copyinstr+0x8a>
    8000189c:	b765                	j	80001844 <copyinstr+0x48>
    8000189e:	4781                	li	a5,0
    800018a0:	b761                	j	80001828 <copyinstr+0x2c>
      return -1;
    800018a2:	557d                	li	a0,-1
    800018a4:	b769                	j	8000182e <copyinstr+0x32>
    srcva = va0 + PGSIZE;
    800018a6:	6b85                	lui	s7,0x1
    800018a8:	9ba6                	add	s7,s7,s1
    800018aa:	87da                	mv	a5,s6
    800018ac:	b76d                	j	80001856 <copyinstr+0x5a>
  int got_null = 0;
    800018ae:	4781                	li	a5,0
  if(got_null){
    800018b0:	37fd                	addiw	a5,a5,-1
    800018b2:	0007851b          	sext.w	a0,a5
}
    800018b6:	8082                	ret

00000000800018b8 <log_process_queue>:
struct log_entry logs[MAX_LOG_ENTRIES];
int log_index = 0;

int random_ct =0 ;

void log_process_queue(struct proc *p) {
    800018b8:	1141                	addi	sp,sp,-16
    800018ba:	e422                	sd	s0,8(sp)
    800018bc:	0800                	addi	s0,sp,16
  if (log_index < MAX_LOG_ENTRIES) {
    800018be:	00007797          	auipc	a5,0x7
    800018c2:	2567a783          	lw	a5,598(a5) # 80008b14 <log_index>
    800018c6:	6709                	lui	a4,0x2
    800018c8:	75670713          	addi	a4,a4,1878 # 2756 <_entry-0x7fffd8aa>
    800018cc:	02f74e63          	blt	a4,a5,80001908 <log_process_queue+0x50>
    logs[log_index].pid = p->pid - 2;
    800018d0:	00479693          	slli	a3,a5,0x4
    800018d4:	00019717          	auipc	a4,0x19
    800018d8:	8fc70713          	addi	a4,a4,-1796 # 8001a1d0 <logs>
    800018dc:	9736                	add	a4,a4,a3
    800018de:	5914                	lw	a3,48(a0)
    800018e0:	36f9                	addiw	a3,a3,-2 # ffffffffffffeffe <end+0xffffffff7ffb24de>
    800018e2:	c314                	sw	a3,0(a4)
    logs[log_index].time = random_ct;
    800018e4:	00007697          	auipc	a3,0x7
    800018e8:	22c6a683          	lw	a3,556(a3) # 80008b10 <random_ct>
    800018ec:	c354                	sw	a3,4(a4)
    logs[log_index].ticktime = ticks;
    800018ee:	00007697          	auipc	a3,0x7
    800018f2:	22e6a683          	lw	a3,558(a3) # 80008b1c <ticks>
    800018f6:	c714                	sw	a3,8(a4)
    logs[log_index].queue = p->queue;
    800018f8:	23052683          	lw	a3,560(a0)
    800018fc:	c754                	sw	a3,12(a4)
    log_index++;
    800018fe:	2785                	addiw	a5,a5,1
    80001900:	00007717          	auipc	a4,0x7
    80001904:	20f72a23          	sw	a5,532(a4) # 80008b14 <log_index>
  }
}
    80001908:	6422                	ld	s0,8(sp)
    8000190a:	0141                	addi	sp,sp,16
    8000190c:	8082                	ret

000000008000190e <count_trailing_zeros>:


int count_trailing_zeros(uint64_t value) {
    8000190e:	1141                	addi	sp,sp,-16
    80001910:	e422                	sd	s0,8(sp)
    80001912:	0800                	addi	s0,sp,16
    if (value == 0) {
    80001914:	cd11                	beqz	a0,80001930 <count_trailing_zeros+0x22>
    80001916:	87aa                	mv	a5,a0
        return 64; // If the value is zero, return 64 (all bits are zero)
    }
    
    int count = 0;
    while ((value & 1) == 0) { // While the least significant bit is 0
    80001918:	00157713          	andi	a4,a0,1
    8000191c:	ef09                	bnez	a4,80001936 <count_trailing_zeros+0x28>
    int count = 0;
    8000191e:	4501                	li	a0,0
        count++;
    80001920:	2505                	addiw	a0,a0,1
        value >>= 1; // Right shift to check the next bit
    80001922:	8385                	srli	a5,a5,0x1
    while ((value & 1) == 0) { // While the least significant bit is 0
    80001924:	0017f713          	andi	a4,a5,1
    80001928:	df65                	beqz	a4,80001920 <count_trailing_zeros+0x12>
    }
    return count; // Return the count of trailing zeros
}
    8000192a:	6422                	ld	s0,8(sp)
    8000192c:	0141                	addi	sp,sp,16
    8000192e:	8082                	ret
        return 64; // If the value is zero, return 64 (all bits are zero)
    80001930:	04000513          	li	a0,64
    80001934:	bfdd                	j	8000192a <count_trailing_zeros+0x1c>
    return count; // Return the count of trailing zeros
    80001936:	4501                	li	a0,0
    80001938:	bfcd                	j	8000192a <count_trailing_zeros+0x1c>

000000008000193a <rg>:




int rg(int l, int r)
{
    8000193a:	1141                	addi	sp,sp,-16
    8000193c:	e422                	sd	s0,8(sp)
    8000193e:	0800                	addi	s0,sp,16
  uint64 lbs_tr = (uint64)ticks + 0;
    80001940:	00007717          	auipc	a4,0x7
    80001944:	1dc76703          	lwu	a4,476(a4) # 80008b1c <ticks>
  lbs_tr = lbs_tr ^ (lbs_tr << 13);
    80001948:	00d71793          	slli	a5,a4,0xd
    8000194c:	8fb9                	xor	a5,a5,a4
  lbs_tr = lbs_tr ^ (lbs_tr >> 17);
    8000194e:	0117d713          	srli	a4,a5,0x11
    80001952:	8f3d                	xor	a4,a4,a5
  lbs_tr = lbs_tr ^ (lbs_tr << 5);
    80001954:	00571793          	slli	a5,a4,0x5
    80001958:	8fb9                	xor	a5,a5,a4

  lbs_tr = lbs_tr % (r - l);
    8000195a:	9d89                	subw	a1,a1,a0
    8000195c:	02b7f7b3          	remu	a5,a5,a1
  lbs_tr = lbs_tr + l;

  return lbs_tr;
}
    80001960:	9d3d                	addw	a0,a0,a5
    80001962:	6422                	ld	s0,8(sp)
    80001964:	0141                	addi	sp,sp,16
    80001966:	8082                	ret

0000000080001968 <max>:


int max(int a, int b)
{
    80001968:	1141                	addi	sp,sp,-16
    8000196a:	e422                	sd	s0,8(sp)
    8000196c:	0800                	addi	s0,sp,16

  if (a > b)
    8000196e:	87aa                	mv	a5,a0
    80001970:	00b55363          	bge	a0,a1,80001976 <max+0xe>
    80001974:	87ae                	mv	a5,a1
  }
  else
  {
    return b;
  }
}
    80001976:	0007851b          	sext.w	a0,a5
    8000197a:	6422                	ld	s0,8(sp)
    8000197c:	0141                	addi	sp,sp,16
    8000197e:	8082                	ret

0000000080001980 <min>:

int min(int a, int b)
{
    80001980:	1141                	addi	sp,sp,-16
    80001982:	e422                	sd	s0,8(sp)
    80001984:	0800                	addi	s0,sp,16

  if (a < b)
    80001986:	87aa                	mv	a5,a0
    80001988:	00a5d363          	bge	a1,a0,8000198e <min+0xe>
    8000198c:	87ae                	mv	a5,a1
  }
  else
  {
    return b;
  }
}
    8000198e:	0007851b          	sext.w	a0,a5
    80001992:	6422                	ld	s0,8(sp)
    80001994:	0141                	addi	sp,sp,16
    80001996:	8082                	ret

0000000080001998 <proc_mapstacks>:

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void proc_mapstacks(pagetable_t kpgtbl)
{
    80001998:	7139                	addi	sp,sp,-64
    8000199a:	fc06                	sd	ra,56(sp)
    8000199c:	f822                	sd	s0,48(sp)
    8000199e:	f426                	sd	s1,40(sp)
    800019a0:	f04a                	sd	s2,32(sp)
    800019a2:	ec4e                	sd	s3,24(sp)
    800019a4:	e852                	sd	s4,16(sp)
    800019a6:	e456                	sd	s5,8(sp)
    800019a8:	e05a                	sd	s6,0(sp)
    800019aa:	0080                	addi	s0,sp,64
    800019ac:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    800019ae:	00010497          	auipc	s1,0x10
    800019b2:	82248493          	addi	s1,s1,-2014 # 800111d0 <proc>
  {
    char *pa = kalloc();
    if (pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int)(p - proc));
    800019b6:	8b26                	mv	s6,s1
    800019b8:	f8e39937          	lui	s2,0xf8e39
    800019bc:	e3990913          	addi	s2,s2,-455 # fffffffff8e38e39 <end+0xffffffff78dec319>
    800019c0:	0932                	slli	s2,s2,0xc
    800019c2:	e3990913          	addi	s2,s2,-455
    800019c6:	0932                	slli	s2,s2,0xc
    800019c8:	e3990913          	addi	s2,s2,-455
    800019cc:	0932                	slli	s2,s2,0xc
    800019ce:	e3990913          	addi	s2,s2,-455
    800019d2:	040009b7          	lui	s3,0x4000
    800019d6:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    800019d8:	09b2                	slli	s3,s3,0xc
  for (p = proc; p < &proc[NPROC]; p++)
    800019da:	00018a97          	auipc	s5,0x18
    800019de:	7f6a8a93          	addi	s5,s5,2038 # 8001a1d0 <logs>
    char *pa = kalloc();
    800019e2:	fffff097          	auipc	ra,0xfffff
    800019e6:	166080e7          	jalr	358(ra) # 80000b48 <kalloc>
    800019ea:	862a                	mv	a2,a0
    if (pa == 0)
    800019ec:	c121                	beqz	a0,80001a2c <proc_mapstacks+0x94>
    uint64 va = KSTACK((int)(p - proc));
    800019ee:	416485b3          	sub	a1,s1,s6
    800019f2:	8599                	srai	a1,a1,0x6
    800019f4:	032585b3          	mul	a1,a1,s2
    800019f8:	2585                	addiw	a1,a1,1
    800019fa:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800019fe:	4719                	li	a4,6
    80001a00:	6685                	lui	a3,0x1
    80001a02:	40b985b3          	sub	a1,s3,a1
    80001a06:	8552                	mv	a0,s4
    80001a08:	fffff097          	auipc	ra,0xfffff
    80001a0c:	790080e7          	jalr	1936(ra) # 80001198 <kvmmap>
  for (p = proc; p < &proc[NPROC]; p++)
    80001a10:	24048493          	addi	s1,s1,576
    80001a14:	fd5497e3          	bne	s1,s5,800019e2 <proc_mapstacks+0x4a>
  }
}
    80001a18:	70e2                	ld	ra,56(sp)
    80001a1a:	7442                	ld	s0,48(sp)
    80001a1c:	74a2                	ld	s1,40(sp)
    80001a1e:	7902                	ld	s2,32(sp)
    80001a20:	69e2                	ld	s3,24(sp)
    80001a22:	6a42                	ld	s4,16(sp)
    80001a24:	6aa2                	ld	s5,8(sp)
    80001a26:	6b02                	ld	s6,0(sp)
    80001a28:	6121                	addi	sp,sp,64
    80001a2a:	8082                	ret
      panic("kalloc");
    80001a2c:	00006517          	auipc	a0,0x6
    80001a30:	78c50513          	addi	a0,a0,1932 # 800081b8 <etext+0x1b8>
    80001a34:	fffff097          	auipc	ra,0xfffff
    80001a38:	b2c080e7          	jalr	-1236(ra) # 80000560 <panic>

0000000080001a3c <procinit>:

// initialize the proc table.
void procinit(void)
{
    80001a3c:	7139                	addi	sp,sp,-64
    80001a3e:	fc06                	sd	ra,56(sp)
    80001a40:	f822                	sd	s0,48(sp)
    80001a42:	f426                	sd	s1,40(sp)
    80001a44:	f04a                	sd	s2,32(sp)
    80001a46:	ec4e                	sd	s3,24(sp)
    80001a48:	e852                	sd	s4,16(sp)
    80001a4a:	e456                	sd	s5,8(sp)
    80001a4c:	e05a                	sd	s6,0(sp)
    80001a4e:	0080                	addi	s0,sp,64
  struct proc *p;

  initlock(&pid_lock, "nextpid");
    80001a50:	00006597          	auipc	a1,0x6
    80001a54:	77058593          	addi	a1,a1,1904 # 800081c0 <etext+0x1c0>
    80001a58:	0000f517          	auipc	a0,0xf
    80001a5c:	32850513          	addi	a0,a0,808 # 80010d80 <pid_lock>
    80001a60:	fffff097          	auipc	ra,0xfffff
    80001a64:	148080e7          	jalr	328(ra) # 80000ba8 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001a68:	00006597          	auipc	a1,0x6
    80001a6c:	76058593          	addi	a1,a1,1888 # 800081c8 <etext+0x1c8>
    80001a70:	0000f517          	auipc	a0,0xf
    80001a74:	32850513          	addi	a0,a0,808 # 80010d98 <wait_lock>
    80001a78:	fffff097          	auipc	ra,0xfffff
    80001a7c:	130080e7          	jalr	304(ra) # 80000ba8 <initlock>
  for (p = proc; p < &proc[NPROC]; p++)
    80001a80:	0000f497          	auipc	s1,0xf
    80001a84:	75048493          	addi	s1,s1,1872 # 800111d0 <proc>
  {
    initlock(&p->lock, "proc");
    80001a88:	00006b17          	auipc	s6,0x6
    80001a8c:	750b0b13          	addi	s6,s6,1872 # 800081d8 <etext+0x1d8>
    p->state = UNUSED;
    p->kstack = KSTACK((int)(p - proc));
    80001a90:	8aa6                	mv	s5,s1
    80001a92:	f8e39937          	lui	s2,0xf8e39
    80001a96:	e3990913          	addi	s2,s2,-455 # fffffffff8e38e39 <end+0xffffffff78dec319>
    80001a9a:	0932                	slli	s2,s2,0xc
    80001a9c:	e3990913          	addi	s2,s2,-455
    80001aa0:	0932                	slli	s2,s2,0xc
    80001aa2:	e3990913          	addi	s2,s2,-455
    80001aa6:	0932                	slli	s2,s2,0xc
    80001aa8:	e3990913          	addi	s2,s2,-455
    80001aac:	040009b7          	lui	s3,0x4000
    80001ab0:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001ab2:	09b2                	slli	s3,s3,0xc
  for (p = proc; p < &proc[NPROC]; p++)
    80001ab4:	00018a17          	auipc	s4,0x18
    80001ab8:	71ca0a13          	addi	s4,s4,1820 # 8001a1d0 <logs>
    initlock(&p->lock, "proc");
    80001abc:	85da                	mv	a1,s6
    80001abe:	8526                	mv	a0,s1
    80001ac0:	fffff097          	auipc	ra,0xfffff
    80001ac4:	0e8080e7          	jalr	232(ra) # 80000ba8 <initlock>
    p->state = UNUSED;
    80001ac8:	0004ac23          	sw	zero,24(s1)
    p->kstack = KSTACK((int)(p - proc));
    80001acc:	415487b3          	sub	a5,s1,s5
    80001ad0:	8799                	srai	a5,a5,0x6
    80001ad2:	032787b3          	mul	a5,a5,s2
    80001ad6:	2785                	addiw	a5,a5,1
    80001ad8:	00d7979b          	slliw	a5,a5,0xd
    80001adc:	40f987b3          	sub	a5,s3,a5
    80001ae0:	e0bc                	sd	a5,64(s1)
  for (p = proc; p < &proc[NPROC]; p++)
    80001ae2:	24048493          	addi	s1,s1,576
    80001ae6:	fd449be3          	bne	s1,s4,80001abc <procinit+0x80>
  }
}
    80001aea:	70e2                	ld	ra,56(sp)
    80001aec:	7442                	ld	s0,48(sp)
    80001aee:	74a2                	ld	s1,40(sp)
    80001af0:	7902                	ld	s2,32(sp)
    80001af2:	69e2                	ld	s3,24(sp)
    80001af4:	6a42                	ld	s4,16(sp)
    80001af6:	6aa2                	ld	s5,8(sp)
    80001af8:	6b02                	ld	s6,0(sp)
    80001afa:	6121                	addi	sp,sp,64
    80001afc:	8082                	ret

0000000080001afe <cpuid>:

// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int cpuid()
{
    80001afe:	1141                	addi	sp,sp,-16
    80001b00:	e422                	sd	s0,8(sp)
    80001b02:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001b04:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001b06:	2501                	sext.w	a0,a0
    80001b08:	6422                	ld	s0,8(sp)
    80001b0a:	0141                	addi	sp,sp,16
    80001b0c:	8082                	ret

0000000080001b0e <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu *
mycpu(void)
{
    80001b0e:	1141                	addi	sp,sp,-16
    80001b10:	e422                	sd	s0,8(sp)
    80001b12:	0800                	addi	s0,sp,16
    80001b14:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001b16:	2781                	sext.w	a5,a5
    80001b18:	079e                	slli	a5,a5,0x7
  return c;
}
    80001b1a:	0000f517          	auipc	a0,0xf
    80001b1e:	29650513          	addi	a0,a0,662 # 80010db0 <cpus>
    80001b22:	953e                	add	a0,a0,a5
    80001b24:	6422                	ld	s0,8(sp)
    80001b26:	0141                	addi	sp,sp,16
    80001b28:	8082                	ret

0000000080001b2a <myproc>:

// Return the current struct proc *, or zero if none.
struct proc *
myproc(void)
{
    80001b2a:	1101                	addi	sp,sp,-32
    80001b2c:	ec06                	sd	ra,24(sp)
    80001b2e:	e822                	sd	s0,16(sp)
    80001b30:	e426                	sd	s1,8(sp)
    80001b32:	1000                	addi	s0,sp,32
  push_off();
    80001b34:	fffff097          	auipc	ra,0xfffff
    80001b38:	0b8080e7          	jalr	184(ra) # 80000bec <push_off>
    80001b3c:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001b3e:	2781                	sext.w	a5,a5
    80001b40:	079e                	slli	a5,a5,0x7
    80001b42:	0000f717          	auipc	a4,0xf
    80001b46:	23e70713          	addi	a4,a4,574 # 80010d80 <pid_lock>
    80001b4a:	97ba                	add	a5,a5,a4
    80001b4c:	7b84                	ld	s1,48(a5)
  pop_off();
    80001b4e:	fffff097          	auipc	ra,0xfffff
    80001b52:	13e080e7          	jalr	318(ra) # 80000c8c <pop_off>
  return p;
}
    80001b56:	8526                	mv	a0,s1
    80001b58:	60e2                	ld	ra,24(sp)
    80001b5a:	6442                	ld	s0,16(sp)
    80001b5c:	64a2                	ld	s1,8(sp)
    80001b5e:	6105                	addi	sp,sp,32
    80001b60:	8082                	ret

0000000080001b62 <forkret>:
}

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void forkret(void)
{
    80001b62:	1141                	addi	sp,sp,-16
    80001b64:	e406                	sd	ra,8(sp)
    80001b66:	e022                	sd	s0,0(sp)
    80001b68:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001b6a:	00000097          	auipc	ra,0x0
    80001b6e:	fc0080e7          	jalr	-64(ra) # 80001b2a <myproc>
    80001b72:	fffff097          	auipc	ra,0xfffff
    80001b76:	17a080e7          	jalr	378(ra) # 80000cec <release>

  if (first)
    80001b7a:	00007797          	auipc	a5,0x7
    80001b7e:	e467a783          	lw	a5,-442(a5) # 800089c0 <first.0>
    80001b82:	eb89                	bnez	a5,80001b94 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001b84:	00001097          	auipc	ra,0x1
    80001b88:	01e080e7          	jalr	30(ra) # 80002ba2 <usertrapret>
}
    80001b8c:	60a2                	ld	ra,8(sp)
    80001b8e:	6402                	ld	s0,0(sp)
    80001b90:	0141                	addi	sp,sp,16
    80001b92:	8082                	ret
    first = 0;
    80001b94:	00007797          	auipc	a5,0x7
    80001b98:	e207a623          	sw	zero,-468(a5) # 800089c0 <first.0>
    fsinit(ROOTDEV);
    80001b9c:	4505                	li	a0,1
    80001b9e:	00002097          	auipc	ra,0x2
    80001ba2:	f98080e7          	jalr	-104(ra) # 80003b36 <fsinit>
    80001ba6:	bff9                	j	80001b84 <forkret+0x22>

0000000080001ba8 <allocpid>:
{
    80001ba8:	1101                	addi	sp,sp,-32
    80001baa:	ec06                	sd	ra,24(sp)
    80001bac:	e822                	sd	s0,16(sp)
    80001bae:	e426                	sd	s1,8(sp)
    80001bb0:	e04a                	sd	s2,0(sp)
    80001bb2:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001bb4:	0000f917          	auipc	s2,0xf
    80001bb8:	1cc90913          	addi	s2,s2,460 # 80010d80 <pid_lock>
    80001bbc:	854a                	mv	a0,s2
    80001bbe:	fffff097          	auipc	ra,0xfffff
    80001bc2:	07a080e7          	jalr	122(ra) # 80000c38 <acquire>
  pid = nextpid;
    80001bc6:	00007797          	auipc	a5,0x7
    80001bca:	dfe78793          	addi	a5,a5,-514 # 800089c4 <nextpid>
    80001bce:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001bd0:	0014871b          	addiw	a4,s1,1
    80001bd4:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001bd6:	854a                	mv	a0,s2
    80001bd8:	fffff097          	auipc	ra,0xfffff
    80001bdc:	114080e7          	jalr	276(ra) # 80000cec <release>
}
    80001be0:	8526                	mv	a0,s1
    80001be2:	60e2                	ld	ra,24(sp)
    80001be4:	6442                	ld	s0,16(sp)
    80001be6:	64a2                	ld	s1,8(sp)
    80001be8:	6902                	ld	s2,0(sp)
    80001bea:	6105                	addi	sp,sp,32
    80001bec:	8082                	ret

0000000080001bee <proc_pagetable>:
{
    80001bee:	1101                	addi	sp,sp,-32
    80001bf0:	ec06                	sd	ra,24(sp)
    80001bf2:	e822                	sd	s0,16(sp)
    80001bf4:	e426                	sd	s1,8(sp)
    80001bf6:	e04a                	sd	s2,0(sp)
    80001bf8:	1000                	addi	s0,sp,32
    80001bfa:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001bfc:	fffff097          	auipc	ra,0xfffff
    80001c00:	796080e7          	jalr	1942(ra) # 80001392 <uvmcreate>
    80001c04:	84aa                	mv	s1,a0
  if (pagetable == 0)
    80001c06:	c121                	beqz	a0,80001c46 <proc_pagetable+0x58>
  if (mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001c08:	4729                	li	a4,10
    80001c0a:	00005697          	auipc	a3,0x5
    80001c0e:	3f668693          	addi	a3,a3,1014 # 80007000 <_trampoline>
    80001c12:	6605                	lui	a2,0x1
    80001c14:	040005b7          	lui	a1,0x4000
    80001c18:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001c1a:	05b2                	slli	a1,a1,0xc
    80001c1c:	fffff097          	auipc	ra,0xfffff
    80001c20:	4dc080e7          	jalr	1244(ra) # 800010f8 <mappages>
    80001c24:	02054863          	bltz	a0,80001c54 <proc_pagetable+0x66>
  if (mappages(pagetable, TRAPFRAME, PGSIZE,
    80001c28:	4719                	li	a4,6
    80001c2a:	05893683          	ld	a3,88(s2)
    80001c2e:	6605                	lui	a2,0x1
    80001c30:	020005b7          	lui	a1,0x2000
    80001c34:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001c36:	05b6                	slli	a1,a1,0xd
    80001c38:	8526                	mv	a0,s1
    80001c3a:	fffff097          	auipc	ra,0xfffff
    80001c3e:	4be080e7          	jalr	1214(ra) # 800010f8 <mappages>
    80001c42:	02054163          	bltz	a0,80001c64 <proc_pagetable+0x76>
}
    80001c46:	8526                	mv	a0,s1
    80001c48:	60e2                	ld	ra,24(sp)
    80001c4a:	6442                	ld	s0,16(sp)
    80001c4c:	64a2                	ld	s1,8(sp)
    80001c4e:	6902                	ld	s2,0(sp)
    80001c50:	6105                	addi	sp,sp,32
    80001c52:	8082                	ret
    uvmfree(pagetable, 0);
    80001c54:	4581                	li	a1,0
    80001c56:	8526                	mv	a0,s1
    80001c58:	00000097          	auipc	ra,0x0
    80001c5c:	94c080e7          	jalr	-1716(ra) # 800015a4 <uvmfree>
    return 0;
    80001c60:	4481                	li	s1,0
    80001c62:	b7d5                	j	80001c46 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001c64:	4681                	li	a3,0
    80001c66:	4605                	li	a2,1
    80001c68:	040005b7          	lui	a1,0x4000
    80001c6c:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001c6e:	05b2                	slli	a1,a1,0xc
    80001c70:	8526                	mv	a0,s1
    80001c72:	fffff097          	auipc	ra,0xfffff
    80001c76:	64c080e7          	jalr	1612(ra) # 800012be <uvmunmap>
    uvmfree(pagetable, 0);
    80001c7a:	4581                	li	a1,0
    80001c7c:	8526                	mv	a0,s1
    80001c7e:	00000097          	auipc	ra,0x0
    80001c82:	926080e7          	jalr	-1754(ra) # 800015a4 <uvmfree>
    return 0;
    80001c86:	4481                	li	s1,0
    80001c88:	bf7d                	j	80001c46 <proc_pagetable+0x58>

0000000080001c8a <proc_freepagetable>:
{
    80001c8a:	1101                	addi	sp,sp,-32
    80001c8c:	ec06                	sd	ra,24(sp)
    80001c8e:	e822                	sd	s0,16(sp)
    80001c90:	e426                	sd	s1,8(sp)
    80001c92:	e04a                	sd	s2,0(sp)
    80001c94:	1000                	addi	s0,sp,32
    80001c96:	84aa                	mv	s1,a0
    80001c98:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001c9a:	4681                	li	a3,0
    80001c9c:	4605                	li	a2,1
    80001c9e:	040005b7          	lui	a1,0x4000
    80001ca2:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001ca4:	05b2                	slli	a1,a1,0xc
    80001ca6:	fffff097          	auipc	ra,0xfffff
    80001caa:	618080e7          	jalr	1560(ra) # 800012be <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001cae:	4681                	li	a3,0
    80001cb0:	4605                	li	a2,1
    80001cb2:	020005b7          	lui	a1,0x2000
    80001cb6:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001cb8:	05b6                	slli	a1,a1,0xd
    80001cba:	8526                	mv	a0,s1
    80001cbc:	fffff097          	auipc	ra,0xfffff
    80001cc0:	602080e7          	jalr	1538(ra) # 800012be <uvmunmap>
  uvmfree(pagetable, sz);
    80001cc4:	85ca                	mv	a1,s2
    80001cc6:	8526                	mv	a0,s1
    80001cc8:	00000097          	auipc	ra,0x0
    80001ccc:	8dc080e7          	jalr	-1828(ra) # 800015a4 <uvmfree>
}
    80001cd0:	60e2                	ld	ra,24(sp)
    80001cd2:	6442                	ld	s0,16(sp)
    80001cd4:	64a2                	ld	s1,8(sp)
    80001cd6:	6902                	ld	s2,0(sp)
    80001cd8:	6105                	addi	sp,sp,32
    80001cda:	8082                	ret

0000000080001cdc <freeproc>:
{
    80001cdc:	1101                	addi	sp,sp,-32
    80001cde:	ec06                	sd	ra,24(sp)
    80001ce0:	e822                	sd	s0,16(sp)
    80001ce2:	e426                	sd	s1,8(sp)
    80001ce4:	1000                	addi	s0,sp,32
    80001ce6:	84aa                	mv	s1,a0
  if (p->trapframe)
    80001ce8:	6d28                	ld	a0,88(a0)
    80001cea:	c509                	beqz	a0,80001cf4 <freeproc+0x18>
    kfree((void *)p->trapframe);
    80001cec:	fffff097          	auipc	ra,0xfffff
    80001cf0:	d5e080e7          	jalr	-674(ra) # 80000a4a <kfree>
  p->trapframe = 0;
    80001cf4:	0404bc23          	sd	zero,88(s1)
  if (p->pagetable)
    80001cf8:	68a8                	ld	a0,80(s1)
    80001cfa:	c511                	beqz	a0,80001d06 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001cfc:	64ac                	ld	a1,72(s1)
    80001cfe:	00000097          	auipc	ra,0x0
    80001d02:	f8c080e7          	jalr	-116(ra) # 80001c8a <proc_freepagetable>
  p->pagetable = 0;
    80001d06:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001d0a:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001d0e:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001d12:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001d16:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001d1a:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001d1e:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001d22:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001d26:	0004ac23          	sw	zero,24(s1)
}
    80001d2a:	60e2                	ld	ra,24(sp)
    80001d2c:	6442                	ld	s0,16(sp)
    80001d2e:	64a2                	ld	s1,8(sp)
    80001d30:	6105                	addi	sp,sp,32
    80001d32:	8082                	ret

0000000080001d34 <allocproc>:
{
    80001d34:	1101                	addi	sp,sp,-32
    80001d36:	ec06                	sd	ra,24(sp)
    80001d38:	e822                	sd	s0,16(sp)
    80001d3a:	e426                	sd	s1,8(sp)
    80001d3c:	e04a                	sd	s2,0(sp)
    80001d3e:	1000                	addi	s0,sp,32
  for (p = proc; p < &proc[NPROC]; p++)
    80001d40:	0000f497          	auipc	s1,0xf
    80001d44:	49048493          	addi	s1,s1,1168 # 800111d0 <proc>
    80001d48:	00018917          	auipc	s2,0x18
    80001d4c:	48890913          	addi	s2,s2,1160 # 8001a1d0 <logs>
    acquire(&p->lock);
    80001d50:	8526                	mv	a0,s1
    80001d52:	fffff097          	auipc	ra,0xfffff
    80001d56:	ee6080e7          	jalr	-282(ra) # 80000c38 <acquire>
    if (p->state == UNUSED)
    80001d5a:	4c9c                	lw	a5,24(s1)
    80001d5c:	cf81                	beqz	a5,80001d74 <allocproc+0x40>
      release(&p->lock);
    80001d5e:	8526                	mv	a0,s1
    80001d60:	fffff097          	auipc	ra,0xfffff
    80001d64:	f8c080e7          	jalr	-116(ra) # 80000cec <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80001d68:	24048493          	addi	s1,s1,576
    80001d6c:	ff2492e3          	bne	s1,s2,80001d50 <allocproc+0x1c>
  return 0;
    80001d70:	4481                	li	s1,0
    80001d72:	a86d                	j	80001e2c <allocproc+0xf8>
  p->pid = allocpid();
    80001d74:	00000097          	auipc	ra,0x0
    80001d78:	e34080e7          	jalr	-460(ra) # 80001ba8 <allocpid>
    80001d7c:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001d7e:	4785                	li	a5,1
    80001d80:	cc9c                	sw	a5,24(s1)
  if ((p->trapframe = (struct trapframe *)kalloc()) == 0)
    80001d82:	fffff097          	auipc	ra,0xfffff
    80001d86:	dc6080e7          	jalr	-570(ra) # 80000b48 <kalloc>
    80001d8a:	892a                	mv	s2,a0
    80001d8c:	eca8                	sd	a0,88(s1)
    80001d8e:	c555                	beqz	a0,80001e3a <allocproc+0x106>
  p->pagetable = proc_pagetable(p);
    80001d90:	8526                	mv	a0,s1
    80001d92:	00000097          	auipc	ra,0x0
    80001d96:	e5c080e7          	jalr	-420(ra) # 80001bee <proc_pagetable>
    80001d9a:	892a                	mv	s2,a0
    80001d9c:	e8a8                	sd	a0,80(s1)
  if (p->pagetable == 0)
    80001d9e:	c955                	beqz	a0,80001e52 <allocproc+0x11e>
  memset(&p->context, 0, sizeof(p->context));
    80001da0:	07000613          	li	a2,112
    80001da4:	4581                	li	a1,0
    80001da6:	06048513          	addi	a0,s1,96
    80001daa:	fffff097          	auipc	ra,0xfffff
    80001dae:	f8a080e7          	jalr	-118(ra) # 80000d34 <memset>
  p->context.ra = (uint64)forkret;
    80001db2:	00000797          	auipc	a5,0x0
    80001db6:	db078793          	addi	a5,a5,-592 # 80001b62 <forkret>
    80001dba:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001dbc:	60bc                	ld	a5,64(s1)
    80001dbe:	6705                	lui	a4,0x1
    80001dc0:	97ba                	add	a5,a5,a4
    80001dc2:	f4bc                	sd	a5,104(s1)
   memset(p->syscall_count, 0, sizeof(p->syscall_count));
    80001dc4:	08000613          	li	a2,128
    80001dc8:	4581                	li	a1,0
    80001dca:	17448513          	addi	a0,s1,372
    80001dce:	fffff097          	auipc	ra,0xfffff
    80001dd2:	f66080e7          	jalr	-154(ra) # 80000d34 <memset>
  p->rtime = 0;
    80001dd6:	1604a423          	sw	zero,360(s1)
  p->etime = 0;
    80001dda:	1604a823          	sw	zero,368(s1)
  p->ctime = ticks;
    80001dde:	00007797          	auipc	a5,0x7
    80001de2:	d3e7a783          	lw	a5,-706(a5) # 80008b1c <ticks>
    80001de6:	16f4a623          	sw	a5,364(s1)
  p->tickets = 1;
    80001dea:	4705                	li	a4,1
    80001dec:	1ee4ac23          	sw	a4,504(s1)
  p->arrival_t =ticks;
    80001df0:	1782                	slli	a5,a5,0x20
    80001df2:	9381                	srli	a5,a5,0x20
    80001df4:	20f4b023          	sd	a5,512(s1)
  p->s_tcks = 0;
    80001df8:	2004a623          	sw	zero,524(s1)
  p->hlp = 1;
    80001dfc:	20e4ac23          	sw	a4,536(s1)
   p->pqtct = 0;
    80001e00:	2204a623          	sw	zero,556(s1)
  p->queue = 1;
    80001e04:	22e4a823          	sw	a4,560(s1)
  p->wwpqtct = 0;
    80001e08:	2204aa23          	sw	zero,564(s1)
  p->qnumber = npnq[0];
    80001e0c:	0000f797          	auipc	a5,0xf
    80001e10:	f7478793          	addi	a5,a5,-140 # 80010d80 <pid_lock>
    80001e14:	4307a703          	lw	a4,1072(a5)
    80001e18:	22e4ac23          	sw	a4,568(s1)
  npnq[0]++;
    80001e1c:	2705                	addiw	a4,a4,1 # 1001 <_entry-0x7fffefff>
    80001e1e:	42e7a823          	sw	a4,1072(a5)
  roqd[0]++;
    80001e22:	4407a703          	lw	a4,1088(a5)
    80001e26:	2705                	addiw	a4,a4,1
    80001e28:	44e7a023          	sw	a4,1088(a5)
}
    80001e2c:	8526                	mv	a0,s1
    80001e2e:	60e2                	ld	ra,24(sp)
    80001e30:	6442                	ld	s0,16(sp)
    80001e32:	64a2                	ld	s1,8(sp)
    80001e34:	6902                	ld	s2,0(sp)
    80001e36:	6105                	addi	sp,sp,32
    80001e38:	8082                	ret
    freeproc(p);
    80001e3a:	8526                	mv	a0,s1
    80001e3c:	00000097          	auipc	ra,0x0
    80001e40:	ea0080e7          	jalr	-352(ra) # 80001cdc <freeproc>
    release(&p->lock);
    80001e44:	8526                	mv	a0,s1
    80001e46:	fffff097          	auipc	ra,0xfffff
    80001e4a:	ea6080e7          	jalr	-346(ra) # 80000cec <release>
    return 0;
    80001e4e:	84ca                	mv	s1,s2
    80001e50:	bff1                	j	80001e2c <allocproc+0xf8>
    freeproc(p);
    80001e52:	8526                	mv	a0,s1
    80001e54:	00000097          	auipc	ra,0x0
    80001e58:	e88080e7          	jalr	-376(ra) # 80001cdc <freeproc>
    release(&p->lock);
    80001e5c:	8526                	mv	a0,s1
    80001e5e:	fffff097          	auipc	ra,0xfffff
    80001e62:	e8e080e7          	jalr	-370(ra) # 80000cec <release>
    return 0;
    80001e66:	84ca                	mv	s1,s2
    80001e68:	b7d1                	j	80001e2c <allocproc+0xf8>

0000000080001e6a <userinit>:
{
    80001e6a:	1101                	addi	sp,sp,-32
    80001e6c:	ec06                	sd	ra,24(sp)
    80001e6e:	e822                	sd	s0,16(sp)
    80001e70:	e426                	sd	s1,8(sp)
    80001e72:	1000                	addi	s0,sp,32
  p = allocproc();
    80001e74:	00000097          	auipc	ra,0x0
    80001e78:	ec0080e7          	jalr	-320(ra) # 80001d34 <allocproc>
    80001e7c:	84aa                	mv	s1,a0
  initproc = p;
    80001e7e:	00007797          	auipc	a5,0x7
    80001e82:	c8a7b523          	sd	a0,-886(a5) # 80008b08 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001e86:	03400613          	li	a2,52
    80001e8a:	00007597          	auipc	a1,0x7
    80001e8e:	b4658593          	addi	a1,a1,-1210 # 800089d0 <initcode>
    80001e92:	6928                	ld	a0,80(a0)
    80001e94:	fffff097          	auipc	ra,0xfffff
    80001e98:	52c080e7          	jalr	1324(ra) # 800013c0 <uvmfirst>
  p->sz = PGSIZE;
    80001e9c:	6785                	lui	a5,0x1
    80001e9e:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;     // user program counter
    80001ea0:	6cb8                	ld	a4,88(s1)
    80001ea2:	00073c23          	sd	zero,24(a4)
  p->trapframe->sp = PGSIZE; // user stack pointer
    80001ea6:	6cb8                	ld	a4,88(s1)
    80001ea8:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001eaa:	4641                	li	a2,16
    80001eac:	00006597          	auipc	a1,0x6
    80001eb0:	33458593          	addi	a1,a1,820 # 800081e0 <etext+0x1e0>
    80001eb4:	15848513          	addi	a0,s1,344
    80001eb8:	fffff097          	auipc	ra,0xfffff
    80001ebc:	fbe080e7          	jalr	-66(ra) # 80000e76 <safestrcpy>
  p->cwd = namei("/");
    80001ec0:	00006517          	auipc	a0,0x6
    80001ec4:	33050513          	addi	a0,a0,816 # 800081f0 <etext+0x1f0>
    80001ec8:	00002097          	auipc	ra,0x2
    80001ecc:	6c0080e7          	jalr	1728(ra) # 80004588 <namei>
    80001ed0:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001ed4:	478d                	li	a5,3
    80001ed6:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001ed8:	8526                	mv	a0,s1
    80001eda:	fffff097          	auipc	ra,0xfffff
    80001ede:	e12080e7          	jalr	-494(ra) # 80000cec <release>
}
    80001ee2:	60e2                	ld	ra,24(sp)
    80001ee4:	6442                	ld	s0,16(sp)
    80001ee6:	64a2                	ld	s1,8(sp)
    80001ee8:	6105                	addi	sp,sp,32
    80001eea:	8082                	ret

0000000080001eec <growproc>:
{
    80001eec:	1101                	addi	sp,sp,-32
    80001eee:	ec06                	sd	ra,24(sp)
    80001ef0:	e822                	sd	s0,16(sp)
    80001ef2:	e426                	sd	s1,8(sp)
    80001ef4:	e04a                	sd	s2,0(sp)
    80001ef6:	1000                	addi	s0,sp,32
    80001ef8:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001efa:	00000097          	auipc	ra,0x0
    80001efe:	c30080e7          	jalr	-976(ra) # 80001b2a <myproc>
    80001f02:	84aa                	mv	s1,a0
  sz = p->sz;
    80001f04:	652c                	ld	a1,72(a0)
  if (n > 0)
    80001f06:	01204c63          	bgtz	s2,80001f1e <growproc+0x32>
  else if (n < 0)
    80001f0a:	02094663          	bltz	s2,80001f36 <growproc+0x4a>
  p->sz = sz;
    80001f0e:	e4ac                	sd	a1,72(s1)
  return 0;
    80001f10:	4501                	li	a0,0
}
    80001f12:	60e2                	ld	ra,24(sp)
    80001f14:	6442                	ld	s0,16(sp)
    80001f16:	64a2                	ld	s1,8(sp)
    80001f18:	6902                	ld	s2,0(sp)
    80001f1a:	6105                	addi	sp,sp,32
    80001f1c:	8082                	ret
    if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0)
    80001f1e:	4691                	li	a3,4
    80001f20:	00b90633          	add	a2,s2,a1
    80001f24:	6928                	ld	a0,80(a0)
    80001f26:	fffff097          	auipc	ra,0xfffff
    80001f2a:	554080e7          	jalr	1364(ra) # 8000147a <uvmalloc>
    80001f2e:	85aa                	mv	a1,a0
    80001f30:	fd79                	bnez	a0,80001f0e <growproc+0x22>
      return -1;
    80001f32:	557d                	li	a0,-1
    80001f34:	bff9                	j	80001f12 <growproc+0x26>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001f36:	00b90633          	add	a2,s2,a1
    80001f3a:	6928                	ld	a0,80(a0)
    80001f3c:	fffff097          	auipc	ra,0xfffff
    80001f40:	4f6080e7          	jalr	1270(ra) # 80001432 <uvmdealloc>
    80001f44:	85aa                	mv	a1,a0
    80001f46:	b7e1                	j	80001f0e <growproc+0x22>

0000000080001f48 <fork>:
{
    80001f48:	7139                	addi	sp,sp,-64
    80001f4a:	fc06                	sd	ra,56(sp)
    80001f4c:	f822                	sd	s0,48(sp)
    80001f4e:	f04a                	sd	s2,32(sp)
    80001f50:	e456                	sd	s5,8(sp)
    80001f52:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001f54:	00000097          	auipc	ra,0x0
    80001f58:	bd6080e7          	jalr	-1066(ra) # 80001b2a <myproc>
    80001f5c:	8aaa                	mv	s5,a0
  if ((np = allocproc()) == 0)
    80001f5e:	00000097          	auipc	ra,0x0
    80001f62:	dd6080e7          	jalr	-554(ra) # 80001d34 <allocproc>
    80001f66:	12050863          	beqz	a0,80002096 <fork+0x14e>
    80001f6a:	ec4e                	sd	s3,24(sp)
    80001f6c:	89aa                	mv	s3,a0
  if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0)
    80001f6e:	048ab603          	ld	a2,72(s5)
    80001f72:	692c                	ld	a1,80(a0)
    80001f74:	050ab503          	ld	a0,80(s5)
    80001f78:	fffff097          	auipc	ra,0xfffff
    80001f7c:	666080e7          	jalr	1638(ra) # 800015de <uvmcopy>
    80001f80:	04054e63          	bltz	a0,80001fdc <fork+0x94>
    80001f84:	f426                	sd	s1,40(sp)
    80001f86:	e852                	sd	s4,16(sp)
  np->sz = p->sz;
    80001f88:	048ab783          	ld	a5,72(s5)
    80001f8c:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    80001f90:	058ab683          	ld	a3,88(s5)
    80001f94:	87b6                	mv	a5,a3
    80001f96:	0589b703          	ld	a4,88(s3)
    80001f9a:	12068693          	addi	a3,a3,288
    80001f9e:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001fa2:	6788                	ld	a0,8(a5)
    80001fa4:	6b8c                	ld	a1,16(a5)
    80001fa6:	6f90                	ld	a2,24(a5)
    80001fa8:	01073023          	sd	a6,0(a4)
    80001fac:	e708                	sd	a0,8(a4)
    80001fae:	eb0c                	sd	a1,16(a4)
    80001fb0:	ef10                	sd	a2,24(a4)
    80001fb2:	02078793          	addi	a5,a5,32
    80001fb6:	02070713          	addi	a4,a4,32
    80001fba:	fed792e3          	bne	a5,a3,80001f9e <fork+0x56>
  np->s1 = p->s1;
    80001fbe:	1f4aa783          	lw	a5,500(s5)
    80001fc2:	1ef9aa23          	sw	a5,500(s3)
  np->trapframe->a0 = 0;
    80001fc6:	0589b783          	ld	a5,88(s3)
    80001fca:	0607b823          	sd	zero,112(a5)
  for (i = 0; i < NOFILE; i++)
    80001fce:	0d0a8493          	addi	s1,s5,208
    80001fd2:	0d098913          	addi	s2,s3,208
    80001fd6:	150a8a13          	addi	s4,s5,336
    80001fda:	a015                	j	80001ffe <fork+0xb6>
    freeproc(np);
    80001fdc:	854e                	mv	a0,s3
    80001fde:	00000097          	auipc	ra,0x0
    80001fe2:	cfe080e7          	jalr	-770(ra) # 80001cdc <freeproc>
    release(&np->lock);
    80001fe6:	854e                	mv	a0,s3
    80001fe8:	fffff097          	auipc	ra,0xfffff
    80001fec:	d04080e7          	jalr	-764(ra) # 80000cec <release>
    return -1;
    80001ff0:	597d                	li	s2,-1
    80001ff2:	69e2                	ld	s3,24(sp)
    80001ff4:	a851                	j	80002088 <fork+0x140>
  for (i = 0; i < NOFILE; i++)
    80001ff6:	04a1                	addi	s1,s1,8
    80001ff8:	0921                	addi	s2,s2,8
    80001ffa:	01448b63          	beq	s1,s4,80002010 <fork+0xc8>
    if (p->ofile[i])
    80001ffe:	6088                	ld	a0,0(s1)
    80002000:	d97d                	beqz	a0,80001ff6 <fork+0xae>
      np->ofile[i] = filedup(p->ofile[i]);
    80002002:	00003097          	auipc	ra,0x3
    80002006:	bfe080e7          	jalr	-1026(ra) # 80004c00 <filedup>
    8000200a:	00a93023          	sd	a0,0(s2)
    8000200e:	b7e5                	j	80001ff6 <fork+0xae>
  np->cwd = idup(p->cwd);
    80002010:	150ab503          	ld	a0,336(s5)
    80002014:	00002097          	auipc	ra,0x2
    80002018:	d68080e7          	jalr	-664(ra) # 80003d7c <idup>
    8000201c:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80002020:	4641                	li	a2,16
    80002022:	158a8593          	addi	a1,s5,344
    80002026:	15898513          	addi	a0,s3,344
    8000202a:	fffff097          	auipc	ra,0xfffff
    8000202e:	e4c080e7          	jalr	-436(ra) # 80000e76 <safestrcpy>
  pid = np->pid;
    80002032:	0309a903          	lw	s2,48(s3)
  release(&np->lock);
    80002036:	854e                	mv	a0,s3
    80002038:	fffff097          	auipc	ra,0xfffff
    8000203c:	cb4080e7          	jalr	-844(ra) # 80000cec <release>
  acquire(&wait_lock);
    80002040:	0000f497          	auipc	s1,0xf
    80002044:	d5848493          	addi	s1,s1,-680 # 80010d98 <wait_lock>
    80002048:	8526                	mv	a0,s1
    8000204a:	fffff097          	auipc	ra,0xfffff
    8000204e:	bee080e7          	jalr	-1042(ra) # 80000c38 <acquire>
  np->parent = p;
    80002052:	0359bc23          	sd	s5,56(s3)
  np->tickets = np->parent->tickets;
    80002056:	1f8aa783          	lw	a5,504(s5)
    8000205a:	1ef9ac23          	sw	a5,504(s3)
  release(&wait_lock);
    8000205e:	8526                	mv	a0,s1
    80002060:	fffff097          	auipc	ra,0xfffff
    80002064:	c8c080e7          	jalr	-884(ra) # 80000cec <release>
  acquire(&np->lock);
    80002068:	854e                	mv	a0,s3
    8000206a:	fffff097          	auipc	ra,0xfffff
    8000206e:	bce080e7          	jalr	-1074(ra) # 80000c38 <acquire>
  np->state = RUNNABLE;
    80002072:	478d                	li	a5,3
    80002074:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80002078:	854e                	mv	a0,s3
    8000207a:	fffff097          	auipc	ra,0xfffff
    8000207e:	c72080e7          	jalr	-910(ra) # 80000cec <release>
  return pid;
    80002082:	74a2                	ld	s1,40(sp)
    80002084:	69e2                	ld	s3,24(sp)
    80002086:	6a42                	ld	s4,16(sp)
}
    80002088:	854a                	mv	a0,s2
    8000208a:	70e2                	ld	ra,56(sp)
    8000208c:	7442                	ld	s0,48(sp)
    8000208e:	7902                	ld	s2,32(sp)
    80002090:	6aa2                	ld	s5,8(sp)
    80002092:	6121                	addi	sp,sp,64
    80002094:	8082                	ret
    return -1;
    80002096:	597d                	li	s2,-1
    80002098:	bfc5                	j	80002088 <fork+0x140>

000000008000209a <scheduler>:
{  
    8000209a:	715d                	addi	sp,sp,-80
    8000209c:	e486                	sd	ra,72(sp)
    8000209e:	e0a2                	sd	s0,64(sp)
    800020a0:	fc26                	sd	s1,56(sp)
    800020a2:	f84a                	sd	s2,48(sp)
    800020a4:	f44e                	sd	s3,40(sp)
    800020a6:	f052                	sd	s4,32(sp)
    800020a8:	ec56                	sd	s5,24(sp)
    800020aa:	e85a                	sd	s6,16(sp)
    800020ac:	e45e                	sd	s7,8(sp)
    800020ae:	0880                	addi	s0,sp,80
    800020b0:	8792                	mv	a5,tp
  int id = r_tp();
    800020b2:	2781                	sext.w	a5,a5
c->proc = 0;
    800020b4:	00779b13          	slli	s6,a5,0x7
    800020b8:	0000f717          	auipc	a4,0xf
    800020bc:	cc870713          	addi	a4,a4,-824 # 80010d80 <pid_lock>
    800020c0:	975a                	add	a4,a4,s6
    800020c2:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &winner->context);
    800020c6:	0000f717          	auipc	a4,0xf
    800020ca:	cf270713          	addi	a4,a4,-782 # 80010db8 <cpus+0x8>
    800020ce:	9b3a                	add	s6,s6,a4
    int sum_tkt = 0;
    800020d0:	4a01                	li	s4,0
        if (p->state == RUNNABLE) {
    800020d2:	490d                	li	s2,3
    for (p = proc; p < &proc[NPROC]; p++) {
    800020d4:	00018997          	auipc	s3,0x18
    800020d8:	0fc98993          	addi	s3,s3,252 # 8001a1d0 <logs>
        c->proc = winner;
    800020dc:	079e                	slli	a5,a5,0x7
    800020de:	0000fa97          	auipc	s5,0xf
    800020e2:	ca2a8a93          	addi	s5,s5,-862 # 80010d80 <pid_lock>
    800020e6:	9abe                	add	s5,s5,a5
    800020e8:	a049                	j	8000216a <scheduler+0xd0>
    for (p = proc; p < &proc[NPROC]; p++) {
    800020ea:	24078793          	addi	a5,a5,576
    800020ee:	01378963          	beq	a5,s3,80002100 <scheduler+0x66>
        if (p->state == RUNNABLE) {
    800020f2:	4f98                	lw	a4,24(a5)
    800020f4:	ff271be3          	bne	a4,s2,800020ea <scheduler+0x50>
            sum_tkt += p->tickets;
    800020f8:	1f87a703          	lw	a4,504(a5)
    800020fc:	9db9                	addw	a1,a1,a4
            runnable_count++;
    800020fe:	b7f5                	j	800020ea <scheduler+0x50>
    int rtvll = rg(0, sum_tkt); // Ensure this function is correctly defined
    80002100:	8552                	mv	a0,s4
    80002102:	00000097          	auipc	ra,0x0
    80002106:	838080e7          	jalr	-1992(ra) # 8000193a <rg>
    8000210a:	8baa                	mv	s7,a0
    for (p = proc; p < &proc[NPROC]; p++) {
    8000210c:	0000f497          	auipc	s1,0xf
    80002110:	0c448493          	addi	s1,s1,196 # 800111d0 <proc>
    80002114:	a811                	j	80002128 <scheduler+0x8e>
        release(&p->lock);
    80002116:	8526                	mv	a0,s1
    80002118:	fffff097          	auipc	ra,0xfffff
    8000211c:	bd4080e7          	jalr	-1068(ra) # 80000cec <release>
    for (p = proc; p < &proc[NPROC]; p++) {
    80002120:	24048493          	addi	s1,s1,576
    80002124:	05348363          	beq	s1,s3,8000216a <scheduler+0xd0>
        acquire(&p->lock);
    80002128:	8526                	mv	a0,s1
    8000212a:	fffff097          	auipc	ra,0xfffff
    8000212e:	b0e080e7          	jalr	-1266(ra) # 80000c38 <acquire>
        if (p->state == RUNNABLE) {
    80002132:	4c9c                	lw	a5,24(s1)
    80002134:	ff2791e3          	bne	a5,s2,80002116 <scheduler+0x7c>
            if (p->tickets > rtvll) {
    80002138:	1f84a783          	lw	a5,504(s1)
    8000213c:	00fbc563          	blt	s7,a5,80002146 <scheduler+0xac>
          rtvll = rtvll - p->tickets;
    80002140:	40fb8bbb          	subw	s7,s7,a5
    80002144:	bfc9                	j	80002116 <scheduler+0x7c>
        winner->state = RUNNING;
    80002146:	4791                	li	a5,4
    80002148:	cc9c                	sw	a5,24(s1)
        c->proc = winner;
    8000214a:	029ab823          	sd	s1,48(s5)
        swtch(&c->context, &winner->context);
    8000214e:	06048593          	addi	a1,s1,96
    80002152:	855a                	mv	a0,s6
    80002154:	00001097          	auipc	ra,0x1
    80002158:	9a4080e7          	jalr	-1628(ra) # 80002af8 <swtch>
        c->proc = 0;
    8000215c:	020ab823          	sd	zero,48(s5)
        release(&winner->lock);
    80002160:	8526                	mv	a0,s1
    80002162:	fffff097          	auipc	ra,0xfffff
    80002166:	b8a080e7          	jalr	-1142(ra) # 80000cec <release>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000216a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000216e:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002172:	10079073          	csrw	sstatus,a5
    int sum_tkt = 0;
    80002176:	85d2                	mv	a1,s4
    for (p = proc; p < &proc[NPROC]; p++) {
    80002178:	0000f797          	auipc	a5,0xf
    8000217c:	05878793          	addi	a5,a5,88 # 800111d0 <proc>
    80002180:	bf8d                	j	800020f2 <scheduler+0x58>

0000000080002182 <sched>:
{
    80002182:	7179                	addi	sp,sp,-48
    80002184:	f406                	sd	ra,40(sp)
    80002186:	f022                	sd	s0,32(sp)
    80002188:	ec26                	sd	s1,24(sp)
    8000218a:	e84a                	sd	s2,16(sp)
    8000218c:	e44e                	sd	s3,8(sp)
    8000218e:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002190:	00000097          	auipc	ra,0x0
    80002194:	99a080e7          	jalr	-1638(ra) # 80001b2a <myproc>
    80002198:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    8000219a:	fffff097          	auipc	ra,0xfffff
    8000219e:	a24080e7          	jalr	-1500(ra) # 80000bbe <holding>
    800021a2:	c93d                	beqz	a0,80002218 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    800021a4:	8792                	mv	a5,tp
  if (mycpu()->noff != 1)
    800021a6:	2781                	sext.w	a5,a5
    800021a8:	079e                	slli	a5,a5,0x7
    800021aa:	0000f717          	auipc	a4,0xf
    800021ae:	bd670713          	addi	a4,a4,-1066 # 80010d80 <pid_lock>
    800021b2:	97ba                	add	a5,a5,a4
    800021b4:	0a87a703          	lw	a4,168(a5)
    800021b8:	4785                	li	a5,1
    800021ba:	06f71763          	bne	a4,a5,80002228 <sched+0xa6>
  if (p->state == RUNNING)
    800021be:	4c98                	lw	a4,24(s1)
    800021c0:	4791                	li	a5,4
    800021c2:	06f70b63          	beq	a4,a5,80002238 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800021c6:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800021ca:	8b89                	andi	a5,a5,2
  if (intr_get())
    800021cc:	efb5                	bnez	a5,80002248 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    800021ce:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    800021d0:	0000f917          	auipc	s2,0xf
    800021d4:	bb090913          	addi	s2,s2,-1104 # 80010d80 <pid_lock>
    800021d8:	2781                	sext.w	a5,a5
    800021da:	079e                	slli	a5,a5,0x7
    800021dc:	97ca                	add	a5,a5,s2
    800021de:	0ac7a983          	lw	s3,172(a5)
    800021e2:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    800021e4:	2781                	sext.w	a5,a5
    800021e6:	079e                	slli	a5,a5,0x7
    800021e8:	0000f597          	auipc	a1,0xf
    800021ec:	bd058593          	addi	a1,a1,-1072 # 80010db8 <cpus+0x8>
    800021f0:	95be                	add	a1,a1,a5
    800021f2:	06048513          	addi	a0,s1,96
    800021f6:	00001097          	auipc	ra,0x1
    800021fa:	902080e7          	jalr	-1790(ra) # 80002af8 <swtch>
    800021fe:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002200:	2781                	sext.w	a5,a5
    80002202:	079e                	slli	a5,a5,0x7
    80002204:	993e                	add	s2,s2,a5
    80002206:	0b392623          	sw	s3,172(s2)
}
    8000220a:	70a2                	ld	ra,40(sp)
    8000220c:	7402                	ld	s0,32(sp)
    8000220e:	64e2                	ld	s1,24(sp)
    80002210:	6942                	ld	s2,16(sp)
    80002212:	69a2                	ld	s3,8(sp)
    80002214:	6145                	addi	sp,sp,48
    80002216:	8082                	ret
    panic("sched p->lock");
    80002218:	00006517          	auipc	a0,0x6
    8000221c:	fe050513          	addi	a0,a0,-32 # 800081f8 <etext+0x1f8>
    80002220:	ffffe097          	auipc	ra,0xffffe
    80002224:	340080e7          	jalr	832(ra) # 80000560 <panic>
    panic("sched locks");
    80002228:	00006517          	auipc	a0,0x6
    8000222c:	fe050513          	addi	a0,a0,-32 # 80008208 <etext+0x208>
    80002230:	ffffe097          	auipc	ra,0xffffe
    80002234:	330080e7          	jalr	816(ra) # 80000560 <panic>
    panic("sched running");
    80002238:	00006517          	auipc	a0,0x6
    8000223c:	fe050513          	addi	a0,a0,-32 # 80008218 <etext+0x218>
    80002240:	ffffe097          	auipc	ra,0xffffe
    80002244:	320080e7          	jalr	800(ra) # 80000560 <panic>
    panic("sched interruptible");
    80002248:	00006517          	auipc	a0,0x6
    8000224c:	fe050513          	addi	a0,a0,-32 # 80008228 <etext+0x228>
    80002250:	ffffe097          	auipc	ra,0xffffe
    80002254:	310080e7          	jalr	784(ra) # 80000560 <panic>

0000000080002258 <yield>:
{
    80002258:	1101                	addi	sp,sp,-32
    8000225a:	ec06                	sd	ra,24(sp)
    8000225c:	e822                	sd	s0,16(sp)
    8000225e:	e426                	sd	s1,8(sp)
    80002260:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002262:	00000097          	auipc	ra,0x0
    80002266:	8c8080e7          	jalr	-1848(ra) # 80001b2a <myproc>
    8000226a:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000226c:	fffff097          	auipc	ra,0xfffff
    80002270:	9cc080e7          	jalr	-1588(ra) # 80000c38 <acquire>
  p->state = RUNNABLE;
    80002274:	478d                	li	a5,3
    80002276:	cc9c                	sw	a5,24(s1)
  sched();
    80002278:	00000097          	auipc	ra,0x0
    8000227c:	f0a080e7          	jalr	-246(ra) # 80002182 <sched>
  release(&p->lock);
    80002280:	8526                	mv	a0,s1
    80002282:	fffff097          	auipc	ra,0xfffff
    80002286:	a6a080e7          	jalr	-1430(ra) # 80000cec <release>
}
    8000228a:	60e2                	ld	ra,24(sp)
    8000228c:	6442                	ld	s0,16(sp)
    8000228e:	64a2                	ld	s1,8(sp)
    80002290:	6105                	addi	sp,sp,32
    80002292:	8082                	ret

0000000080002294 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void sleep(void *chan, struct spinlock *lk)
{
    80002294:	7179                	addi	sp,sp,-48
    80002296:	f406                	sd	ra,40(sp)
    80002298:	f022                	sd	s0,32(sp)
    8000229a:	ec26                	sd	s1,24(sp)
    8000229c:	e84a                	sd	s2,16(sp)
    8000229e:	e44e                	sd	s3,8(sp)
    800022a0:	1800                	addi	s0,sp,48
    800022a2:	89aa                	mv	s3,a0
    800022a4:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800022a6:	00000097          	auipc	ra,0x0
    800022aa:	884080e7          	jalr	-1916(ra) # 80001b2a <myproc>
    800022ae:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock); // DOC: sleeplock1
    800022b0:	fffff097          	auipc	ra,0xfffff
    800022b4:	988080e7          	jalr	-1656(ra) # 80000c38 <acquire>
  release(lk);
    800022b8:	854a                	mv	a0,s2
    800022ba:	fffff097          	auipc	ra,0xfffff
    800022be:	a32080e7          	jalr	-1486(ra) # 80000cec <release>

  // Go to sleep.
  p->chan = chan;
    800022c2:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    800022c6:	4789                	li	a5,2
    800022c8:	cc9c                	sw	a5,24(s1)

  sched();
    800022ca:	00000097          	auipc	ra,0x0
    800022ce:	eb8080e7          	jalr	-328(ra) # 80002182 <sched>

  // Tidy up.
  p->chan = 0;
    800022d2:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    800022d6:	8526                	mv	a0,s1
    800022d8:	fffff097          	auipc	ra,0xfffff
    800022dc:	a14080e7          	jalr	-1516(ra) # 80000cec <release>
  acquire(lk);
    800022e0:	854a                	mv	a0,s2
    800022e2:	fffff097          	auipc	ra,0xfffff
    800022e6:	956080e7          	jalr	-1706(ra) # 80000c38 <acquire>
}
    800022ea:	70a2                	ld	ra,40(sp)
    800022ec:	7402                	ld	s0,32(sp)
    800022ee:	64e2                	ld	s1,24(sp)
    800022f0:	6942                	ld	s2,16(sp)
    800022f2:	69a2                	ld	s3,8(sp)
    800022f4:	6145                	addi	sp,sp,48
    800022f6:	8082                	ret

00000000800022f8 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void wakeup(void *chan)
{
    800022f8:	7139                	addi	sp,sp,-64
    800022fa:	fc06                	sd	ra,56(sp)
    800022fc:	f822                	sd	s0,48(sp)
    800022fe:	f426                	sd	s1,40(sp)
    80002300:	f04a                	sd	s2,32(sp)
    80002302:	ec4e                	sd	s3,24(sp)
    80002304:	e852                	sd	s4,16(sp)
    80002306:	e456                	sd	s5,8(sp)
    80002308:	0080                	addi	s0,sp,64
    8000230a:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    8000230c:	0000f497          	auipc	s1,0xf
    80002310:	ec448493          	addi	s1,s1,-316 # 800111d0 <proc>
  {
    if (p != myproc())
    {
      acquire(&p->lock);
      if (p->state == SLEEPING && p->chan == chan)
    80002314:	4989                	li	s3,2
      {
        p->state = RUNNABLE;
    80002316:	4a8d                	li	s5,3
  for (p = proc; p < &proc[NPROC]; p++)
    80002318:	00018917          	auipc	s2,0x18
    8000231c:	eb890913          	addi	s2,s2,-328 # 8001a1d0 <logs>
    80002320:	a811                	j	80002334 <wakeup+0x3c>
      }
      release(&p->lock);
    80002322:	8526                	mv	a0,s1
    80002324:	fffff097          	auipc	ra,0xfffff
    80002328:	9c8080e7          	jalr	-1592(ra) # 80000cec <release>
  for (p = proc; p < &proc[NPROC]; p++)
    8000232c:	24048493          	addi	s1,s1,576
    80002330:	03248663          	beq	s1,s2,8000235c <wakeup+0x64>
    if (p != myproc())
    80002334:	fffff097          	auipc	ra,0xfffff
    80002338:	7f6080e7          	jalr	2038(ra) # 80001b2a <myproc>
    8000233c:	fea488e3          	beq	s1,a0,8000232c <wakeup+0x34>
      acquire(&p->lock);
    80002340:	8526                	mv	a0,s1
    80002342:	fffff097          	auipc	ra,0xfffff
    80002346:	8f6080e7          	jalr	-1802(ra) # 80000c38 <acquire>
      if (p->state == SLEEPING && p->chan == chan)
    8000234a:	4c9c                	lw	a5,24(s1)
    8000234c:	fd379be3          	bne	a5,s3,80002322 <wakeup+0x2a>
    80002350:	709c                	ld	a5,32(s1)
    80002352:	fd4798e3          	bne	a5,s4,80002322 <wakeup+0x2a>
        p->state = RUNNABLE;
    80002356:	0154ac23          	sw	s5,24(s1)
    8000235a:	b7e1                	j	80002322 <wakeup+0x2a>
    }
  }
}
    8000235c:	70e2                	ld	ra,56(sp)
    8000235e:	7442                	ld	s0,48(sp)
    80002360:	74a2                	ld	s1,40(sp)
    80002362:	7902                	ld	s2,32(sp)
    80002364:	69e2                	ld	s3,24(sp)
    80002366:	6a42                	ld	s4,16(sp)
    80002368:	6aa2                	ld	s5,8(sp)
    8000236a:	6121                	addi	sp,sp,64
    8000236c:	8082                	ret

000000008000236e <reparent>:
{
    8000236e:	7179                	addi	sp,sp,-48
    80002370:	f406                	sd	ra,40(sp)
    80002372:	f022                	sd	s0,32(sp)
    80002374:	ec26                	sd	s1,24(sp)
    80002376:	e84a                	sd	s2,16(sp)
    80002378:	e44e                	sd	s3,8(sp)
    8000237a:	e052                	sd	s4,0(sp)
    8000237c:	1800                	addi	s0,sp,48
    8000237e:	892a                	mv	s2,a0
  for (pp = proc; pp < &proc[NPROC]; pp++)
    80002380:	0000f497          	auipc	s1,0xf
    80002384:	e5048493          	addi	s1,s1,-432 # 800111d0 <proc>
      pp->parent = initproc;
    80002388:	00006a17          	auipc	s4,0x6
    8000238c:	780a0a13          	addi	s4,s4,1920 # 80008b08 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++)
    80002390:	00018997          	auipc	s3,0x18
    80002394:	e4098993          	addi	s3,s3,-448 # 8001a1d0 <logs>
    80002398:	a029                	j	800023a2 <reparent+0x34>
    8000239a:	24048493          	addi	s1,s1,576
    8000239e:	01348d63          	beq	s1,s3,800023b8 <reparent+0x4a>
    if (pp->parent == p)
    800023a2:	7c9c                	ld	a5,56(s1)
    800023a4:	ff279be3          	bne	a5,s2,8000239a <reparent+0x2c>
      pp->parent = initproc;
    800023a8:	000a3503          	ld	a0,0(s4)
    800023ac:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    800023ae:	00000097          	auipc	ra,0x0
    800023b2:	f4a080e7          	jalr	-182(ra) # 800022f8 <wakeup>
    800023b6:	b7d5                	j	8000239a <reparent+0x2c>
}
    800023b8:	70a2                	ld	ra,40(sp)
    800023ba:	7402                	ld	s0,32(sp)
    800023bc:	64e2                	ld	s1,24(sp)
    800023be:	6942                	ld	s2,16(sp)
    800023c0:	69a2                	ld	s3,8(sp)
    800023c2:	6a02                	ld	s4,0(sp)
    800023c4:	6145                	addi	sp,sp,48
    800023c6:	8082                	ret

00000000800023c8 <exit>:
{
    800023c8:	7179                	addi	sp,sp,-48
    800023ca:	f406                	sd	ra,40(sp)
    800023cc:	f022                	sd	s0,32(sp)
    800023ce:	ec26                	sd	s1,24(sp)
    800023d0:	e84a                	sd	s2,16(sp)
    800023d2:	e44e                	sd	s3,8(sp)
    800023d4:	e052                	sd	s4,0(sp)
    800023d6:	1800                	addi	s0,sp,48
    800023d8:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800023da:	fffff097          	auipc	ra,0xfffff
    800023de:	750080e7          	jalr	1872(ra) # 80001b2a <myproc>
    800023e2:	89aa                	mv	s3,a0
  if (p == initproc)
    800023e4:	00006797          	auipc	a5,0x6
    800023e8:	7247b783          	ld	a5,1828(a5) # 80008b08 <initproc>
    800023ec:	0d050493          	addi	s1,a0,208
    800023f0:	15050913          	addi	s2,a0,336
    800023f4:	02a79363          	bne	a5,a0,8000241a <exit+0x52>
    panic("init exiting");
    800023f8:	00006517          	auipc	a0,0x6
    800023fc:	e4850513          	addi	a0,a0,-440 # 80008240 <etext+0x240>
    80002400:	ffffe097          	auipc	ra,0xffffe
    80002404:	160080e7          	jalr	352(ra) # 80000560 <panic>
      fileclose(f);
    80002408:	00003097          	auipc	ra,0x3
    8000240c:	84a080e7          	jalr	-1974(ra) # 80004c52 <fileclose>
      p->ofile[fd] = 0;
    80002410:	0004b023          	sd	zero,0(s1)
  for (int fd = 0; fd < NOFILE; fd++)
    80002414:	04a1                	addi	s1,s1,8
    80002416:	01248563          	beq	s1,s2,80002420 <exit+0x58>
    if (p->ofile[fd])
    8000241a:	6088                	ld	a0,0(s1)
    8000241c:	f575                	bnez	a0,80002408 <exit+0x40>
    8000241e:	bfdd                	j	80002414 <exit+0x4c>
  begin_op();
    80002420:	00002097          	auipc	ra,0x2
    80002424:	368080e7          	jalr	872(ra) # 80004788 <begin_op>
  iput(p->cwd);
    80002428:	1509b503          	ld	a0,336(s3)
    8000242c:	00002097          	auipc	ra,0x2
    80002430:	b4c080e7          	jalr	-1204(ra) # 80003f78 <iput>
  end_op();
    80002434:	00002097          	auipc	ra,0x2
    80002438:	3ce080e7          	jalr	974(ra) # 80004802 <end_op>
  p->cwd = 0;
    8000243c:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002440:	0000f497          	auipc	s1,0xf
    80002444:	95848493          	addi	s1,s1,-1704 # 80010d98 <wait_lock>
    80002448:	8526                	mv	a0,s1
    8000244a:	ffffe097          	auipc	ra,0xffffe
    8000244e:	7ee080e7          	jalr	2030(ra) # 80000c38 <acquire>
  reparent(p);
    80002452:	854e                	mv	a0,s3
    80002454:	00000097          	auipc	ra,0x0
    80002458:	f1a080e7          	jalr	-230(ra) # 8000236e <reparent>
  wakeup(p->parent);
    8000245c:	0389b503          	ld	a0,56(s3)
    80002460:	00000097          	auipc	ra,0x0
    80002464:	e98080e7          	jalr	-360(ra) # 800022f8 <wakeup>
  acquire(&p->lock);
    80002468:	854e                	mv	a0,s3
    8000246a:	ffffe097          	auipc	ra,0xffffe
    8000246e:	7ce080e7          	jalr	1998(ra) # 80000c38 <acquire>
  p->xstate = status;
    80002472:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002476:	4795                	li	a5,5
    80002478:	00f9ac23          	sw	a5,24(s3)
  p->etime = ticks;
    8000247c:	00006797          	auipc	a5,0x6
    80002480:	6a07a783          	lw	a5,1696(a5) # 80008b1c <ticks>
    80002484:	16f9a823          	sw	a5,368(s3)
  release(&wait_lock);
    80002488:	8526                	mv	a0,s1
    8000248a:	fffff097          	auipc	ra,0xfffff
    8000248e:	862080e7          	jalr	-1950(ra) # 80000cec <release>
  sched();
    80002492:	00000097          	auipc	ra,0x0
    80002496:	cf0080e7          	jalr	-784(ra) # 80002182 <sched>
  panic("zombie exit");
    8000249a:	00006517          	auipc	a0,0x6
    8000249e:	db650513          	addi	a0,a0,-586 # 80008250 <etext+0x250>
    800024a2:	ffffe097          	auipc	ra,0xffffe
    800024a6:	0be080e7          	jalr	190(ra) # 80000560 <panic>

00000000800024aa <kill>:

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int kill(int pid)
{
    800024aa:	7179                	addi	sp,sp,-48
    800024ac:	f406                	sd	ra,40(sp)
    800024ae:	f022                	sd	s0,32(sp)
    800024b0:	ec26                	sd	s1,24(sp)
    800024b2:	e84a                	sd	s2,16(sp)
    800024b4:	e44e                	sd	s3,8(sp)
    800024b6:	1800                	addi	s0,sp,48
    800024b8:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    800024ba:	0000f497          	auipc	s1,0xf
    800024be:	d1648493          	addi	s1,s1,-746 # 800111d0 <proc>
    800024c2:	00018997          	auipc	s3,0x18
    800024c6:	d0e98993          	addi	s3,s3,-754 # 8001a1d0 <logs>
  {
    acquire(&p->lock);
    800024ca:	8526                	mv	a0,s1
    800024cc:	ffffe097          	auipc	ra,0xffffe
    800024d0:	76c080e7          	jalr	1900(ra) # 80000c38 <acquire>
    if (p->pid == pid)
    800024d4:	589c                	lw	a5,48(s1)
    800024d6:	01278d63          	beq	a5,s2,800024f0 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800024da:	8526                	mv	a0,s1
    800024dc:	fffff097          	auipc	ra,0xfffff
    800024e0:	810080e7          	jalr	-2032(ra) # 80000cec <release>
  for (p = proc; p < &proc[NPROC]; p++)
    800024e4:	24048493          	addi	s1,s1,576
    800024e8:	ff3491e3          	bne	s1,s3,800024ca <kill+0x20>
  }
  return -1;
    800024ec:	557d                	li	a0,-1
    800024ee:	a829                	j	80002508 <kill+0x5e>
      p->killed = 1;
    800024f0:	4785                	li	a5,1
    800024f2:	d49c                	sw	a5,40(s1)
      if (p->state == SLEEPING)
    800024f4:	4c98                	lw	a4,24(s1)
    800024f6:	4789                	li	a5,2
    800024f8:	00f70f63          	beq	a4,a5,80002516 <kill+0x6c>
      release(&p->lock);
    800024fc:	8526                	mv	a0,s1
    800024fe:	ffffe097          	auipc	ra,0xffffe
    80002502:	7ee080e7          	jalr	2030(ra) # 80000cec <release>
      return 0;
    80002506:	4501                	li	a0,0
}
    80002508:	70a2                	ld	ra,40(sp)
    8000250a:	7402                	ld	s0,32(sp)
    8000250c:	64e2                	ld	s1,24(sp)
    8000250e:	6942                	ld	s2,16(sp)
    80002510:	69a2                	ld	s3,8(sp)
    80002512:	6145                	addi	sp,sp,48
    80002514:	8082                	ret
        p->state = RUNNABLE;
    80002516:	478d                	li	a5,3
    80002518:	cc9c                	sw	a5,24(s1)
    8000251a:	b7cd                	j	800024fc <kill+0x52>

000000008000251c <getSysCount>:

int getSysCount(int mask) 
{
    8000251c:	7179                	addi	sp,sp,-48
    8000251e:	f406                	sd	ra,40(sp)
    80002520:	f022                	sd	s0,32(sp)
    80002522:	ec26                	sd	s1,24(sp)
    80002524:	e84a                	sd	s2,16(sp)
    80002526:	e44e                	sd	s3,8(sp)
    80002528:	1800                	addi	s0,sp,48
    8000252a:	84aa                	mv	s1,a0
    8000252c:	4901                	li	s2,0
  struct proc *p = myproc(); // Get the current process
    8000252e:	fffff097          	auipc	ra,0xfffff
    80002532:	5fc080e7          	jalr	1532(ra) # 80001b2a <myproc>
    80002536:	89aa                	mv	s3,a0
    80002538:	4601                	li	a2,0
  
  
   for (int i = 1; i < NUMBER_OF_SYSCALLS; i++) {
    8000253a:	4785                	li	a5,1

    if ((mask>>i) & 1) j =i;
    8000253c:	4585                	li	a1,1
   for (int i = 1; i < NUMBER_OF_SYSCALLS; i++) {
    8000253e:	02000693          	li	a3,32
    80002542:	a021                	j	8000254a <getSysCount+0x2e>
    80002544:	2785                	addiw	a5,a5,1
    80002546:	00d78963          	beq	a5,a3,80002558 <getSysCount+0x3c>
    if ((mask>>i) & 1) j =i;
    8000254a:	40f4d73b          	sraw	a4,s1,a5
    8000254e:	8b05                	andi	a4,a4,1
    80002550:	db75                	beqz	a4,80002544 <getSysCount+0x28>
    80002552:	893e                	mv	s2,a5
    80002554:	862e                	mv	a2,a1
    80002556:	b7fd                	j	80002544 <getSysCount+0x28>
    80002558:	c609                	beqz	a2,80002562 <getSysCount+0x46>
    8000255a:	00006797          	auipc	a5,0x6
    8000255e:	5b27af23          	sw	s2,1470(a5) # 80008b18 <j>

   }
   printf("PID %d called %s %d times.\n",p-> pid, syscall_names[j-1], p->syscall_count[j]);
    80002562:	00006497          	auipc	s1,0x6
    80002566:	5b648493          	addi	s1,s1,1462 # 80008b18 <j>
    8000256a:	409c                	lw	a5,0(s1)
    8000256c:	05c78713          	addi	a4,a5,92
    80002570:	070a                	slli	a4,a4,0x2
    80002572:	974e                	add	a4,a4,s3
    80002574:	37fd                	addiw	a5,a5,-1
    80002576:	078e                	slli	a5,a5,0x3
    80002578:	00006697          	auipc	a3,0x6
    8000257c:	49068693          	addi	a3,a3,1168 # 80008a08 <syscall_names>
    80002580:	97b6                	add	a5,a5,a3
    80002582:	4354                	lw	a3,4(a4)
    80002584:	6390                	ld	a2,0(a5)
    80002586:	0309a583          	lw	a1,48(s3)
    8000258a:	00006517          	auipc	a0,0x6
    8000258e:	cd650513          	addi	a0,a0,-810 # 80008260 <etext+0x260>
    80002592:	ffffe097          	auipc	ra,0xffffe
    80002596:	018080e7          	jalr	24(ra) # 800005aa <printf>
   return p->syscall_count[j];
    8000259a:	409c                	lw	a5,0(s1)
    8000259c:	05c78793          	addi	a5,a5,92
    800025a0:	078a                	slli	a5,a5,0x2
    800025a2:	99be                	add	s3,s3,a5
}
    800025a4:	0049a503          	lw	a0,4(s3)
    800025a8:	70a2                	ld	ra,40(sp)
    800025aa:	7402                	ld	s0,32(sp)
    800025ac:	64e2                	ld	s1,24(sp)
    800025ae:	6942                	ld	s2,16(sp)
    800025b0:	69a2                	ld	s3,8(sp)
    800025b2:	6145                	addi	sp,sp,48
    800025b4:	8082                	ret

00000000800025b6 <setkilled>:

void setkilled(struct proc *p)
{
    800025b6:	1101                	addi	sp,sp,-32
    800025b8:	ec06                	sd	ra,24(sp)
    800025ba:	e822                	sd	s0,16(sp)
    800025bc:	e426                	sd	s1,8(sp)
    800025be:	1000                	addi	s0,sp,32
    800025c0:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800025c2:	ffffe097          	auipc	ra,0xffffe
    800025c6:	676080e7          	jalr	1654(ra) # 80000c38 <acquire>
  p->killed = 1;
    800025ca:	4785                	li	a5,1
    800025cc:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    800025ce:	8526                	mv	a0,s1
    800025d0:	ffffe097          	auipc	ra,0xffffe
    800025d4:	71c080e7          	jalr	1820(ra) # 80000cec <release>
}
    800025d8:	60e2                	ld	ra,24(sp)
    800025da:	6442                	ld	s0,16(sp)
    800025dc:	64a2                	ld	s1,8(sp)
    800025de:	6105                	addi	sp,sp,32
    800025e0:	8082                	ret

00000000800025e2 <killed>:

int killed(struct proc *p)
{
    800025e2:	1101                	addi	sp,sp,-32
    800025e4:	ec06                	sd	ra,24(sp)
    800025e6:	e822                	sd	s0,16(sp)
    800025e8:	e426                	sd	s1,8(sp)
    800025ea:	e04a                	sd	s2,0(sp)
    800025ec:	1000                	addi	s0,sp,32
    800025ee:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    800025f0:	ffffe097          	auipc	ra,0xffffe
    800025f4:	648080e7          	jalr	1608(ra) # 80000c38 <acquire>
  k = p->killed;
    800025f8:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    800025fc:	8526                	mv	a0,s1
    800025fe:	ffffe097          	auipc	ra,0xffffe
    80002602:	6ee080e7          	jalr	1774(ra) # 80000cec <release>
  return k;
}
    80002606:	854a                	mv	a0,s2
    80002608:	60e2                	ld	ra,24(sp)
    8000260a:	6442                	ld	s0,16(sp)
    8000260c:	64a2                	ld	s1,8(sp)
    8000260e:	6902                	ld	s2,0(sp)
    80002610:	6105                	addi	sp,sp,32
    80002612:	8082                	ret

0000000080002614 <wait>:
{
    80002614:	715d                	addi	sp,sp,-80
    80002616:	e486                	sd	ra,72(sp)
    80002618:	e0a2                	sd	s0,64(sp)
    8000261a:	fc26                	sd	s1,56(sp)
    8000261c:	f84a                	sd	s2,48(sp)
    8000261e:	f44e                	sd	s3,40(sp)
    80002620:	f052                	sd	s4,32(sp)
    80002622:	ec56                	sd	s5,24(sp)
    80002624:	e85a                	sd	s6,16(sp)
    80002626:	e45e                	sd	s7,8(sp)
    80002628:	e062                	sd	s8,0(sp)
    8000262a:	0880                	addi	s0,sp,80
    8000262c:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    8000262e:	fffff097          	auipc	ra,0xfffff
    80002632:	4fc080e7          	jalr	1276(ra) # 80001b2a <myproc>
    80002636:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002638:	0000e517          	auipc	a0,0xe
    8000263c:	76050513          	addi	a0,a0,1888 # 80010d98 <wait_lock>
    80002640:	ffffe097          	auipc	ra,0xffffe
    80002644:	5f8080e7          	jalr	1528(ra) # 80000c38 <acquire>
    havekids = 0;
    80002648:	4b81                	li	s7,0
        if (pp->state == ZOMBIE)
    8000264a:	4a15                	li	s4,5
        havekids = 1;
    8000264c:	4a85                	li	s5,1
    for (pp = proc; pp < &proc[NPROC]; pp++)
    8000264e:	00018997          	auipc	s3,0x18
    80002652:	b8298993          	addi	s3,s3,-1150 # 8001a1d0 <logs>
    sleep(p, &wait_lock); // DOC: wait-sleep
    80002656:	0000ec17          	auipc	s8,0xe
    8000265a:	742c0c13          	addi	s8,s8,1858 # 80010d98 <wait_lock>
    8000265e:	a0d1                	j	80002722 <wait+0x10e>
          pid = pp->pid;
    80002660:	0304a983          	lw	s3,48(s1)
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002664:	000b0e63          	beqz	s6,80002680 <wait+0x6c>
    80002668:	4691                	li	a3,4
    8000266a:	02c48613          	addi	a2,s1,44
    8000266e:	85da                	mv	a1,s6
    80002670:	05093503          	ld	a0,80(s2)
    80002674:	fffff097          	auipc	ra,0xfffff
    80002678:	06e080e7          	jalr	110(ra) # 800016e2 <copyout>
    8000267c:	04054163          	bltz	a0,800026be <wait+0xaa>
          freeproc(pp);
    80002680:	8526                	mv	a0,s1
    80002682:	fffff097          	auipc	ra,0xfffff
    80002686:	65a080e7          	jalr	1626(ra) # 80001cdc <freeproc>
          release(&pp->lock);
    8000268a:	8526                	mv	a0,s1
    8000268c:	ffffe097          	auipc	ra,0xffffe
    80002690:	660080e7          	jalr	1632(ra) # 80000cec <release>
          release(&wait_lock);
    80002694:	0000e517          	auipc	a0,0xe
    80002698:	70450513          	addi	a0,a0,1796 # 80010d98 <wait_lock>
    8000269c:	ffffe097          	auipc	ra,0xffffe
    800026a0:	650080e7          	jalr	1616(ra) # 80000cec <release>
}
    800026a4:	854e                	mv	a0,s3
    800026a6:	60a6                	ld	ra,72(sp)
    800026a8:	6406                	ld	s0,64(sp)
    800026aa:	74e2                	ld	s1,56(sp)
    800026ac:	7942                	ld	s2,48(sp)
    800026ae:	79a2                	ld	s3,40(sp)
    800026b0:	7a02                	ld	s4,32(sp)
    800026b2:	6ae2                	ld	s5,24(sp)
    800026b4:	6b42                	ld	s6,16(sp)
    800026b6:	6ba2                	ld	s7,8(sp)
    800026b8:	6c02                	ld	s8,0(sp)
    800026ba:	6161                	addi	sp,sp,80
    800026bc:	8082                	ret
            release(&pp->lock);
    800026be:	8526                	mv	a0,s1
    800026c0:	ffffe097          	auipc	ra,0xffffe
    800026c4:	62c080e7          	jalr	1580(ra) # 80000cec <release>
            release(&wait_lock);
    800026c8:	0000e517          	auipc	a0,0xe
    800026cc:	6d050513          	addi	a0,a0,1744 # 80010d98 <wait_lock>
    800026d0:	ffffe097          	auipc	ra,0xffffe
    800026d4:	61c080e7          	jalr	1564(ra) # 80000cec <release>
            return -1;
    800026d8:	59fd                	li	s3,-1
    800026da:	b7e9                	j	800026a4 <wait+0x90>
    for (pp = proc; pp < &proc[NPROC]; pp++)
    800026dc:	24048493          	addi	s1,s1,576
    800026e0:	03348463          	beq	s1,s3,80002708 <wait+0xf4>
      if (pp->parent == p)
    800026e4:	7c9c                	ld	a5,56(s1)
    800026e6:	ff279be3          	bne	a5,s2,800026dc <wait+0xc8>
        acquire(&pp->lock);
    800026ea:	8526                	mv	a0,s1
    800026ec:	ffffe097          	auipc	ra,0xffffe
    800026f0:	54c080e7          	jalr	1356(ra) # 80000c38 <acquire>
        if (pp->state == ZOMBIE)
    800026f4:	4c9c                	lw	a5,24(s1)
    800026f6:	f74785e3          	beq	a5,s4,80002660 <wait+0x4c>
        release(&pp->lock);
    800026fa:	8526                	mv	a0,s1
    800026fc:	ffffe097          	auipc	ra,0xffffe
    80002700:	5f0080e7          	jalr	1520(ra) # 80000cec <release>
        havekids = 1;
    80002704:	8756                	mv	a4,s5
    80002706:	bfd9                	j	800026dc <wait+0xc8>
    if (!havekids || killed(p))
    80002708:	c31d                	beqz	a4,8000272e <wait+0x11a>
    8000270a:	854a                	mv	a0,s2
    8000270c:	00000097          	auipc	ra,0x0
    80002710:	ed6080e7          	jalr	-298(ra) # 800025e2 <killed>
    80002714:	ed09                	bnez	a0,8000272e <wait+0x11a>
    sleep(p, &wait_lock); // DOC: wait-sleep
    80002716:	85e2                	mv	a1,s8
    80002718:	854a                	mv	a0,s2
    8000271a:	00000097          	auipc	ra,0x0
    8000271e:	b7a080e7          	jalr	-1158(ra) # 80002294 <sleep>
    havekids = 0;
    80002722:	875e                	mv	a4,s7
    for (pp = proc; pp < &proc[NPROC]; pp++)
    80002724:	0000f497          	auipc	s1,0xf
    80002728:	aac48493          	addi	s1,s1,-1364 # 800111d0 <proc>
    8000272c:	bf65                	j	800026e4 <wait+0xd0>
      release(&wait_lock);
    8000272e:	0000e517          	auipc	a0,0xe
    80002732:	66a50513          	addi	a0,a0,1642 # 80010d98 <wait_lock>
    80002736:	ffffe097          	auipc	ra,0xffffe
    8000273a:	5b6080e7          	jalr	1462(ra) # 80000cec <release>
      return -1;
    8000273e:	59fd                	li	s3,-1
    80002740:	b795                	j	800026a4 <wait+0x90>

0000000080002742 <either_copyout>:

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002742:	7179                	addi	sp,sp,-48
    80002744:	f406                	sd	ra,40(sp)
    80002746:	f022                	sd	s0,32(sp)
    80002748:	ec26                	sd	s1,24(sp)
    8000274a:	e84a                	sd	s2,16(sp)
    8000274c:	e44e                	sd	s3,8(sp)
    8000274e:	e052                	sd	s4,0(sp)
    80002750:	1800                	addi	s0,sp,48
    80002752:	84aa                	mv	s1,a0
    80002754:	892e                	mv	s2,a1
    80002756:	89b2                	mv	s3,a2
    80002758:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000275a:	fffff097          	auipc	ra,0xfffff
    8000275e:	3d0080e7          	jalr	976(ra) # 80001b2a <myproc>
  if (user_dst)
    80002762:	c08d                	beqz	s1,80002784 <either_copyout+0x42>
  {
    return copyout(p->pagetable, dst, src, len);
    80002764:	86d2                	mv	a3,s4
    80002766:	864e                	mv	a2,s3
    80002768:	85ca                	mv	a1,s2
    8000276a:	6928                	ld	a0,80(a0)
    8000276c:	fffff097          	auipc	ra,0xfffff
    80002770:	f76080e7          	jalr	-138(ra) # 800016e2 <copyout>
  else
  {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002774:	70a2                	ld	ra,40(sp)
    80002776:	7402                	ld	s0,32(sp)
    80002778:	64e2                	ld	s1,24(sp)
    8000277a:	6942                	ld	s2,16(sp)
    8000277c:	69a2                	ld	s3,8(sp)
    8000277e:	6a02                	ld	s4,0(sp)
    80002780:	6145                	addi	sp,sp,48
    80002782:	8082                	ret
    memmove((char *)dst, src, len);
    80002784:	000a061b          	sext.w	a2,s4
    80002788:	85ce                	mv	a1,s3
    8000278a:	854a                	mv	a0,s2
    8000278c:	ffffe097          	auipc	ra,0xffffe
    80002790:	604080e7          	jalr	1540(ra) # 80000d90 <memmove>
    return 0;
    80002794:	8526                	mv	a0,s1
    80002796:	bff9                	j	80002774 <either_copyout+0x32>

0000000080002798 <either_copyin>:

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002798:	7179                	addi	sp,sp,-48
    8000279a:	f406                	sd	ra,40(sp)
    8000279c:	f022                	sd	s0,32(sp)
    8000279e:	ec26                	sd	s1,24(sp)
    800027a0:	e84a                	sd	s2,16(sp)
    800027a2:	e44e                	sd	s3,8(sp)
    800027a4:	e052                	sd	s4,0(sp)
    800027a6:	1800                	addi	s0,sp,48
    800027a8:	892a                	mv	s2,a0
    800027aa:	84ae                	mv	s1,a1
    800027ac:	89b2                	mv	s3,a2
    800027ae:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800027b0:	fffff097          	auipc	ra,0xfffff
    800027b4:	37a080e7          	jalr	890(ra) # 80001b2a <myproc>
  if (user_src)
    800027b8:	c08d                	beqz	s1,800027da <either_copyin+0x42>
  {
    return copyin(p->pagetable, dst, src, len);
    800027ba:	86d2                	mv	a3,s4
    800027bc:	864e                	mv	a2,s3
    800027be:	85ca                	mv	a1,s2
    800027c0:	6928                	ld	a0,80(a0)
    800027c2:	fffff097          	auipc	ra,0xfffff
    800027c6:	fac080e7          	jalr	-84(ra) # 8000176e <copyin>
  else
  {
    memmove(dst, (char *)src, len);
    return 0;
  }
}
    800027ca:	70a2                	ld	ra,40(sp)
    800027cc:	7402                	ld	s0,32(sp)
    800027ce:	64e2                	ld	s1,24(sp)
    800027d0:	6942                	ld	s2,16(sp)
    800027d2:	69a2                	ld	s3,8(sp)
    800027d4:	6a02                	ld	s4,0(sp)
    800027d6:	6145                	addi	sp,sp,48
    800027d8:	8082                	ret
    memmove(dst, (char *)src, len);
    800027da:	000a061b          	sext.w	a2,s4
    800027de:	85ce                	mv	a1,s3
    800027e0:	854a                	mv	a0,s2
    800027e2:	ffffe097          	auipc	ra,0xffffe
    800027e6:	5ae080e7          	jalr	1454(ra) # 80000d90 <memmove>
    return 0;
    800027ea:	8526                	mv	a0,s1
    800027ec:	bff9                	j	800027ca <either_copyin+0x32>

00000000800027ee <procdump>:

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void procdump(void)
{
    800027ee:	7139                	addi	sp,sp,-64
    800027f0:	fc06                	sd	ra,56(sp)
    800027f2:	f822                	sd	s0,48(sp)
    800027f4:	f426                	sd	s1,40(sp)
    800027f6:	f04a                	sd	s2,32(sp)
    800027f8:	ec4e                	sd	s3,24(sp)
    800027fa:	e852                	sd	s4,16(sp)
    800027fc:	e456                	sd	s5,8(sp)
    800027fe:	0080                	addi	s0,sp,64
      [RUNNING] "run   ",
      [ZOMBIE] "zombie"}; */
  struct proc *p;
 // char *state;

  printf("\n");
    80002800:	00006517          	auipc	a0,0x6
    80002804:	81050513          	addi	a0,a0,-2032 # 80008010 <etext+0x10>
    80002808:	ffffe097          	auipc	ra,0xffffe
    8000280c:	da2080e7          	jalr	-606(ra) # 800005aa <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    80002810:	0000f497          	auipc	s1,0xf
    80002814:	9c048493          	addi	s1,s1,-1600 # 800111d0 <proc>
    else
      state = "???"; */
    
    
    //printf("%d %s", p->pid, p->name);
     if(p->pid > 2){
    80002818:	4989                	li	s3,2
    printf("%d  %d  %d  %d  %d ", p->pid, p->queue, p->pqtct, p->wwpqtct,p->qnumber);
    8000281a:	00006a97          	auipc	s5,0x6
    8000281e:	a66a8a93          	addi	s5,s5,-1434 # 80008280 <etext+0x280>
    //printf("#NN - %d %s %s %d %d %d %d", p->pid, p->state, p->name, p->queue, p->tickcount, p->waittickcount, p->queueposition);
    printf("\n");
    80002822:	00005a17          	auipc	s4,0x5
    80002826:	7eea0a13          	addi	s4,s4,2030 # 80008010 <etext+0x10>
  for (p = proc; p < &proc[NPROC]; p++)
    8000282a:	00018917          	auipc	s2,0x18
    8000282e:	9a690913          	addi	s2,s2,-1626 # 8001a1d0 <logs>
    80002832:	a029                	j	8000283c <procdump+0x4e>
    80002834:	24048493          	addi	s1,s1,576
    80002838:	03248a63          	beq	s1,s2,8000286c <procdump+0x7e>
    if (p->state == UNUSED)
    8000283c:	4c9c                	lw	a5,24(s1)
    8000283e:	dbfd                	beqz	a5,80002834 <procdump+0x46>
     if(p->pid > 2){
    80002840:	588c                	lw	a1,48(s1)
    80002842:	feb9d9e3          	bge	s3,a1,80002834 <procdump+0x46>
    printf("%d  %d  %d  %d  %d ", p->pid, p->queue, p->pqtct, p->wwpqtct,p->qnumber);
    80002846:	2384a783          	lw	a5,568(s1)
    8000284a:	2344a703          	lw	a4,564(s1)
    8000284e:	22c4a683          	lw	a3,556(s1)
    80002852:	2304a603          	lw	a2,560(s1)
    80002856:	8556                	mv	a0,s5
    80002858:	ffffe097          	auipc	ra,0xffffe
    8000285c:	d52080e7          	jalr	-686(ra) # 800005aa <printf>
    printf("\n");
    80002860:	8552                	mv	a0,s4
    80002862:	ffffe097          	auipc	ra,0xffffe
    80002866:	d48080e7          	jalr	-696(ra) # 800005aa <printf>
    8000286a:	b7e9                	j	80002834 <procdump+0x46>
    }
  }
}
    8000286c:	70e2                	ld	ra,56(sp)
    8000286e:	7442                	ld	s0,48(sp)
    80002870:	74a2                	ld	s1,40(sp)
    80002872:	7902                	ld	s2,32(sp)
    80002874:	69e2                	ld	s3,24(sp)
    80002876:	6a42                	ld	s4,16(sp)
    80002878:	6aa2                	ld	s5,8(sp)
    8000287a:	6121                	addi	sp,sp,64
    8000287c:	8082                	ret

000000008000287e <waitx>:

// waitx
int waitx(uint64 addr, uint *wtime, uint *rtime)
{
    8000287e:	711d                	addi	sp,sp,-96
    80002880:	ec86                	sd	ra,88(sp)
    80002882:	e8a2                	sd	s0,80(sp)
    80002884:	e4a6                	sd	s1,72(sp)
    80002886:	e0ca                	sd	s2,64(sp)
    80002888:	fc4e                	sd	s3,56(sp)
    8000288a:	f852                	sd	s4,48(sp)
    8000288c:	f456                	sd	s5,40(sp)
    8000288e:	f05a                	sd	s6,32(sp)
    80002890:	ec5e                	sd	s7,24(sp)
    80002892:	e862                	sd	s8,16(sp)
    80002894:	e466                	sd	s9,8(sp)
    80002896:	e06a                	sd	s10,0(sp)
    80002898:	1080                	addi	s0,sp,96
    8000289a:	8b2a                	mv	s6,a0
    8000289c:	8bae                	mv	s7,a1
    8000289e:	8c32                	mv	s8,a2
  struct proc *np;
  int havekids, pid;
  struct proc *p = myproc();
    800028a0:	fffff097          	auipc	ra,0xfffff
    800028a4:	28a080e7          	jalr	650(ra) # 80001b2a <myproc>
    800028a8:	892a                	mv	s2,a0

  acquire(&wait_lock);
    800028aa:	0000e517          	auipc	a0,0xe
    800028ae:	4ee50513          	addi	a0,a0,1262 # 80010d98 <wait_lock>
    800028b2:	ffffe097          	auipc	ra,0xffffe
    800028b6:	386080e7          	jalr	902(ra) # 80000c38 <acquire>

  for (;;)
  {
    // Scan through table looking for exited children.
    havekids = 0;
    800028ba:	4c81                	li	s9,0
      {
        // make sure the child isn't still in exit() or swtch().
        acquire(&np->lock);

        havekids = 1;
        if (np->state == ZOMBIE)
    800028bc:	4a15                	li	s4,5
        havekids = 1;
    800028be:	4a85                	li	s5,1
    for (np = proc; np < &proc[NPROC]; np++)
    800028c0:	00018997          	auipc	s3,0x18
    800028c4:	91098993          	addi	s3,s3,-1776 # 8001a1d0 <logs>
      release(&wait_lock);
      return -1;
    }

    // Wait for a child to exit.
    sleep(p, &wait_lock); // DOC: wait-sleep
    800028c8:	0000ed17          	auipc	s10,0xe
    800028cc:	4d0d0d13          	addi	s10,s10,1232 # 80010d98 <wait_lock>
    800028d0:	a8e9                	j	800029aa <waitx+0x12c>
          pid = np->pid;
    800028d2:	0304a983          	lw	s3,48(s1)
          *rtime = np->rtime;
    800028d6:	1684a783          	lw	a5,360(s1)
    800028da:	00fc2023          	sw	a5,0(s8)
          *wtime = np->etime - np->ctime - np->rtime;
    800028de:	16c4a703          	lw	a4,364(s1)
    800028e2:	9f3d                	addw	a4,a4,a5
    800028e4:	1704a783          	lw	a5,368(s1)
    800028e8:	9f99                	subw	a5,a5,a4
    800028ea:	00fba023          	sw	a5,0(s7) # 1000 <_entry-0x7ffff000>
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    800028ee:	000b0e63          	beqz	s6,8000290a <waitx+0x8c>
    800028f2:	4691                	li	a3,4
    800028f4:	02c48613          	addi	a2,s1,44
    800028f8:	85da                	mv	a1,s6
    800028fa:	05093503          	ld	a0,80(s2)
    800028fe:	fffff097          	auipc	ra,0xfffff
    80002902:	de4080e7          	jalr	-540(ra) # 800016e2 <copyout>
    80002906:	04054363          	bltz	a0,8000294c <waitx+0xce>
          freeproc(np);
    8000290a:	8526                	mv	a0,s1
    8000290c:	fffff097          	auipc	ra,0xfffff
    80002910:	3d0080e7          	jalr	976(ra) # 80001cdc <freeproc>
          release(&np->lock);
    80002914:	8526                	mv	a0,s1
    80002916:	ffffe097          	auipc	ra,0xffffe
    8000291a:	3d6080e7          	jalr	982(ra) # 80000cec <release>
          release(&wait_lock);
    8000291e:	0000e517          	auipc	a0,0xe
    80002922:	47a50513          	addi	a0,a0,1146 # 80010d98 <wait_lock>
    80002926:	ffffe097          	auipc	ra,0xffffe
    8000292a:	3c6080e7          	jalr	966(ra) # 80000cec <release>
  }
}
    8000292e:	854e                	mv	a0,s3
    80002930:	60e6                	ld	ra,88(sp)
    80002932:	6446                	ld	s0,80(sp)
    80002934:	64a6                	ld	s1,72(sp)
    80002936:	6906                	ld	s2,64(sp)
    80002938:	79e2                	ld	s3,56(sp)
    8000293a:	7a42                	ld	s4,48(sp)
    8000293c:	7aa2                	ld	s5,40(sp)
    8000293e:	7b02                	ld	s6,32(sp)
    80002940:	6be2                	ld	s7,24(sp)
    80002942:	6c42                	ld	s8,16(sp)
    80002944:	6ca2                	ld	s9,8(sp)
    80002946:	6d02                	ld	s10,0(sp)
    80002948:	6125                	addi	sp,sp,96
    8000294a:	8082                	ret
            release(&np->lock);
    8000294c:	8526                	mv	a0,s1
    8000294e:	ffffe097          	auipc	ra,0xffffe
    80002952:	39e080e7          	jalr	926(ra) # 80000cec <release>
            release(&wait_lock);
    80002956:	0000e517          	auipc	a0,0xe
    8000295a:	44250513          	addi	a0,a0,1090 # 80010d98 <wait_lock>
    8000295e:	ffffe097          	auipc	ra,0xffffe
    80002962:	38e080e7          	jalr	910(ra) # 80000cec <release>
            return -1;
    80002966:	59fd                	li	s3,-1
    80002968:	b7d9                	j	8000292e <waitx+0xb0>
    for (np = proc; np < &proc[NPROC]; np++)
    8000296a:	24048493          	addi	s1,s1,576
    8000296e:	03348463          	beq	s1,s3,80002996 <waitx+0x118>
      if (np->parent == p)
    80002972:	7c9c                	ld	a5,56(s1)
    80002974:	ff279be3          	bne	a5,s2,8000296a <waitx+0xec>
        acquire(&np->lock);
    80002978:	8526                	mv	a0,s1
    8000297a:	ffffe097          	auipc	ra,0xffffe
    8000297e:	2be080e7          	jalr	702(ra) # 80000c38 <acquire>
        if (np->state == ZOMBIE)
    80002982:	4c9c                	lw	a5,24(s1)
    80002984:	f54787e3          	beq	a5,s4,800028d2 <waitx+0x54>
        release(&np->lock);
    80002988:	8526                	mv	a0,s1
    8000298a:	ffffe097          	auipc	ra,0xffffe
    8000298e:	362080e7          	jalr	866(ra) # 80000cec <release>
        havekids = 1;
    80002992:	8756                	mv	a4,s5
    80002994:	bfd9                	j	8000296a <waitx+0xec>
    if (!havekids || p->killed)
    80002996:	c305                	beqz	a4,800029b6 <waitx+0x138>
    80002998:	02892783          	lw	a5,40(s2)
    8000299c:	ef89                	bnez	a5,800029b6 <waitx+0x138>
    sleep(p, &wait_lock); // DOC: wait-sleep
    8000299e:	85ea                	mv	a1,s10
    800029a0:	854a                	mv	a0,s2
    800029a2:	00000097          	auipc	ra,0x0
    800029a6:	8f2080e7          	jalr	-1806(ra) # 80002294 <sleep>
    havekids = 0;
    800029aa:	8766                	mv	a4,s9
    for (np = proc; np < &proc[NPROC]; np++)
    800029ac:	0000f497          	auipc	s1,0xf
    800029b0:	82448493          	addi	s1,s1,-2012 # 800111d0 <proc>
    800029b4:	bf7d                	j	80002972 <waitx+0xf4>
      release(&wait_lock);
    800029b6:	0000e517          	auipc	a0,0xe
    800029ba:	3e250513          	addi	a0,a0,994 # 80010d98 <wait_lock>
    800029be:	ffffe097          	auipc	ra,0xffffe
    800029c2:	32e080e7          	jalr	814(ra) # 80000cec <release>
      return -1;
    800029c6:	59fd                	li	s3,-1
    800029c8:	b79d                	j	8000292e <waitx+0xb0>

00000000800029ca <update_time>:

void update_time()
{
    800029ca:	7179                	addi	sp,sp,-48
    800029cc:	f406                	sd	ra,40(sp)
    800029ce:	f022                	sd	s0,32(sp)
    800029d0:	ec26                	sd	s1,24(sp)
    800029d2:	e84a                	sd	s2,16(sp)
    800029d4:	e44e                	sd	s3,8(sp)
    800029d6:	1800                	addi	s0,sp,48
  struct proc *p;
  for (p = proc; p < &proc[NPROC]; p++)
    800029d8:	0000e497          	auipc	s1,0xe
    800029dc:	7f848493          	addi	s1,s1,2040 # 800111d0 <proc>
  {
    acquire(&p->lock);
    if (p->state == RUNNING)
    800029e0:	4991                	li	s3,4
  for (p = proc; p < &proc[NPROC]; p++)
    800029e2:	00017917          	auipc	s2,0x17
    800029e6:	7ee90913          	addi	s2,s2,2030 # 8001a1d0 <logs>
    800029ea:	a811                	j	800029fe <update_time+0x34>
    {
      p->rtime++;
    }
    release(&p->lock);
    800029ec:	8526                	mv	a0,s1
    800029ee:	ffffe097          	auipc	ra,0xffffe
    800029f2:	2fe080e7          	jalr	766(ra) # 80000cec <release>
  for (p = proc; p < &proc[NPROC]; p++)
    800029f6:	24048493          	addi	s1,s1,576
    800029fa:	03248063          	beq	s1,s2,80002a1a <update_time+0x50>
    acquire(&p->lock);
    800029fe:	8526                	mv	a0,s1
    80002a00:	ffffe097          	auipc	ra,0xffffe
    80002a04:	238080e7          	jalr	568(ra) # 80000c38 <acquire>
    if (p->state == RUNNING)
    80002a08:	4c9c                	lw	a5,24(s1)
    80002a0a:	ff3791e3          	bne	a5,s3,800029ec <update_time+0x22>
      p->rtime++;
    80002a0e:	1684a783          	lw	a5,360(s1)
    80002a12:	2785                	addiw	a5,a5,1
    80002a14:	16f4a423          	sw	a5,360(s1)
    80002a18:	bfd1                	j	800029ec <update_time+0x22>
  }
}
    80002a1a:	70a2                	ld	ra,40(sp)
    80002a1c:	7402                	ld	s0,32(sp)
    80002a1e:	64e2                	ld	s1,24(sp)
    80002a20:	6942                	ld	s2,16(sp)
    80002a22:	69a2                	ld	s3,8(sp)
    80002a24:	6145                	addi	sp,sp,48
    80002a26:	8082                	ret

0000000080002a28 <print_logg>:


void print_logg() {
    80002a28:	7179                	addi	sp,sp,-48
    80002a2a:	f406                	sd	ra,40(sp)
    80002a2c:	f022                	sd	s0,32(sp)
    80002a2e:	1800                	addi	s0,sp,48
    // Check if there are any log entries to print
    if (log_index == 0) {
    80002a30:	00006797          	auipc	a5,0x6
    80002a34:	0e47a783          	lw	a5,228(a5) # 80008b14 <log_index>
    80002a38:	c7dd                	beqz	a5,80002ae6 <print_logg+0xbe>
        printf("No log entries available.\n");
        return;
    }

    printf("Process Queue Log:\n");
    80002a3a:	00006517          	auipc	a0,0x6
    80002a3e:	87e50513          	addi	a0,a0,-1922 # 800082b8 <etext+0x2b8>
    80002a42:	ffffe097          	auipc	ra,0xffffe
    80002a46:	b68080e7          	jalr	-1176(ra) # 800005aa <printf>
    printf("----------------------------------------------------\n");
    80002a4a:	00006517          	auipc	a0,0x6
    80002a4e:	88650513          	addi	a0,a0,-1914 # 800082d0 <etext+0x2d0>
    80002a52:	ffffe097          	auipc	ra,0xffffe
    80002a56:	b58080e7          	jalr	-1192(ra) # 800005aa <printf>
    printf("| PID | Time | Queue | TckTime\n");
    80002a5a:	00006517          	auipc	a0,0x6
    80002a5e:	8ae50513          	addi	a0,a0,-1874 # 80008308 <etext+0x308>
    80002a62:	ffffe097          	auipc	ra,0xffffe
    80002a66:	b48080e7          	jalr	-1208(ra) # 800005aa <printf>
    printf("----------------------------------------------------\n");
    80002a6a:	00006517          	auipc	a0,0x6
    80002a6e:	86650513          	addi	a0,a0,-1946 # 800082d0 <etext+0x2d0>
    80002a72:	ffffe097          	auipc	ra,0xffffe
    80002a76:	b38080e7          	jalr	-1224(ra) # 800005aa <printf>

    // Loop through each log entry and print the details
    for (int i = 0; i < log_index; i++) {
    80002a7a:	00006797          	auipc	a5,0x6
    80002a7e:	09a7a783          	lw	a5,154(a5) # 80008b14 <log_index>
    80002a82:	04f05663          	blez	a5,80002ace <print_logg+0xa6>
    80002a86:	ec26                	sd	s1,24(sp)
    80002a88:	e84a                	sd	s2,16(sp)
    80002a8a:	e44e                	sd	s3,8(sp)
    80002a8c:	e052                	sd	s4,0(sp)
    80002a8e:	00017497          	auipc	s1,0x17
    80002a92:	74248493          	addi	s1,s1,1858 # 8001a1d0 <logs>
    80002a96:	4901                	li	s2,0
        printf("| %d | %d | %d | %d |\n", logs[i].pid, logs[i].time, logs[i].queue, logs[i].ticktime) ;
    80002a98:	00006a17          	auipc	s4,0x6
    80002a9c:	890a0a13          	addi	s4,s4,-1904 # 80008328 <etext+0x328>
    for (int i = 0; i < log_index; i++) {
    80002aa0:	00006997          	auipc	s3,0x6
    80002aa4:	07498993          	addi	s3,s3,116 # 80008b14 <log_index>
        printf("| %d | %d | %d | %d |\n", logs[i].pid, logs[i].time, logs[i].queue, logs[i].ticktime) ;
    80002aa8:	4498                	lw	a4,8(s1)
    80002aaa:	44d4                	lw	a3,12(s1)
    80002aac:	40d0                	lw	a2,4(s1)
    80002aae:	408c                	lw	a1,0(s1)
    80002ab0:	8552                	mv	a0,s4
    80002ab2:	ffffe097          	auipc	ra,0xffffe
    80002ab6:	af8080e7          	jalr	-1288(ra) # 800005aa <printf>
    for (int i = 0; i < log_index; i++) {
    80002aba:	2905                	addiw	s2,s2,1
    80002abc:	04c1                	addi	s1,s1,16
    80002abe:	0009a783          	lw	a5,0(s3)
    80002ac2:	fef943e3          	blt	s2,a5,80002aa8 <print_logg+0x80>
    80002ac6:	64e2                	ld	s1,24(sp)
    80002ac8:	6942                	ld	s2,16(sp)
    80002aca:	69a2                	ld	s3,8(sp)
    80002acc:	6a02                	ld	s4,0(sp)
    }

    printf("----------------------------------------------------\n");
    80002ace:	00006517          	auipc	a0,0x6
    80002ad2:	80250513          	addi	a0,a0,-2046 # 800082d0 <etext+0x2d0>
    80002ad6:	ffffe097          	auipc	ra,0xffffe
    80002ada:	ad4080e7          	jalr	-1324(ra) # 800005aa <printf>
}
    80002ade:	70a2                	ld	ra,40(sp)
    80002ae0:	7402                	ld	s0,32(sp)
    80002ae2:	6145                	addi	sp,sp,48
    80002ae4:	8082                	ret
        printf("No log entries available.\n");
    80002ae6:	00005517          	auipc	a0,0x5
    80002aea:	7b250513          	addi	a0,a0,1970 # 80008298 <etext+0x298>
    80002aee:	ffffe097          	auipc	ra,0xffffe
    80002af2:	abc080e7          	jalr	-1348(ra) # 800005aa <printf>
        return;
    80002af6:	b7e5                	j	80002ade <print_logg+0xb6>

0000000080002af8 <swtch>:
    80002af8:	00153023          	sd	ra,0(a0)
    80002afc:	00253423          	sd	sp,8(a0)
    80002b00:	e900                	sd	s0,16(a0)
    80002b02:	ed04                	sd	s1,24(a0)
    80002b04:	03253023          	sd	s2,32(a0)
    80002b08:	03353423          	sd	s3,40(a0)
    80002b0c:	03453823          	sd	s4,48(a0)
    80002b10:	03553c23          	sd	s5,56(a0)
    80002b14:	05653023          	sd	s6,64(a0)
    80002b18:	05753423          	sd	s7,72(a0)
    80002b1c:	05853823          	sd	s8,80(a0)
    80002b20:	05953c23          	sd	s9,88(a0)
    80002b24:	07a53023          	sd	s10,96(a0)
    80002b28:	07b53423          	sd	s11,104(a0)
    80002b2c:	0005b083          	ld	ra,0(a1)
    80002b30:	0085b103          	ld	sp,8(a1)
    80002b34:	6980                	ld	s0,16(a1)
    80002b36:	6d84                	ld	s1,24(a1)
    80002b38:	0205b903          	ld	s2,32(a1)
    80002b3c:	0285b983          	ld	s3,40(a1)
    80002b40:	0305ba03          	ld	s4,48(a1)
    80002b44:	0385ba83          	ld	s5,56(a1)
    80002b48:	0405bb03          	ld	s6,64(a1)
    80002b4c:	0485bb83          	ld	s7,72(a1)
    80002b50:	0505bc03          	ld	s8,80(a1)
    80002b54:	0585bc83          	ld	s9,88(a1)
    80002b58:	0605bd03          	ld	s10,96(a1)
    80002b5c:	0685bd83          	ld	s11,104(a1)
    80002b60:	8082                	ret

0000000080002b62 <trapinit>:
void kernelvec();

extern int devintr();

void trapinit(void)
{
    80002b62:	1141                	addi	sp,sp,-16
    80002b64:	e406                	sd	ra,8(sp)
    80002b66:	e022                	sd	s0,0(sp)
    80002b68:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002b6a:	00005597          	auipc	a1,0x5
    80002b6e:	7d658593          	addi	a1,a1,2006 # 80008340 <etext+0x340>
    80002b72:	0003f517          	auipc	a0,0x3f
    80002b76:	bce50513          	addi	a0,a0,-1074 # 80041740 <tickslock>
    80002b7a:	ffffe097          	auipc	ra,0xffffe
    80002b7e:	02e080e7          	jalr	46(ra) # 80000ba8 <initlock>
}
    80002b82:	60a2                	ld	ra,8(sp)
    80002b84:	6402                	ld	s0,0(sp)
    80002b86:	0141                	addi	sp,sp,16
    80002b88:	8082                	ret

0000000080002b8a <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void trapinithart(void)
{
    80002b8a:	1141                	addi	sp,sp,-16
    80002b8c:	e422                	sd	s0,8(sp)
    80002b8e:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002b90:	00003797          	auipc	a5,0x3
    80002b94:	7c078793          	addi	a5,a5,1984 # 80006350 <kernelvec>
    80002b98:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002b9c:	6422                	ld	s0,8(sp)
    80002b9e:	0141                	addi	sp,sp,16
    80002ba0:	8082                	ret

0000000080002ba2 <usertrapret>:

//
// return to user space
//
void usertrapret(void)
{
    80002ba2:	1141                	addi	sp,sp,-16
    80002ba4:	e406                	sd	ra,8(sp)
    80002ba6:	e022                	sd	s0,0(sp)
    80002ba8:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002baa:	fffff097          	auipc	ra,0xfffff
    80002bae:	f80080e7          	jalr	-128(ra) # 80001b2a <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002bb2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002bb6:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002bb8:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002bbc:	00004697          	auipc	a3,0x4
    80002bc0:	44468693          	addi	a3,a3,1092 # 80007000 <_trampoline>
    80002bc4:	00004717          	auipc	a4,0x4
    80002bc8:	43c70713          	addi	a4,a4,1084 # 80007000 <_trampoline>
    80002bcc:	8f15                	sub	a4,a4,a3
    80002bce:	040007b7          	lui	a5,0x4000
    80002bd2:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    80002bd4:	07b2                	slli	a5,a5,0xc
    80002bd6:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002bd8:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002bdc:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002bde:	18002673          	csrr	a2,satp
    80002be2:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002be4:	6d30                	ld	a2,88(a0)
    80002be6:	6138                	ld	a4,64(a0)
    80002be8:	6585                	lui	a1,0x1
    80002bea:	972e                	add	a4,a4,a1
    80002bec:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002bee:	6d38                	ld	a4,88(a0)
    80002bf0:	00000617          	auipc	a2,0x0
    80002bf4:	14660613          	addi	a2,a2,326 # 80002d36 <usertrap>
    80002bf8:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp(); // hartid for cpuid()
    80002bfa:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002bfc:	8612                	mv	a2,tp
    80002bfe:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c00:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.

  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002c04:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002c08:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002c0c:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002c10:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002c12:	6f18                	ld	a4,24(a4)
    80002c14:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002c18:	6928                	ld	a0,80(a0)
    80002c1a:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002c1c:	00004717          	auipc	a4,0x4
    80002c20:	48070713          	addi	a4,a4,1152 # 8000709c <userret>
    80002c24:	8f15                	sub	a4,a4,a3
    80002c26:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80002c28:	577d                	li	a4,-1
    80002c2a:	177e                	slli	a4,a4,0x3f
    80002c2c:	8d59                	or	a0,a0,a4
    80002c2e:	9782                	jalr	a5
}
    80002c30:	60a2                	ld	ra,8(sp)
    80002c32:	6402                	ld	s0,0(sp)
    80002c34:	0141                	addi	sp,sp,16
    80002c36:	8082                	ret

0000000080002c38 <clockintr>:
  w_sepc(sepc);
  w_sstatus(sstatus);
}

void clockintr()
{
    80002c38:	1101                	addi	sp,sp,-32
    80002c3a:	ec06                	sd	ra,24(sp)
    80002c3c:	e822                	sd	s0,16(sp)
    80002c3e:	e426                	sd	s1,8(sp)
    80002c40:	e04a                	sd	s2,0(sp)
    80002c42:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002c44:	0003f917          	auipc	s2,0x3f
    80002c48:	afc90913          	addi	s2,s2,-1284 # 80041740 <tickslock>
    80002c4c:	854a                	mv	a0,s2
    80002c4e:	ffffe097          	auipc	ra,0xffffe
    80002c52:	fea080e7          	jalr	-22(ra) # 80000c38 <acquire>
  ticks++;
    80002c56:	00006497          	auipc	s1,0x6
    80002c5a:	ec648493          	addi	s1,s1,-314 # 80008b1c <ticks>
    80002c5e:	409c                	lw	a5,0(s1)
    80002c60:	2785                	addiw	a5,a5,1
    80002c62:	c09c                	sw	a5,0(s1)
  update_time();
    80002c64:	00000097          	auipc	ra,0x0
    80002c68:	d66080e7          	jalr	-666(ra) # 800029ca <update_time>
  //   // {
  //   //   p->wtime++;
  //   // }
  //   release(&p->lock);
  // }
  wakeup(&ticks);
    80002c6c:	8526                	mv	a0,s1
    80002c6e:	fffff097          	auipc	ra,0xfffff
    80002c72:	68a080e7          	jalr	1674(ra) # 800022f8 <wakeup>
  release(&tickslock);
    80002c76:	854a                	mv	a0,s2
    80002c78:	ffffe097          	auipc	ra,0xffffe
    80002c7c:	074080e7          	jalr	116(ra) # 80000cec <release>
}
    80002c80:	60e2                	ld	ra,24(sp)
    80002c82:	6442                	ld	s0,16(sp)
    80002c84:	64a2                	ld	s1,8(sp)
    80002c86:	6902                	ld	s2,0(sp)
    80002c88:	6105                	addi	sp,sp,32
    80002c8a:	8082                	ret

0000000080002c8c <devintr>:
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002c8c:	142027f3          	csrr	a5,scause

    return 2;
  }
  else
  {
    return 0;
    80002c90:	4501                	li	a0,0
  if ((scause & 0x8000000000000000L) &&
    80002c92:	0a07d163          	bgez	a5,80002d34 <devintr+0xa8>
{
    80002c96:	1101                	addi	sp,sp,-32
    80002c98:	ec06                	sd	ra,24(sp)
    80002c9a:	e822                	sd	s0,16(sp)
    80002c9c:	1000                	addi	s0,sp,32
      (scause & 0xff) == 9)
    80002c9e:	0ff7f713          	zext.b	a4,a5
  if ((scause & 0x8000000000000000L) &&
    80002ca2:	46a5                	li	a3,9
    80002ca4:	00d70c63          	beq	a4,a3,80002cbc <devintr+0x30>
  else if (scause == 0x8000000000000001L)
    80002ca8:	577d                	li	a4,-1
    80002caa:	177e                	slli	a4,a4,0x3f
    80002cac:	0705                	addi	a4,a4,1
    return 0;
    80002cae:	4501                	li	a0,0
  else if (scause == 0x8000000000000001L)
    80002cb0:	06e78163          	beq	a5,a4,80002d12 <devintr+0x86>
  }
}
    80002cb4:	60e2                	ld	ra,24(sp)
    80002cb6:	6442                	ld	s0,16(sp)
    80002cb8:	6105                	addi	sp,sp,32
    80002cba:	8082                	ret
    80002cbc:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    80002cbe:	00003097          	auipc	ra,0x3
    80002cc2:	79e080e7          	jalr	1950(ra) # 8000645c <plic_claim>
    80002cc6:	84aa                	mv	s1,a0
    if (irq == UART0_IRQ)
    80002cc8:	47a9                	li	a5,10
    80002cca:	00f50963          	beq	a0,a5,80002cdc <devintr+0x50>
    else if (irq == VIRTIO0_IRQ)
    80002cce:	4785                	li	a5,1
    80002cd0:	00f50b63          	beq	a0,a5,80002ce6 <devintr+0x5a>
    return 1;
    80002cd4:	4505                	li	a0,1
    else if (irq)
    80002cd6:	ec89                	bnez	s1,80002cf0 <devintr+0x64>
    80002cd8:	64a2                	ld	s1,8(sp)
    80002cda:	bfe9                	j	80002cb4 <devintr+0x28>
      uartintr();
    80002cdc:	ffffe097          	auipc	ra,0xffffe
    80002ce0:	d1e080e7          	jalr	-738(ra) # 800009fa <uartintr>
    if (irq)
    80002ce4:	a839                	j	80002d02 <devintr+0x76>
      virtio_disk_intr();
    80002ce6:	00004097          	auipc	ra,0x4
    80002cea:	ca0080e7          	jalr	-864(ra) # 80006986 <virtio_disk_intr>
    if (irq)
    80002cee:	a811                	j	80002d02 <devintr+0x76>
      printf("unexpected interrupt irq=%d\n", irq);
    80002cf0:	85a6                	mv	a1,s1
    80002cf2:	00005517          	auipc	a0,0x5
    80002cf6:	65650513          	addi	a0,a0,1622 # 80008348 <etext+0x348>
    80002cfa:	ffffe097          	auipc	ra,0xffffe
    80002cfe:	8b0080e7          	jalr	-1872(ra) # 800005aa <printf>
      plic_complete(irq);
    80002d02:	8526                	mv	a0,s1
    80002d04:	00003097          	auipc	ra,0x3
    80002d08:	77c080e7          	jalr	1916(ra) # 80006480 <plic_complete>
    return 1;
    80002d0c:	4505                	li	a0,1
    80002d0e:	64a2                	ld	s1,8(sp)
    80002d10:	b755                	j	80002cb4 <devintr+0x28>
    if (cpuid() == 0)
    80002d12:	fffff097          	auipc	ra,0xfffff
    80002d16:	dec080e7          	jalr	-532(ra) # 80001afe <cpuid>
    80002d1a:	c901                	beqz	a0,80002d2a <devintr+0x9e>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002d1c:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002d20:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002d22:	14479073          	csrw	sip,a5
    return 2;
    80002d26:	4509                	li	a0,2
    80002d28:	b771                	j	80002cb4 <devintr+0x28>
      clockintr();
    80002d2a:	00000097          	auipc	ra,0x0
    80002d2e:	f0e080e7          	jalr	-242(ra) # 80002c38 <clockintr>
    80002d32:	b7ed                	j	80002d1c <devintr+0x90>
}
    80002d34:	8082                	ret

0000000080002d36 <usertrap>:
{
    80002d36:	1101                	addi	sp,sp,-32
    80002d38:	ec06                	sd	ra,24(sp)
    80002d3a:	e822                	sd	s0,16(sp)
    80002d3c:	e426                	sd	s1,8(sp)
    80002d3e:	e04a                	sd	s2,0(sp)
    80002d40:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002d42:	100027f3          	csrr	a5,sstatus
  if ((r_sstatus() & SSTATUS_SPP) != 0)
    80002d46:	1007f793          	andi	a5,a5,256
    80002d4a:	e3b1                	bnez	a5,80002d8e <usertrap+0x58>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002d4c:	00003797          	auipc	a5,0x3
    80002d50:	60478793          	addi	a5,a5,1540 # 80006350 <kernelvec>
    80002d54:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002d58:	fffff097          	auipc	ra,0xfffff
    80002d5c:	dd2080e7          	jalr	-558(ra) # 80001b2a <myproc>
    80002d60:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002d62:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002d64:	14102773          	csrr	a4,sepc
    80002d68:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002d6a:	14202773          	csrr	a4,scause
  if (r_scause() == 8)
    80002d6e:	47a1                	li	a5,8
    80002d70:	02f70763          	beq	a4,a5,80002d9e <usertrap+0x68>
  else if ((which_dev = devintr()) != 0)
    80002d74:	00000097          	auipc	ra,0x0
    80002d78:	f18080e7          	jalr	-232(ra) # 80002c8c <devintr>
    80002d7c:	892a                	mv	s2,a0
    80002d7e:	c92d                	beqz	a0,80002df0 <usertrap+0xba>
  if (killed(p))
    80002d80:	8526                	mv	a0,s1
    80002d82:	00000097          	auipc	ra,0x0
    80002d86:	860080e7          	jalr	-1952(ra) # 800025e2 <killed>
    80002d8a:	c555                	beqz	a0,80002e36 <usertrap+0x100>
    80002d8c:	a045                	j	80002e2c <usertrap+0xf6>
    panic("usertrap: not from user mode");
    80002d8e:	00005517          	auipc	a0,0x5
    80002d92:	5da50513          	addi	a0,a0,1498 # 80008368 <etext+0x368>
    80002d96:	ffffd097          	auipc	ra,0xffffd
    80002d9a:	7ca080e7          	jalr	1994(ra) # 80000560 <panic>
    if (killed(p))
    80002d9e:	00000097          	auipc	ra,0x0
    80002da2:	844080e7          	jalr	-1980(ra) # 800025e2 <killed>
    80002da6:	ed1d                	bnez	a0,80002de4 <usertrap+0xae>
    p->trapframe->epc += 4;
    80002da8:	6cb8                	ld	a4,88(s1)
    80002daa:	6f1c                	ld	a5,24(a4)
    80002dac:	0791                	addi	a5,a5,4
    80002dae:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002db0:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002db4:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002db8:	10079073          	csrw	sstatus,a5
    syscall();
    80002dbc:	00000097          	auipc	ra,0x0
    80002dc0:	322080e7          	jalr	802(ra) # 800030de <syscall>
  if (killed(p))
    80002dc4:	8526                	mv	a0,s1
    80002dc6:	00000097          	auipc	ra,0x0
    80002dca:	81c080e7          	jalr	-2020(ra) # 800025e2 <killed>
    80002dce:	ed31                	bnez	a0,80002e2a <usertrap+0xf4>
  usertrapret();
    80002dd0:	00000097          	auipc	ra,0x0
    80002dd4:	dd2080e7          	jalr	-558(ra) # 80002ba2 <usertrapret>
}
    80002dd8:	60e2                	ld	ra,24(sp)
    80002dda:	6442                	ld	s0,16(sp)
    80002ddc:	64a2                	ld	s1,8(sp)
    80002dde:	6902                	ld	s2,0(sp)
    80002de0:	6105                	addi	sp,sp,32
    80002de2:	8082                	ret
      exit(-1);
    80002de4:	557d                	li	a0,-1
    80002de6:	fffff097          	auipc	ra,0xfffff
    80002dea:	5e2080e7          	jalr	1506(ra) # 800023c8 <exit>
    80002dee:	bf6d                	j	80002da8 <usertrap+0x72>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002df0:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002df4:	5890                	lw	a2,48(s1)
    80002df6:	00005517          	auipc	a0,0x5
    80002dfa:	59250513          	addi	a0,a0,1426 # 80008388 <etext+0x388>
    80002dfe:	ffffd097          	auipc	ra,0xffffd
    80002e02:	7ac080e7          	jalr	1964(ra) # 800005aa <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002e06:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002e0a:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002e0e:	00005517          	auipc	a0,0x5
    80002e12:	5aa50513          	addi	a0,a0,1450 # 800083b8 <etext+0x3b8>
    80002e16:	ffffd097          	auipc	ra,0xffffd
    80002e1a:	794080e7          	jalr	1940(ra) # 800005aa <printf>
    setkilled(p);
    80002e1e:	8526                	mv	a0,s1
    80002e20:	fffff097          	auipc	ra,0xfffff
    80002e24:	796080e7          	jalr	1942(ra) # 800025b6 <setkilled>
    80002e28:	bf71                	j	80002dc4 <usertrap+0x8e>
  if (killed(p))
    80002e2a:	4901                	li	s2,0
    exit(-1);
    80002e2c:	557d                	li	a0,-1
    80002e2e:	fffff097          	auipc	ra,0xfffff
    80002e32:	59a080e7          	jalr	1434(ra) # 800023c8 <exit>
   if (which_dev == 2 && p->alarm_act == 1 && p->hlp == 1) {
    80002e36:	4789                	li	a5,2
    80002e38:	f8f91ce3          	bne	s2,a5,80002dd0 <usertrap+0x9a>
    80002e3c:	2284a703          	lw	a4,552(s1)
    80002e40:	4785                	li	a5,1
    80002e42:	00f70763          	beq	a4,a5,80002e50 <usertrap+0x11a>
    yield();
    80002e46:	fffff097          	auipc	ra,0xfffff
    80002e4a:	412080e7          	jalr	1042(ra) # 80002258 <yield>
    80002e4e:	b749                	j	80002dd0 <usertrap+0x9a>
   if (which_dev == 2 && p->alarm_act == 1 && p->hlp == 1) {
    80002e50:	2184a703          	lw	a4,536(s1)
    80002e54:	fef719e3          	bne	a4,a5,80002e46 <usertrap+0x110>
      struct trapframe *tf = kalloc();
    80002e58:	ffffe097          	auipc	ra,0xffffe
    80002e5c:	cf0080e7          	jalr	-784(ra) # 80000b48 <kalloc>
    80002e60:	892a                	mv	s2,a0
      memmove(tf, p->trapframe, PGSIZE);
    80002e62:	6605                	lui	a2,0x1
    80002e64:	6cac                	ld	a1,88(s1)
    80002e66:	ffffe097          	auipc	ra,0xffffe
    80002e6a:	f2a080e7          	jalr	-214(ra) # 80000d90 <memmove>
      p->alarm_tf = tf;
    80002e6e:	2324b023          	sd	s2,544(s1)
      p->s_tcks++;
    80002e72:	20c4a783          	lw	a5,524(s1)
    80002e76:	2785                	addiw	a5,a5,1
    80002e78:	20f4a623          	sw	a5,524(s1)
      if (p->s_tcks % p->ticks == 0){
    80002e7c:	2084a703          	lw	a4,520(s1)
    80002e80:	02e7e7bb          	remw	a5,a5,a4
    80002e84:	f3e9                	bnez	a5,80002e46 <usertrap+0x110>
        p->trapframe->epc = p->handler;
    80002e86:	6cbc                	ld	a5,88(s1)
    80002e88:	2104b703          	ld	a4,528(s1)
    80002e8c:	ef98                	sd	a4,24(a5)
        p->hlp = 0;
    80002e8e:	2004ac23          	sw	zero,536(s1)
    80002e92:	bf55                	j	80002e46 <usertrap+0x110>

0000000080002e94 <kerneltrap>:
{
    80002e94:	7179                	addi	sp,sp,-48
    80002e96:	f406                	sd	ra,40(sp)
    80002e98:	f022                	sd	s0,32(sp)
    80002e9a:	ec26                	sd	s1,24(sp)
    80002e9c:	e84a                	sd	s2,16(sp)
    80002e9e:	e44e                	sd	s3,8(sp)
    80002ea0:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002ea2:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002ea6:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002eaa:	142029f3          	csrr	s3,scause
  if ((sstatus & SSTATUS_SPP) == 0)
    80002eae:	1004f793          	andi	a5,s1,256
    80002eb2:	cb85                	beqz	a5,80002ee2 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002eb4:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002eb8:	8b89                	andi	a5,a5,2
  if (intr_get() != 0)
    80002eba:	ef85                	bnez	a5,80002ef2 <kerneltrap+0x5e>
  if ((which_dev = devintr()) == 0)
    80002ebc:	00000097          	auipc	ra,0x0
    80002ec0:	dd0080e7          	jalr	-560(ra) # 80002c8c <devintr>
    80002ec4:	cd1d                	beqz	a0,80002f02 <kerneltrap+0x6e>
  if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002ec6:	4789                	li	a5,2
    80002ec8:	06f50a63          	beq	a0,a5,80002f3c <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002ecc:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002ed0:	10049073          	csrw	sstatus,s1
}
    80002ed4:	70a2                	ld	ra,40(sp)
    80002ed6:	7402                	ld	s0,32(sp)
    80002ed8:	64e2                	ld	s1,24(sp)
    80002eda:	6942                	ld	s2,16(sp)
    80002edc:	69a2                	ld	s3,8(sp)
    80002ede:	6145                	addi	sp,sp,48
    80002ee0:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002ee2:	00005517          	auipc	a0,0x5
    80002ee6:	4f650513          	addi	a0,a0,1270 # 800083d8 <etext+0x3d8>
    80002eea:	ffffd097          	auipc	ra,0xffffd
    80002eee:	676080e7          	jalr	1654(ra) # 80000560 <panic>
    panic("kerneltrap: interrupts enabled");
    80002ef2:	00005517          	auipc	a0,0x5
    80002ef6:	50e50513          	addi	a0,a0,1294 # 80008400 <etext+0x400>
    80002efa:	ffffd097          	auipc	ra,0xffffd
    80002efe:	666080e7          	jalr	1638(ra) # 80000560 <panic>
    printf("scause %p\n", scause);
    80002f02:	85ce                	mv	a1,s3
    80002f04:	00005517          	auipc	a0,0x5
    80002f08:	51c50513          	addi	a0,a0,1308 # 80008420 <etext+0x420>
    80002f0c:	ffffd097          	auipc	ra,0xffffd
    80002f10:	69e080e7          	jalr	1694(ra) # 800005aa <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002f14:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002f18:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002f1c:	00005517          	auipc	a0,0x5
    80002f20:	51450513          	addi	a0,a0,1300 # 80008430 <etext+0x430>
    80002f24:	ffffd097          	auipc	ra,0xffffd
    80002f28:	686080e7          	jalr	1670(ra) # 800005aa <printf>
    panic("kerneltrap");
    80002f2c:	00005517          	auipc	a0,0x5
    80002f30:	51c50513          	addi	a0,a0,1308 # 80008448 <etext+0x448>
    80002f34:	ffffd097          	auipc	ra,0xffffd
    80002f38:	62c080e7          	jalr	1580(ra) # 80000560 <panic>
  if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002f3c:	fffff097          	auipc	ra,0xfffff
    80002f40:	bee080e7          	jalr	-1042(ra) # 80001b2a <myproc>
    80002f44:	d541                	beqz	a0,80002ecc <kerneltrap+0x38>
    80002f46:	fffff097          	auipc	ra,0xfffff
    80002f4a:	be4080e7          	jalr	-1052(ra) # 80001b2a <myproc>
    80002f4e:	4d18                	lw	a4,24(a0)
    80002f50:	4791                	li	a5,4
    80002f52:	f6f71de3          	bne	a4,a5,80002ecc <kerneltrap+0x38>
    yield();
    80002f56:	fffff097          	auipc	ra,0xfffff
    80002f5a:	302080e7          	jalr	770(ra) # 80002258 <yield>
    80002f5e:	b7bd                	j	80002ecc <kerneltrap+0x38>

0000000080002f60 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002f60:	1101                	addi	sp,sp,-32
    80002f62:	ec06                	sd	ra,24(sp)
    80002f64:	e822                	sd	s0,16(sp)
    80002f66:	e426                	sd	s1,8(sp)
    80002f68:	1000                	addi	s0,sp,32
    80002f6a:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002f6c:	fffff097          	auipc	ra,0xfffff
    80002f70:	bbe080e7          	jalr	-1090(ra) # 80001b2a <myproc>
  switch (n) {
    80002f74:	4795                	li	a5,5
    80002f76:	0497e163          	bltu	a5,s1,80002fb8 <argraw+0x58>
    80002f7a:	048a                	slli	s1,s1,0x2
    80002f7c:	00006717          	auipc	a4,0x6
    80002f80:	94c70713          	addi	a4,a4,-1716 # 800088c8 <digits+0x18>
    80002f84:	94ba                	add	s1,s1,a4
    80002f86:	409c                	lw	a5,0(s1)
    80002f88:	97ba                	add	a5,a5,a4
    80002f8a:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002f8c:	6d3c                	ld	a5,88(a0)
    80002f8e:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002f90:	60e2                	ld	ra,24(sp)
    80002f92:	6442                	ld	s0,16(sp)
    80002f94:	64a2                	ld	s1,8(sp)
    80002f96:	6105                	addi	sp,sp,32
    80002f98:	8082                	ret
    return p->trapframe->a1;
    80002f9a:	6d3c                	ld	a5,88(a0)
    80002f9c:	7fa8                	ld	a0,120(a5)
    80002f9e:	bfcd                	j	80002f90 <argraw+0x30>
    return p->trapframe->a2;
    80002fa0:	6d3c                	ld	a5,88(a0)
    80002fa2:	63c8                	ld	a0,128(a5)
    80002fa4:	b7f5                	j	80002f90 <argraw+0x30>
    return p->trapframe->a3;
    80002fa6:	6d3c                	ld	a5,88(a0)
    80002fa8:	67c8                	ld	a0,136(a5)
    80002faa:	b7dd                	j	80002f90 <argraw+0x30>
    return p->trapframe->a4;
    80002fac:	6d3c                	ld	a5,88(a0)
    80002fae:	6bc8                	ld	a0,144(a5)
    80002fb0:	b7c5                	j	80002f90 <argraw+0x30>
    return p->trapframe->a5;
    80002fb2:	6d3c                	ld	a5,88(a0)
    80002fb4:	6fc8                	ld	a0,152(a5)
    80002fb6:	bfe9                	j	80002f90 <argraw+0x30>
  panic("argraw");
    80002fb8:	00005517          	auipc	a0,0x5
    80002fbc:	4a050513          	addi	a0,a0,1184 # 80008458 <etext+0x458>
    80002fc0:	ffffd097          	auipc	ra,0xffffd
    80002fc4:	5a0080e7          	jalr	1440(ra) # 80000560 <panic>

0000000080002fc8 <fetchaddr>:
{
    80002fc8:	1101                	addi	sp,sp,-32
    80002fca:	ec06                	sd	ra,24(sp)
    80002fcc:	e822                	sd	s0,16(sp)
    80002fce:	e426                	sd	s1,8(sp)
    80002fd0:	e04a                	sd	s2,0(sp)
    80002fd2:	1000                	addi	s0,sp,32
    80002fd4:	84aa                	mv	s1,a0
    80002fd6:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002fd8:	fffff097          	auipc	ra,0xfffff
    80002fdc:	b52080e7          	jalr	-1198(ra) # 80001b2a <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002fe0:	653c                	ld	a5,72(a0)
    80002fe2:	02f4f863          	bgeu	s1,a5,80003012 <fetchaddr+0x4a>
    80002fe6:	00848713          	addi	a4,s1,8
    80002fea:	02e7e663          	bltu	a5,a4,80003016 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002fee:	46a1                	li	a3,8
    80002ff0:	8626                	mv	a2,s1
    80002ff2:	85ca                	mv	a1,s2
    80002ff4:	6928                	ld	a0,80(a0)
    80002ff6:	ffffe097          	auipc	ra,0xffffe
    80002ffa:	778080e7          	jalr	1912(ra) # 8000176e <copyin>
    80002ffe:	00a03533          	snez	a0,a0
    80003002:	40a00533          	neg	a0,a0
}
    80003006:	60e2                	ld	ra,24(sp)
    80003008:	6442                	ld	s0,16(sp)
    8000300a:	64a2                	ld	s1,8(sp)
    8000300c:	6902                	ld	s2,0(sp)
    8000300e:	6105                	addi	sp,sp,32
    80003010:	8082                	ret
    return -1;
    80003012:	557d                	li	a0,-1
    80003014:	bfcd                	j	80003006 <fetchaddr+0x3e>
    80003016:	557d                	li	a0,-1
    80003018:	b7fd                	j	80003006 <fetchaddr+0x3e>

000000008000301a <fetchstr>:
{
    8000301a:	7179                	addi	sp,sp,-48
    8000301c:	f406                	sd	ra,40(sp)
    8000301e:	f022                	sd	s0,32(sp)
    80003020:	ec26                	sd	s1,24(sp)
    80003022:	e84a                	sd	s2,16(sp)
    80003024:	e44e                	sd	s3,8(sp)
    80003026:	1800                	addi	s0,sp,48
    80003028:	892a                	mv	s2,a0
    8000302a:	84ae                	mv	s1,a1
    8000302c:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    8000302e:	fffff097          	auipc	ra,0xfffff
    80003032:	afc080e7          	jalr	-1284(ra) # 80001b2a <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80003036:	86ce                	mv	a3,s3
    80003038:	864a                	mv	a2,s2
    8000303a:	85a6                	mv	a1,s1
    8000303c:	6928                	ld	a0,80(a0)
    8000303e:	ffffe097          	auipc	ra,0xffffe
    80003042:	7be080e7          	jalr	1982(ra) # 800017fc <copyinstr>
    80003046:	00054e63          	bltz	a0,80003062 <fetchstr+0x48>
  return strlen(buf);
    8000304a:	8526                	mv	a0,s1
    8000304c:	ffffe097          	auipc	ra,0xffffe
    80003050:	e5c080e7          	jalr	-420(ra) # 80000ea8 <strlen>
}
    80003054:	70a2                	ld	ra,40(sp)
    80003056:	7402                	ld	s0,32(sp)
    80003058:	64e2                	ld	s1,24(sp)
    8000305a:	6942                	ld	s2,16(sp)
    8000305c:	69a2                	ld	s3,8(sp)
    8000305e:	6145                	addi	sp,sp,48
    80003060:	8082                	ret
    return -1;
    80003062:	557d                	li	a0,-1
    80003064:	bfc5                	j	80003054 <fetchstr+0x3a>

0000000080003066 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80003066:	1101                	addi	sp,sp,-32
    80003068:	ec06                	sd	ra,24(sp)
    8000306a:	e822                	sd	s0,16(sp)
    8000306c:	e426                	sd	s1,8(sp)
    8000306e:	1000                	addi	s0,sp,32
    80003070:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80003072:	00000097          	auipc	ra,0x0
    80003076:	eee080e7          	jalr	-274(ra) # 80002f60 <argraw>
    8000307a:	c088                	sw	a0,0(s1)
}
    8000307c:	60e2                	ld	ra,24(sp)
    8000307e:	6442                	ld	s0,16(sp)
    80003080:	64a2                	ld	s1,8(sp)
    80003082:	6105                	addi	sp,sp,32
    80003084:	8082                	ret

0000000080003086 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80003086:	1101                	addi	sp,sp,-32
    80003088:	ec06                	sd	ra,24(sp)
    8000308a:	e822                	sd	s0,16(sp)
    8000308c:	e426                	sd	s1,8(sp)
    8000308e:	1000                	addi	s0,sp,32
    80003090:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80003092:	00000097          	auipc	ra,0x0
    80003096:	ece080e7          	jalr	-306(ra) # 80002f60 <argraw>
    8000309a:	e088                	sd	a0,0(s1)
}
    8000309c:	60e2                	ld	ra,24(sp)
    8000309e:	6442                	ld	s0,16(sp)
    800030a0:	64a2                	ld	s1,8(sp)
    800030a2:	6105                	addi	sp,sp,32
    800030a4:	8082                	ret

00000000800030a6 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    800030a6:	7179                	addi	sp,sp,-48
    800030a8:	f406                	sd	ra,40(sp)
    800030aa:	f022                	sd	s0,32(sp)
    800030ac:	ec26                	sd	s1,24(sp)
    800030ae:	e84a                	sd	s2,16(sp)
    800030b0:	1800                	addi	s0,sp,48
    800030b2:	84ae                	mv	s1,a1
    800030b4:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    800030b6:	fd840593          	addi	a1,s0,-40
    800030ba:	00000097          	auipc	ra,0x0
    800030be:	fcc080e7          	jalr	-52(ra) # 80003086 <argaddr>
  return fetchstr(addr, buf, max);
    800030c2:	864a                	mv	a2,s2
    800030c4:	85a6                	mv	a1,s1
    800030c6:	fd843503          	ld	a0,-40(s0)
    800030ca:	00000097          	auipc	ra,0x0
    800030ce:	f50080e7          	jalr	-176(ra) # 8000301a <fetchstr>
}
    800030d2:	70a2                	ld	ra,40(sp)
    800030d4:	7402                	ld	s0,32(sp)
    800030d6:	64e2                	ld	s1,24(sp)
    800030d8:	6942                	ld	s2,16(sp)
    800030da:	6145                	addi	sp,sp,48
    800030dc:	8082                	ret

00000000800030de <syscall>:

};

void
syscall(void)
{
    800030de:	1101                	addi	sp,sp,-32
    800030e0:	ec06                	sd	ra,24(sp)
    800030e2:	e822                	sd	s0,16(sp)
    800030e4:	e426                	sd	s1,8(sp)
    800030e6:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    800030e8:	fffff097          	auipc	ra,0xfffff
    800030ec:	a42080e7          	jalr	-1470(ra) # 80001b2a <myproc>
    800030f0:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    800030f2:	6d3c                	ld	a5,88(a0)
    800030f4:	77dc                	ld	a5,168(a5)
    800030f6:	0007869b          	sext.w	a3,a5
  
  
   
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    800030fa:	37fd                	addiw	a5,a5,-1
    800030fc:	4769                	li	a4,26
    800030fe:	02f76863          	bltu	a4,a5,8000312e <syscall+0x50>
    80003102:	00369713          	slli	a4,a3,0x3
    80003106:	00005797          	auipc	a5,0x5
    8000310a:	7da78793          	addi	a5,a5,2010 # 800088e0 <syscalls>
    8000310e:	97ba                	add	a5,a5,a4
    80003110:	6398                	ld	a4,0(a5)
    80003112:	cf11                	beqz	a4,8000312e <syscall+0x50>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
     // Increment the syscall count for this syscall's parent
      if(p->parent!=NULL)  p->parent->syscall_count[num]++; // Ensure syscall_count is initialized
    80003114:	7d1c                	ld	a5,56(a0)
    80003116:	cb81                	beqz	a5,80003126 <syscall+0x48>
    80003118:	068a                	slli	a3,a3,0x2
    8000311a:	97b6                	add	a5,a5,a3
    8000311c:	1747a683          	lw	a3,372(a5)
    80003120:	2685                	addiw	a3,a3,1
    80003122:	16d7aa23          	sw	a3,372(a5)
    p->trapframe->a0 = syscalls[num]();
    80003126:	6ca4                	ld	s1,88(s1)
    80003128:	9702                	jalr	a4
    8000312a:	f8a8                	sd	a0,112(s1)
    8000312c:	a839                	j	8000314a <syscall+0x6c>
  
  } else {
    printf("%d %s: unknown sys call %d\n",
    8000312e:	15848613          	addi	a2,s1,344
    80003132:	588c                	lw	a1,48(s1)
    80003134:	00005517          	auipc	a0,0x5
    80003138:	32c50513          	addi	a0,a0,812 # 80008460 <etext+0x460>
    8000313c:	ffffd097          	auipc	ra,0xffffd
    80003140:	46e080e7          	jalr	1134(ra) # 800005aa <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80003144:	6cbc                	ld	a5,88(s1)
    80003146:	577d                	li	a4,-1
    80003148:	fbb8                	sd	a4,112(a5)
  }
}
    8000314a:	60e2                	ld	ra,24(sp)
    8000314c:	6442                	ld	s0,16(sp)
    8000314e:	64a2                	ld	s1,8(sp)
    80003150:	6105                	addi	sp,sp,32
    80003152:	8082                	ret

0000000080003154 <sys_printlog>:
extern char *syscall_names[];

#define NUMBER_OF_SYSCALLS 32 

uint64 
sys_printlog(void) {
    80003154:	1141                	addi	sp,sp,-16
    80003156:	e406                	sd	ra,8(sp)
    80003158:	e022                	sd	s0,0(sp)
    8000315a:	0800                	addi	s0,sp,16
  print_logg();
    8000315c:	00000097          	auipc	ra,0x0
    80003160:	8cc080e7          	jalr	-1844(ra) # 80002a28 <print_logg>
  return 0 ;
}
    80003164:	4501                	li	a0,0
    80003166:	60a2                	ld	ra,8(sp)
    80003168:	6402                	ld	s0,0(sp)
    8000316a:	0141                	addi	sp,sp,16
    8000316c:	8082                	ret

000000008000316e <sys_sigalarm>:


uint64
 sys_sigalarm(void) {
    8000316e:	1101                	addi	sp,sp,-32
    80003170:	ec06                	sd	ra,24(sp)
    80003172:	e822                	sd	s0,16(sp)
    80003174:	1000                	addi	s0,sp,32
  int intervalj;
  uint64 handlerj;

  argint(0, &intervalj) ;
    80003176:	fec40593          	addi	a1,s0,-20
    8000317a:	4501                	li	a0,0
    8000317c:	00000097          	auipc	ra,0x0
    80003180:	eea080e7          	jalr	-278(ra) # 80003066 <argint>
  argaddr(1, &handlerj) ;
    80003184:	fe040593          	addi	a1,s0,-32
    80003188:	4505                	li	a0,1
    8000318a:	00000097          	auipc	ra,0x0
    8000318e:	efc080e7          	jalr	-260(ra) # 80003086 <argaddr>
  

  struct proc *p = myproc();
    80003192:	fffff097          	auipc	ra,0xfffff
    80003196:	998080e7          	jalr	-1640(ra) # 80001b2a <myproc>
  
  p->ticks = intervalj;
    8000319a:	fec42783          	lw	a5,-20(s0)
    8000319e:	20f52423          	sw	a5,520(a0)

  p->handler = handlerj;
    800031a2:	fe043783          	ld	a5,-32(s0)
    800031a6:	20f53823          	sd	a5,528(a0)
  p->alarm_act = 1;  // Alarm is now active
    800031aa:	4785                	li	a5,1
    800031ac:	22f52423          	sw	a5,552(a0)
  

  return 0;
}
    800031b0:	4501                	li	a0,0
    800031b2:	60e2                	ld	ra,24(sp)
    800031b4:	6442                	ld	s0,16(sp)
    800031b6:	6105                	addi	sp,sp,32
    800031b8:	8082                	ret

00000000800031ba <sys_sigreturn>:

uint64 
sys_sigreturn(void)
{
    800031ba:	1101                	addi	sp,sp,-32
    800031bc:	ec06                	sd	ra,24(sp)
    800031be:	e822                	sd	s0,16(sp)
    800031c0:	e426                	sd	s1,8(sp)
    800031c2:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800031c4:	fffff097          	auipc	ra,0xfffff
    800031c8:	966080e7          	jalr	-1690(ra) # 80001b2a <myproc>
    800031cc:	84aa                	mv	s1,a0
  memmove(p->trapframe, p->alarm_tf, PGSIZE);
    800031ce:	6605                	lui	a2,0x1
    800031d0:	22053583          	ld	a1,544(a0)
    800031d4:	6d28                	ld	a0,88(a0)
    800031d6:	ffffe097          	auipc	ra,0xffffe
    800031da:	bba080e7          	jalr	-1094(ra) # 80000d90 <memmove>
 
  kfree(p->alarm_tf);
    800031de:	2204b503          	ld	a0,544(s1)
    800031e2:	ffffe097          	auipc	ra,0xffffe
    800031e6:	868080e7          	jalr	-1944(ra) # 80000a4a <kfree>
  p->hlp = 1;
    800031ea:	4785                	li	a5,1
    800031ec:	20f4ac23          	sw	a5,536(s1)
  return myproc()->trapframe->a0;
    800031f0:	fffff097          	auipc	ra,0xfffff
    800031f4:	93a080e7          	jalr	-1734(ra) # 80001b2a <myproc>
    800031f8:	6d3c                	ld	a5,88(a0)
}
    800031fa:	7ba8                	ld	a0,112(a5)
    800031fc:	60e2                	ld	ra,24(sp)
    800031fe:	6442                	ld	s0,16(sp)
    80003200:	64a2                	ld	s1,8(sp)
    80003202:	6105                	addi	sp,sp,32
    80003204:	8082                	ret

0000000080003206 <sys_settickets>:

uint64
sys_settickets(void)
{
    80003206:	1101                	addi	sp,sp,-32
    80003208:	ec06                	sd	ra,24(sp)
    8000320a:	e822                	sd	s0,16(sp)
    8000320c:	1000                	addi	s0,sp,32
    int n;
     (argint(0, &n)); 
    8000320e:	fec40593          	addi	a1,s0,-20
    80003212:	4501                	li	a0,0
    80003214:	00000097          	auipc	ra,0x0
    80003218:	e52080e7          	jalr	-430(ra) # 80003066 <argint>
     if( n < 1) {
    8000321c:	fec42783          	lw	a5,-20(s0)
        return -1; // Invalid input
    80003220:	557d                	li	a0,-1
     if( n < 1) {
    80003222:	00f05b63          	blez	a5,80003238 <sys_settickets+0x32>
    }
    
    // Set the tickets for the calling process
    struct proc *p = myproc();
    80003226:	fffff097          	auipc	ra,0xfffff
    8000322a:	904080e7          	jalr	-1788(ra) # 80001b2a <myproc>
    p->tickets = n;
    8000322e:	fec42783          	lw	a5,-20(s0)
    80003232:	1ef52c23          	sw	a5,504(a0)
    
    return 0;
    80003236:	4501                	li	a0,0
}
    80003238:	60e2                	ld	ra,24(sp)
    8000323a:	6442                	ld	s0,16(sp)
    8000323c:	6105                	addi	sp,sp,32
    8000323e:	8082                	ret

0000000080003240 <sys_getSysCount>:



uint64
sys_getSysCount(void) {
    80003240:	1101                	addi	sp,sp,-32
    80003242:	ec06                	sd	ra,24(sp)
    80003244:	e822                	sd	s0,16(sp)
    80003246:	1000                	addi	s0,sp,32
    int mask;

    // Fetch the mask argument
     argint(0, &mask) ;
    80003248:	fec40593          	addi	a1,s0,-20
    8000324c:	4501                	li	a0,0
    8000324e:	00000097          	auipc	ra,0x0
    80003252:	e18080e7          	jalr	-488(ra) # 80003066 <argint>
      
    myproc()->s1 = mask;
    80003256:	fffff097          	auipc	ra,0xfffff
    8000325a:	8d4080e7          	jalr	-1836(ra) # 80001b2a <myproc>
    8000325e:	fec42783          	lw	a5,-20(s0)
    80003262:	1ef52a23          	sw	a5,500(a0)
    int p = getSysCount(mask);
    80003266:	853e                	mv	a0,a5
    80003268:	fffff097          	auipc	ra,0xfffff
    8000326c:	2b4080e7          	jalr	692(ra) # 8000251c <getSysCount>
    
    return p; 
    
}
    80003270:	60e2                	ld	ra,24(sp)
    80003272:	6442                	ld	s0,16(sp)
    80003274:	6105                	addi	sp,sp,32
    80003276:	8082                	ret

0000000080003278 <sys_exit>:



uint64
sys_exit(void)
{
    80003278:	1101                	addi	sp,sp,-32
    8000327a:	ec06                	sd	ra,24(sp)
    8000327c:	e822                	sd	s0,16(sp)
    8000327e:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80003280:	fec40593          	addi	a1,s0,-20
    80003284:	4501                	li	a0,0
    80003286:	00000097          	auipc	ra,0x0
    8000328a:	de0080e7          	jalr	-544(ra) # 80003066 <argint>
  exit(n);
    8000328e:	fec42503          	lw	a0,-20(s0)
    80003292:	fffff097          	auipc	ra,0xfffff
    80003296:	136080e7          	jalr	310(ra) # 800023c8 <exit>
  return 0; // not reached
}
    8000329a:	4501                	li	a0,0
    8000329c:	60e2                	ld	ra,24(sp)
    8000329e:	6442                	ld	s0,16(sp)
    800032a0:	6105                	addi	sp,sp,32
    800032a2:	8082                	ret

00000000800032a4 <sys_getpid>:

uint64
sys_getpid(void)
{
    800032a4:	1141                	addi	sp,sp,-16
    800032a6:	e406                	sd	ra,8(sp)
    800032a8:	e022                	sd	s0,0(sp)
    800032aa:	0800                	addi	s0,sp,16
  return myproc()->pid;
    800032ac:	fffff097          	auipc	ra,0xfffff
    800032b0:	87e080e7          	jalr	-1922(ra) # 80001b2a <myproc>
}
    800032b4:	5908                	lw	a0,48(a0)
    800032b6:	60a2                	ld	ra,8(sp)
    800032b8:	6402                	ld	s0,0(sp)
    800032ba:	0141                	addi	sp,sp,16
    800032bc:	8082                	ret

00000000800032be <sys_fork>:

uint64
sys_fork(void)
{
    800032be:	1141                	addi	sp,sp,-16
    800032c0:	e406                	sd	ra,8(sp)
    800032c2:	e022                	sd	s0,0(sp)
    800032c4:	0800                	addi	s0,sp,16
  return fork();
    800032c6:	fffff097          	auipc	ra,0xfffff
    800032ca:	c82080e7          	jalr	-894(ra) # 80001f48 <fork>
}
    800032ce:	60a2                	ld	ra,8(sp)
    800032d0:	6402                	ld	s0,0(sp)
    800032d2:	0141                	addi	sp,sp,16
    800032d4:	8082                	ret

00000000800032d6 <sys_wait>:

uint64
sys_wait(void)
{
    800032d6:	1101                	addi	sp,sp,-32
    800032d8:	ec06                	sd	ra,24(sp)
    800032da:	e822                	sd	s0,16(sp)
    800032dc:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    800032de:	fe840593          	addi	a1,s0,-24
    800032e2:	4501                	li	a0,0
    800032e4:	00000097          	auipc	ra,0x0
    800032e8:	da2080e7          	jalr	-606(ra) # 80003086 <argaddr>
  return wait(p);
    800032ec:	fe843503          	ld	a0,-24(s0)
    800032f0:	fffff097          	auipc	ra,0xfffff
    800032f4:	324080e7          	jalr	804(ra) # 80002614 <wait>
}
    800032f8:	60e2                	ld	ra,24(sp)
    800032fa:	6442                	ld	s0,16(sp)
    800032fc:	6105                	addi	sp,sp,32
    800032fe:	8082                	ret

0000000080003300 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80003300:	7179                	addi	sp,sp,-48
    80003302:	f406                	sd	ra,40(sp)
    80003304:	f022                	sd	s0,32(sp)
    80003306:	ec26                	sd	s1,24(sp)
    80003308:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    8000330a:	fdc40593          	addi	a1,s0,-36
    8000330e:	4501                	li	a0,0
    80003310:	00000097          	auipc	ra,0x0
    80003314:	d56080e7          	jalr	-682(ra) # 80003066 <argint>
  addr = myproc()->sz;
    80003318:	fffff097          	auipc	ra,0xfffff
    8000331c:	812080e7          	jalr	-2030(ra) # 80001b2a <myproc>
    80003320:	6524                	ld	s1,72(a0)
  if (growproc(n) < 0)
    80003322:	fdc42503          	lw	a0,-36(s0)
    80003326:	fffff097          	auipc	ra,0xfffff
    8000332a:	bc6080e7          	jalr	-1082(ra) # 80001eec <growproc>
    8000332e:	00054863          	bltz	a0,8000333e <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    80003332:	8526                	mv	a0,s1
    80003334:	70a2                	ld	ra,40(sp)
    80003336:	7402                	ld	s0,32(sp)
    80003338:	64e2                	ld	s1,24(sp)
    8000333a:	6145                	addi	sp,sp,48
    8000333c:	8082                	ret
    return -1;
    8000333e:	54fd                	li	s1,-1
    80003340:	bfcd                	j	80003332 <sys_sbrk+0x32>

0000000080003342 <sys_sleep>:

uint64
sys_sleep(void)
{
    80003342:	7139                	addi	sp,sp,-64
    80003344:	fc06                	sd	ra,56(sp)
    80003346:	f822                	sd	s0,48(sp)
    80003348:	f04a                	sd	s2,32(sp)
    8000334a:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    8000334c:	fcc40593          	addi	a1,s0,-52
    80003350:	4501                	li	a0,0
    80003352:	00000097          	auipc	ra,0x0
    80003356:	d14080e7          	jalr	-748(ra) # 80003066 <argint>
  acquire(&tickslock);
    8000335a:	0003e517          	auipc	a0,0x3e
    8000335e:	3e650513          	addi	a0,a0,998 # 80041740 <tickslock>
    80003362:	ffffe097          	auipc	ra,0xffffe
    80003366:	8d6080e7          	jalr	-1834(ra) # 80000c38 <acquire>
  ticks0 = ticks;
    8000336a:	00005917          	auipc	s2,0x5
    8000336e:	7b292903          	lw	s2,1970(s2) # 80008b1c <ticks>
  while (ticks - ticks0 < n)
    80003372:	fcc42783          	lw	a5,-52(s0)
    80003376:	c3b9                	beqz	a5,800033bc <sys_sleep+0x7a>
    80003378:	f426                	sd	s1,40(sp)
    8000337a:	ec4e                	sd	s3,24(sp)
    if (killed(myproc()))
    {
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    8000337c:	0003e997          	auipc	s3,0x3e
    80003380:	3c498993          	addi	s3,s3,964 # 80041740 <tickslock>
    80003384:	00005497          	auipc	s1,0x5
    80003388:	79848493          	addi	s1,s1,1944 # 80008b1c <ticks>
    if (killed(myproc()))
    8000338c:	ffffe097          	auipc	ra,0xffffe
    80003390:	79e080e7          	jalr	1950(ra) # 80001b2a <myproc>
    80003394:	fffff097          	auipc	ra,0xfffff
    80003398:	24e080e7          	jalr	590(ra) # 800025e2 <killed>
    8000339c:	ed15                	bnez	a0,800033d8 <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    8000339e:	85ce                	mv	a1,s3
    800033a0:	8526                	mv	a0,s1
    800033a2:	fffff097          	auipc	ra,0xfffff
    800033a6:	ef2080e7          	jalr	-270(ra) # 80002294 <sleep>
  while (ticks - ticks0 < n)
    800033aa:	409c                	lw	a5,0(s1)
    800033ac:	412787bb          	subw	a5,a5,s2
    800033b0:	fcc42703          	lw	a4,-52(s0)
    800033b4:	fce7ece3          	bltu	a5,a4,8000338c <sys_sleep+0x4a>
    800033b8:	74a2                	ld	s1,40(sp)
    800033ba:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    800033bc:	0003e517          	auipc	a0,0x3e
    800033c0:	38450513          	addi	a0,a0,900 # 80041740 <tickslock>
    800033c4:	ffffe097          	auipc	ra,0xffffe
    800033c8:	928080e7          	jalr	-1752(ra) # 80000cec <release>
  return 0;
    800033cc:	4501                	li	a0,0
}
    800033ce:	70e2                	ld	ra,56(sp)
    800033d0:	7442                	ld	s0,48(sp)
    800033d2:	7902                	ld	s2,32(sp)
    800033d4:	6121                	addi	sp,sp,64
    800033d6:	8082                	ret
      release(&tickslock);
    800033d8:	0003e517          	auipc	a0,0x3e
    800033dc:	36850513          	addi	a0,a0,872 # 80041740 <tickslock>
    800033e0:	ffffe097          	auipc	ra,0xffffe
    800033e4:	90c080e7          	jalr	-1780(ra) # 80000cec <release>
      return -1;
    800033e8:	557d                	li	a0,-1
    800033ea:	74a2                	ld	s1,40(sp)
    800033ec:	69e2                	ld	s3,24(sp)
    800033ee:	b7c5                	j	800033ce <sys_sleep+0x8c>

00000000800033f0 <sys_kill>:

uint64
sys_kill(void)
{
    800033f0:	1101                	addi	sp,sp,-32
    800033f2:	ec06                	sd	ra,24(sp)
    800033f4:	e822                	sd	s0,16(sp)
    800033f6:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    800033f8:	fec40593          	addi	a1,s0,-20
    800033fc:	4501                	li	a0,0
    800033fe:	00000097          	auipc	ra,0x0
    80003402:	c68080e7          	jalr	-920(ra) # 80003066 <argint>
  return kill(pid);
    80003406:	fec42503          	lw	a0,-20(s0)
    8000340a:	fffff097          	auipc	ra,0xfffff
    8000340e:	0a0080e7          	jalr	160(ra) # 800024aa <kill>
}
    80003412:	60e2                	ld	ra,24(sp)
    80003414:	6442                	ld	s0,16(sp)
    80003416:	6105                	addi	sp,sp,32
    80003418:	8082                	ret

000000008000341a <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    8000341a:	1101                	addi	sp,sp,-32
    8000341c:	ec06                	sd	ra,24(sp)
    8000341e:	e822                	sd	s0,16(sp)
    80003420:	e426                	sd	s1,8(sp)
    80003422:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80003424:	0003e517          	auipc	a0,0x3e
    80003428:	31c50513          	addi	a0,a0,796 # 80041740 <tickslock>
    8000342c:	ffffe097          	auipc	ra,0xffffe
    80003430:	80c080e7          	jalr	-2036(ra) # 80000c38 <acquire>
  xticks = ticks;
    80003434:	00005497          	auipc	s1,0x5
    80003438:	6e84a483          	lw	s1,1768(s1) # 80008b1c <ticks>
  release(&tickslock);
    8000343c:	0003e517          	auipc	a0,0x3e
    80003440:	30450513          	addi	a0,a0,772 # 80041740 <tickslock>
    80003444:	ffffe097          	auipc	ra,0xffffe
    80003448:	8a8080e7          	jalr	-1880(ra) # 80000cec <release>
  return xticks;
}
    8000344c:	02049513          	slli	a0,s1,0x20
    80003450:	9101                	srli	a0,a0,0x20
    80003452:	60e2                	ld	ra,24(sp)
    80003454:	6442                	ld	s0,16(sp)
    80003456:	64a2                	ld	s1,8(sp)
    80003458:	6105                	addi	sp,sp,32
    8000345a:	8082                	ret

000000008000345c <sys_waitx>:

uint64
sys_waitx(void)
{
    8000345c:	7139                	addi	sp,sp,-64
    8000345e:	fc06                	sd	ra,56(sp)
    80003460:	f822                	sd	s0,48(sp)
    80003462:	f426                	sd	s1,40(sp)
    80003464:	f04a                	sd	s2,32(sp)
    80003466:	0080                	addi	s0,sp,64
  uint64 addr, addr1, addr2;
  uint wtime, rtime;
  argaddr(0, &addr);
    80003468:	fd840593          	addi	a1,s0,-40
    8000346c:	4501                	li	a0,0
    8000346e:	00000097          	auipc	ra,0x0
    80003472:	c18080e7          	jalr	-1000(ra) # 80003086 <argaddr>
  argaddr(1, &addr1); // user virtual memory
    80003476:	fd040593          	addi	a1,s0,-48
    8000347a:	4505                	li	a0,1
    8000347c:	00000097          	auipc	ra,0x0
    80003480:	c0a080e7          	jalr	-1014(ra) # 80003086 <argaddr>
  argaddr(2, &addr2);
    80003484:	fc840593          	addi	a1,s0,-56
    80003488:	4509                	li	a0,2
    8000348a:	00000097          	auipc	ra,0x0
    8000348e:	bfc080e7          	jalr	-1028(ra) # 80003086 <argaddr>
  int ret = waitx(addr, &wtime, &rtime);
    80003492:	fc040613          	addi	a2,s0,-64
    80003496:	fc440593          	addi	a1,s0,-60
    8000349a:	fd843503          	ld	a0,-40(s0)
    8000349e:	fffff097          	auipc	ra,0xfffff
    800034a2:	3e0080e7          	jalr	992(ra) # 8000287e <waitx>
    800034a6:	892a                	mv	s2,a0
  struct proc *p = myproc();
    800034a8:	ffffe097          	auipc	ra,0xffffe
    800034ac:	682080e7          	jalr	1666(ra) # 80001b2a <myproc>
    800034b0:	84aa                	mv	s1,a0
  if (copyout(p->pagetable, addr1, (char *)&wtime, sizeof(int)) < 0)
    800034b2:	4691                	li	a3,4
    800034b4:	fc440613          	addi	a2,s0,-60
    800034b8:	fd043583          	ld	a1,-48(s0)
    800034bc:	6928                	ld	a0,80(a0)
    800034be:	ffffe097          	auipc	ra,0xffffe
    800034c2:	224080e7          	jalr	548(ra) # 800016e2 <copyout>
    return -1;
    800034c6:	57fd                	li	a5,-1
  if (copyout(p->pagetable, addr1, (char *)&wtime, sizeof(int)) < 0)
    800034c8:	00054f63          	bltz	a0,800034e6 <sys_waitx+0x8a>
  if (copyout(p->pagetable, addr2, (char *)&rtime, sizeof(int)) < 0)
    800034cc:	4691                	li	a3,4
    800034ce:	fc040613          	addi	a2,s0,-64
    800034d2:	fc843583          	ld	a1,-56(s0)
    800034d6:	68a8                	ld	a0,80(s1)
    800034d8:	ffffe097          	auipc	ra,0xffffe
    800034dc:	20a080e7          	jalr	522(ra) # 800016e2 <copyout>
    800034e0:	00054a63          	bltz	a0,800034f4 <sys_waitx+0x98>
    return -1;
  return ret;
    800034e4:	87ca                	mv	a5,s2
}
    800034e6:	853e                	mv	a0,a5
    800034e8:	70e2                	ld	ra,56(sp)
    800034ea:	7442                	ld	s0,48(sp)
    800034ec:	74a2                	ld	s1,40(sp)
    800034ee:	7902                	ld	s2,32(sp)
    800034f0:	6121                	addi	sp,sp,64
    800034f2:	8082                	ret
    return -1;
    800034f4:	57fd                	li	a5,-1
    800034f6:	bfc5                	j	800034e6 <sys_waitx+0x8a>

00000000800034f8 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    800034f8:	7179                	addi	sp,sp,-48
    800034fa:	f406                	sd	ra,40(sp)
    800034fc:	f022                	sd	s0,32(sp)
    800034fe:	ec26                	sd	s1,24(sp)
    80003500:	e84a                	sd	s2,16(sp)
    80003502:	e44e                	sd	s3,8(sp)
    80003504:	e052                	sd	s4,0(sp)
    80003506:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003508:	00005597          	auipc	a1,0x5
    8000350c:	07058593          	addi	a1,a1,112 # 80008578 <etext+0x578>
    80003510:	0003e517          	auipc	a0,0x3e
    80003514:	24850513          	addi	a0,a0,584 # 80041758 <bcache>
    80003518:	ffffd097          	auipc	ra,0xffffd
    8000351c:	690080e7          	jalr	1680(ra) # 80000ba8 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003520:	00046797          	auipc	a5,0x46
    80003524:	23878793          	addi	a5,a5,568 # 80049758 <bcache+0x8000>
    80003528:	00046717          	auipc	a4,0x46
    8000352c:	49870713          	addi	a4,a4,1176 # 800499c0 <bcache+0x8268>
    80003530:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80003534:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003538:	0003e497          	auipc	s1,0x3e
    8000353c:	23848493          	addi	s1,s1,568 # 80041770 <bcache+0x18>
    b->next = bcache.head.next;
    80003540:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80003542:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80003544:	00005a17          	auipc	s4,0x5
    80003548:	03ca0a13          	addi	s4,s4,60 # 80008580 <etext+0x580>
    b->next = bcache.head.next;
    8000354c:	2b893783          	ld	a5,696(s2)
    80003550:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80003552:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80003556:	85d2                	mv	a1,s4
    80003558:	01048513          	addi	a0,s1,16
    8000355c:	00001097          	auipc	ra,0x1
    80003560:	4e8080e7          	jalr	1256(ra) # 80004a44 <initsleeplock>
    bcache.head.next->prev = b;
    80003564:	2b893783          	ld	a5,696(s2)
    80003568:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    8000356a:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000356e:	45848493          	addi	s1,s1,1112
    80003572:	fd349de3          	bne	s1,s3,8000354c <binit+0x54>
  }
}
    80003576:	70a2                	ld	ra,40(sp)
    80003578:	7402                	ld	s0,32(sp)
    8000357a:	64e2                	ld	s1,24(sp)
    8000357c:	6942                	ld	s2,16(sp)
    8000357e:	69a2                	ld	s3,8(sp)
    80003580:	6a02                	ld	s4,0(sp)
    80003582:	6145                	addi	sp,sp,48
    80003584:	8082                	ret

0000000080003586 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80003586:	7179                	addi	sp,sp,-48
    80003588:	f406                	sd	ra,40(sp)
    8000358a:	f022                	sd	s0,32(sp)
    8000358c:	ec26                	sd	s1,24(sp)
    8000358e:	e84a                	sd	s2,16(sp)
    80003590:	e44e                	sd	s3,8(sp)
    80003592:	1800                	addi	s0,sp,48
    80003594:	892a                	mv	s2,a0
    80003596:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80003598:	0003e517          	auipc	a0,0x3e
    8000359c:	1c050513          	addi	a0,a0,448 # 80041758 <bcache>
    800035a0:	ffffd097          	auipc	ra,0xffffd
    800035a4:	698080e7          	jalr	1688(ra) # 80000c38 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800035a8:	00046497          	auipc	s1,0x46
    800035ac:	4684b483          	ld	s1,1128(s1) # 80049a10 <bcache+0x82b8>
    800035b0:	00046797          	auipc	a5,0x46
    800035b4:	41078793          	addi	a5,a5,1040 # 800499c0 <bcache+0x8268>
    800035b8:	02f48f63          	beq	s1,a5,800035f6 <bread+0x70>
    800035bc:	873e                	mv	a4,a5
    800035be:	a021                	j	800035c6 <bread+0x40>
    800035c0:	68a4                	ld	s1,80(s1)
    800035c2:	02e48a63          	beq	s1,a4,800035f6 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    800035c6:	449c                	lw	a5,8(s1)
    800035c8:	ff279ce3          	bne	a5,s2,800035c0 <bread+0x3a>
    800035cc:	44dc                	lw	a5,12(s1)
    800035ce:	ff3799e3          	bne	a5,s3,800035c0 <bread+0x3a>
      b->refcnt++;
    800035d2:	40bc                	lw	a5,64(s1)
    800035d4:	2785                	addiw	a5,a5,1
    800035d6:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800035d8:	0003e517          	auipc	a0,0x3e
    800035dc:	18050513          	addi	a0,a0,384 # 80041758 <bcache>
    800035e0:	ffffd097          	auipc	ra,0xffffd
    800035e4:	70c080e7          	jalr	1804(ra) # 80000cec <release>
      acquiresleep(&b->lock);
    800035e8:	01048513          	addi	a0,s1,16
    800035ec:	00001097          	auipc	ra,0x1
    800035f0:	492080e7          	jalr	1170(ra) # 80004a7e <acquiresleep>
      return b;
    800035f4:	a8b9                	j	80003652 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800035f6:	00046497          	auipc	s1,0x46
    800035fa:	4124b483          	ld	s1,1042(s1) # 80049a08 <bcache+0x82b0>
    800035fe:	00046797          	auipc	a5,0x46
    80003602:	3c278793          	addi	a5,a5,962 # 800499c0 <bcache+0x8268>
    80003606:	00f48863          	beq	s1,a5,80003616 <bread+0x90>
    8000360a:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    8000360c:	40bc                	lw	a5,64(s1)
    8000360e:	cf81                	beqz	a5,80003626 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003610:	64a4                	ld	s1,72(s1)
    80003612:	fee49de3          	bne	s1,a4,8000360c <bread+0x86>
  panic("bget: no buffers");
    80003616:	00005517          	auipc	a0,0x5
    8000361a:	f7250513          	addi	a0,a0,-142 # 80008588 <etext+0x588>
    8000361e:	ffffd097          	auipc	ra,0xffffd
    80003622:	f42080e7          	jalr	-190(ra) # 80000560 <panic>
      b->dev = dev;
    80003626:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    8000362a:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    8000362e:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003632:	4785                	li	a5,1
    80003634:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003636:	0003e517          	auipc	a0,0x3e
    8000363a:	12250513          	addi	a0,a0,290 # 80041758 <bcache>
    8000363e:	ffffd097          	auipc	ra,0xffffd
    80003642:	6ae080e7          	jalr	1710(ra) # 80000cec <release>
      acquiresleep(&b->lock);
    80003646:	01048513          	addi	a0,s1,16
    8000364a:	00001097          	auipc	ra,0x1
    8000364e:	434080e7          	jalr	1076(ra) # 80004a7e <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003652:	409c                	lw	a5,0(s1)
    80003654:	cb89                	beqz	a5,80003666 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003656:	8526                	mv	a0,s1
    80003658:	70a2                	ld	ra,40(sp)
    8000365a:	7402                	ld	s0,32(sp)
    8000365c:	64e2                	ld	s1,24(sp)
    8000365e:	6942                	ld	s2,16(sp)
    80003660:	69a2                	ld	s3,8(sp)
    80003662:	6145                	addi	sp,sp,48
    80003664:	8082                	ret
    virtio_disk_rw(b, 0);
    80003666:	4581                	li	a1,0
    80003668:	8526                	mv	a0,s1
    8000366a:	00003097          	auipc	ra,0x3
    8000366e:	0ee080e7          	jalr	238(ra) # 80006758 <virtio_disk_rw>
    b->valid = 1;
    80003672:	4785                	li	a5,1
    80003674:	c09c                	sw	a5,0(s1)
  return b;
    80003676:	b7c5                	j	80003656 <bread+0xd0>

0000000080003678 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003678:	1101                	addi	sp,sp,-32
    8000367a:	ec06                	sd	ra,24(sp)
    8000367c:	e822                	sd	s0,16(sp)
    8000367e:	e426                	sd	s1,8(sp)
    80003680:	1000                	addi	s0,sp,32
    80003682:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003684:	0541                	addi	a0,a0,16
    80003686:	00001097          	auipc	ra,0x1
    8000368a:	492080e7          	jalr	1170(ra) # 80004b18 <holdingsleep>
    8000368e:	cd01                	beqz	a0,800036a6 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003690:	4585                	li	a1,1
    80003692:	8526                	mv	a0,s1
    80003694:	00003097          	auipc	ra,0x3
    80003698:	0c4080e7          	jalr	196(ra) # 80006758 <virtio_disk_rw>
}
    8000369c:	60e2                	ld	ra,24(sp)
    8000369e:	6442                	ld	s0,16(sp)
    800036a0:	64a2                	ld	s1,8(sp)
    800036a2:	6105                	addi	sp,sp,32
    800036a4:	8082                	ret
    panic("bwrite");
    800036a6:	00005517          	auipc	a0,0x5
    800036aa:	efa50513          	addi	a0,a0,-262 # 800085a0 <etext+0x5a0>
    800036ae:	ffffd097          	auipc	ra,0xffffd
    800036b2:	eb2080e7          	jalr	-334(ra) # 80000560 <panic>

00000000800036b6 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800036b6:	1101                	addi	sp,sp,-32
    800036b8:	ec06                	sd	ra,24(sp)
    800036ba:	e822                	sd	s0,16(sp)
    800036bc:	e426                	sd	s1,8(sp)
    800036be:	e04a                	sd	s2,0(sp)
    800036c0:	1000                	addi	s0,sp,32
    800036c2:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800036c4:	01050913          	addi	s2,a0,16
    800036c8:	854a                	mv	a0,s2
    800036ca:	00001097          	auipc	ra,0x1
    800036ce:	44e080e7          	jalr	1102(ra) # 80004b18 <holdingsleep>
    800036d2:	c925                	beqz	a0,80003742 <brelse+0x8c>
    panic("brelse");

  releasesleep(&b->lock);
    800036d4:	854a                	mv	a0,s2
    800036d6:	00001097          	auipc	ra,0x1
    800036da:	3fe080e7          	jalr	1022(ra) # 80004ad4 <releasesleep>

  acquire(&bcache.lock);
    800036de:	0003e517          	auipc	a0,0x3e
    800036e2:	07a50513          	addi	a0,a0,122 # 80041758 <bcache>
    800036e6:	ffffd097          	auipc	ra,0xffffd
    800036ea:	552080e7          	jalr	1362(ra) # 80000c38 <acquire>
  b->refcnt--;
    800036ee:	40bc                	lw	a5,64(s1)
    800036f0:	37fd                	addiw	a5,a5,-1
    800036f2:	0007871b          	sext.w	a4,a5
    800036f6:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800036f8:	e71d                	bnez	a4,80003726 <brelse+0x70>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800036fa:	68b8                	ld	a4,80(s1)
    800036fc:	64bc                	ld	a5,72(s1)
    800036fe:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80003700:	68b8                	ld	a4,80(s1)
    80003702:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003704:	00046797          	auipc	a5,0x46
    80003708:	05478793          	addi	a5,a5,84 # 80049758 <bcache+0x8000>
    8000370c:	2b87b703          	ld	a4,696(a5)
    80003710:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003712:	00046717          	auipc	a4,0x46
    80003716:	2ae70713          	addi	a4,a4,686 # 800499c0 <bcache+0x8268>
    8000371a:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    8000371c:	2b87b703          	ld	a4,696(a5)
    80003720:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003722:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003726:	0003e517          	auipc	a0,0x3e
    8000372a:	03250513          	addi	a0,a0,50 # 80041758 <bcache>
    8000372e:	ffffd097          	auipc	ra,0xffffd
    80003732:	5be080e7          	jalr	1470(ra) # 80000cec <release>
}
    80003736:	60e2                	ld	ra,24(sp)
    80003738:	6442                	ld	s0,16(sp)
    8000373a:	64a2                	ld	s1,8(sp)
    8000373c:	6902                	ld	s2,0(sp)
    8000373e:	6105                	addi	sp,sp,32
    80003740:	8082                	ret
    panic("brelse");
    80003742:	00005517          	auipc	a0,0x5
    80003746:	e6650513          	addi	a0,a0,-410 # 800085a8 <etext+0x5a8>
    8000374a:	ffffd097          	auipc	ra,0xffffd
    8000374e:	e16080e7          	jalr	-490(ra) # 80000560 <panic>

0000000080003752 <bpin>:

void
bpin(struct buf *b) {
    80003752:	1101                	addi	sp,sp,-32
    80003754:	ec06                	sd	ra,24(sp)
    80003756:	e822                	sd	s0,16(sp)
    80003758:	e426                	sd	s1,8(sp)
    8000375a:	1000                	addi	s0,sp,32
    8000375c:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000375e:	0003e517          	auipc	a0,0x3e
    80003762:	ffa50513          	addi	a0,a0,-6 # 80041758 <bcache>
    80003766:	ffffd097          	auipc	ra,0xffffd
    8000376a:	4d2080e7          	jalr	1234(ra) # 80000c38 <acquire>
  b->refcnt++;
    8000376e:	40bc                	lw	a5,64(s1)
    80003770:	2785                	addiw	a5,a5,1
    80003772:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003774:	0003e517          	auipc	a0,0x3e
    80003778:	fe450513          	addi	a0,a0,-28 # 80041758 <bcache>
    8000377c:	ffffd097          	auipc	ra,0xffffd
    80003780:	570080e7          	jalr	1392(ra) # 80000cec <release>
}
    80003784:	60e2                	ld	ra,24(sp)
    80003786:	6442                	ld	s0,16(sp)
    80003788:	64a2                	ld	s1,8(sp)
    8000378a:	6105                	addi	sp,sp,32
    8000378c:	8082                	ret

000000008000378e <bunpin>:

void
bunpin(struct buf *b) {
    8000378e:	1101                	addi	sp,sp,-32
    80003790:	ec06                	sd	ra,24(sp)
    80003792:	e822                	sd	s0,16(sp)
    80003794:	e426                	sd	s1,8(sp)
    80003796:	1000                	addi	s0,sp,32
    80003798:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000379a:	0003e517          	auipc	a0,0x3e
    8000379e:	fbe50513          	addi	a0,a0,-66 # 80041758 <bcache>
    800037a2:	ffffd097          	auipc	ra,0xffffd
    800037a6:	496080e7          	jalr	1174(ra) # 80000c38 <acquire>
  b->refcnt--;
    800037aa:	40bc                	lw	a5,64(s1)
    800037ac:	37fd                	addiw	a5,a5,-1
    800037ae:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800037b0:	0003e517          	auipc	a0,0x3e
    800037b4:	fa850513          	addi	a0,a0,-88 # 80041758 <bcache>
    800037b8:	ffffd097          	auipc	ra,0xffffd
    800037bc:	534080e7          	jalr	1332(ra) # 80000cec <release>
}
    800037c0:	60e2                	ld	ra,24(sp)
    800037c2:	6442                	ld	s0,16(sp)
    800037c4:	64a2                	ld	s1,8(sp)
    800037c6:	6105                	addi	sp,sp,32
    800037c8:	8082                	ret

00000000800037ca <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800037ca:	1101                	addi	sp,sp,-32
    800037cc:	ec06                	sd	ra,24(sp)
    800037ce:	e822                	sd	s0,16(sp)
    800037d0:	e426                	sd	s1,8(sp)
    800037d2:	e04a                	sd	s2,0(sp)
    800037d4:	1000                	addi	s0,sp,32
    800037d6:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800037d8:	00d5d59b          	srliw	a1,a1,0xd
    800037dc:	00046797          	auipc	a5,0x46
    800037e0:	6587a783          	lw	a5,1624(a5) # 80049e34 <sb+0x1c>
    800037e4:	9dbd                	addw	a1,a1,a5
    800037e6:	00000097          	auipc	ra,0x0
    800037ea:	da0080e7          	jalr	-608(ra) # 80003586 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800037ee:	0074f713          	andi	a4,s1,7
    800037f2:	4785                	li	a5,1
    800037f4:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800037f8:	14ce                	slli	s1,s1,0x33
    800037fa:	90d9                	srli	s1,s1,0x36
    800037fc:	00950733          	add	a4,a0,s1
    80003800:	05874703          	lbu	a4,88(a4)
    80003804:	00e7f6b3          	and	a3,a5,a4
    80003808:	c69d                	beqz	a3,80003836 <bfree+0x6c>
    8000380a:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    8000380c:	94aa                	add	s1,s1,a0
    8000380e:	fff7c793          	not	a5,a5
    80003812:	8f7d                	and	a4,a4,a5
    80003814:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80003818:	00001097          	auipc	ra,0x1
    8000381c:	148080e7          	jalr	328(ra) # 80004960 <log_write>
  brelse(bp);
    80003820:	854a                	mv	a0,s2
    80003822:	00000097          	auipc	ra,0x0
    80003826:	e94080e7          	jalr	-364(ra) # 800036b6 <brelse>
}
    8000382a:	60e2                	ld	ra,24(sp)
    8000382c:	6442                	ld	s0,16(sp)
    8000382e:	64a2                	ld	s1,8(sp)
    80003830:	6902                	ld	s2,0(sp)
    80003832:	6105                	addi	sp,sp,32
    80003834:	8082                	ret
    panic("freeing free block");
    80003836:	00005517          	auipc	a0,0x5
    8000383a:	d7a50513          	addi	a0,a0,-646 # 800085b0 <etext+0x5b0>
    8000383e:	ffffd097          	auipc	ra,0xffffd
    80003842:	d22080e7          	jalr	-734(ra) # 80000560 <panic>

0000000080003846 <balloc>:
{
    80003846:	711d                	addi	sp,sp,-96
    80003848:	ec86                	sd	ra,88(sp)
    8000384a:	e8a2                	sd	s0,80(sp)
    8000384c:	e4a6                	sd	s1,72(sp)
    8000384e:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003850:	00046797          	auipc	a5,0x46
    80003854:	5cc7a783          	lw	a5,1484(a5) # 80049e1c <sb+0x4>
    80003858:	10078f63          	beqz	a5,80003976 <balloc+0x130>
    8000385c:	e0ca                	sd	s2,64(sp)
    8000385e:	fc4e                	sd	s3,56(sp)
    80003860:	f852                	sd	s4,48(sp)
    80003862:	f456                	sd	s5,40(sp)
    80003864:	f05a                	sd	s6,32(sp)
    80003866:	ec5e                	sd	s7,24(sp)
    80003868:	e862                	sd	s8,16(sp)
    8000386a:	e466                	sd	s9,8(sp)
    8000386c:	8baa                	mv	s7,a0
    8000386e:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003870:	00046b17          	auipc	s6,0x46
    80003874:	5a8b0b13          	addi	s6,s6,1448 # 80049e18 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003878:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    8000387a:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000387c:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    8000387e:	6c89                	lui	s9,0x2
    80003880:	a061                	j	80003908 <balloc+0xc2>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003882:	97ca                	add	a5,a5,s2
    80003884:	8e55                	or	a2,a2,a3
    80003886:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    8000388a:	854a                	mv	a0,s2
    8000388c:	00001097          	auipc	ra,0x1
    80003890:	0d4080e7          	jalr	212(ra) # 80004960 <log_write>
        brelse(bp);
    80003894:	854a                	mv	a0,s2
    80003896:	00000097          	auipc	ra,0x0
    8000389a:	e20080e7          	jalr	-480(ra) # 800036b6 <brelse>
  bp = bread(dev, bno);
    8000389e:	85a6                	mv	a1,s1
    800038a0:	855e                	mv	a0,s7
    800038a2:	00000097          	auipc	ra,0x0
    800038a6:	ce4080e7          	jalr	-796(ra) # 80003586 <bread>
    800038aa:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800038ac:	40000613          	li	a2,1024
    800038b0:	4581                	li	a1,0
    800038b2:	05850513          	addi	a0,a0,88
    800038b6:	ffffd097          	auipc	ra,0xffffd
    800038ba:	47e080e7          	jalr	1150(ra) # 80000d34 <memset>
  log_write(bp);
    800038be:	854a                	mv	a0,s2
    800038c0:	00001097          	auipc	ra,0x1
    800038c4:	0a0080e7          	jalr	160(ra) # 80004960 <log_write>
  brelse(bp);
    800038c8:	854a                	mv	a0,s2
    800038ca:	00000097          	auipc	ra,0x0
    800038ce:	dec080e7          	jalr	-532(ra) # 800036b6 <brelse>
}
    800038d2:	6906                	ld	s2,64(sp)
    800038d4:	79e2                	ld	s3,56(sp)
    800038d6:	7a42                	ld	s4,48(sp)
    800038d8:	7aa2                	ld	s5,40(sp)
    800038da:	7b02                	ld	s6,32(sp)
    800038dc:	6be2                	ld	s7,24(sp)
    800038de:	6c42                	ld	s8,16(sp)
    800038e0:	6ca2                	ld	s9,8(sp)
}
    800038e2:	8526                	mv	a0,s1
    800038e4:	60e6                	ld	ra,88(sp)
    800038e6:	6446                	ld	s0,80(sp)
    800038e8:	64a6                	ld	s1,72(sp)
    800038ea:	6125                	addi	sp,sp,96
    800038ec:	8082                	ret
    brelse(bp);
    800038ee:	854a                	mv	a0,s2
    800038f0:	00000097          	auipc	ra,0x0
    800038f4:	dc6080e7          	jalr	-570(ra) # 800036b6 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800038f8:	015c87bb          	addw	a5,s9,s5
    800038fc:	00078a9b          	sext.w	s5,a5
    80003900:	004b2703          	lw	a4,4(s6)
    80003904:	06eaf163          	bgeu	s5,a4,80003966 <balloc+0x120>
    bp = bread(dev, BBLOCK(b, sb));
    80003908:	41fad79b          	sraiw	a5,s5,0x1f
    8000390c:	0137d79b          	srliw	a5,a5,0x13
    80003910:	015787bb          	addw	a5,a5,s5
    80003914:	40d7d79b          	sraiw	a5,a5,0xd
    80003918:	01cb2583          	lw	a1,28(s6)
    8000391c:	9dbd                	addw	a1,a1,a5
    8000391e:	855e                	mv	a0,s7
    80003920:	00000097          	auipc	ra,0x0
    80003924:	c66080e7          	jalr	-922(ra) # 80003586 <bread>
    80003928:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000392a:	004b2503          	lw	a0,4(s6)
    8000392e:	000a849b          	sext.w	s1,s5
    80003932:	8762                	mv	a4,s8
    80003934:	faa4fde3          	bgeu	s1,a0,800038ee <balloc+0xa8>
      m = 1 << (bi % 8);
    80003938:	00777693          	andi	a3,a4,7
    8000393c:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003940:	41f7579b          	sraiw	a5,a4,0x1f
    80003944:	01d7d79b          	srliw	a5,a5,0x1d
    80003948:	9fb9                	addw	a5,a5,a4
    8000394a:	4037d79b          	sraiw	a5,a5,0x3
    8000394e:	00f90633          	add	a2,s2,a5
    80003952:	05864603          	lbu	a2,88(a2) # 1058 <_entry-0x7fffefa8>
    80003956:	00c6f5b3          	and	a1,a3,a2
    8000395a:	d585                	beqz	a1,80003882 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000395c:	2705                	addiw	a4,a4,1
    8000395e:	2485                	addiw	s1,s1,1
    80003960:	fd471ae3          	bne	a4,s4,80003934 <balloc+0xee>
    80003964:	b769                	j	800038ee <balloc+0xa8>
    80003966:	6906                	ld	s2,64(sp)
    80003968:	79e2                	ld	s3,56(sp)
    8000396a:	7a42                	ld	s4,48(sp)
    8000396c:	7aa2                	ld	s5,40(sp)
    8000396e:	7b02                	ld	s6,32(sp)
    80003970:	6be2                	ld	s7,24(sp)
    80003972:	6c42                	ld	s8,16(sp)
    80003974:	6ca2                	ld	s9,8(sp)
  printf("balloc: out of blocks\n");
    80003976:	00005517          	auipc	a0,0x5
    8000397a:	c5250513          	addi	a0,a0,-942 # 800085c8 <etext+0x5c8>
    8000397e:	ffffd097          	auipc	ra,0xffffd
    80003982:	c2c080e7          	jalr	-980(ra) # 800005aa <printf>
  return 0;
    80003986:	4481                	li	s1,0
    80003988:	bfa9                	j	800038e2 <balloc+0x9c>

000000008000398a <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    8000398a:	7179                	addi	sp,sp,-48
    8000398c:	f406                	sd	ra,40(sp)
    8000398e:	f022                	sd	s0,32(sp)
    80003990:	ec26                	sd	s1,24(sp)
    80003992:	e84a                	sd	s2,16(sp)
    80003994:	e44e                	sd	s3,8(sp)
    80003996:	1800                	addi	s0,sp,48
    80003998:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    8000399a:	47ad                	li	a5,11
    8000399c:	02b7e863          	bltu	a5,a1,800039cc <bmap+0x42>
    if((addr = ip->addrs[bn]) == 0){
    800039a0:	02059793          	slli	a5,a1,0x20
    800039a4:	01e7d593          	srli	a1,a5,0x1e
    800039a8:	00b504b3          	add	s1,a0,a1
    800039ac:	0504a903          	lw	s2,80(s1)
    800039b0:	08091263          	bnez	s2,80003a34 <bmap+0xaa>
      addr = balloc(ip->dev);
    800039b4:	4108                	lw	a0,0(a0)
    800039b6:	00000097          	auipc	ra,0x0
    800039ba:	e90080e7          	jalr	-368(ra) # 80003846 <balloc>
    800039be:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800039c2:	06090963          	beqz	s2,80003a34 <bmap+0xaa>
        return 0;
      ip->addrs[bn] = addr;
    800039c6:	0524a823          	sw	s2,80(s1)
    800039ca:	a0ad                	j	80003a34 <bmap+0xaa>
    }
    return addr;
  }
  bn -= NDIRECT;
    800039cc:	ff45849b          	addiw	s1,a1,-12
    800039d0:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800039d4:	0ff00793          	li	a5,255
    800039d8:	08e7e863          	bltu	a5,a4,80003a68 <bmap+0xde>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    800039dc:	08052903          	lw	s2,128(a0)
    800039e0:	00091f63          	bnez	s2,800039fe <bmap+0x74>
      addr = balloc(ip->dev);
    800039e4:	4108                	lw	a0,0(a0)
    800039e6:	00000097          	auipc	ra,0x0
    800039ea:	e60080e7          	jalr	-416(ra) # 80003846 <balloc>
    800039ee:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800039f2:	04090163          	beqz	s2,80003a34 <bmap+0xaa>
    800039f6:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    800039f8:	0929a023          	sw	s2,128(s3)
    800039fc:	a011                	j	80003a00 <bmap+0x76>
    800039fe:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    80003a00:	85ca                	mv	a1,s2
    80003a02:	0009a503          	lw	a0,0(s3)
    80003a06:	00000097          	auipc	ra,0x0
    80003a0a:	b80080e7          	jalr	-1152(ra) # 80003586 <bread>
    80003a0e:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003a10:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003a14:	02049713          	slli	a4,s1,0x20
    80003a18:	01e75593          	srli	a1,a4,0x1e
    80003a1c:	00b784b3          	add	s1,a5,a1
    80003a20:	0004a903          	lw	s2,0(s1)
    80003a24:	02090063          	beqz	s2,80003a44 <bmap+0xba>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003a28:	8552                	mv	a0,s4
    80003a2a:	00000097          	auipc	ra,0x0
    80003a2e:	c8c080e7          	jalr	-884(ra) # 800036b6 <brelse>
    return addr;
    80003a32:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    80003a34:	854a                	mv	a0,s2
    80003a36:	70a2                	ld	ra,40(sp)
    80003a38:	7402                	ld	s0,32(sp)
    80003a3a:	64e2                	ld	s1,24(sp)
    80003a3c:	6942                	ld	s2,16(sp)
    80003a3e:	69a2                	ld	s3,8(sp)
    80003a40:	6145                	addi	sp,sp,48
    80003a42:	8082                	ret
      addr = balloc(ip->dev);
    80003a44:	0009a503          	lw	a0,0(s3)
    80003a48:	00000097          	auipc	ra,0x0
    80003a4c:	dfe080e7          	jalr	-514(ra) # 80003846 <balloc>
    80003a50:	0005091b          	sext.w	s2,a0
      if(addr){
    80003a54:	fc090ae3          	beqz	s2,80003a28 <bmap+0x9e>
        a[bn] = addr;
    80003a58:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003a5c:	8552                	mv	a0,s4
    80003a5e:	00001097          	auipc	ra,0x1
    80003a62:	f02080e7          	jalr	-254(ra) # 80004960 <log_write>
    80003a66:	b7c9                	j	80003a28 <bmap+0x9e>
    80003a68:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    80003a6a:	00005517          	auipc	a0,0x5
    80003a6e:	b7650513          	addi	a0,a0,-1162 # 800085e0 <etext+0x5e0>
    80003a72:	ffffd097          	auipc	ra,0xffffd
    80003a76:	aee080e7          	jalr	-1298(ra) # 80000560 <panic>

0000000080003a7a <iget>:
{
    80003a7a:	7179                	addi	sp,sp,-48
    80003a7c:	f406                	sd	ra,40(sp)
    80003a7e:	f022                	sd	s0,32(sp)
    80003a80:	ec26                	sd	s1,24(sp)
    80003a82:	e84a                	sd	s2,16(sp)
    80003a84:	e44e                	sd	s3,8(sp)
    80003a86:	e052                	sd	s4,0(sp)
    80003a88:	1800                	addi	s0,sp,48
    80003a8a:	89aa                	mv	s3,a0
    80003a8c:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003a8e:	00046517          	auipc	a0,0x46
    80003a92:	3aa50513          	addi	a0,a0,938 # 80049e38 <itable>
    80003a96:	ffffd097          	auipc	ra,0xffffd
    80003a9a:	1a2080e7          	jalr	418(ra) # 80000c38 <acquire>
  empty = 0;
    80003a9e:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003aa0:	00046497          	auipc	s1,0x46
    80003aa4:	3b048493          	addi	s1,s1,944 # 80049e50 <itable+0x18>
    80003aa8:	00048697          	auipc	a3,0x48
    80003aac:	e3868693          	addi	a3,a3,-456 # 8004b8e0 <log>
    80003ab0:	a039                	j	80003abe <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003ab2:	02090b63          	beqz	s2,80003ae8 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003ab6:	08848493          	addi	s1,s1,136
    80003aba:	02d48a63          	beq	s1,a3,80003aee <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003abe:	449c                	lw	a5,8(s1)
    80003ac0:	fef059e3          	blez	a5,80003ab2 <iget+0x38>
    80003ac4:	4098                	lw	a4,0(s1)
    80003ac6:	ff3716e3          	bne	a4,s3,80003ab2 <iget+0x38>
    80003aca:	40d8                	lw	a4,4(s1)
    80003acc:	ff4713e3          	bne	a4,s4,80003ab2 <iget+0x38>
      ip->ref++;
    80003ad0:	2785                	addiw	a5,a5,1
    80003ad2:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003ad4:	00046517          	auipc	a0,0x46
    80003ad8:	36450513          	addi	a0,a0,868 # 80049e38 <itable>
    80003adc:	ffffd097          	auipc	ra,0xffffd
    80003ae0:	210080e7          	jalr	528(ra) # 80000cec <release>
      return ip;
    80003ae4:	8926                	mv	s2,s1
    80003ae6:	a03d                	j	80003b14 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003ae8:	f7f9                	bnez	a5,80003ab6 <iget+0x3c>
      empty = ip;
    80003aea:	8926                	mv	s2,s1
    80003aec:	b7e9                	j	80003ab6 <iget+0x3c>
  if(empty == 0)
    80003aee:	02090c63          	beqz	s2,80003b26 <iget+0xac>
  ip->dev = dev;
    80003af2:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003af6:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003afa:	4785                	li	a5,1
    80003afc:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003b00:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003b04:	00046517          	auipc	a0,0x46
    80003b08:	33450513          	addi	a0,a0,820 # 80049e38 <itable>
    80003b0c:	ffffd097          	auipc	ra,0xffffd
    80003b10:	1e0080e7          	jalr	480(ra) # 80000cec <release>
}
    80003b14:	854a                	mv	a0,s2
    80003b16:	70a2                	ld	ra,40(sp)
    80003b18:	7402                	ld	s0,32(sp)
    80003b1a:	64e2                	ld	s1,24(sp)
    80003b1c:	6942                	ld	s2,16(sp)
    80003b1e:	69a2                	ld	s3,8(sp)
    80003b20:	6a02                	ld	s4,0(sp)
    80003b22:	6145                	addi	sp,sp,48
    80003b24:	8082                	ret
    panic("iget: no inodes");
    80003b26:	00005517          	auipc	a0,0x5
    80003b2a:	ad250513          	addi	a0,a0,-1326 # 800085f8 <etext+0x5f8>
    80003b2e:	ffffd097          	auipc	ra,0xffffd
    80003b32:	a32080e7          	jalr	-1486(ra) # 80000560 <panic>

0000000080003b36 <fsinit>:
fsinit(int dev) {
    80003b36:	7179                	addi	sp,sp,-48
    80003b38:	f406                	sd	ra,40(sp)
    80003b3a:	f022                	sd	s0,32(sp)
    80003b3c:	ec26                	sd	s1,24(sp)
    80003b3e:	e84a                	sd	s2,16(sp)
    80003b40:	e44e                	sd	s3,8(sp)
    80003b42:	1800                	addi	s0,sp,48
    80003b44:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003b46:	4585                	li	a1,1
    80003b48:	00000097          	auipc	ra,0x0
    80003b4c:	a3e080e7          	jalr	-1474(ra) # 80003586 <bread>
    80003b50:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003b52:	00046997          	auipc	s3,0x46
    80003b56:	2c698993          	addi	s3,s3,710 # 80049e18 <sb>
    80003b5a:	02000613          	li	a2,32
    80003b5e:	05850593          	addi	a1,a0,88
    80003b62:	854e                	mv	a0,s3
    80003b64:	ffffd097          	auipc	ra,0xffffd
    80003b68:	22c080e7          	jalr	556(ra) # 80000d90 <memmove>
  brelse(bp);
    80003b6c:	8526                	mv	a0,s1
    80003b6e:	00000097          	auipc	ra,0x0
    80003b72:	b48080e7          	jalr	-1208(ra) # 800036b6 <brelse>
  if(sb.magic != FSMAGIC)
    80003b76:	0009a703          	lw	a4,0(s3)
    80003b7a:	102037b7          	lui	a5,0x10203
    80003b7e:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003b82:	02f71263          	bne	a4,a5,80003ba6 <fsinit+0x70>
  initlog(dev, &sb);
    80003b86:	00046597          	auipc	a1,0x46
    80003b8a:	29258593          	addi	a1,a1,658 # 80049e18 <sb>
    80003b8e:	854a                	mv	a0,s2
    80003b90:	00001097          	auipc	ra,0x1
    80003b94:	b60080e7          	jalr	-1184(ra) # 800046f0 <initlog>
}
    80003b98:	70a2                	ld	ra,40(sp)
    80003b9a:	7402                	ld	s0,32(sp)
    80003b9c:	64e2                	ld	s1,24(sp)
    80003b9e:	6942                	ld	s2,16(sp)
    80003ba0:	69a2                	ld	s3,8(sp)
    80003ba2:	6145                	addi	sp,sp,48
    80003ba4:	8082                	ret
    panic("invalid file system");
    80003ba6:	00005517          	auipc	a0,0x5
    80003baa:	a6250513          	addi	a0,a0,-1438 # 80008608 <etext+0x608>
    80003bae:	ffffd097          	auipc	ra,0xffffd
    80003bb2:	9b2080e7          	jalr	-1614(ra) # 80000560 <panic>

0000000080003bb6 <iinit>:
{
    80003bb6:	7179                	addi	sp,sp,-48
    80003bb8:	f406                	sd	ra,40(sp)
    80003bba:	f022                	sd	s0,32(sp)
    80003bbc:	ec26                	sd	s1,24(sp)
    80003bbe:	e84a                	sd	s2,16(sp)
    80003bc0:	e44e                	sd	s3,8(sp)
    80003bc2:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003bc4:	00005597          	auipc	a1,0x5
    80003bc8:	a5c58593          	addi	a1,a1,-1444 # 80008620 <etext+0x620>
    80003bcc:	00046517          	auipc	a0,0x46
    80003bd0:	26c50513          	addi	a0,a0,620 # 80049e38 <itable>
    80003bd4:	ffffd097          	auipc	ra,0xffffd
    80003bd8:	fd4080e7          	jalr	-44(ra) # 80000ba8 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003bdc:	00046497          	auipc	s1,0x46
    80003be0:	28448493          	addi	s1,s1,644 # 80049e60 <itable+0x28>
    80003be4:	00048997          	auipc	s3,0x48
    80003be8:	d0c98993          	addi	s3,s3,-756 # 8004b8f0 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003bec:	00005917          	auipc	s2,0x5
    80003bf0:	a3c90913          	addi	s2,s2,-1476 # 80008628 <etext+0x628>
    80003bf4:	85ca                	mv	a1,s2
    80003bf6:	8526                	mv	a0,s1
    80003bf8:	00001097          	auipc	ra,0x1
    80003bfc:	e4c080e7          	jalr	-436(ra) # 80004a44 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003c00:	08848493          	addi	s1,s1,136
    80003c04:	ff3498e3          	bne	s1,s3,80003bf4 <iinit+0x3e>
}
    80003c08:	70a2                	ld	ra,40(sp)
    80003c0a:	7402                	ld	s0,32(sp)
    80003c0c:	64e2                	ld	s1,24(sp)
    80003c0e:	6942                	ld	s2,16(sp)
    80003c10:	69a2                	ld	s3,8(sp)
    80003c12:	6145                	addi	sp,sp,48
    80003c14:	8082                	ret

0000000080003c16 <ialloc>:
{
    80003c16:	7139                	addi	sp,sp,-64
    80003c18:	fc06                	sd	ra,56(sp)
    80003c1a:	f822                	sd	s0,48(sp)
    80003c1c:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    80003c1e:	00046717          	auipc	a4,0x46
    80003c22:	20672703          	lw	a4,518(a4) # 80049e24 <sb+0xc>
    80003c26:	4785                	li	a5,1
    80003c28:	06e7f463          	bgeu	a5,a4,80003c90 <ialloc+0x7a>
    80003c2c:	f426                	sd	s1,40(sp)
    80003c2e:	f04a                	sd	s2,32(sp)
    80003c30:	ec4e                	sd	s3,24(sp)
    80003c32:	e852                	sd	s4,16(sp)
    80003c34:	e456                	sd	s5,8(sp)
    80003c36:	e05a                	sd	s6,0(sp)
    80003c38:	8aaa                	mv	s5,a0
    80003c3a:	8b2e                	mv	s6,a1
    80003c3c:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003c3e:	00046a17          	auipc	s4,0x46
    80003c42:	1daa0a13          	addi	s4,s4,474 # 80049e18 <sb>
    80003c46:	00495593          	srli	a1,s2,0x4
    80003c4a:	018a2783          	lw	a5,24(s4)
    80003c4e:	9dbd                	addw	a1,a1,a5
    80003c50:	8556                	mv	a0,s5
    80003c52:	00000097          	auipc	ra,0x0
    80003c56:	934080e7          	jalr	-1740(ra) # 80003586 <bread>
    80003c5a:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003c5c:	05850993          	addi	s3,a0,88
    80003c60:	00f97793          	andi	a5,s2,15
    80003c64:	079a                	slli	a5,a5,0x6
    80003c66:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003c68:	00099783          	lh	a5,0(s3)
    80003c6c:	cf9d                	beqz	a5,80003caa <ialloc+0x94>
    brelse(bp);
    80003c6e:	00000097          	auipc	ra,0x0
    80003c72:	a48080e7          	jalr	-1464(ra) # 800036b6 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003c76:	0905                	addi	s2,s2,1
    80003c78:	00ca2703          	lw	a4,12(s4)
    80003c7c:	0009079b          	sext.w	a5,s2
    80003c80:	fce7e3e3          	bltu	a5,a4,80003c46 <ialloc+0x30>
    80003c84:	74a2                	ld	s1,40(sp)
    80003c86:	7902                	ld	s2,32(sp)
    80003c88:	69e2                	ld	s3,24(sp)
    80003c8a:	6a42                	ld	s4,16(sp)
    80003c8c:	6aa2                	ld	s5,8(sp)
    80003c8e:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    80003c90:	00005517          	auipc	a0,0x5
    80003c94:	9a050513          	addi	a0,a0,-1632 # 80008630 <etext+0x630>
    80003c98:	ffffd097          	auipc	ra,0xffffd
    80003c9c:	912080e7          	jalr	-1774(ra) # 800005aa <printf>
  return 0;
    80003ca0:	4501                	li	a0,0
}
    80003ca2:	70e2                	ld	ra,56(sp)
    80003ca4:	7442                	ld	s0,48(sp)
    80003ca6:	6121                	addi	sp,sp,64
    80003ca8:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003caa:	04000613          	li	a2,64
    80003cae:	4581                	li	a1,0
    80003cb0:	854e                	mv	a0,s3
    80003cb2:	ffffd097          	auipc	ra,0xffffd
    80003cb6:	082080e7          	jalr	130(ra) # 80000d34 <memset>
      dip->type = type;
    80003cba:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003cbe:	8526                	mv	a0,s1
    80003cc0:	00001097          	auipc	ra,0x1
    80003cc4:	ca0080e7          	jalr	-864(ra) # 80004960 <log_write>
      brelse(bp);
    80003cc8:	8526                	mv	a0,s1
    80003cca:	00000097          	auipc	ra,0x0
    80003cce:	9ec080e7          	jalr	-1556(ra) # 800036b6 <brelse>
      return iget(dev, inum);
    80003cd2:	0009059b          	sext.w	a1,s2
    80003cd6:	8556                	mv	a0,s5
    80003cd8:	00000097          	auipc	ra,0x0
    80003cdc:	da2080e7          	jalr	-606(ra) # 80003a7a <iget>
    80003ce0:	74a2                	ld	s1,40(sp)
    80003ce2:	7902                	ld	s2,32(sp)
    80003ce4:	69e2                	ld	s3,24(sp)
    80003ce6:	6a42                	ld	s4,16(sp)
    80003ce8:	6aa2                	ld	s5,8(sp)
    80003cea:	6b02                	ld	s6,0(sp)
    80003cec:	bf5d                	j	80003ca2 <ialloc+0x8c>

0000000080003cee <iupdate>:
{
    80003cee:	1101                	addi	sp,sp,-32
    80003cf0:	ec06                	sd	ra,24(sp)
    80003cf2:	e822                	sd	s0,16(sp)
    80003cf4:	e426                	sd	s1,8(sp)
    80003cf6:	e04a                	sd	s2,0(sp)
    80003cf8:	1000                	addi	s0,sp,32
    80003cfa:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003cfc:	415c                	lw	a5,4(a0)
    80003cfe:	0047d79b          	srliw	a5,a5,0x4
    80003d02:	00046597          	auipc	a1,0x46
    80003d06:	12e5a583          	lw	a1,302(a1) # 80049e30 <sb+0x18>
    80003d0a:	9dbd                	addw	a1,a1,a5
    80003d0c:	4108                	lw	a0,0(a0)
    80003d0e:	00000097          	auipc	ra,0x0
    80003d12:	878080e7          	jalr	-1928(ra) # 80003586 <bread>
    80003d16:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003d18:	05850793          	addi	a5,a0,88
    80003d1c:	40d8                	lw	a4,4(s1)
    80003d1e:	8b3d                	andi	a4,a4,15
    80003d20:	071a                	slli	a4,a4,0x6
    80003d22:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003d24:	04449703          	lh	a4,68(s1)
    80003d28:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003d2c:	04649703          	lh	a4,70(s1)
    80003d30:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003d34:	04849703          	lh	a4,72(s1)
    80003d38:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003d3c:	04a49703          	lh	a4,74(s1)
    80003d40:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003d44:	44f8                	lw	a4,76(s1)
    80003d46:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003d48:	03400613          	li	a2,52
    80003d4c:	05048593          	addi	a1,s1,80
    80003d50:	00c78513          	addi	a0,a5,12
    80003d54:	ffffd097          	auipc	ra,0xffffd
    80003d58:	03c080e7          	jalr	60(ra) # 80000d90 <memmove>
  log_write(bp);
    80003d5c:	854a                	mv	a0,s2
    80003d5e:	00001097          	auipc	ra,0x1
    80003d62:	c02080e7          	jalr	-1022(ra) # 80004960 <log_write>
  brelse(bp);
    80003d66:	854a                	mv	a0,s2
    80003d68:	00000097          	auipc	ra,0x0
    80003d6c:	94e080e7          	jalr	-1714(ra) # 800036b6 <brelse>
}
    80003d70:	60e2                	ld	ra,24(sp)
    80003d72:	6442                	ld	s0,16(sp)
    80003d74:	64a2                	ld	s1,8(sp)
    80003d76:	6902                	ld	s2,0(sp)
    80003d78:	6105                	addi	sp,sp,32
    80003d7a:	8082                	ret

0000000080003d7c <idup>:
{
    80003d7c:	1101                	addi	sp,sp,-32
    80003d7e:	ec06                	sd	ra,24(sp)
    80003d80:	e822                	sd	s0,16(sp)
    80003d82:	e426                	sd	s1,8(sp)
    80003d84:	1000                	addi	s0,sp,32
    80003d86:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003d88:	00046517          	auipc	a0,0x46
    80003d8c:	0b050513          	addi	a0,a0,176 # 80049e38 <itable>
    80003d90:	ffffd097          	auipc	ra,0xffffd
    80003d94:	ea8080e7          	jalr	-344(ra) # 80000c38 <acquire>
  ip->ref++;
    80003d98:	449c                	lw	a5,8(s1)
    80003d9a:	2785                	addiw	a5,a5,1
    80003d9c:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003d9e:	00046517          	auipc	a0,0x46
    80003da2:	09a50513          	addi	a0,a0,154 # 80049e38 <itable>
    80003da6:	ffffd097          	auipc	ra,0xffffd
    80003daa:	f46080e7          	jalr	-186(ra) # 80000cec <release>
}
    80003dae:	8526                	mv	a0,s1
    80003db0:	60e2                	ld	ra,24(sp)
    80003db2:	6442                	ld	s0,16(sp)
    80003db4:	64a2                	ld	s1,8(sp)
    80003db6:	6105                	addi	sp,sp,32
    80003db8:	8082                	ret

0000000080003dba <ilock>:
{
    80003dba:	1101                	addi	sp,sp,-32
    80003dbc:	ec06                	sd	ra,24(sp)
    80003dbe:	e822                	sd	s0,16(sp)
    80003dc0:	e426                	sd	s1,8(sp)
    80003dc2:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003dc4:	c10d                	beqz	a0,80003de6 <ilock+0x2c>
    80003dc6:	84aa                	mv	s1,a0
    80003dc8:	451c                	lw	a5,8(a0)
    80003dca:	00f05e63          	blez	a5,80003de6 <ilock+0x2c>
  acquiresleep(&ip->lock);
    80003dce:	0541                	addi	a0,a0,16
    80003dd0:	00001097          	auipc	ra,0x1
    80003dd4:	cae080e7          	jalr	-850(ra) # 80004a7e <acquiresleep>
  if(ip->valid == 0){
    80003dd8:	40bc                	lw	a5,64(s1)
    80003dda:	cf99                	beqz	a5,80003df8 <ilock+0x3e>
}
    80003ddc:	60e2                	ld	ra,24(sp)
    80003dde:	6442                	ld	s0,16(sp)
    80003de0:	64a2                	ld	s1,8(sp)
    80003de2:	6105                	addi	sp,sp,32
    80003de4:	8082                	ret
    80003de6:	e04a                	sd	s2,0(sp)
    panic("ilock");
    80003de8:	00005517          	auipc	a0,0x5
    80003dec:	86050513          	addi	a0,a0,-1952 # 80008648 <etext+0x648>
    80003df0:	ffffc097          	auipc	ra,0xffffc
    80003df4:	770080e7          	jalr	1904(ra) # 80000560 <panic>
    80003df8:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003dfa:	40dc                	lw	a5,4(s1)
    80003dfc:	0047d79b          	srliw	a5,a5,0x4
    80003e00:	00046597          	auipc	a1,0x46
    80003e04:	0305a583          	lw	a1,48(a1) # 80049e30 <sb+0x18>
    80003e08:	9dbd                	addw	a1,a1,a5
    80003e0a:	4088                	lw	a0,0(s1)
    80003e0c:	fffff097          	auipc	ra,0xfffff
    80003e10:	77a080e7          	jalr	1914(ra) # 80003586 <bread>
    80003e14:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003e16:	05850593          	addi	a1,a0,88
    80003e1a:	40dc                	lw	a5,4(s1)
    80003e1c:	8bbd                	andi	a5,a5,15
    80003e1e:	079a                	slli	a5,a5,0x6
    80003e20:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003e22:	00059783          	lh	a5,0(a1)
    80003e26:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003e2a:	00259783          	lh	a5,2(a1)
    80003e2e:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003e32:	00459783          	lh	a5,4(a1)
    80003e36:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003e3a:	00659783          	lh	a5,6(a1)
    80003e3e:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003e42:	459c                	lw	a5,8(a1)
    80003e44:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003e46:	03400613          	li	a2,52
    80003e4a:	05b1                	addi	a1,a1,12
    80003e4c:	05048513          	addi	a0,s1,80
    80003e50:	ffffd097          	auipc	ra,0xffffd
    80003e54:	f40080e7          	jalr	-192(ra) # 80000d90 <memmove>
    brelse(bp);
    80003e58:	854a                	mv	a0,s2
    80003e5a:	00000097          	auipc	ra,0x0
    80003e5e:	85c080e7          	jalr	-1956(ra) # 800036b6 <brelse>
    ip->valid = 1;
    80003e62:	4785                	li	a5,1
    80003e64:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003e66:	04449783          	lh	a5,68(s1)
    80003e6a:	c399                	beqz	a5,80003e70 <ilock+0xb6>
    80003e6c:	6902                	ld	s2,0(sp)
    80003e6e:	b7bd                	j	80003ddc <ilock+0x22>
      panic("ilock: no type");
    80003e70:	00004517          	auipc	a0,0x4
    80003e74:	7e050513          	addi	a0,a0,2016 # 80008650 <etext+0x650>
    80003e78:	ffffc097          	auipc	ra,0xffffc
    80003e7c:	6e8080e7          	jalr	1768(ra) # 80000560 <panic>

0000000080003e80 <iunlock>:
{
    80003e80:	1101                	addi	sp,sp,-32
    80003e82:	ec06                	sd	ra,24(sp)
    80003e84:	e822                	sd	s0,16(sp)
    80003e86:	e426                	sd	s1,8(sp)
    80003e88:	e04a                	sd	s2,0(sp)
    80003e8a:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003e8c:	c905                	beqz	a0,80003ebc <iunlock+0x3c>
    80003e8e:	84aa                	mv	s1,a0
    80003e90:	01050913          	addi	s2,a0,16
    80003e94:	854a                	mv	a0,s2
    80003e96:	00001097          	auipc	ra,0x1
    80003e9a:	c82080e7          	jalr	-894(ra) # 80004b18 <holdingsleep>
    80003e9e:	cd19                	beqz	a0,80003ebc <iunlock+0x3c>
    80003ea0:	449c                	lw	a5,8(s1)
    80003ea2:	00f05d63          	blez	a5,80003ebc <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003ea6:	854a                	mv	a0,s2
    80003ea8:	00001097          	auipc	ra,0x1
    80003eac:	c2c080e7          	jalr	-980(ra) # 80004ad4 <releasesleep>
}
    80003eb0:	60e2                	ld	ra,24(sp)
    80003eb2:	6442                	ld	s0,16(sp)
    80003eb4:	64a2                	ld	s1,8(sp)
    80003eb6:	6902                	ld	s2,0(sp)
    80003eb8:	6105                	addi	sp,sp,32
    80003eba:	8082                	ret
    panic("iunlock");
    80003ebc:	00004517          	auipc	a0,0x4
    80003ec0:	7a450513          	addi	a0,a0,1956 # 80008660 <etext+0x660>
    80003ec4:	ffffc097          	auipc	ra,0xffffc
    80003ec8:	69c080e7          	jalr	1692(ra) # 80000560 <panic>

0000000080003ecc <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003ecc:	7179                	addi	sp,sp,-48
    80003ece:	f406                	sd	ra,40(sp)
    80003ed0:	f022                	sd	s0,32(sp)
    80003ed2:	ec26                	sd	s1,24(sp)
    80003ed4:	e84a                	sd	s2,16(sp)
    80003ed6:	e44e                	sd	s3,8(sp)
    80003ed8:	1800                	addi	s0,sp,48
    80003eda:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003edc:	05050493          	addi	s1,a0,80
    80003ee0:	08050913          	addi	s2,a0,128
    80003ee4:	a021                	j	80003eec <itrunc+0x20>
    80003ee6:	0491                	addi	s1,s1,4
    80003ee8:	01248d63          	beq	s1,s2,80003f02 <itrunc+0x36>
    if(ip->addrs[i]){
    80003eec:	408c                	lw	a1,0(s1)
    80003eee:	dde5                	beqz	a1,80003ee6 <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    80003ef0:	0009a503          	lw	a0,0(s3)
    80003ef4:	00000097          	auipc	ra,0x0
    80003ef8:	8d6080e7          	jalr	-1834(ra) # 800037ca <bfree>
      ip->addrs[i] = 0;
    80003efc:	0004a023          	sw	zero,0(s1)
    80003f00:	b7dd                	j	80003ee6 <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003f02:	0809a583          	lw	a1,128(s3)
    80003f06:	ed99                	bnez	a1,80003f24 <itrunc+0x58>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003f08:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003f0c:	854e                	mv	a0,s3
    80003f0e:	00000097          	auipc	ra,0x0
    80003f12:	de0080e7          	jalr	-544(ra) # 80003cee <iupdate>
}
    80003f16:	70a2                	ld	ra,40(sp)
    80003f18:	7402                	ld	s0,32(sp)
    80003f1a:	64e2                	ld	s1,24(sp)
    80003f1c:	6942                	ld	s2,16(sp)
    80003f1e:	69a2                	ld	s3,8(sp)
    80003f20:	6145                	addi	sp,sp,48
    80003f22:	8082                	ret
    80003f24:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003f26:	0009a503          	lw	a0,0(s3)
    80003f2a:	fffff097          	auipc	ra,0xfffff
    80003f2e:	65c080e7          	jalr	1628(ra) # 80003586 <bread>
    80003f32:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003f34:	05850493          	addi	s1,a0,88
    80003f38:	45850913          	addi	s2,a0,1112
    80003f3c:	a021                	j	80003f44 <itrunc+0x78>
    80003f3e:	0491                	addi	s1,s1,4
    80003f40:	01248b63          	beq	s1,s2,80003f56 <itrunc+0x8a>
      if(a[j])
    80003f44:	408c                	lw	a1,0(s1)
    80003f46:	dde5                	beqz	a1,80003f3e <itrunc+0x72>
        bfree(ip->dev, a[j]);
    80003f48:	0009a503          	lw	a0,0(s3)
    80003f4c:	00000097          	auipc	ra,0x0
    80003f50:	87e080e7          	jalr	-1922(ra) # 800037ca <bfree>
    80003f54:	b7ed                	j	80003f3e <itrunc+0x72>
    brelse(bp);
    80003f56:	8552                	mv	a0,s4
    80003f58:	fffff097          	auipc	ra,0xfffff
    80003f5c:	75e080e7          	jalr	1886(ra) # 800036b6 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003f60:	0809a583          	lw	a1,128(s3)
    80003f64:	0009a503          	lw	a0,0(s3)
    80003f68:	00000097          	auipc	ra,0x0
    80003f6c:	862080e7          	jalr	-1950(ra) # 800037ca <bfree>
    ip->addrs[NDIRECT] = 0;
    80003f70:	0809a023          	sw	zero,128(s3)
    80003f74:	6a02                	ld	s4,0(sp)
    80003f76:	bf49                	j	80003f08 <itrunc+0x3c>

0000000080003f78 <iput>:
{
    80003f78:	1101                	addi	sp,sp,-32
    80003f7a:	ec06                	sd	ra,24(sp)
    80003f7c:	e822                	sd	s0,16(sp)
    80003f7e:	e426                	sd	s1,8(sp)
    80003f80:	1000                	addi	s0,sp,32
    80003f82:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003f84:	00046517          	auipc	a0,0x46
    80003f88:	eb450513          	addi	a0,a0,-332 # 80049e38 <itable>
    80003f8c:	ffffd097          	auipc	ra,0xffffd
    80003f90:	cac080e7          	jalr	-852(ra) # 80000c38 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003f94:	4498                	lw	a4,8(s1)
    80003f96:	4785                	li	a5,1
    80003f98:	02f70263          	beq	a4,a5,80003fbc <iput+0x44>
  ip->ref--;
    80003f9c:	449c                	lw	a5,8(s1)
    80003f9e:	37fd                	addiw	a5,a5,-1
    80003fa0:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003fa2:	00046517          	auipc	a0,0x46
    80003fa6:	e9650513          	addi	a0,a0,-362 # 80049e38 <itable>
    80003faa:	ffffd097          	auipc	ra,0xffffd
    80003fae:	d42080e7          	jalr	-702(ra) # 80000cec <release>
}
    80003fb2:	60e2                	ld	ra,24(sp)
    80003fb4:	6442                	ld	s0,16(sp)
    80003fb6:	64a2                	ld	s1,8(sp)
    80003fb8:	6105                	addi	sp,sp,32
    80003fba:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003fbc:	40bc                	lw	a5,64(s1)
    80003fbe:	dff9                	beqz	a5,80003f9c <iput+0x24>
    80003fc0:	04a49783          	lh	a5,74(s1)
    80003fc4:	ffe1                	bnez	a5,80003f9c <iput+0x24>
    80003fc6:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    80003fc8:	01048913          	addi	s2,s1,16
    80003fcc:	854a                	mv	a0,s2
    80003fce:	00001097          	auipc	ra,0x1
    80003fd2:	ab0080e7          	jalr	-1360(ra) # 80004a7e <acquiresleep>
    release(&itable.lock);
    80003fd6:	00046517          	auipc	a0,0x46
    80003fda:	e6250513          	addi	a0,a0,-414 # 80049e38 <itable>
    80003fde:	ffffd097          	auipc	ra,0xffffd
    80003fe2:	d0e080e7          	jalr	-754(ra) # 80000cec <release>
    itrunc(ip);
    80003fe6:	8526                	mv	a0,s1
    80003fe8:	00000097          	auipc	ra,0x0
    80003fec:	ee4080e7          	jalr	-284(ra) # 80003ecc <itrunc>
    ip->type = 0;
    80003ff0:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003ff4:	8526                	mv	a0,s1
    80003ff6:	00000097          	auipc	ra,0x0
    80003ffa:	cf8080e7          	jalr	-776(ra) # 80003cee <iupdate>
    ip->valid = 0;
    80003ffe:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80004002:	854a                	mv	a0,s2
    80004004:	00001097          	auipc	ra,0x1
    80004008:	ad0080e7          	jalr	-1328(ra) # 80004ad4 <releasesleep>
    acquire(&itable.lock);
    8000400c:	00046517          	auipc	a0,0x46
    80004010:	e2c50513          	addi	a0,a0,-468 # 80049e38 <itable>
    80004014:	ffffd097          	auipc	ra,0xffffd
    80004018:	c24080e7          	jalr	-988(ra) # 80000c38 <acquire>
    8000401c:	6902                	ld	s2,0(sp)
    8000401e:	bfbd                	j	80003f9c <iput+0x24>

0000000080004020 <iunlockput>:
{
    80004020:	1101                	addi	sp,sp,-32
    80004022:	ec06                	sd	ra,24(sp)
    80004024:	e822                	sd	s0,16(sp)
    80004026:	e426                	sd	s1,8(sp)
    80004028:	1000                	addi	s0,sp,32
    8000402a:	84aa                	mv	s1,a0
  iunlock(ip);
    8000402c:	00000097          	auipc	ra,0x0
    80004030:	e54080e7          	jalr	-428(ra) # 80003e80 <iunlock>
  iput(ip);
    80004034:	8526                	mv	a0,s1
    80004036:	00000097          	auipc	ra,0x0
    8000403a:	f42080e7          	jalr	-190(ra) # 80003f78 <iput>
}
    8000403e:	60e2                	ld	ra,24(sp)
    80004040:	6442                	ld	s0,16(sp)
    80004042:	64a2                	ld	s1,8(sp)
    80004044:	6105                	addi	sp,sp,32
    80004046:	8082                	ret

0000000080004048 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80004048:	1141                	addi	sp,sp,-16
    8000404a:	e422                	sd	s0,8(sp)
    8000404c:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    8000404e:	411c                	lw	a5,0(a0)
    80004050:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80004052:	415c                	lw	a5,4(a0)
    80004054:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80004056:	04451783          	lh	a5,68(a0)
    8000405a:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    8000405e:	04a51783          	lh	a5,74(a0)
    80004062:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80004066:	04c56783          	lwu	a5,76(a0)
    8000406a:	e99c                	sd	a5,16(a1)
}
    8000406c:	6422                	ld	s0,8(sp)
    8000406e:	0141                	addi	sp,sp,16
    80004070:	8082                	ret

0000000080004072 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80004072:	457c                	lw	a5,76(a0)
    80004074:	10d7e563          	bltu	a5,a3,8000417e <readi+0x10c>
{
    80004078:	7159                	addi	sp,sp,-112
    8000407a:	f486                	sd	ra,104(sp)
    8000407c:	f0a2                	sd	s0,96(sp)
    8000407e:	eca6                	sd	s1,88(sp)
    80004080:	e0d2                	sd	s4,64(sp)
    80004082:	fc56                	sd	s5,56(sp)
    80004084:	f85a                	sd	s6,48(sp)
    80004086:	f45e                	sd	s7,40(sp)
    80004088:	1880                	addi	s0,sp,112
    8000408a:	8b2a                	mv	s6,a0
    8000408c:	8bae                	mv	s7,a1
    8000408e:	8a32                	mv	s4,a2
    80004090:	84b6                	mv	s1,a3
    80004092:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80004094:	9f35                	addw	a4,a4,a3
    return 0;
    80004096:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80004098:	0cd76a63          	bltu	a4,a3,8000416c <readi+0xfa>
    8000409c:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    8000409e:	00e7f463          	bgeu	a5,a4,800040a6 <readi+0x34>
    n = ip->size - off;
    800040a2:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800040a6:	0a0a8963          	beqz	s5,80004158 <readi+0xe6>
    800040aa:	e8ca                	sd	s2,80(sp)
    800040ac:	f062                	sd	s8,32(sp)
    800040ae:	ec66                	sd	s9,24(sp)
    800040b0:	e86a                	sd	s10,16(sp)
    800040b2:	e46e                	sd	s11,8(sp)
    800040b4:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800040b6:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    800040ba:	5c7d                	li	s8,-1
    800040bc:	a82d                	j	800040f6 <readi+0x84>
    800040be:	020d1d93          	slli	s11,s10,0x20
    800040c2:	020ddd93          	srli	s11,s11,0x20
    800040c6:	05890613          	addi	a2,s2,88
    800040ca:	86ee                	mv	a3,s11
    800040cc:	963a                	add	a2,a2,a4
    800040ce:	85d2                	mv	a1,s4
    800040d0:	855e                	mv	a0,s7
    800040d2:	ffffe097          	auipc	ra,0xffffe
    800040d6:	670080e7          	jalr	1648(ra) # 80002742 <either_copyout>
    800040da:	05850d63          	beq	a0,s8,80004134 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    800040de:	854a                	mv	a0,s2
    800040e0:	fffff097          	auipc	ra,0xfffff
    800040e4:	5d6080e7          	jalr	1494(ra) # 800036b6 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800040e8:	013d09bb          	addw	s3,s10,s3
    800040ec:	009d04bb          	addw	s1,s10,s1
    800040f0:	9a6e                	add	s4,s4,s11
    800040f2:	0559fd63          	bgeu	s3,s5,8000414c <readi+0xda>
    uint addr = bmap(ip, off/BSIZE);
    800040f6:	00a4d59b          	srliw	a1,s1,0xa
    800040fa:	855a                	mv	a0,s6
    800040fc:	00000097          	auipc	ra,0x0
    80004100:	88e080e7          	jalr	-1906(ra) # 8000398a <bmap>
    80004104:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80004108:	c9b1                	beqz	a1,8000415c <readi+0xea>
    bp = bread(ip->dev, addr);
    8000410a:	000b2503          	lw	a0,0(s6)
    8000410e:	fffff097          	auipc	ra,0xfffff
    80004112:	478080e7          	jalr	1144(ra) # 80003586 <bread>
    80004116:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80004118:	3ff4f713          	andi	a4,s1,1023
    8000411c:	40ec87bb          	subw	a5,s9,a4
    80004120:	413a86bb          	subw	a3,s5,s3
    80004124:	8d3e                	mv	s10,a5
    80004126:	2781                	sext.w	a5,a5
    80004128:	0006861b          	sext.w	a2,a3
    8000412c:	f8f679e3          	bgeu	a2,a5,800040be <readi+0x4c>
    80004130:	8d36                	mv	s10,a3
    80004132:	b771                	j	800040be <readi+0x4c>
      brelse(bp);
    80004134:	854a                	mv	a0,s2
    80004136:	fffff097          	auipc	ra,0xfffff
    8000413a:	580080e7          	jalr	1408(ra) # 800036b6 <brelse>
      tot = -1;
    8000413e:	59fd                	li	s3,-1
      break;
    80004140:	6946                	ld	s2,80(sp)
    80004142:	7c02                	ld	s8,32(sp)
    80004144:	6ce2                	ld	s9,24(sp)
    80004146:	6d42                	ld	s10,16(sp)
    80004148:	6da2                	ld	s11,8(sp)
    8000414a:	a831                	j	80004166 <readi+0xf4>
    8000414c:	6946                	ld	s2,80(sp)
    8000414e:	7c02                	ld	s8,32(sp)
    80004150:	6ce2                	ld	s9,24(sp)
    80004152:	6d42                	ld	s10,16(sp)
    80004154:	6da2                	ld	s11,8(sp)
    80004156:	a801                	j	80004166 <readi+0xf4>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004158:	89d6                	mv	s3,s5
    8000415a:	a031                	j	80004166 <readi+0xf4>
    8000415c:	6946                	ld	s2,80(sp)
    8000415e:	7c02                	ld	s8,32(sp)
    80004160:	6ce2                	ld	s9,24(sp)
    80004162:	6d42                	ld	s10,16(sp)
    80004164:	6da2                	ld	s11,8(sp)
  }
  return tot;
    80004166:	0009851b          	sext.w	a0,s3
    8000416a:	69a6                	ld	s3,72(sp)
}
    8000416c:	70a6                	ld	ra,104(sp)
    8000416e:	7406                	ld	s0,96(sp)
    80004170:	64e6                	ld	s1,88(sp)
    80004172:	6a06                	ld	s4,64(sp)
    80004174:	7ae2                	ld	s5,56(sp)
    80004176:	7b42                	ld	s6,48(sp)
    80004178:	7ba2                	ld	s7,40(sp)
    8000417a:	6165                	addi	sp,sp,112
    8000417c:	8082                	ret
    return 0;
    8000417e:	4501                	li	a0,0
}
    80004180:	8082                	ret

0000000080004182 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80004182:	457c                	lw	a5,76(a0)
    80004184:	10d7ee63          	bltu	a5,a3,800042a0 <writei+0x11e>
{
    80004188:	7159                	addi	sp,sp,-112
    8000418a:	f486                	sd	ra,104(sp)
    8000418c:	f0a2                	sd	s0,96(sp)
    8000418e:	e8ca                	sd	s2,80(sp)
    80004190:	e0d2                	sd	s4,64(sp)
    80004192:	fc56                	sd	s5,56(sp)
    80004194:	f85a                	sd	s6,48(sp)
    80004196:	f45e                	sd	s7,40(sp)
    80004198:	1880                	addi	s0,sp,112
    8000419a:	8aaa                	mv	s5,a0
    8000419c:	8bae                	mv	s7,a1
    8000419e:	8a32                	mv	s4,a2
    800041a0:	8936                	mv	s2,a3
    800041a2:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    800041a4:	00e687bb          	addw	a5,a3,a4
    800041a8:	0ed7ee63          	bltu	a5,a3,800042a4 <writei+0x122>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    800041ac:	00043737          	lui	a4,0x43
    800041b0:	0ef76c63          	bltu	a4,a5,800042a8 <writei+0x126>
    800041b4:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800041b6:	0c0b0d63          	beqz	s6,80004290 <writei+0x10e>
    800041ba:	eca6                	sd	s1,88(sp)
    800041bc:	f062                	sd	s8,32(sp)
    800041be:	ec66                	sd	s9,24(sp)
    800041c0:	e86a                	sd	s10,16(sp)
    800041c2:	e46e                	sd	s11,8(sp)
    800041c4:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800041c6:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    800041ca:	5c7d                	li	s8,-1
    800041cc:	a091                	j	80004210 <writei+0x8e>
    800041ce:	020d1d93          	slli	s11,s10,0x20
    800041d2:	020ddd93          	srli	s11,s11,0x20
    800041d6:	05848513          	addi	a0,s1,88
    800041da:	86ee                	mv	a3,s11
    800041dc:	8652                	mv	a2,s4
    800041de:	85de                	mv	a1,s7
    800041e0:	953a                	add	a0,a0,a4
    800041e2:	ffffe097          	auipc	ra,0xffffe
    800041e6:	5b6080e7          	jalr	1462(ra) # 80002798 <either_copyin>
    800041ea:	07850263          	beq	a0,s8,8000424e <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    800041ee:	8526                	mv	a0,s1
    800041f0:	00000097          	auipc	ra,0x0
    800041f4:	770080e7          	jalr	1904(ra) # 80004960 <log_write>
    brelse(bp);
    800041f8:	8526                	mv	a0,s1
    800041fa:	fffff097          	auipc	ra,0xfffff
    800041fe:	4bc080e7          	jalr	1212(ra) # 800036b6 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004202:	013d09bb          	addw	s3,s10,s3
    80004206:	012d093b          	addw	s2,s10,s2
    8000420a:	9a6e                	add	s4,s4,s11
    8000420c:	0569f663          	bgeu	s3,s6,80004258 <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80004210:	00a9559b          	srliw	a1,s2,0xa
    80004214:	8556                	mv	a0,s5
    80004216:	fffff097          	auipc	ra,0xfffff
    8000421a:	774080e7          	jalr	1908(ra) # 8000398a <bmap>
    8000421e:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80004222:	c99d                	beqz	a1,80004258 <writei+0xd6>
    bp = bread(ip->dev, addr);
    80004224:	000aa503          	lw	a0,0(s5)
    80004228:	fffff097          	auipc	ra,0xfffff
    8000422c:	35e080e7          	jalr	862(ra) # 80003586 <bread>
    80004230:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80004232:	3ff97713          	andi	a4,s2,1023
    80004236:	40ec87bb          	subw	a5,s9,a4
    8000423a:	413b06bb          	subw	a3,s6,s3
    8000423e:	8d3e                	mv	s10,a5
    80004240:	2781                	sext.w	a5,a5
    80004242:	0006861b          	sext.w	a2,a3
    80004246:	f8f674e3          	bgeu	a2,a5,800041ce <writei+0x4c>
    8000424a:	8d36                	mv	s10,a3
    8000424c:	b749                	j	800041ce <writei+0x4c>
      brelse(bp);
    8000424e:	8526                	mv	a0,s1
    80004250:	fffff097          	auipc	ra,0xfffff
    80004254:	466080e7          	jalr	1126(ra) # 800036b6 <brelse>
  }

  if(off > ip->size)
    80004258:	04caa783          	lw	a5,76(s5)
    8000425c:	0327fc63          	bgeu	a5,s2,80004294 <writei+0x112>
    ip->size = off;
    80004260:	052aa623          	sw	s2,76(s5)
    80004264:	64e6                	ld	s1,88(sp)
    80004266:	7c02                	ld	s8,32(sp)
    80004268:	6ce2                	ld	s9,24(sp)
    8000426a:	6d42                	ld	s10,16(sp)
    8000426c:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    8000426e:	8556                	mv	a0,s5
    80004270:	00000097          	auipc	ra,0x0
    80004274:	a7e080e7          	jalr	-1410(ra) # 80003cee <iupdate>

  return tot;
    80004278:	0009851b          	sext.w	a0,s3
    8000427c:	69a6                	ld	s3,72(sp)
}
    8000427e:	70a6                	ld	ra,104(sp)
    80004280:	7406                	ld	s0,96(sp)
    80004282:	6946                	ld	s2,80(sp)
    80004284:	6a06                	ld	s4,64(sp)
    80004286:	7ae2                	ld	s5,56(sp)
    80004288:	7b42                	ld	s6,48(sp)
    8000428a:	7ba2                	ld	s7,40(sp)
    8000428c:	6165                	addi	sp,sp,112
    8000428e:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004290:	89da                	mv	s3,s6
    80004292:	bff1                	j	8000426e <writei+0xec>
    80004294:	64e6                	ld	s1,88(sp)
    80004296:	7c02                	ld	s8,32(sp)
    80004298:	6ce2                	ld	s9,24(sp)
    8000429a:	6d42                	ld	s10,16(sp)
    8000429c:	6da2                	ld	s11,8(sp)
    8000429e:	bfc1                	j	8000426e <writei+0xec>
    return -1;
    800042a0:	557d                	li	a0,-1
}
    800042a2:	8082                	ret
    return -1;
    800042a4:	557d                	li	a0,-1
    800042a6:	bfe1                	j	8000427e <writei+0xfc>
    return -1;
    800042a8:	557d                	li	a0,-1
    800042aa:	bfd1                	j	8000427e <writei+0xfc>

00000000800042ac <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    800042ac:	1141                	addi	sp,sp,-16
    800042ae:	e406                	sd	ra,8(sp)
    800042b0:	e022                	sd	s0,0(sp)
    800042b2:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    800042b4:	4639                	li	a2,14
    800042b6:	ffffd097          	auipc	ra,0xffffd
    800042ba:	b4e080e7          	jalr	-1202(ra) # 80000e04 <strncmp>
}
    800042be:	60a2                	ld	ra,8(sp)
    800042c0:	6402                	ld	s0,0(sp)
    800042c2:	0141                	addi	sp,sp,16
    800042c4:	8082                	ret

00000000800042c6 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    800042c6:	7139                	addi	sp,sp,-64
    800042c8:	fc06                	sd	ra,56(sp)
    800042ca:	f822                	sd	s0,48(sp)
    800042cc:	f426                	sd	s1,40(sp)
    800042ce:	f04a                	sd	s2,32(sp)
    800042d0:	ec4e                	sd	s3,24(sp)
    800042d2:	e852                	sd	s4,16(sp)
    800042d4:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    800042d6:	04451703          	lh	a4,68(a0)
    800042da:	4785                	li	a5,1
    800042dc:	00f71a63          	bne	a4,a5,800042f0 <dirlookup+0x2a>
    800042e0:	892a                	mv	s2,a0
    800042e2:	89ae                	mv	s3,a1
    800042e4:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    800042e6:	457c                	lw	a5,76(a0)
    800042e8:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    800042ea:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    800042ec:	e79d                	bnez	a5,8000431a <dirlookup+0x54>
    800042ee:	a8a5                	j	80004366 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    800042f0:	00004517          	auipc	a0,0x4
    800042f4:	37850513          	addi	a0,a0,888 # 80008668 <etext+0x668>
    800042f8:	ffffc097          	auipc	ra,0xffffc
    800042fc:	268080e7          	jalr	616(ra) # 80000560 <panic>
      panic("dirlookup read");
    80004300:	00004517          	auipc	a0,0x4
    80004304:	38050513          	addi	a0,a0,896 # 80008680 <etext+0x680>
    80004308:	ffffc097          	auipc	ra,0xffffc
    8000430c:	258080e7          	jalr	600(ra) # 80000560 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004310:	24c1                	addiw	s1,s1,16
    80004312:	04c92783          	lw	a5,76(s2)
    80004316:	04f4f763          	bgeu	s1,a5,80004364 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000431a:	4741                	li	a4,16
    8000431c:	86a6                	mv	a3,s1
    8000431e:	fc040613          	addi	a2,s0,-64
    80004322:	4581                	li	a1,0
    80004324:	854a                	mv	a0,s2
    80004326:	00000097          	auipc	ra,0x0
    8000432a:	d4c080e7          	jalr	-692(ra) # 80004072 <readi>
    8000432e:	47c1                	li	a5,16
    80004330:	fcf518e3          	bne	a0,a5,80004300 <dirlookup+0x3a>
    if(de.inum == 0)
    80004334:	fc045783          	lhu	a5,-64(s0)
    80004338:	dfe1                	beqz	a5,80004310 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    8000433a:	fc240593          	addi	a1,s0,-62
    8000433e:	854e                	mv	a0,s3
    80004340:	00000097          	auipc	ra,0x0
    80004344:	f6c080e7          	jalr	-148(ra) # 800042ac <namecmp>
    80004348:	f561                	bnez	a0,80004310 <dirlookup+0x4a>
      if(poff)
    8000434a:	000a0463          	beqz	s4,80004352 <dirlookup+0x8c>
        *poff = off;
    8000434e:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80004352:	fc045583          	lhu	a1,-64(s0)
    80004356:	00092503          	lw	a0,0(s2)
    8000435a:	fffff097          	auipc	ra,0xfffff
    8000435e:	720080e7          	jalr	1824(ra) # 80003a7a <iget>
    80004362:	a011                	j	80004366 <dirlookup+0xa0>
  return 0;
    80004364:	4501                	li	a0,0
}
    80004366:	70e2                	ld	ra,56(sp)
    80004368:	7442                	ld	s0,48(sp)
    8000436a:	74a2                	ld	s1,40(sp)
    8000436c:	7902                	ld	s2,32(sp)
    8000436e:	69e2                	ld	s3,24(sp)
    80004370:	6a42                	ld	s4,16(sp)
    80004372:	6121                	addi	sp,sp,64
    80004374:	8082                	ret

0000000080004376 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80004376:	711d                	addi	sp,sp,-96
    80004378:	ec86                	sd	ra,88(sp)
    8000437a:	e8a2                	sd	s0,80(sp)
    8000437c:	e4a6                	sd	s1,72(sp)
    8000437e:	e0ca                	sd	s2,64(sp)
    80004380:	fc4e                	sd	s3,56(sp)
    80004382:	f852                	sd	s4,48(sp)
    80004384:	f456                	sd	s5,40(sp)
    80004386:	f05a                	sd	s6,32(sp)
    80004388:	ec5e                	sd	s7,24(sp)
    8000438a:	e862                	sd	s8,16(sp)
    8000438c:	e466                	sd	s9,8(sp)
    8000438e:	1080                	addi	s0,sp,96
    80004390:	84aa                	mv	s1,a0
    80004392:	8b2e                	mv	s6,a1
    80004394:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80004396:	00054703          	lbu	a4,0(a0)
    8000439a:	02f00793          	li	a5,47
    8000439e:	02f70263          	beq	a4,a5,800043c2 <namex+0x4c>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    800043a2:	ffffd097          	auipc	ra,0xffffd
    800043a6:	788080e7          	jalr	1928(ra) # 80001b2a <myproc>
    800043aa:	15053503          	ld	a0,336(a0)
    800043ae:	00000097          	auipc	ra,0x0
    800043b2:	9ce080e7          	jalr	-1586(ra) # 80003d7c <idup>
    800043b6:	8a2a                	mv	s4,a0
  while(*path == '/')
    800043b8:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    800043bc:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    800043be:	4b85                	li	s7,1
    800043c0:	a875                	j	8000447c <namex+0x106>
    ip = iget(ROOTDEV, ROOTINO);
    800043c2:	4585                	li	a1,1
    800043c4:	4505                	li	a0,1
    800043c6:	fffff097          	auipc	ra,0xfffff
    800043ca:	6b4080e7          	jalr	1716(ra) # 80003a7a <iget>
    800043ce:	8a2a                	mv	s4,a0
    800043d0:	b7e5                	j	800043b8 <namex+0x42>
      iunlockput(ip);
    800043d2:	8552                	mv	a0,s4
    800043d4:	00000097          	auipc	ra,0x0
    800043d8:	c4c080e7          	jalr	-948(ra) # 80004020 <iunlockput>
      return 0;
    800043dc:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    800043de:	8552                	mv	a0,s4
    800043e0:	60e6                	ld	ra,88(sp)
    800043e2:	6446                	ld	s0,80(sp)
    800043e4:	64a6                	ld	s1,72(sp)
    800043e6:	6906                	ld	s2,64(sp)
    800043e8:	79e2                	ld	s3,56(sp)
    800043ea:	7a42                	ld	s4,48(sp)
    800043ec:	7aa2                	ld	s5,40(sp)
    800043ee:	7b02                	ld	s6,32(sp)
    800043f0:	6be2                	ld	s7,24(sp)
    800043f2:	6c42                	ld	s8,16(sp)
    800043f4:	6ca2                	ld	s9,8(sp)
    800043f6:	6125                	addi	sp,sp,96
    800043f8:	8082                	ret
      iunlock(ip);
    800043fa:	8552                	mv	a0,s4
    800043fc:	00000097          	auipc	ra,0x0
    80004400:	a84080e7          	jalr	-1404(ra) # 80003e80 <iunlock>
      return ip;
    80004404:	bfe9                	j	800043de <namex+0x68>
      iunlockput(ip);
    80004406:	8552                	mv	a0,s4
    80004408:	00000097          	auipc	ra,0x0
    8000440c:	c18080e7          	jalr	-1000(ra) # 80004020 <iunlockput>
      return 0;
    80004410:	8a4e                	mv	s4,s3
    80004412:	b7f1                	j	800043de <namex+0x68>
  len = path - s;
    80004414:	40998633          	sub	a2,s3,s1
    80004418:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    8000441c:	099c5863          	bge	s8,s9,800044ac <namex+0x136>
    memmove(name, s, DIRSIZ);
    80004420:	4639                	li	a2,14
    80004422:	85a6                	mv	a1,s1
    80004424:	8556                	mv	a0,s5
    80004426:	ffffd097          	auipc	ra,0xffffd
    8000442a:	96a080e7          	jalr	-1686(ra) # 80000d90 <memmove>
    8000442e:	84ce                	mv	s1,s3
  while(*path == '/')
    80004430:	0004c783          	lbu	a5,0(s1)
    80004434:	01279763          	bne	a5,s2,80004442 <namex+0xcc>
    path++;
    80004438:	0485                	addi	s1,s1,1
  while(*path == '/')
    8000443a:	0004c783          	lbu	a5,0(s1)
    8000443e:	ff278de3          	beq	a5,s2,80004438 <namex+0xc2>
    ilock(ip);
    80004442:	8552                	mv	a0,s4
    80004444:	00000097          	auipc	ra,0x0
    80004448:	976080e7          	jalr	-1674(ra) # 80003dba <ilock>
    if(ip->type != T_DIR){
    8000444c:	044a1783          	lh	a5,68(s4)
    80004450:	f97791e3          	bne	a5,s7,800043d2 <namex+0x5c>
    if(nameiparent && *path == '\0'){
    80004454:	000b0563          	beqz	s6,8000445e <namex+0xe8>
    80004458:	0004c783          	lbu	a5,0(s1)
    8000445c:	dfd9                	beqz	a5,800043fa <namex+0x84>
    if((next = dirlookup(ip, name, 0)) == 0){
    8000445e:	4601                	li	a2,0
    80004460:	85d6                	mv	a1,s5
    80004462:	8552                	mv	a0,s4
    80004464:	00000097          	auipc	ra,0x0
    80004468:	e62080e7          	jalr	-414(ra) # 800042c6 <dirlookup>
    8000446c:	89aa                	mv	s3,a0
    8000446e:	dd41                	beqz	a0,80004406 <namex+0x90>
    iunlockput(ip);
    80004470:	8552                	mv	a0,s4
    80004472:	00000097          	auipc	ra,0x0
    80004476:	bae080e7          	jalr	-1106(ra) # 80004020 <iunlockput>
    ip = next;
    8000447a:	8a4e                	mv	s4,s3
  while(*path == '/')
    8000447c:	0004c783          	lbu	a5,0(s1)
    80004480:	01279763          	bne	a5,s2,8000448e <namex+0x118>
    path++;
    80004484:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004486:	0004c783          	lbu	a5,0(s1)
    8000448a:	ff278de3          	beq	a5,s2,80004484 <namex+0x10e>
  if(*path == 0)
    8000448e:	cb9d                	beqz	a5,800044c4 <namex+0x14e>
  while(*path != '/' && *path != 0)
    80004490:	0004c783          	lbu	a5,0(s1)
    80004494:	89a6                	mv	s3,s1
  len = path - s;
    80004496:	4c81                	li	s9,0
    80004498:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    8000449a:	01278963          	beq	a5,s2,800044ac <namex+0x136>
    8000449e:	dbbd                	beqz	a5,80004414 <namex+0x9e>
    path++;
    800044a0:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    800044a2:	0009c783          	lbu	a5,0(s3)
    800044a6:	ff279ce3          	bne	a5,s2,8000449e <namex+0x128>
    800044aa:	b7ad                	j	80004414 <namex+0x9e>
    memmove(name, s, len);
    800044ac:	2601                	sext.w	a2,a2
    800044ae:	85a6                	mv	a1,s1
    800044b0:	8556                	mv	a0,s5
    800044b2:	ffffd097          	auipc	ra,0xffffd
    800044b6:	8de080e7          	jalr	-1826(ra) # 80000d90 <memmove>
    name[len] = 0;
    800044ba:	9cd6                	add	s9,s9,s5
    800044bc:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    800044c0:	84ce                	mv	s1,s3
    800044c2:	b7bd                	j	80004430 <namex+0xba>
  if(nameiparent){
    800044c4:	f00b0de3          	beqz	s6,800043de <namex+0x68>
    iput(ip);
    800044c8:	8552                	mv	a0,s4
    800044ca:	00000097          	auipc	ra,0x0
    800044ce:	aae080e7          	jalr	-1362(ra) # 80003f78 <iput>
    return 0;
    800044d2:	4a01                	li	s4,0
    800044d4:	b729                	j	800043de <namex+0x68>

00000000800044d6 <dirlink>:
{
    800044d6:	7139                	addi	sp,sp,-64
    800044d8:	fc06                	sd	ra,56(sp)
    800044da:	f822                	sd	s0,48(sp)
    800044dc:	f04a                	sd	s2,32(sp)
    800044de:	ec4e                	sd	s3,24(sp)
    800044e0:	e852                	sd	s4,16(sp)
    800044e2:	0080                	addi	s0,sp,64
    800044e4:	892a                	mv	s2,a0
    800044e6:	8a2e                	mv	s4,a1
    800044e8:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    800044ea:	4601                	li	a2,0
    800044ec:	00000097          	auipc	ra,0x0
    800044f0:	dda080e7          	jalr	-550(ra) # 800042c6 <dirlookup>
    800044f4:	ed25                	bnez	a0,8000456c <dirlink+0x96>
    800044f6:	f426                	sd	s1,40(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    800044f8:	04c92483          	lw	s1,76(s2)
    800044fc:	c49d                	beqz	s1,8000452a <dirlink+0x54>
    800044fe:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004500:	4741                	li	a4,16
    80004502:	86a6                	mv	a3,s1
    80004504:	fc040613          	addi	a2,s0,-64
    80004508:	4581                	li	a1,0
    8000450a:	854a                	mv	a0,s2
    8000450c:	00000097          	auipc	ra,0x0
    80004510:	b66080e7          	jalr	-1178(ra) # 80004072 <readi>
    80004514:	47c1                	li	a5,16
    80004516:	06f51163          	bne	a0,a5,80004578 <dirlink+0xa2>
    if(de.inum == 0)
    8000451a:	fc045783          	lhu	a5,-64(s0)
    8000451e:	c791                	beqz	a5,8000452a <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004520:	24c1                	addiw	s1,s1,16
    80004522:	04c92783          	lw	a5,76(s2)
    80004526:	fcf4ede3          	bltu	s1,a5,80004500 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    8000452a:	4639                	li	a2,14
    8000452c:	85d2                	mv	a1,s4
    8000452e:	fc240513          	addi	a0,s0,-62
    80004532:	ffffd097          	auipc	ra,0xffffd
    80004536:	908080e7          	jalr	-1784(ra) # 80000e3a <strncpy>
  de.inum = inum;
    8000453a:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000453e:	4741                	li	a4,16
    80004540:	86a6                	mv	a3,s1
    80004542:	fc040613          	addi	a2,s0,-64
    80004546:	4581                	li	a1,0
    80004548:	854a                	mv	a0,s2
    8000454a:	00000097          	auipc	ra,0x0
    8000454e:	c38080e7          	jalr	-968(ra) # 80004182 <writei>
    80004552:	1541                	addi	a0,a0,-16
    80004554:	00a03533          	snez	a0,a0
    80004558:	40a00533          	neg	a0,a0
    8000455c:	74a2                	ld	s1,40(sp)
}
    8000455e:	70e2                	ld	ra,56(sp)
    80004560:	7442                	ld	s0,48(sp)
    80004562:	7902                	ld	s2,32(sp)
    80004564:	69e2                	ld	s3,24(sp)
    80004566:	6a42                	ld	s4,16(sp)
    80004568:	6121                	addi	sp,sp,64
    8000456a:	8082                	ret
    iput(ip);
    8000456c:	00000097          	auipc	ra,0x0
    80004570:	a0c080e7          	jalr	-1524(ra) # 80003f78 <iput>
    return -1;
    80004574:	557d                	li	a0,-1
    80004576:	b7e5                	j	8000455e <dirlink+0x88>
      panic("dirlink read");
    80004578:	00004517          	auipc	a0,0x4
    8000457c:	11850513          	addi	a0,a0,280 # 80008690 <etext+0x690>
    80004580:	ffffc097          	auipc	ra,0xffffc
    80004584:	fe0080e7          	jalr	-32(ra) # 80000560 <panic>

0000000080004588 <namei>:

struct inode*
namei(char *path)
{
    80004588:	1101                	addi	sp,sp,-32
    8000458a:	ec06                	sd	ra,24(sp)
    8000458c:	e822                	sd	s0,16(sp)
    8000458e:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004590:	fe040613          	addi	a2,s0,-32
    80004594:	4581                	li	a1,0
    80004596:	00000097          	auipc	ra,0x0
    8000459a:	de0080e7          	jalr	-544(ra) # 80004376 <namex>
}
    8000459e:	60e2                	ld	ra,24(sp)
    800045a0:	6442                	ld	s0,16(sp)
    800045a2:	6105                	addi	sp,sp,32
    800045a4:	8082                	ret

00000000800045a6 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800045a6:	1141                	addi	sp,sp,-16
    800045a8:	e406                	sd	ra,8(sp)
    800045aa:	e022                	sd	s0,0(sp)
    800045ac:	0800                	addi	s0,sp,16
    800045ae:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800045b0:	4585                	li	a1,1
    800045b2:	00000097          	auipc	ra,0x0
    800045b6:	dc4080e7          	jalr	-572(ra) # 80004376 <namex>
}
    800045ba:	60a2                	ld	ra,8(sp)
    800045bc:	6402                	ld	s0,0(sp)
    800045be:	0141                	addi	sp,sp,16
    800045c0:	8082                	ret

00000000800045c2 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800045c2:	1101                	addi	sp,sp,-32
    800045c4:	ec06                	sd	ra,24(sp)
    800045c6:	e822                	sd	s0,16(sp)
    800045c8:	e426                	sd	s1,8(sp)
    800045ca:	e04a                	sd	s2,0(sp)
    800045cc:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800045ce:	00047917          	auipc	s2,0x47
    800045d2:	31290913          	addi	s2,s2,786 # 8004b8e0 <log>
    800045d6:	01892583          	lw	a1,24(s2)
    800045da:	02892503          	lw	a0,40(s2)
    800045de:	fffff097          	auipc	ra,0xfffff
    800045e2:	fa8080e7          	jalr	-88(ra) # 80003586 <bread>
    800045e6:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    800045e8:	02c92603          	lw	a2,44(s2)
    800045ec:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    800045ee:	00c05f63          	blez	a2,8000460c <write_head+0x4a>
    800045f2:	00047717          	auipc	a4,0x47
    800045f6:	31e70713          	addi	a4,a4,798 # 8004b910 <log+0x30>
    800045fa:	87aa                	mv	a5,a0
    800045fc:	060a                	slli	a2,a2,0x2
    800045fe:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80004600:	4314                	lw	a3,0(a4)
    80004602:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80004604:	0711                	addi	a4,a4,4
    80004606:	0791                	addi	a5,a5,4
    80004608:	fec79ce3          	bne	a5,a2,80004600 <write_head+0x3e>
  }
  bwrite(buf);
    8000460c:	8526                	mv	a0,s1
    8000460e:	fffff097          	auipc	ra,0xfffff
    80004612:	06a080e7          	jalr	106(ra) # 80003678 <bwrite>
  brelse(buf);
    80004616:	8526                	mv	a0,s1
    80004618:	fffff097          	auipc	ra,0xfffff
    8000461c:	09e080e7          	jalr	158(ra) # 800036b6 <brelse>
}
    80004620:	60e2                	ld	ra,24(sp)
    80004622:	6442                	ld	s0,16(sp)
    80004624:	64a2                	ld	s1,8(sp)
    80004626:	6902                	ld	s2,0(sp)
    80004628:	6105                	addi	sp,sp,32
    8000462a:	8082                	ret

000000008000462c <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    8000462c:	00047797          	auipc	a5,0x47
    80004630:	2e07a783          	lw	a5,736(a5) # 8004b90c <log+0x2c>
    80004634:	0af05d63          	blez	a5,800046ee <install_trans+0xc2>
{
    80004638:	7139                	addi	sp,sp,-64
    8000463a:	fc06                	sd	ra,56(sp)
    8000463c:	f822                	sd	s0,48(sp)
    8000463e:	f426                	sd	s1,40(sp)
    80004640:	f04a                	sd	s2,32(sp)
    80004642:	ec4e                	sd	s3,24(sp)
    80004644:	e852                	sd	s4,16(sp)
    80004646:	e456                	sd	s5,8(sp)
    80004648:	e05a                	sd	s6,0(sp)
    8000464a:	0080                	addi	s0,sp,64
    8000464c:	8b2a                	mv	s6,a0
    8000464e:	00047a97          	auipc	s5,0x47
    80004652:	2c2a8a93          	addi	s5,s5,706 # 8004b910 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004656:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004658:	00047997          	auipc	s3,0x47
    8000465c:	28898993          	addi	s3,s3,648 # 8004b8e0 <log>
    80004660:	a00d                	j	80004682 <install_trans+0x56>
    brelse(lbuf);
    80004662:	854a                	mv	a0,s2
    80004664:	fffff097          	auipc	ra,0xfffff
    80004668:	052080e7          	jalr	82(ra) # 800036b6 <brelse>
    brelse(dbuf);
    8000466c:	8526                	mv	a0,s1
    8000466e:	fffff097          	auipc	ra,0xfffff
    80004672:	048080e7          	jalr	72(ra) # 800036b6 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004676:	2a05                	addiw	s4,s4,1
    80004678:	0a91                	addi	s5,s5,4
    8000467a:	02c9a783          	lw	a5,44(s3)
    8000467e:	04fa5e63          	bge	s4,a5,800046da <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004682:	0189a583          	lw	a1,24(s3)
    80004686:	014585bb          	addw	a1,a1,s4
    8000468a:	2585                	addiw	a1,a1,1
    8000468c:	0289a503          	lw	a0,40(s3)
    80004690:	fffff097          	auipc	ra,0xfffff
    80004694:	ef6080e7          	jalr	-266(ra) # 80003586 <bread>
    80004698:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    8000469a:	000aa583          	lw	a1,0(s5)
    8000469e:	0289a503          	lw	a0,40(s3)
    800046a2:	fffff097          	auipc	ra,0xfffff
    800046a6:	ee4080e7          	jalr	-284(ra) # 80003586 <bread>
    800046aa:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800046ac:	40000613          	li	a2,1024
    800046b0:	05890593          	addi	a1,s2,88
    800046b4:	05850513          	addi	a0,a0,88
    800046b8:	ffffc097          	auipc	ra,0xffffc
    800046bc:	6d8080e7          	jalr	1752(ra) # 80000d90 <memmove>
    bwrite(dbuf);  // write dst to disk
    800046c0:	8526                	mv	a0,s1
    800046c2:	fffff097          	auipc	ra,0xfffff
    800046c6:	fb6080e7          	jalr	-74(ra) # 80003678 <bwrite>
    if(recovering == 0)
    800046ca:	f80b1ce3          	bnez	s6,80004662 <install_trans+0x36>
      bunpin(dbuf);
    800046ce:	8526                	mv	a0,s1
    800046d0:	fffff097          	auipc	ra,0xfffff
    800046d4:	0be080e7          	jalr	190(ra) # 8000378e <bunpin>
    800046d8:	b769                	j	80004662 <install_trans+0x36>
}
    800046da:	70e2                	ld	ra,56(sp)
    800046dc:	7442                	ld	s0,48(sp)
    800046de:	74a2                	ld	s1,40(sp)
    800046e0:	7902                	ld	s2,32(sp)
    800046e2:	69e2                	ld	s3,24(sp)
    800046e4:	6a42                	ld	s4,16(sp)
    800046e6:	6aa2                	ld	s5,8(sp)
    800046e8:	6b02                	ld	s6,0(sp)
    800046ea:	6121                	addi	sp,sp,64
    800046ec:	8082                	ret
    800046ee:	8082                	ret

00000000800046f0 <initlog>:
{
    800046f0:	7179                	addi	sp,sp,-48
    800046f2:	f406                	sd	ra,40(sp)
    800046f4:	f022                	sd	s0,32(sp)
    800046f6:	ec26                	sd	s1,24(sp)
    800046f8:	e84a                	sd	s2,16(sp)
    800046fa:	e44e                	sd	s3,8(sp)
    800046fc:	1800                	addi	s0,sp,48
    800046fe:	892a                	mv	s2,a0
    80004700:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004702:	00047497          	auipc	s1,0x47
    80004706:	1de48493          	addi	s1,s1,478 # 8004b8e0 <log>
    8000470a:	00004597          	auipc	a1,0x4
    8000470e:	f9658593          	addi	a1,a1,-106 # 800086a0 <etext+0x6a0>
    80004712:	8526                	mv	a0,s1
    80004714:	ffffc097          	auipc	ra,0xffffc
    80004718:	494080e7          	jalr	1172(ra) # 80000ba8 <initlock>
  log.start = sb->logstart;
    8000471c:	0149a583          	lw	a1,20(s3)
    80004720:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80004722:	0109a783          	lw	a5,16(s3)
    80004726:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004728:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    8000472c:	854a                	mv	a0,s2
    8000472e:	fffff097          	auipc	ra,0xfffff
    80004732:	e58080e7          	jalr	-424(ra) # 80003586 <bread>
  log.lh.n = lh->n;
    80004736:	4d30                	lw	a2,88(a0)
    80004738:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    8000473a:	00c05f63          	blez	a2,80004758 <initlog+0x68>
    8000473e:	87aa                	mv	a5,a0
    80004740:	00047717          	auipc	a4,0x47
    80004744:	1d070713          	addi	a4,a4,464 # 8004b910 <log+0x30>
    80004748:	060a                	slli	a2,a2,0x2
    8000474a:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    8000474c:	4ff4                	lw	a3,92(a5)
    8000474e:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004750:	0791                	addi	a5,a5,4
    80004752:	0711                	addi	a4,a4,4
    80004754:	fec79ce3          	bne	a5,a2,8000474c <initlog+0x5c>
  brelse(buf);
    80004758:	fffff097          	auipc	ra,0xfffff
    8000475c:	f5e080e7          	jalr	-162(ra) # 800036b6 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004760:	4505                	li	a0,1
    80004762:	00000097          	auipc	ra,0x0
    80004766:	eca080e7          	jalr	-310(ra) # 8000462c <install_trans>
  log.lh.n = 0;
    8000476a:	00047797          	auipc	a5,0x47
    8000476e:	1a07a123          	sw	zero,418(a5) # 8004b90c <log+0x2c>
  write_head(); // clear the log
    80004772:	00000097          	auipc	ra,0x0
    80004776:	e50080e7          	jalr	-432(ra) # 800045c2 <write_head>
}
    8000477a:	70a2                	ld	ra,40(sp)
    8000477c:	7402                	ld	s0,32(sp)
    8000477e:	64e2                	ld	s1,24(sp)
    80004780:	6942                	ld	s2,16(sp)
    80004782:	69a2                	ld	s3,8(sp)
    80004784:	6145                	addi	sp,sp,48
    80004786:	8082                	ret

0000000080004788 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004788:	1101                	addi	sp,sp,-32
    8000478a:	ec06                	sd	ra,24(sp)
    8000478c:	e822                	sd	s0,16(sp)
    8000478e:	e426                	sd	s1,8(sp)
    80004790:	e04a                	sd	s2,0(sp)
    80004792:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004794:	00047517          	auipc	a0,0x47
    80004798:	14c50513          	addi	a0,a0,332 # 8004b8e0 <log>
    8000479c:	ffffc097          	auipc	ra,0xffffc
    800047a0:	49c080e7          	jalr	1180(ra) # 80000c38 <acquire>
  while(1){
    if(log.committing){
    800047a4:	00047497          	auipc	s1,0x47
    800047a8:	13c48493          	addi	s1,s1,316 # 8004b8e0 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800047ac:	4979                	li	s2,30
    800047ae:	a039                	j	800047bc <begin_op+0x34>
      sleep(&log, &log.lock);
    800047b0:	85a6                	mv	a1,s1
    800047b2:	8526                	mv	a0,s1
    800047b4:	ffffe097          	auipc	ra,0xffffe
    800047b8:	ae0080e7          	jalr	-1312(ra) # 80002294 <sleep>
    if(log.committing){
    800047bc:	50dc                	lw	a5,36(s1)
    800047be:	fbed                	bnez	a5,800047b0 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800047c0:	5098                	lw	a4,32(s1)
    800047c2:	2705                	addiw	a4,a4,1
    800047c4:	0027179b          	slliw	a5,a4,0x2
    800047c8:	9fb9                	addw	a5,a5,a4
    800047ca:	0017979b          	slliw	a5,a5,0x1
    800047ce:	54d4                	lw	a3,44(s1)
    800047d0:	9fb5                	addw	a5,a5,a3
    800047d2:	00f95963          	bge	s2,a5,800047e4 <begin_op+0x5c>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800047d6:	85a6                	mv	a1,s1
    800047d8:	8526                	mv	a0,s1
    800047da:	ffffe097          	auipc	ra,0xffffe
    800047de:	aba080e7          	jalr	-1350(ra) # 80002294 <sleep>
    800047e2:	bfe9                	j	800047bc <begin_op+0x34>
    } else {
      log.outstanding += 1;
    800047e4:	00047517          	auipc	a0,0x47
    800047e8:	0fc50513          	addi	a0,a0,252 # 8004b8e0 <log>
    800047ec:	d118                	sw	a4,32(a0)
      release(&log.lock);
    800047ee:	ffffc097          	auipc	ra,0xffffc
    800047f2:	4fe080e7          	jalr	1278(ra) # 80000cec <release>
      break;
    }
  }
}
    800047f6:	60e2                	ld	ra,24(sp)
    800047f8:	6442                	ld	s0,16(sp)
    800047fa:	64a2                	ld	s1,8(sp)
    800047fc:	6902                	ld	s2,0(sp)
    800047fe:	6105                	addi	sp,sp,32
    80004800:	8082                	ret

0000000080004802 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004802:	7139                	addi	sp,sp,-64
    80004804:	fc06                	sd	ra,56(sp)
    80004806:	f822                	sd	s0,48(sp)
    80004808:	f426                	sd	s1,40(sp)
    8000480a:	f04a                	sd	s2,32(sp)
    8000480c:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    8000480e:	00047497          	auipc	s1,0x47
    80004812:	0d248493          	addi	s1,s1,210 # 8004b8e0 <log>
    80004816:	8526                	mv	a0,s1
    80004818:	ffffc097          	auipc	ra,0xffffc
    8000481c:	420080e7          	jalr	1056(ra) # 80000c38 <acquire>
  log.outstanding -= 1;
    80004820:	509c                	lw	a5,32(s1)
    80004822:	37fd                	addiw	a5,a5,-1
    80004824:	0007891b          	sext.w	s2,a5
    80004828:	d09c                	sw	a5,32(s1)
  if(log.committing)
    8000482a:	50dc                	lw	a5,36(s1)
    8000482c:	e7b9                	bnez	a5,8000487a <end_op+0x78>
    panic("log.committing");
  if(log.outstanding == 0){
    8000482e:	06091163          	bnez	s2,80004890 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    80004832:	00047497          	auipc	s1,0x47
    80004836:	0ae48493          	addi	s1,s1,174 # 8004b8e0 <log>
    8000483a:	4785                	li	a5,1
    8000483c:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    8000483e:	8526                	mv	a0,s1
    80004840:	ffffc097          	auipc	ra,0xffffc
    80004844:	4ac080e7          	jalr	1196(ra) # 80000cec <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004848:	54dc                	lw	a5,44(s1)
    8000484a:	06f04763          	bgtz	a5,800048b8 <end_op+0xb6>
    acquire(&log.lock);
    8000484e:	00047497          	auipc	s1,0x47
    80004852:	09248493          	addi	s1,s1,146 # 8004b8e0 <log>
    80004856:	8526                	mv	a0,s1
    80004858:	ffffc097          	auipc	ra,0xffffc
    8000485c:	3e0080e7          	jalr	992(ra) # 80000c38 <acquire>
    log.committing = 0;
    80004860:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004864:	8526                	mv	a0,s1
    80004866:	ffffe097          	auipc	ra,0xffffe
    8000486a:	a92080e7          	jalr	-1390(ra) # 800022f8 <wakeup>
    release(&log.lock);
    8000486e:	8526                	mv	a0,s1
    80004870:	ffffc097          	auipc	ra,0xffffc
    80004874:	47c080e7          	jalr	1148(ra) # 80000cec <release>
}
    80004878:	a815                	j	800048ac <end_op+0xaa>
    8000487a:	ec4e                	sd	s3,24(sp)
    8000487c:	e852                	sd	s4,16(sp)
    8000487e:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80004880:	00004517          	auipc	a0,0x4
    80004884:	e2850513          	addi	a0,a0,-472 # 800086a8 <etext+0x6a8>
    80004888:	ffffc097          	auipc	ra,0xffffc
    8000488c:	cd8080e7          	jalr	-808(ra) # 80000560 <panic>
    wakeup(&log);
    80004890:	00047497          	auipc	s1,0x47
    80004894:	05048493          	addi	s1,s1,80 # 8004b8e0 <log>
    80004898:	8526                	mv	a0,s1
    8000489a:	ffffe097          	auipc	ra,0xffffe
    8000489e:	a5e080e7          	jalr	-1442(ra) # 800022f8 <wakeup>
  release(&log.lock);
    800048a2:	8526                	mv	a0,s1
    800048a4:	ffffc097          	auipc	ra,0xffffc
    800048a8:	448080e7          	jalr	1096(ra) # 80000cec <release>
}
    800048ac:	70e2                	ld	ra,56(sp)
    800048ae:	7442                	ld	s0,48(sp)
    800048b0:	74a2                	ld	s1,40(sp)
    800048b2:	7902                	ld	s2,32(sp)
    800048b4:	6121                	addi	sp,sp,64
    800048b6:	8082                	ret
    800048b8:	ec4e                	sd	s3,24(sp)
    800048ba:	e852                	sd	s4,16(sp)
    800048bc:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    800048be:	00047a97          	auipc	s5,0x47
    800048c2:	052a8a93          	addi	s5,s5,82 # 8004b910 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800048c6:	00047a17          	auipc	s4,0x47
    800048ca:	01aa0a13          	addi	s4,s4,26 # 8004b8e0 <log>
    800048ce:	018a2583          	lw	a1,24(s4)
    800048d2:	012585bb          	addw	a1,a1,s2
    800048d6:	2585                	addiw	a1,a1,1
    800048d8:	028a2503          	lw	a0,40(s4)
    800048dc:	fffff097          	auipc	ra,0xfffff
    800048e0:	caa080e7          	jalr	-854(ra) # 80003586 <bread>
    800048e4:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800048e6:	000aa583          	lw	a1,0(s5)
    800048ea:	028a2503          	lw	a0,40(s4)
    800048ee:	fffff097          	auipc	ra,0xfffff
    800048f2:	c98080e7          	jalr	-872(ra) # 80003586 <bread>
    800048f6:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800048f8:	40000613          	li	a2,1024
    800048fc:	05850593          	addi	a1,a0,88
    80004900:	05848513          	addi	a0,s1,88
    80004904:	ffffc097          	auipc	ra,0xffffc
    80004908:	48c080e7          	jalr	1164(ra) # 80000d90 <memmove>
    bwrite(to);  // write the log
    8000490c:	8526                	mv	a0,s1
    8000490e:	fffff097          	auipc	ra,0xfffff
    80004912:	d6a080e7          	jalr	-662(ra) # 80003678 <bwrite>
    brelse(from);
    80004916:	854e                	mv	a0,s3
    80004918:	fffff097          	auipc	ra,0xfffff
    8000491c:	d9e080e7          	jalr	-610(ra) # 800036b6 <brelse>
    brelse(to);
    80004920:	8526                	mv	a0,s1
    80004922:	fffff097          	auipc	ra,0xfffff
    80004926:	d94080e7          	jalr	-620(ra) # 800036b6 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000492a:	2905                	addiw	s2,s2,1
    8000492c:	0a91                	addi	s5,s5,4
    8000492e:	02ca2783          	lw	a5,44(s4)
    80004932:	f8f94ee3          	blt	s2,a5,800048ce <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004936:	00000097          	auipc	ra,0x0
    8000493a:	c8c080e7          	jalr	-884(ra) # 800045c2 <write_head>
    install_trans(0); // Now install writes to home locations
    8000493e:	4501                	li	a0,0
    80004940:	00000097          	auipc	ra,0x0
    80004944:	cec080e7          	jalr	-788(ra) # 8000462c <install_trans>
    log.lh.n = 0;
    80004948:	00047797          	auipc	a5,0x47
    8000494c:	fc07a223          	sw	zero,-60(a5) # 8004b90c <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004950:	00000097          	auipc	ra,0x0
    80004954:	c72080e7          	jalr	-910(ra) # 800045c2 <write_head>
    80004958:	69e2                	ld	s3,24(sp)
    8000495a:	6a42                	ld	s4,16(sp)
    8000495c:	6aa2                	ld	s5,8(sp)
    8000495e:	bdc5                	j	8000484e <end_op+0x4c>

0000000080004960 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004960:	1101                	addi	sp,sp,-32
    80004962:	ec06                	sd	ra,24(sp)
    80004964:	e822                	sd	s0,16(sp)
    80004966:	e426                	sd	s1,8(sp)
    80004968:	e04a                	sd	s2,0(sp)
    8000496a:	1000                	addi	s0,sp,32
    8000496c:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    8000496e:	00047917          	auipc	s2,0x47
    80004972:	f7290913          	addi	s2,s2,-142 # 8004b8e0 <log>
    80004976:	854a                	mv	a0,s2
    80004978:	ffffc097          	auipc	ra,0xffffc
    8000497c:	2c0080e7          	jalr	704(ra) # 80000c38 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004980:	02c92603          	lw	a2,44(s2)
    80004984:	47f5                	li	a5,29
    80004986:	06c7c563          	blt	a5,a2,800049f0 <log_write+0x90>
    8000498a:	00047797          	auipc	a5,0x47
    8000498e:	f727a783          	lw	a5,-142(a5) # 8004b8fc <log+0x1c>
    80004992:	37fd                	addiw	a5,a5,-1
    80004994:	04f65e63          	bge	a2,a5,800049f0 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004998:	00047797          	auipc	a5,0x47
    8000499c:	f687a783          	lw	a5,-152(a5) # 8004b900 <log+0x20>
    800049a0:	06f05063          	blez	a5,80004a00 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800049a4:	4781                	li	a5,0
    800049a6:	06c05563          	blez	a2,80004a10 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    800049aa:	44cc                	lw	a1,12(s1)
    800049ac:	00047717          	auipc	a4,0x47
    800049b0:	f6470713          	addi	a4,a4,-156 # 8004b910 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    800049b4:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    800049b6:	4314                	lw	a3,0(a4)
    800049b8:	04b68c63          	beq	a3,a1,80004a10 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    800049bc:	2785                	addiw	a5,a5,1
    800049be:	0711                	addi	a4,a4,4
    800049c0:	fef61be3          	bne	a2,a5,800049b6 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    800049c4:	0621                	addi	a2,a2,8
    800049c6:	060a                	slli	a2,a2,0x2
    800049c8:	00047797          	auipc	a5,0x47
    800049cc:	f1878793          	addi	a5,a5,-232 # 8004b8e0 <log>
    800049d0:	97b2                	add	a5,a5,a2
    800049d2:	44d8                	lw	a4,12(s1)
    800049d4:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    800049d6:	8526                	mv	a0,s1
    800049d8:	fffff097          	auipc	ra,0xfffff
    800049dc:	d7a080e7          	jalr	-646(ra) # 80003752 <bpin>
    log.lh.n++;
    800049e0:	00047717          	auipc	a4,0x47
    800049e4:	f0070713          	addi	a4,a4,-256 # 8004b8e0 <log>
    800049e8:	575c                	lw	a5,44(a4)
    800049ea:	2785                	addiw	a5,a5,1
    800049ec:	d75c                	sw	a5,44(a4)
    800049ee:	a82d                	j	80004a28 <log_write+0xc8>
    panic("too big a transaction");
    800049f0:	00004517          	auipc	a0,0x4
    800049f4:	cc850513          	addi	a0,a0,-824 # 800086b8 <etext+0x6b8>
    800049f8:	ffffc097          	auipc	ra,0xffffc
    800049fc:	b68080e7          	jalr	-1176(ra) # 80000560 <panic>
    panic("log_write outside of trans");
    80004a00:	00004517          	auipc	a0,0x4
    80004a04:	cd050513          	addi	a0,a0,-816 # 800086d0 <etext+0x6d0>
    80004a08:	ffffc097          	auipc	ra,0xffffc
    80004a0c:	b58080e7          	jalr	-1192(ra) # 80000560 <panic>
  log.lh.block[i] = b->blockno;
    80004a10:	00878693          	addi	a3,a5,8
    80004a14:	068a                	slli	a3,a3,0x2
    80004a16:	00047717          	auipc	a4,0x47
    80004a1a:	eca70713          	addi	a4,a4,-310 # 8004b8e0 <log>
    80004a1e:	9736                	add	a4,a4,a3
    80004a20:	44d4                	lw	a3,12(s1)
    80004a22:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004a24:	faf609e3          	beq	a2,a5,800049d6 <log_write+0x76>
  }
  release(&log.lock);
    80004a28:	00047517          	auipc	a0,0x47
    80004a2c:	eb850513          	addi	a0,a0,-328 # 8004b8e0 <log>
    80004a30:	ffffc097          	auipc	ra,0xffffc
    80004a34:	2bc080e7          	jalr	700(ra) # 80000cec <release>
}
    80004a38:	60e2                	ld	ra,24(sp)
    80004a3a:	6442                	ld	s0,16(sp)
    80004a3c:	64a2                	ld	s1,8(sp)
    80004a3e:	6902                	ld	s2,0(sp)
    80004a40:	6105                	addi	sp,sp,32
    80004a42:	8082                	ret

0000000080004a44 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004a44:	1101                	addi	sp,sp,-32
    80004a46:	ec06                	sd	ra,24(sp)
    80004a48:	e822                	sd	s0,16(sp)
    80004a4a:	e426                	sd	s1,8(sp)
    80004a4c:	e04a                	sd	s2,0(sp)
    80004a4e:	1000                	addi	s0,sp,32
    80004a50:	84aa                	mv	s1,a0
    80004a52:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004a54:	00004597          	auipc	a1,0x4
    80004a58:	c9c58593          	addi	a1,a1,-868 # 800086f0 <etext+0x6f0>
    80004a5c:	0521                	addi	a0,a0,8
    80004a5e:	ffffc097          	auipc	ra,0xffffc
    80004a62:	14a080e7          	jalr	330(ra) # 80000ba8 <initlock>
  lk->name = name;
    80004a66:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004a6a:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004a6e:	0204a423          	sw	zero,40(s1)
}
    80004a72:	60e2                	ld	ra,24(sp)
    80004a74:	6442                	ld	s0,16(sp)
    80004a76:	64a2                	ld	s1,8(sp)
    80004a78:	6902                	ld	s2,0(sp)
    80004a7a:	6105                	addi	sp,sp,32
    80004a7c:	8082                	ret

0000000080004a7e <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004a7e:	1101                	addi	sp,sp,-32
    80004a80:	ec06                	sd	ra,24(sp)
    80004a82:	e822                	sd	s0,16(sp)
    80004a84:	e426                	sd	s1,8(sp)
    80004a86:	e04a                	sd	s2,0(sp)
    80004a88:	1000                	addi	s0,sp,32
    80004a8a:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004a8c:	00850913          	addi	s2,a0,8
    80004a90:	854a                	mv	a0,s2
    80004a92:	ffffc097          	auipc	ra,0xffffc
    80004a96:	1a6080e7          	jalr	422(ra) # 80000c38 <acquire>
  while (lk->locked) {
    80004a9a:	409c                	lw	a5,0(s1)
    80004a9c:	cb89                	beqz	a5,80004aae <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004a9e:	85ca                	mv	a1,s2
    80004aa0:	8526                	mv	a0,s1
    80004aa2:	ffffd097          	auipc	ra,0xffffd
    80004aa6:	7f2080e7          	jalr	2034(ra) # 80002294 <sleep>
  while (lk->locked) {
    80004aaa:	409c                	lw	a5,0(s1)
    80004aac:	fbed                	bnez	a5,80004a9e <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004aae:	4785                	li	a5,1
    80004ab0:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004ab2:	ffffd097          	auipc	ra,0xffffd
    80004ab6:	078080e7          	jalr	120(ra) # 80001b2a <myproc>
    80004aba:	591c                	lw	a5,48(a0)
    80004abc:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004abe:	854a                	mv	a0,s2
    80004ac0:	ffffc097          	auipc	ra,0xffffc
    80004ac4:	22c080e7          	jalr	556(ra) # 80000cec <release>
}
    80004ac8:	60e2                	ld	ra,24(sp)
    80004aca:	6442                	ld	s0,16(sp)
    80004acc:	64a2                	ld	s1,8(sp)
    80004ace:	6902                	ld	s2,0(sp)
    80004ad0:	6105                	addi	sp,sp,32
    80004ad2:	8082                	ret

0000000080004ad4 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004ad4:	1101                	addi	sp,sp,-32
    80004ad6:	ec06                	sd	ra,24(sp)
    80004ad8:	e822                	sd	s0,16(sp)
    80004ada:	e426                	sd	s1,8(sp)
    80004adc:	e04a                	sd	s2,0(sp)
    80004ade:	1000                	addi	s0,sp,32
    80004ae0:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004ae2:	00850913          	addi	s2,a0,8
    80004ae6:	854a                	mv	a0,s2
    80004ae8:	ffffc097          	auipc	ra,0xffffc
    80004aec:	150080e7          	jalr	336(ra) # 80000c38 <acquire>
  lk->locked = 0;
    80004af0:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004af4:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004af8:	8526                	mv	a0,s1
    80004afa:	ffffd097          	auipc	ra,0xffffd
    80004afe:	7fe080e7          	jalr	2046(ra) # 800022f8 <wakeup>
  release(&lk->lk);
    80004b02:	854a                	mv	a0,s2
    80004b04:	ffffc097          	auipc	ra,0xffffc
    80004b08:	1e8080e7          	jalr	488(ra) # 80000cec <release>
}
    80004b0c:	60e2                	ld	ra,24(sp)
    80004b0e:	6442                	ld	s0,16(sp)
    80004b10:	64a2                	ld	s1,8(sp)
    80004b12:	6902                	ld	s2,0(sp)
    80004b14:	6105                	addi	sp,sp,32
    80004b16:	8082                	ret

0000000080004b18 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004b18:	7179                	addi	sp,sp,-48
    80004b1a:	f406                	sd	ra,40(sp)
    80004b1c:	f022                	sd	s0,32(sp)
    80004b1e:	ec26                	sd	s1,24(sp)
    80004b20:	e84a                	sd	s2,16(sp)
    80004b22:	1800                	addi	s0,sp,48
    80004b24:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004b26:	00850913          	addi	s2,a0,8
    80004b2a:	854a                	mv	a0,s2
    80004b2c:	ffffc097          	auipc	ra,0xffffc
    80004b30:	10c080e7          	jalr	268(ra) # 80000c38 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004b34:	409c                	lw	a5,0(s1)
    80004b36:	ef91                	bnez	a5,80004b52 <holdingsleep+0x3a>
    80004b38:	4481                	li	s1,0
  release(&lk->lk);
    80004b3a:	854a                	mv	a0,s2
    80004b3c:	ffffc097          	auipc	ra,0xffffc
    80004b40:	1b0080e7          	jalr	432(ra) # 80000cec <release>
  return r;
}
    80004b44:	8526                	mv	a0,s1
    80004b46:	70a2                	ld	ra,40(sp)
    80004b48:	7402                	ld	s0,32(sp)
    80004b4a:	64e2                	ld	s1,24(sp)
    80004b4c:	6942                	ld	s2,16(sp)
    80004b4e:	6145                	addi	sp,sp,48
    80004b50:	8082                	ret
    80004b52:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    80004b54:	0284a983          	lw	s3,40(s1)
    80004b58:	ffffd097          	auipc	ra,0xffffd
    80004b5c:	fd2080e7          	jalr	-46(ra) # 80001b2a <myproc>
    80004b60:	5904                	lw	s1,48(a0)
    80004b62:	413484b3          	sub	s1,s1,s3
    80004b66:	0014b493          	seqz	s1,s1
    80004b6a:	69a2                	ld	s3,8(sp)
    80004b6c:	b7f9                	j	80004b3a <holdingsleep+0x22>

0000000080004b6e <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004b6e:	1141                	addi	sp,sp,-16
    80004b70:	e406                	sd	ra,8(sp)
    80004b72:	e022                	sd	s0,0(sp)
    80004b74:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004b76:	00004597          	auipc	a1,0x4
    80004b7a:	b8a58593          	addi	a1,a1,-1142 # 80008700 <etext+0x700>
    80004b7e:	00047517          	auipc	a0,0x47
    80004b82:	eaa50513          	addi	a0,a0,-342 # 8004ba28 <ftable>
    80004b86:	ffffc097          	auipc	ra,0xffffc
    80004b8a:	022080e7          	jalr	34(ra) # 80000ba8 <initlock>
}
    80004b8e:	60a2                	ld	ra,8(sp)
    80004b90:	6402                	ld	s0,0(sp)
    80004b92:	0141                	addi	sp,sp,16
    80004b94:	8082                	ret

0000000080004b96 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004b96:	1101                	addi	sp,sp,-32
    80004b98:	ec06                	sd	ra,24(sp)
    80004b9a:	e822                	sd	s0,16(sp)
    80004b9c:	e426                	sd	s1,8(sp)
    80004b9e:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004ba0:	00047517          	auipc	a0,0x47
    80004ba4:	e8850513          	addi	a0,a0,-376 # 8004ba28 <ftable>
    80004ba8:	ffffc097          	auipc	ra,0xffffc
    80004bac:	090080e7          	jalr	144(ra) # 80000c38 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004bb0:	00047497          	auipc	s1,0x47
    80004bb4:	e9048493          	addi	s1,s1,-368 # 8004ba40 <ftable+0x18>
    80004bb8:	00048717          	auipc	a4,0x48
    80004bbc:	e2870713          	addi	a4,a4,-472 # 8004c9e0 <disk>
    if(f->ref == 0){
    80004bc0:	40dc                	lw	a5,4(s1)
    80004bc2:	cf99                	beqz	a5,80004be0 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004bc4:	02848493          	addi	s1,s1,40
    80004bc8:	fee49ce3          	bne	s1,a4,80004bc0 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004bcc:	00047517          	auipc	a0,0x47
    80004bd0:	e5c50513          	addi	a0,a0,-420 # 8004ba28 <ftable>
    80004bd4:	ffffc097          	auipc	ra,0xffffc
    80004bd8:	118080e7          	jalr	280(ra) # 80000cec <release>
  return 0;
    80004bdc:	4481                	li	s1,0
    80004bde:	a819                	j	80004bf4 <filealloc+0x5e>
      f->ref = 1;
    80004be0:	4785                	li	a5,1
    80004be2:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004be4:	00047517          	auipc	a0,0x47
    80004be8:	e4450513          	addi	a0,a0,-444 # 8004ba28 <ftable>
    80004bec:	ffffc097          	auipc	ra,0xffffc
    80004bf0:	100080e7          	jalr	256(ra) # 80000cec <release>
}
    80004bf4:	8526                	mv	a0,s1
    80004bf6:	60e2                	ld	ra,24(sp)
    80004bf8:	6442                	ld	s0,16(sp)
    80004bfa:	64a2                	ld	s1,8(sp)
    80004bfc:	6105                	addi	sp,sp,32
    80004bfe:	8082                	ret

0000000080004c00 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004c00:	1101                	addi	sp,sp,-32
    80004c02:	ec06                	sd	ra,24(sp)
    80004c04:	e822                	sd	s0,16(sp)
    80004c06:	e426                	sd	s1,8(sp)
    80004c08:	1000                	addi	s0,sp,32
    80004c0a:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004c0c:	00047517          	auipc	a0,0x47
    80004c10:	e1c50513          	addi	a0,a0,-484 # 8004ba28 <ftable>
    80004c14:	ffffc097          	auipc	ra,0xffffc
    80004c18:	024080e7          	jalr	36(ra) # 80000c38 <acquire>
  if(f->ref < 1)
    80004c1c:	40dc                	lw	a5,4(s1)
    80004c1e:	02f05263          	blez	a5,80004c42 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004c22:	2785                	addiw	a5,a5,1
    80004c24:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004c26:	00047517          	auipc	a0,0x47
    80004c2a:	e0250513          	addi	a0,a0,-510 # 8004ba28 <ftable>
    80004c2e:	ffffc097          	auipc	ra,0xffffc
    80004c32:	0be080e7          	jalr	190(ra) # 80000cec <release>
  return f;
}
    80004c36:	8526                	mv	a0,s1
    80004c38:	60e2                	ld	ra,24(sp)
    80004c3a:	6442                	ld	s0,16(sp)
    80004c3c:	64a2                	ld	s1,8(sp)
    80004c3e:	6105                	addi	sp,sp,32
    80004c40:	8082                	ret
    panic("filedup");
    80004c42:	00004517          	auipc	a0,0x4
    80004c46:	ac650513          	addi	a0,a0,-1338 # 80008708 <etext+0x708>
    80004c4a:	ffffc097          	auipc	ra,0xffffc
    80004c4e:	916080e7          	jalr	-1770(ra) # 80000560 <panic>

0000000080004c52 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004c52:	7139                	addi	sp,sp,-64
    80004c54:	fc06                	sd	ra,56(sp)
    80004c56:	f822                	sd	s0,48(sp)
    80004c58:	f426                	sd	s1,40(sp)
    80004c5a:	0080                	addi	s0,sp,64
    80004c5c:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004c5e:	00047517          	auipc	a0,0x47
    80004c62:	dca50513          	addi	a0,a0,-566 # 8004ba28 <ftable>
    80004c66:	ffffc097          	auipc	ra,0xffffc
    80004c6a:	fd2080e7          	jalr	-46(ra) # 80000c38 <acquire>
  if(f->ref < 1)
    80004c6e:	40dc                	lw	a5,4(s1)
    80004c70:	04f05c63          	blez	a5,80004cc8 <fileclose+0x76>
    panic("fileclose");
  if(--f->ref > 0){
    80004c74:	37fd                	addiw	a5,a5,-1
    80004c76:	0007871b          	sext.w	a4,a5
    80004c7a:	c0dc                	sw	a5,4(s1)
    80004c7c:	06e04263          	bgtz	a4,80004ce0 <fileclose+0x8e>
    80004c80:	f04a                	sd	s2,32(sp)
    80004c82:	ec4e                	sd	s3,24(sp)
    80004c84:	e852                	sd	s4,16(sp)
    80004c86:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004c88:	0004a903          	lw	s2,0(s1)
    80004c8c:	0094ca83          	lbu	s5,9(s1)
    80004c90:	0104ba03          	ld	s4,16(s1)
    80004c94:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004c98:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004c9c:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004ca0:	00047517          	auipc	a0,0x47
    80004ca4:	d8850513          	addi	a0,a0,-632 # 8004ba28 <ftable>
    80004ca8:	ffffc097          	auipc	ra,0xffffc
    80004cac:	044080e7          	jalr	68(ra) # 80000cec <release>

  if(ff.type == FD_PIPE){
    80004cb0:	4785                	li	a5,1
    80004cb2:	04f90463          	beq	s2,a5,80004cfa <fileclose+0xa8>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004cb6:	3979                	addiw	s2,s2,-2
    80004cb8:	4785                	li	a5,1
    80004cba:	0527fb63          	bgeu	a5,s2,80004d10 <fileclose+0xbe>
    80004cbe:	7902                	ld	s2,32(sp)
    80004cc0:	69e2                	ld	s3,24(sp)
    80004cc2:	6a42                	ld	s4,16(sp)
    80004cc4:	6aa2                	ld	s5,8(sp)
    80004cc6:	a02d                	j	80004cf0 <fileclose+0x9e>
    80004cc8:	f04a                	sd	s2,32(sp)
    80004cca:	ec4e                	sd	s3,24(sp)
    80004ccc:	e852                	sd	s4,16(sp)
    80004cce:	e456                	sd	s5,8(sp)
    panic("fileclose");
    80004cd0:	00004517          	auipc	a0,0x4
    80004cd4:	a4050513          	addi	a0,a0,-1472 # 80008710 <etext+0x710>
    80004cd8:	ffffc097          	auipc	ra,0xffffc
    80004cdc:	888080e7          	jalr	-1912(ra) # 80000560 <panic>
    release(&ftable.lock);
    80004ce0:	00047517          	auipc	a0,0x47
    80004ce4:	d4850513          	addi	a0,a0,-696 # 8004ba28 <ftable>
    80004ce8:	ffffc097          	auipc	ra,0xffffc
    80004cec:	004080e7          	jalr	4(ra) # 80000cec <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    80004cf0:	70e2                	ld	ra,56(sp)
    80004cf2:	7442                	ld	s0,48(sp)
    80004cf4:	74a2                	ld	s1,40(sp)
    80004cf6:	6121                	addi	sp,sp,64
    80004cf8:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004cfa:	85d6                	mv	a1,s5
    80004cfc:	8552                	mv	a0,s4
    80004cfe:	00000097          	auipc	ra,0x0
    80004d02:	3a2080e7          	jalr	930(ra) # 800050a0 <pipeclose>
    80004d06:	7902                	ld	s2,32(sp)
    80004d08:	69e2                	ld	s3,24(sp)
    80004d0a:	6a42                	ld	s4,16(sp)
    80004d0c:	6aa2                	ld	s5,8(sp)
    80004d0e:	b7cd                	j	80004cf0 <fileclose+0x9e>
    begin_op();
    80004d10:	00000097          	auipc	ra,0x0
    80004d14:	a78080e7          	jalr	-1416(ra) # 80004788 <begin_op>
    iput(ff.ip);
    80004d18:	854e                	mv	a0,s3
    80004d1a:	fffff097          	auipc	ra,0xfffff
    80004d1e:	25e080e7          	jalr	606(ra) # 80003f78 <iput>
    end_op();
    80004d22:	00000097          	auipc	ra,0x0
    80004d26:	ae0080e7          	jalr	-1312(ra) # 80004802 <end_op>
    80004d2a:	7902                	ld	s2,32(sp)
    80004d2c:	69e2                	ld	s3,24(sp)
    80004d2e:	6a42                	ld	s4,16(sp)
    80004d30:	6aa2                	ld	s5,8(sp)
    80004d32:	bf7d                	j	80004cf0 <fileclose+0x9e>

0000000080004d34 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004d34:	715d                	addi	sp,sp,-80
    80004d36:	e486                	sd	ra,72(sp)
    80004d38:	e0a2                	sd	s0,64(sp)
    80004d3a:	fc26                	sd	s1,56(sp)
    80004d3c:	f44e                	sd	s3,40(sp)
    80004d3e:	0880                	addi	s0,sp,80
    80004d40:	84aa                	mv	s1,a0
    80004d42:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004d44:	ffffd097          	auipc	ra,0xffffd
    80004d48:	de6080e7          	jalr	-538(ra) # 80001b2a <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004d4c:	409c                	lw	a5,0(s1)
    80004d4e:	37f9                	addiw	a5,a5,-2
    80004d50:	4705                	li	a4,1
    80004d52:	04f76863          	bltu	a4,a5,80004da2 <filestat+0x6e>
    80004d56:	f84a                	sd	s2,48(sp)
    80004d58:	892a                	mv	s2,a0
    ilock(f->ip);
    80004d5a:	6c88                	ld	a0,24(s1)
    80004d5c:	fffff097          	auipc	ra,0xfffff
    80004d60:	05e080e7          	jalr	94(ra) # 80003dba <ilock>
    stati(f->ip, &st);
    80004d64:	fb840593          	addi	a1,s0,-72
    80004d68:	6c88                	ld	a0,24(s1)
    80004d6a:	fffff097          	auipc	ra,0xfffff
    80004d6e:	2de080e7          	jalr	734(ra) # 80004048 <stati>
    iunlock(f->ip);
    80004d72:	6c88                	ld	a0,24(s1)
    80004d74:	fffff097          	auipc	ra,0xfffff
    80004d78:	10c080e7          	jalr	268(ra) # 80003e80 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004d7c:	46e1                	li	a3,24
    80004d7e:	fb840613          	addi	a2,s0,-72
    80004d82:	85ce                	mv	a1,s3
    80004d84:	05093503          	ld	a0,80(s2)
    80004d88:	ffffd097          	auipc	ra,0xffffd
    80004d8c:	95a080e7          	jalr	-1702(ra) # 800016e2 <copyout>
    80004d90:	41f5551b          	sraiw	a0,a0,0x1f
    80004d94:	7942                	ld	s2,48(sp)
      return -1;
    return 0;
  }
  return -1;
}
    80004d96:	60a6                	ld	ra,72(sp)
    80004d98:	6406                	ld	s0,64(sp)
    80004d9a:	74e2                	ld	s1,56(sp)
    80004d9c:	79a2                	ld	s3,40(sp)
    80004d9e:	6161                	addi	sp,sp,80
    80004da0:	8082                	ret
  return -1;
    80004da2:	557d                	li	a0,-1
    80004da4:	bfcd                	j	80004d96 <filestat+0x62>

0000000080004da6 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004da6:	7179                	addi	sp,sp,-48
    80004da8:	f406                	sd	ra,40(sp)
    80004daa:	f022                	sd	s0,32(sp)
    80004dac:	e84a                	sd	s2,16(sp)
    80004dae:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004db0:	00854783          	lbu	a5,8(a0)
    80004db4:	cbc5                	beqz	a5,80004e64 <fileread+0xbe>
    80004db6:	ec26                	sd	s1,24(sp)
    80004db8:	e44e                	sd	s3,8(sp)
    80004dba:	84aa                	mv	s1,a0
    80004dbc:	89ae                	mv	s3,a1
    80004dbe:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004dc0:	411c                	lw	a5,0(a0)
    80004dc2:	4705                	li	a4,1
    80004dc4:	04e78963          	beq	a5,a4,80004e16 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004dc8:	470d                	li	a4,3
    80004dca:	04e78f63          	beq	a5,a4,80004e28 <fileread+0x82>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004dce:	4709                	li	a4,2
    80004dd0:	08e79263          	bne	a5,a4,80004e54 <fileread+0xae>
    ilock(f->ip);
    80004dd4:	6d08                	ld	a0,24(a0)
    80004dd6:	fffff097          	auipc	ra,0xfffff
    80004dda:	fe4080e7          	jalr	-28(ra) # 80003dba <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004dde:	874a                	mv	a4,s2
    80004de0:	5094                	lw	a3,32(s1)
    80004de2:	864e                	mv	a2,s3
    80004de4:	4585                	li	a1,1
    80004de6:	6c88                	ld	a0,24(s1)
    80004de8:	fffff097          	auipc	ra,0xfffff
    80004dec:	28a080e7          	jalr	650(ra) # 80004072 <readi>
    80004df0:	892a                	mv	s2,a0
    80004df2:	00a05563          	blez	a0,80004dfc <fileread+0x56>
      f->off += r;
    80004df6:	509c                	lw	a5,32(s1)
    80004df8:	9fa9                	addw	a5,a5,a0
    80004dfa:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004dfc:	6c88                	ld	a0,24(s1)
    80004dfe:	fffff097          	auipc	ra,0xfffff
    80004e02:	082080e7          	jalr	130(ra) # 80003e80 <iunlock>
    80004e06:	64e2                	ld	s1,24(sp)
    80004e08:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    80004e0a:	854a                	mv	a0,s2
    80004e0c:	70a2                	ld	ra,40(sp)
    80004e0e:	7402                	ld	s0,32(sp)
    80004e10:	6942                	ld	s2,16(sp)
    80004e12:	6145                	addi	sp,sp,48
    80004e14:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004e16:	6908                	ld	a0,16(a0)
    80004e18:	00000097          	auipc	ra,0x0
    80004e1c:	400080e7          	jalr	1024(ra) # 80005218 <piperead>
    80004e20:	892a                	mv	s2,a0
    80004e22:	64e2                	ld	s1,24(sp)
    80004e24:	69a2                	ld	s3,8(sp)
    80004e26:	b7d5                	j	80004e0a <fileread+0x64>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004e28:	02451783          	lh	a5,36(a0)
    80004e2c:	03079693          	slli	a3,a5,0x30
    80004e30:	92c1                	srli	a3,a3,0x30
    80004e32:	4725                	li	a4,9
    80004e34:	02d76a63          	bltu	a4,a3,80004e68 <fileread+0xc2>
    80004e38:	0792                	slli	a5,a5,0x4
    80004e3a:	00047717          	auipc	a4,0x47
    80004e3e:	b4e70713          	addi	a4,a4,-1202 # 8004b988 <devsw>
    80004e42:	97ba                	add	a5,a5,a4
    80004e44:	639c                	ld	a5,0(a5)
    80004e46:	c78d                	beqz	a5,80004e70 <fileread+0xca>
    r = devsw[f->major].read(1, addr, n);
    80004e48:	4505                	li	a0,1
    80004e4a:	9782                	jalr	a5
    80004e4c:	892a                	mv	s2,a0
    80004e4e:	64e2                	ld	s1,24(sp)
    80004e50:	69a2                	ld	s3,8(sp)
    80004e52:	bf65                	j	80004e0a <fileread+0x64>
    panic("fileread");
    80004e54:	00004517          	auipc	a0,0x4
    80004e58:	8cc50513          	addi	a0,a0,-1844 # 80008720 <etext+0x720>
    80004e5c:	ffffb097          	auipc	ra,0xffffb
    80004e60:	704080e7          	jalr	1796(ra) # 80000560 <panic>
    return -1;
    80004e64:	597d                	li	s2,-1
    80004e66:	b755                	j	80004e0a <fileread+0x64>
      return -1;
    80004e68:	597d                	li	s2,-1
    80004e6a:	64e2                	ld	s1,24(sp)
    80004e6c:	69a2                	ld	s3,8(sp)
    80004e6e:	bf71                	j	80004e0a <fileread+0x64>
    80004e70:	597d                	li	s2,-1
    80004e72:	64e2                	ld	s1,24(sp)
    80004e74:	69a2                	ld	s3,8(sp)
    80004e76:	bf51                	j	80004e0a <fileread+0x64>

0000000080004e78 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80004e78:	00954783          	lbu	a5,9(a0)
    80004e7c:	12078963          	beqz	a5,80004fae <filewrite+0x136>
{
    80004e80:	715d                	addi	sp,sp,-80
    80004e82:	e486                	sd	ra,72(sp)
    80004e84:	e0a2                	sd	s0,64(sp)
    80004e86:	f84a                	sd	s2,48(sp)
    80004e88:	f052                	sd	s4,32(sp)
    80004e8a:	e85a                	sd	s6,16(sp)
    80004e8c:	0880                	addi	s0,sp,80
    80004e8e:	892a                	mv	s2,a0
    80004e90:	8b2e                	mv	s6,a1
    80004e92:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004e94:	411c                	lw	a5,0(a0)
    80004e96:	4705                	li	a4,1
    80004e98:	02e78763          	beq	a5,a4,80004ec6 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004e9c:	470d                	li	a4,3
    80004e9e:	02e78a63          	beq	a5,a4,80004ed2 <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004ea2:	4709                	li	a4,2
    80004ea4:	0ee79863          	bne	a5,a4,80004f94 <filewrite+0x11c>
    80004ea8:	f44e                	sd	s3,40(sp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004eaa:	0cc05463          	blez	a2,80004f72 <filewrite+0xfa>
    80004eae:	fc26                	sd	s1,56(sp)
    80004eb0:	ec56                	sd	s5,24(sp)
    80004eb2:	e45e                	sd	s7,8(sp)
    80004eb4:	e062                	sd	s8,0(sp)
    int i = 0;
    80004eb6:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    80004eb8:	6b85                	lui	s7,0x1
    80004eba:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004ebe:	6c05                	lui	s8,0x1
    80004ec0:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80004ec4:	a851                	j	80004f58 <filewrite+0xe0>
    ret = pipewrite(f->pipe, addr, n);
    80004ec6:	6908                	ld	a0,16(a0)
    80004ec8:	00000097          	auipc	ra,0x0
    80004ecc:	248080e7          	jalr	584(ra) # 80005110 <pipewrite>
    80004ed0:	a85d                	j	80004f86 <filewrite+0x10e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004ed2:	02451783          	lh	a5,36(a0)
    80004ed6:	03079693          	slli	a3,a5,0x30
    80004eda:	92c1                	srli	a3,a3,0x30
    80004edc:	4725                	li	a4,9
    80004ede:	0cd76a63          	bltu	a4,a3,80004fb2 <filewrite+0x13a>
    80004ee2:	0792                	slli	a5,a5,0x4
    80004ee4:	00047717          	auipc	a4,0x47
    80004ee8:	aa470713          	addi	a4,a4,-1372 # 8004b988 <devsw>
    80004eec:	97ba                	add	a5,a5,a4
    80004eee:	679c                	ld	a5,8(a5)
    80004ef0:	c3f9                	beqz	a5,80004fb6 <filewrite+0x13e>
    ret = devsw[f->major].write(1, addr, n);
    80004ef2:	4505                	li	a0,1
    80004ef4:	9782                	jalr	a5
    80004ef6:	a841                	j	80004f86 <filewrite+0x10e>
      if(n1 > max)
    80004ef8:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    80004efc:	00000097          	auipc	ra,0x0
    80004f00:	88c080e7          	jalr	-1908(ra) # 80004788 <begin_op>
      ilock(f->ip);
    80004f04:	01893503          	ld	a0,24(s2)
    80004f08:	fffff097          	auipc	ra,0xfffff
    80004f0c:	eb2080e7          	jalr	-334(ra) # 80003dba <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004f10:	8756                	mv	a4,s5
    80004f12:	02092683          	lw	a3,32(s2)
    80004f16:	01698633          	add	a2,s3,s6
    80004f1a:	4585                	li	a1,1
    80004f1c:	01893503          	ld	a0,24(s2)
    80004f20:	fffff097          	auipc	ra,0xfffff
    80004f24:	262080e7          	jalr	610(ra) # 80004182 <writei>
    80004f28:	84aa                	mv	s1,a0
    80004f2a:	00a05763          	blez	a0,80004f38 <filewrite+0xc0>
        f->off += r;
    80004f2e:	02092783          	lw	a5,32(s2)
    80004f32:	9fa9                	addw	a5,a5,a0
    80004f34:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004f38:	01893503          	ld	a0,24(s2)
    80004f3c:	fffff097          	auipc	ra,0xfffff
    80004f40:	f44080e7          	jalr	-188(ra) # 80003e80 <iunlock>
      end_op();
    80004f44:	00000097          	auipc	ra,0x0
    80004f48:	8be080e7          	jalr	-1858(ra) # 80004802 <end_op>

      if(r != n1){
    80004f4c:	029a9563          	bne	s5,s1,80004f76 <filewrite+0xfe>
        // error from writei
        break;
      }
      i += r;
    80004f50:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004f54:	0149da63          	bge	s3,s4,80004f68 <filewrite+0xf0>
      int n1 = n - i;
    80004f58:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    80004f5c:	0004879b          	sext.w	a5,s1
    80004f60:	f8fbdce3          	bge	s7,a5,80004ef8 <filewrite+0x80>
    80004f64:	84e2                	mv	s1,s8
    80004f66:	bf49                	j	80004ef8 <filewrite+0x80>
    80004f68:	74e2                	ld	s1,56(sp)
    80004f6a:	6ae2                	ld	s5,24(sp)
    80004f6c:	6ba2                	ld	s7,8(sp)
    80004f6e:	6c02                	ld	s8,0(sp)
    80004f70:	a039                	j	80004f7e <filewrite+0x106>
    int i = 0;
    80004f72:	4981                	li	s3,0
    80004f74:	a029                	j	80004f7e <filewrite+0x106>
    80004f76:	74e2                	ld	s1,56(sp)
    80004f78:	6ae2                	ld	s5,24(sp)
    80004f7a:	6ba2                	ld	s7,8(sp)
    80004f7c:	6c02                	ld	s8,0(sp)
    }
    ret = (i == n ? n : -1);
    80004f7e:	033a1e63          	bne	s4,s3,80004fba <filewrite+0x142>
    80004f82:	8552                	mv	a0,s4
    80004f84:	79a2                	ld	s3,40(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004f86:	60a6                	ld	ra,72(sp)
    80004f88:	6406                	ld	s0,64(sp)
    80004f8a:	7942                	ld	s2,48(sp)
    80004f8c:	7a02                	ld	s4,32(sp)
    80004f8e:	6b42                	ld	s6,16(sp)
    80004f90:	6161                	addi	sp,sp,80
    80004f92:	8082                	ret
    80004f94:	fc26                	sd	s1,56(sp)
    80004f96:	f44e                	sd	s3,40(sp)
    80004f98:	ec56                	sd	s5,24(sp)
    80004f9a:	e45e                	sd	s7,8(sp)
    80004f9c:	e062                	sd	s8,0(sp)
    panic("filewrite");
    80004f9e:	00003517          	auipc	a0,0x3
    80004fa2:	79250513          	addi	a0,a0,1938 # 80008730 <etext+0x730>
    80004fa6:	ffffb097          	auipc	ra,0xffffb
    80004faa:	5ba080e7          	jalr	1466(ra) # 80000560 <panic>
    return -1;
    80004fae:	557d                	li	a0,-1
}
    80004fb0:	8082                	ret
      return -1;
    80004fb2:	557d                	li	a0,-1
    80004fb4:	bfc9                	j	80004f86 <filewrite+0x10e>
    80004fb6:	557d                	li	a0,-1
    80004fb8:	b7f9                	j	80004f86 <filewrite+0x10e>
    ret = (i == n ? n : -1);
    80004fba:	557d                	li	a0,-1
    80004fbc:	79a2                	ld	s3,40(sp)
    80004fbe:	b7e1                	j	80004f86 <filewrite+0x10e>

0000000080004fc0 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004fc0:	7179                	addi	sp,sp,-48
    80004fc2:	f406                	sd	ra,40(sp)
    80004fc4:	f022                	sd	s0,32(sp)
    80004fc6:	ec26                	sd	s1,24(sp)
    80004fc8:	e052                	sd	s4,0(sp)
    80004fca:	1800                	addi	s0,sp,48
    80004fcc:	84aa                	mv	s1,a0
    80004fce:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004fd0:	0005b023          	sd	zero,0(a1)
    80004fd4:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004fd8:	00000097          	auipc	ra,0x0
    80004fdc:	bbe080e7          	jalr	-1090(ra) # 80004b96 <filealloc>
    80004fe0:	e088                	sd	a0,0(s1)
    80004fe2:	cd49                	beqz	a0,8000507c <pipealloc+0xbc>
    80004fe4:	00000097          	auipc	ra,0x0
    80004fe8:	bb2080e7          	jalr	-1102(ra) # 80004b96 <filealloc>
    80004fec:	00aa3023          	sd	a0,0(s4)
    80004ff0:	c141                	beqz	a0,80005070 <pipealloc+0xb0>
    80004ff2:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004ff4:	ffffc097          	auipc	ra,0xffffc
    80004ff8:	b54080e7          	jalr	-1196(ra) # 80000b48 <kalloc>
    80004ffc:	892a                	mv	s2,a0
    80004ffe:	c13d                	beqz	a0,80005064 <pipealloc+0xa4>
    80005000:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    80005002:	4985                	li	s3,1
    80005004:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80005008:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    8000500c:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80005010:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80005014:	00003597          	auipc	a1,0x3
    80005018:	48458593          	addi	a1,a1,1156 # 80008498 <etext+0x498>
    8000501c:	ffffc097          	auipc	ra,0xffffc
    80005020:	b8c080e7          	jalr	-1140(ra) # 80000ba8 <initlock>
  (*f0)->type = FD_PIPE;
    80005024:	609c                	ld	a5,0(s1)
    80005026:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    8000502a:	609c                	ld	a5,0(s1)
    8000502c:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80005030:	609c                	ld	a5,0(s1)
    80005032:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80005036:	609c                	ld	a5,0(s1)
    80005038:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    8000503c:	000a3783          	ld	a5,0(s4)
    80005040:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80005044:	000a3783          	ld	a5,0(s4)
    80005048:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    8000504c:	000a3783          	ld	a5,0(s4)
    80005050:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80005054:	000a3783          	ld	a5,0(s4)
    80005058:	0127b823          	sd	s2,16(a5)
  return 0;
    8000505c:	4501                	li	a0,0
    8000505e:	6942                	ld	s2,16(sp)
    80005060:	69a2                	ld	s3,8(sp)
    80005062:	a03d                	j	80005090 <pipealloc+0xd0>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80005064:	6088                	ld	a0,0(s1)
    80005066:	c119                	beqz	a0,8000506c <pipealloc+0xac>
    80005068:	6942                	ld	s2,16(sp)
    8000506a:	a029                	j	80005074 <pipealloc+0xb4>
    8000506c:	6942                	ld	s2,16(sp)
    8000506e:	a039                	j	8000507c <pipealloc+0xbc>
    80005070:	6088                	ld	a0,0(s1)
    80005072:	c50d                	beqz	a0,8000509c <pipealloc+0xdc>
    fileclose(*f0);
    80005074:	00000097          	auipc	ra,0x0
    80005078:	bde080e7          	jalr	-1058(ra) # 80004c52 <fileclose>
  if(*f1)
    8000507c:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80005080:	557d                	li	a0,-1
  if(*f1)
    80005082:	c799                	beqz	a5,80005090 <pipealloc+0xd0>
    fileclose(*f1);
    80005084:	853e                	mv	a0,a5
    80005086:	00000097          	auipc	ra,0x0
    8000508a:	bcc080e7          	jalr	-1076(ra) # 80004c52 <fileclose>
  return -1;
    8000508e:	557d                	li	a0,-1
}
    80005090:	70a2                	ld	ra,40(sp)
    80005092:	7402                	ld	s0,32(sp)
    80005094:	64e2                	ld	s1,24(sp)
    80005096:	6a02                	ld	s4,0(sp)
    80005098:	6145                	addi	sp,sp,48
    8000509a:	8082                	ret
  return -1;
    8000509c:	557d                	li	a0,-1
    8000509e:	bfcd                	j	80005090 <pipealloc+0xd0>

00000000800050a0 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    800050a0:	1101                	addi	sp,sp,-32
    800050a2:	ec06                	sd	ra,24(sp)
    800050a4:	e822                	sd	s0,16(sp)
    800050a6:	e426                	sd	s1,8(sp)
    800050a8:	e04a                	sd	s2,0(sp)
    800050aa:	1000                	addi	s0,sp,32
    800050ac:	84aa                	mv	s1,a0
    800050ae:	892e                	mv	s2,a1
  acquire(&pi->lock);
    800050b0:	ffffc097          	auipc	ra,0xffffc
    800050b4:	b88080e7          	jalr	-1144(ra) # 80000c38 <acquire>
  if(writable){
    800050b8:	02090d63          	beqz	s2,800050f2 <pipeclose+0x52>
    pi->writeopen = 0;
    800050bc:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    800050c0:	21848513          	addi	a0,s1,536
    800050c4:	ffffd097          	auipc	ra,0xffffd
    800050c8:	234080e7          	jalr	564(ra) # 800022f8 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    800050cc:	2204b783          	ld	a5,544(s1)
    800050d0:	eb95                	bnez	a5,80005104 <pipeclose+0x64>
    release(&pi->lock);
    800050d2:	8526                	mv	a0,s1
    800050d4:	ffffc097          	auipc	ra,0xffffc
    800050d8:	c18080e7          	jalr	-1000(ra) # 80000cec <release>
    kfree((char*)pi);
    800050dc:	8526                	mv	a0,s1
    800050de:	ffffc097          	auipc	ra,0xffffc
    800050e2:	96c080e7          	jalr	-1684(ra) # 80000a4a <kfree>
  } else
    release(&pi->lock);
}
    800050e6:	60e2                	ld	ra,24(sp)
    800050e8:	6442                	ld	s0,16(sp)
    800050ea:	64a2                	ld	s1,8(sp)
    800050ec:	6902                	ld	s2,0(sp)
    800050ee:	6105                	addi	sp,sp,32
    800050f0:	8082                	ret
    pi->readopen = 0;
    800050f2:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    800050f6:	21c48513          	addi	a0,s1,540
    800050fa:	ffffd097          	auipc	ra,0xffffd
    800050fe:	1fe080e7          	jalr	510(ra) # 800022f8 <wakeup>
    80005102:	b7e9                	j	800050cc <pipeclose+0x2c>
    release(&pi->lock);
    80005104:	8526                	mv	a0,s1
    80005106:	ffffc097          	auipc	ra,0xffffc
    8000510a:	be6080e7          	jalr	-1050(ra) # 80000cec <release>
}
    8000510e:	bfe1                	j	800050e6 <pipeclose+0x46>

0000000080005110 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80005110:	711d                	addi	sp,sp,-96
    80005112:	ec86                	sd	ra,88(sp)
    80005114:	e8a2                	sd	s0,80(sp)
    80005116:	e4a6                	sd	s1,72(sp)
    80005118:	e0ca                	sd	s2,64(sp)
    8000511a:	fc4e                	sd	s3,56(sp)
    8000511c:	f852                	sd	s4,48(sp)
    8000511e:	f456                	sd	s5,40(sp)
    80005120:	1080                	addi	s0,sp,96
    80005122:	84aa                	mv	s1,a0
    80005124:	8aae                	mv	s5,a1
    80005126:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80005128:	ffffd097          	auipc	ra,0xffffd
    8000512c:	a02080e7          	jalr	-1534(ra) # 80001b2a <myproc>
    80005130:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80005132:	8526                	mv	a0,s1
    80005134:	ffffc097          	auipc	ra,0xffffc
    80005138:	b04080e7          	jalr	-1276(ra) # 80000c38 <acquire>
  while(i < n){
    8000513c:	0d405863          	blez	s4,8000520c <pipewrite+0xfc>
    80005140:	f05a                	sd	s6,32(sp)
    80005142:	ec5e                	sd	s7,24(sp)
    80005144:	e862                	sd	s8,16(sp)
  int i = 0;
    80005146:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005148:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    8000514a:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    8000514e:	21c48b93          	addi	s7,s1,540
    80005152:	a089                	j	80005194 <pipewrite+0x84>
      release(&pi->lock);
    80005154:	8526                	mv	a0,s1
    80005156:	ffffc097          	auipc	ra,0xffffc
    8000515a:	b96080e7          	jalr	-1130(ra) # 80000cec <release>
      return -1;
    8000515e:	597d                	li	s2,-1
    80005160:	7b02                	ld	s6,32(sp)
    80005162:	6be2                	ld	s7,24(sp)
    80005164:	6c42                	ld	s8,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80005166:	854a                	mv	a0,s2
    80005168:	60e6                	ld	ra,88(sp)
    8000516a:	6446                	ld	s0,80(sp)
    8000516c:	64a6                	ld	s1,72(sp)
    8000516e:	6906                	ld	s2,64(sp)
    80005170:	79e2                	ld	s3,56(sp)
    80005172:	7a42                	ld	s4,48(sp)
    80005174:	7aa2                	ld	s5,40(sp)
    80005176:	6125                	addi	sp,sp,96
    80005178:	8082                	ret
      wakeup(&pi->nread);
    8000517a:	8562                	mv	a0,s8
    8000517c:	ffffd097          	auipc	ra,0xffffd
    80005180:	17c080e7          	jalr	380(ra) # 800022f8 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80005184:	85a6                	mv	a1,s1
    80005186:	855e                	mv	a0,s7
    80005188:	ffffd097          	auipc	ra,0xffffd
    8000518c:	10c080e7          	jalr	268(ra) # 80002294 <sleep>
  while(i < n){
    80005190:	05495f63          	bge	s2,s4,800051ee <pipewrite+0xde>
    if(pi->readopen == 0 || killed(pr)){
    80005194:	2204a783          	lw	a5,544(s1)
    80005198:	dfd5                	beqz	a5,80005154 <pipewrite+0x44>
    8000519a:	854e                	mv	a0,s3
    8000519c:	ffffd097          	auipc	ra,0xffffd
    800051a0:	446080e7          	jalr	1094(ra) # 800025e2 <killed>
    800051a4:	f945                	bnez	a0,80005154 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    800051a6:	2184a783          	lw	a5,536(s1)
    800051aa:	21c4a703          	lw	a4,540(s1)
    800051ae:	2007879b          	addiw	a5,a5,512
    800051b2:	fcf704e3          	beq	a4,a5,8000517a <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800051b6:	4685                	li	a3,1
    800051b8:	01590633          	add	a2,s2,s5
    800051bc:	faf40593          	addi	a1,s0,-81
    800051c0:	0509b503          	ld	a0,80(s3)
    800051c4:	ffffc097          	auipc	ra,0xffffc
    800051c8:	5aa080e7          	jalr	1450(ra) # 8000176e <copyin>
    800051cc:	05650263          	beq	a0,s6,80005210 <pipewrite+0x100>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    800051d0:	21c4a783          	lw	a5,540(s1)
    800051d4:	0017871b          	addiw	a4,a5,1
    800051d8:	20e4ae23          	sw	a4,540(s1)
    800051dc:	1ff7f793          	andi	a5,a5,511
    800051e0:	97a6                	add	a5,a5,s1
    800051e2:	faf44703          	lbu	a4,-81(s0)
    800051e6:	00e78c23          	sb	a4,24(a5)
      i++;
    800051ea:	2905                	addiw	s2,s2,1
    800051ec:	b755                	j	80005190 <pipewrite+0x80>
    800051ee:	7b02                	ld	s6,32(sp)
    800051f0:	6be2                	ld	s7,24(sp)
    800051f2:	6c42                	ld	s8,16(sp)
  wakeup(&pi->nread);
    800051f4:	21848513          	addi	a0,s1,536
    800051f8:	ffffd097          	auipc	ra,0xffffd
    800051fc:	100080e7          	jalr	256(ra) # 800022f8 <wakeup>
  release(&pi->lock);
    80005200:	8526                	mv	a0,s1
    80005202:	ffffc097          	auipc	ra,0xffffc
    80005206:	aea080e7          	jalr	-1302(ra) # 80000cec <release>
  return i;
    8000520a:	bfb1                	j	80005166 <pipewrite+0x56>
  int i = 0;
    8000520c:	4901                	li	s2,0
    8000520e:	b7dd                	j	800051f4 <pipewrite+0xe4>
    80005210:	7b02                	ld	s6,32(sp)
    80005212:	6be2                	ld	s7,24(sp)
    80005214:	6c42                	ld	s8,16(sp)
    80005216:	bff9                	j	800051f4 <pipewrite+0xe4>

0000000080005218 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80005218:	715d                	addi	sp,sp,-80
    8000521a:	e486                	sd	ra,72(sp)
    8000521c:	e0a2                	sd	s0,64(sp)
    8000521e:	fc26                	sd	s1,56(sp)
    80005220:	f84a                	sd	s2,48(sp)
    80005222:	f44e                	sd	s3,40(sp)
    80005224:	f052                	sd	s4,32(sp)
    80005226:	ec56                	sd	s5,24(sp)
    80005228:	0880                	addi	s0,sp,80
    8000522a:	84aa                	mv	s1,a0
    8000522c:	892e                	mv	s2,a1
    8000522e:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80005230:	ffffd097          	auipc	ra,0xffffd
    80005234:	8fa080e7          	jalr	-1798(ra) # 80001b2a <myproc>
    80005238:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    8000523a:	8526                	mv	a0,s1
    8000523c:	ffffc097          	auipc	ra,0xffffc
    80005240:	9fc080e7          	jalr	-1540(ra) # 80000c38 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005244:	2184a703          	lw	a4,536(s1)
    80005248:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000524c:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005250:	02f71963          	bne	a4,a5,80005282 <piperead+0x6a>
    80005254:	2244a783          	lw	a5,548(s1)
    80005258:	cf95                	beqz	a5,80005294 <piperead+0x7c>
    if(killed(pr)){
    8000525a:	8552                	mv	a0,s4
    8000525c:	ffffd097          	auipc	ra,0xffffd
    80005260:	386080e7          	jalr	902(ra) # 800025e2 <killed>
    80005264:	e10d                	bnez	a0,80005286 <piperead+0x6e>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005266:	85a6                	mv	a1,s1
    80005268:	854e                	mv	a0,s3
    8000526a:	ffffd097          	auipc	ra,0xffffd
    8000526e:	02a080e7          	jalr	42(ra) # 80002294 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005272:	2184a703          	lw	a4,536(s1)
    80005276:	21c4a783          	lw	a5,540(s1)
    8000527a:	fcf70de3          	beq	a4,a5,80005254 <piperead+0x3c>
    8000527e:	e85a                	sd	s6,16(sp)
    80005280:	a819                	j	80005296 <piperead+0x7e>
    80005282:	e85a                	sd	s6,16(sp)
    80005284:	a809                	j	80005296 <piperead+0x7e>
      release(&pi->lock);
    80005286:	8526                	mv	a0,s1
    80005288:	ffffc097          	auipc	ra,0xffffc
    8000528c:	a64080e7          	jalr	-1436(ra) # 80000cec <release>
      return -1;
    80005290:	59fd                	li	s3,-1
    80005292:	a0a5                	j	800052fa <piperead+0xe2>
    80005294:	e85a                	sd	s6,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005296:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005298:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000529a:	05505463          	blez	s5,800052e2 <piperead+0xca>
    if(pi->nread == pi->nwrite)
    8000529e:	2184a783          	lw	a5,536(s1)
    800052a2:	21c4a703          	lw	a4,540(s1)
    800052a6:	02f70e63          	beq	a4,a5,800052e2 <piperead+0xca>
    ch = pi->data[pi->nread++ % PIPESIZE];
    800052aa:	0017871b          	addiw	a4,a5,1
    800052ae:	20e4ac23          	sw	a4,536(s1)
    800052b2:	1ff7f793          	andi	a5,a5,511
    800052b6:	97a6                	add	a5,a5,s1
    800052b8:	0187c783          	lbu	a5,24(a5)
    800052bc:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800052c0:	4685                	li	a3,1
    800052c2:	fbf40613          	addi	a2,s0,-65
    800052c6:	85ca                	mv	a1,s2
    800052c8:	050a3503          	ld	a0,80(s4)
    800052cc:	ffffc097          	auipc	ra,0xffffc
    800052d0:	416080e7          	jalr	1046(ra) # 800016e2 <copyout>
    800052d4:	01650763          	beq	a0,s6,800052e2 <piperead+0xca>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800052d8:	2985                	addiw	s3,s3,1
    800052da:	0905                	addi	s2,s2,1
    800052dc:	fd3a91e3          	bne	s5,s3,8000529e <piperead+0x86>
    800052e0:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    800052e2:	21c48513          	addi	a0,s1,540
    800052e6:	ffffd097          	auipc	ra,0xffffd
    800052ea:	012080e7          	jalr	18(ra) # 800022f8 <wakeup>
  release(&pi->lock);
    800052ee:	8526                	mv	a0,s1
    800052f0:	ffffc097          	auipc	ra,0xffffc
    800052f4:	9fc080e7          	jalr	-1540(ra) # 80000cec <release>
    800052f8:	6b42                	ld	s6,16(sp)
  return i;
}
    800052fa:	854e                	mv	a0,s3
    800052fc:	60a6                	ld	ra,72(sp)
    800052fe:	6406                	ld	s0,64(sp)
    80005300:	74e2                	ld	s1,56(sp)
    80005302:	7942                	ld	s2,48(sp)
    80005304:	79a2                	ld	s3,40(sp)
    80005306:	7a02                	ld	s4,32(sp)
    80005308:	6ae2                	ld	s5,24(sp)
    8000530a:	6161                	addi	sp,sp,80
    8000530c:	8082                	ret

000000008000530e <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    8000530e:	1141                	addi	sp,sp,-16
    80005310:	e422                	sd	s0,8(sp)
    80005312:	0800                	addi	s0,sp,16
    80005314:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80005316:	8905                	andi	a0,a0,1
    80005318:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    8000531a:	8b89                	andi	a5,a5,2
    8000531c:	c399                	beqz	a5,80005322 <flags2perm+0x14>
      perm |= PTE_W;
    8000531e:	00456513          	ori	a0,a0,4
    return perm;
}
    80005322:	6422                	ld	s0,8(sp)
    80005324:	0141                	addi	sp,sp,16
    80005326:	8082                	ret

0000000080005328 <exec>:

int
exec(char *path, char **argv)
{
    80005328:	df010113          	addi	sp,sp,-528
    8000532c:	20113423          	sd	ra,520(sp)
    80005330:	20813023          	sd	s0,512(sp)
    80005334:	ffa6                	sd	s1,504(sp)
    80005336:	fbca                	sd	s2,496(sp)
    80005338:	0c00                	addi	s0,sp,528
    8000533a:	892a                	mv	s2,a0
    8000533c:	dea43c23          	sd	a0,-520(s0)
    80005340:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80005344:	ffffc097          	auipc	ra,0xffffc
    80005348:	7e6080e7          	jalr	2022(ra) # 80001b2a <myproc>
    8000534c:	84aa                	mv	s1,a0

  begin_op();
    8000534e:	fffff097          	auipc	ra,0xfffff
    80005352:	43a080e7          	jalr	1082(ra) # 80004788 <begin_op>

  if((ip = namei(path)) == 0){
    80005356:	854a                	mv	a0,s2
    80005358:	fffff097          	auipc	ra,0xfffff
    8000535c:	230080e7          	jalr	560(ra) # 80004588 <namei>
    80005360:	c135                	beqz	a0,800053c4 <exec+0x9c>
    80005362:	f3d2                	sd	s4,480(sp)
    80005364:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80005366:	fffff097          	auipc	ra,0xfffff
    8000536a:	a54080e7          	jalr	-1452(ra) # 80003dba <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    8000536e:	04000713          	li	a4,64
    80005372:	4681                	li	a3,0
    80005374:	e5040613          	addi	a2,s0,-432
    80005378:	4581                	li	a1,0
    8000537a:	8552                	mv	a0,s4
    8000537c:	fffff097          	auipc	ra,0xfffff
    80005380:	cf6080e7          	jalr	-778(ra) # 80004072 <readi>
    80005384:	04000793          	li	a5,64
    80005388:	00f51a63          	bne	a0,a5,8000539c <exec+0x74>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    8000538c:	e5042703          	lw	a4,-432(s0)
    80005390:	464c47b7          	lui	a5,0x464c4
    80005394:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80005398:	02f70c63          	beq	a4,a5,800053d0 <exec+0xa8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    8000539c:	8552                	mv	a0,s4
    8000539e:	fffff097          	auipc	ra,0xfffff
    800053a2:	c82080e7          	jalr	-894(ra) # 80004020 <iunlockput>
    end_op();
    800053a6:	fffff097          	auipc	ra,0xfffff
    800053aa:	45c080e7          	jalr	1116(ra) # 80004802 <end_op>
  }
  return -1;
    800053ae:	557d                	li	a0,-1
    800053b0:	7a1e                	ld	s4,480(sp)
}
    800053b2:	20813083          	ld	ra,520(sp)
    800053b6:	20013403          	ld	s0,512(sp)
    800053ba:	74fe                	ld	s1,504(sp)
    800053bc:	795e                	ld	s2,496(sp)
    800053be:	21010113          	addi	sp,sp,528
    800053c2:	8082                	ret
    end_op();
    800053c4:	fffff097          	auipc	ra,0xfffff
    800053c8:	43e080e7          	jalr	1086(ra) # 80004802 <end_op>
    return -1;
    800053cc:	557d                	li	a0,-1
    800053ce:	b7d5                	j	800053b2 <exec+0x8a>
    800053d0:	ebda                	sd	s6,464(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    800053d2:	8526                	mv	a0,s1
    800053d4:	ffffd097          	auipc	ra,0xffffd
    800053d8:	81a080e7          	jalr	-2022(ra) # 80001bee <proc_pagetable>
    800053dc:	8b2a                	mv	s6,a0
    800053de:	30050f63          	beqz	a0,800056fc <exec+0x3d4>
    800053e2:	f7ce                	sd	s3,488(sp)
    800053e4:	efd6                	sd	s5,472(sp)
    800053e6:	e7de                	sd	s7,456(sp)
    800053e8:	e3e2                	sd	s8,448(sp)
    800053ea:	ff66                	sd	s9,440(sp)
    800053ec:	fb6a                	sd	s10,432(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800053ee:	e7042d03          	lw	s10,-400(s0)
    800053f2:	e8845783          	lhu	a5,-376(s0)
    800053f6:	14078d63          	beqz	a5,80005550 <exec+0x228>
    800053fa:	f76e                	sd	s11,424(sp)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800053fc:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800053fe:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    80005400:	6c85                	lui	s9,0x1
    80005402:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80005406:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    8000540a:	6a85                	lui	s5,0x1
    8000540c:	a0b5                	j	80005478 <exec+0x150>
      panic("loadseg: address should exist");
    8000540e:	00003517          	auipc	a0,0x3
    80005412:	33250513          	addi	a0,a0,818 # 80008740 <etext+0x740>
    80005416:	ffffb097          	auipc	ra,0xffffb
    8000541a:	14a080e7          	jalr	330(ra) # 80000560 <panic>
    if(sz - i < PGSIZE)
    8000541e:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80005420:	8726                	mv	a4,s1
    80005422:	012c06bb          	addw	a3,s8,s2
    80005426:	4581                	li	a1,0
    80005428:	8552                	mv	a0,s4
    8000542a:	fffff097          	auipc	ra,0xfffff
    8000542e:	c48080e7          	jalr	-952(ra) # 80004072 <readi>
    80005432:	2501                	sext.w	a0,a0
    80005434:	28a49863          	bne	s1,a0,800056c4 <exec+0x39c>
  for(i = 0; i < sz; i += PGSIZE){
    80005438:	012a893b          	addw	s2,s5,s2
    8000543c:	03397563          	bgeu	s2,s3,80005466 <exec+0x13e>
    pa = walkaddr(pagetable, va + i);
    80005440:	02091593          	slli	a1,s2,0x20
    80005444:	9181                	srli	a1,a1,0x20
    80005446:	95de                	add	a1,a1,s7
    80005448:	855a                	mv	a0,s6
    8000544a:	ffffc097          	auipc	ra,0xffffc
    8000544e:	c6c080e7          	jalr	-916(ra) # 800010b6 <walkaddr>
    80005452:	862a                	mv	a2,a0
    if(pa == 0)
    80005454:	dd4d                	beqz	a0,8000540e <exec+0xe6>
    if(sz - i < PGSIZE)
    80005456:	412984bb          	subw	s1,s3,s2
    8000545a:	0004879b          	sext.w	a5,s1
    8000545e:	fcfcf0e3          	bgeu	s9,a5,8000541e <exec+0xf6>
    80005462:	84d6                	mv	s1,s5
    80005464:	bf6d                	j	8000541e <exec+0xf6>
    sz = sz1;
    80005466:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000546a:	2d85                	addiw	s11,s11,1
    8000546c:	038d0d1b          	addiw	s10,s10,56
    80005470:	e8845783          	lhu	a5,-376(s0)
    80005474:	08fdd663          	bge	s11,a5,80005500 <exec+0x1d8>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80005478:	2d01                	sext.w	s10,s10
    8000547a:	03800713          	li	a4,56
    8000547e:	86ea                	mv	a3,s10
    80005480:	e1840613          	addi	a2,s0,-488
    80005484:	4581                	li	a1,0
    80005486:	8552                	mv	a0,s4
    80005488:	fffff097          	auipc	ra,0xfffff
    8000548c:	bea080e7          	jalr	-1046(ra) # 80004072 <readi>
    80005490:	03800793          	li	a5,56
    80005494:	20f51063          	bne	a0,a5,80005694 <exec+0x36c>
    if(ph.type != ELF_PROG_LOAD)
    80005498:	e1842783          	lw	a5,-488(s0)
    8000549c:	4705                	li	a4,1
    8000549e:	fce796e3          	bne	a5,a4,8000546a <exec+0x142>
    if(ph.memsz < ph.filesz)
    800054a2:	e4043483          	ld	s1,-448(s0)
    800054a6:	e3843783          	ld	a5,-456(s0)
    800054aa:	1ef4e963          	bltu	s1,a5,8000569c <exec+0x374>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    800054ae:	e2843783          	ld	a5,-472(s0)
    800054b2:	94be                	add	s1,s1,a5
    800054b4:	1ef4e863          	bltu	s1,a5,800056a4 <exec+0x37c>
    if(ph.vaddr % PGSIZE != 0)
    800054b8:	df043703          	ld	a4,-528(s0)
    800054bc:	8ff9                	and	a5,a5,a4
    800054be:	1e079763          	bnez	a5,800056ac <exec+0x384>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800054c2:	e1c42503          	lw	a0,-484(s0)
    800054c6:	00000097          	auipc	ra,0x0
    800054ca:	e48080e7          	jalr	-440(ra) # 8000530e <flags2perm>
    800054ce:	86aa                	mv	a3,a0
    800054d0:	8626                	mv	a2,s1
    800054d2:	85ca                	mv	a1,s2
    800054d4:	855a                	mv	a0,s6
    800054d6:	ffffc097          	auipc	ra,0xffffc
    800054da:	fa4080e7          	jalr	-92(ra) # 8000147a <uvmalloc>
    800054de:	e0a43423          	sd	a0,-504(s0)
    800054e2:	1c050963          	beqz	a0,800056b4 <exec+0x38c>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800054e6:	e2843b83          	ld	s7,-472(s0)
    800054ea:	e2042c03          	lw	s8,-480(s0)
    800054ee:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    800054f2:	00098463          	beqz	s3,800054fa <exec+0x1d2>
    800054f6:	4901                	li	s2,0
    800054f8:	b7a1                	j	80005440 <exec+0x118>
    sz = sz1;
    800054fa:	e0843903          	ld	s2,-504(s0)
    800054fe:	b7b5                	j	8000546a <exec+0x142>
    80005500:	7dba                	ld	s11,424(sp)
  iunlockput(ip);
    80005502:	8552                	mv	a0,s4
    80005504:	fffff097          	auipc	ra,0xfffff
    80005508:	b1c080e7          	jalr	-1252(ra) # 80004020 <iunlockput>
  end_op();
    8000550c:	fffff097          	auipc	ra,0xfffff
    80005510:	2f6080e7          	jalr	758(ra) # 80004802 <end_op>
  p = myproc();
    80005514:	ffffc097          	auipc	ra,0xffffc
    80005518:	616080e7          	jalr	1558(ra) # 80001b2a <myproc>
    8000551c:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    8000551e:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    80005522:	6985                	lui	s3,0x1
    80005524:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    80005526:	99ca                	add	s3,s3,s2
    80005528:	77fd                	lui	a5,0xfffff
    8000552a:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    8000552e:	4691                	li	a3,4
    80005530:	6609                	lui	a2,0x2
    80005532:	964e                	add	a2,a2,s3
    80005534:	85ce                	mv	a1,s3
    80005536:	855a                	mv	a0,s6
    80005538:	ffffc097          	auipc	ra,0xffffc
    8000553c:	f42080e7          	jalr	-190(ra) # 8000147a <uvmalloc>
    80005540:	892a                	mv	s2,a0
    80005542:	e0a43423          	sd	a0,-504(s0)
    80005546:	e519                	bnez	a0,80005554 <exec+0x22c>
  if(pagetable)
    80005548:	e1343423          	sd	s3,-504(s0)
    8000554c:	4a01                	li	s4,0
    8000554e:	aaa5                	j	800056c6 <exec+0x39e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005550:	4901                	li	s2,0
    80005552:	bf45                	j	80005502 <exec+0x1da>
  uvmclear(pagetable, sz-2*PGSIZE);
    80005554:	75f9                	lui	a1,0xffffe
    80005556:	95aa                	add	a1,a1,a0
    80005558:	855a                	mv	a0,s6
    8000555a:	ffffc097          	auipc	ra,0xffffc
    8000555e:	156080e7          	jalr	342(ra) # 800016b0 <uvmclear>
  stackbase = sp - PGSIZE;
    80005562:	7bfd                	lui	s7,0xfffff
    80005564:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    80005566:	e0043783          	ld	a5,-512(s0)
    8000556a:	6388                	ld	a0,0(a5)
    8000556c:	c52d                	beqz	a0,800055d6 <exec+0x2ae>
    8000556e:	e9040993          	addi	s3,s0,-368
    80005572:	f9040c13          	addi	s8,s0,-112
    80005576:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80005578:	ffffc097          	auipc	ra,0xffffc
    8000557c:	930080e7          	jalr	-1744(ra) # 80000ea8 <strlen>
    80005580:	0015079b          	addiw	a5,a0,1
    80005584:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80005588:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    8000558c:	13796863          	bltu	s2,s7,800056bc <exec+0x394>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005590:	e0043d03          	ld	s10,-512(s0)
    80005594:	000d3a03          	ld	s4,0(s10)
    80005598:	8552                	mv	a0,s4
    8000559a:	ffffc097          	auipc	ra,0xffffc
    8000559e:	90e080e7          	jalr	-1778(ra) # 80000ea8 <strlen>
    800055a2:	0015069b          	addiw	a3,a0,1
    800055a6:	8652                	mv	a2,s4
    800055a8:	85ca                	mv	a1,s2
    800055aa:	855a                	mv	a0,s6
    800055ac:	ffffc097          	auipc	ra,0xffffc
    800055b0:	136080e7          	jalr	310(ra) # 800016e2 <copyout>
    800055b4:	10054663          	bltz	a0,800056c0 <exec+0x398>
    ustack[argc] = sp;
    800055b8:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    800055bc:	0485                	addi	s1,s1,1
    800055be:	008d0793          	addi	a5,s10,8
    800055c2:	e0f43023          	sd	a5,-512(s0)
    800055c6:	008d3503          	ld	a0,8(s10)
    800055ca:	c909                	beqz	a0,800055dc <exec+0x2b4>
    if(argc >= MAXARG)
    800055cc:	09a1                	addi	s3,s3,8
    800055ce:	fb8995e3          	bne	s3,s8,80005578 <exec+0x250>
  ip = 0;
    800055d2:	4a01                	li	s4,0
    800055d4:	a8cd                	j	800056c6 <exec+0x39e>
  sp = sz;
    800055d6:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    800055da:	4481                	li	s1,0
  ustack[argc] = 0;
    800055dc:	00349793          	slli	a5,s1,0x3
    800055e0:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffb2470>
    800055e4:	97a2                	add	a5,a5,s0
    800055e6:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    800055ea:	00148693          	addi	a3,s1,1
    800055ee:	068e                	slli	a3,a3,0x3
    800055f0:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    800055f4:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    800055f8:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    800055fc:	f57966e3          	bltu	s2,s7,80005548 <exec+0x220>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80005600:	e9040613          	addi	a2,s0,-368
    80005604:	85ca                	mv	a1,s2
    80005606:	855a                	mv	a0,s6
    80005608:	ffffc097          	auipc	ra,0xffffc
    8000560c:	0da080e7          	jalr	218(ra) # 800016e2 <copyout>
    80005610:	0e054863          	bltz	a0,80005700 <exec+0x3d8>
  p->trapframe->a1 = sp;
    80005614:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    80005618:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    8000561c:	df843783          	ld	a5,-520(s0)
    80005620:	0007c703          	lbu	a4,0(a5)
    80005624:	cf11                	beqz	a4,80005640 <exec+0x318>
    80005626:	0785                	addi	a5,a5,1
    if(*s == '/')
    80005628:	02f00693          	li	a3,47
    8000562c:	a039                	j	8000563a <exec+0x312>
      last = s+1;
    8000562e:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    80005632:	0785                	addi	a5,a5,1
    80005634:	fff7c703          	lbu	a4,-1(a5)
    80005638:	c701                	beqz	a4,80005640 <exec+0x318>
    if(*s == '/')
    8000563a:	fed71ce3          	bne	a4,a3,80005632 <exec+0x30a>
    8000563e:	bfc5                	j	8000562e <exec+0x306>
  safestrcpy(p->name, last, sizeof(p->name));
    80005640:	4641                	li	a2,16
    80005642:	df843583          	ld	a1,-520(s0)
    80005646:	158a8513          	addi	a0,s5,344
    8000564a:	ffffc097          	auipc	ra,0xffffc
    8000564e:	82c080e7          	jalr	-2004(ra) # 80000e76 <safestrcpy>
  oldpagetable = p->pagetable;
    80005652:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80005656:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    8000565a:	e0843783          	ld	a5,-504(s0)
    8000565e:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80005662:	058ab783          	ld	a5,88(s5)
    80005666:	e6843703          	ld	a4,-408(s0)
    8000566a:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    8000566c:	058ab783          	ld	a5,88(s5)
    80005670:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80005674:	85e6                	mv	a1,s9
    80005676:	ffffc097          	auipc	ra,0xffffc
    8000567a:	614080e7          	jalr	1556(ra) # 80001c8a <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    8000567e:	0004851b          	sext.w	a0,s1
    80005682:	79be                	ld	s3,488(sp)
    80005684:	7a1e                	ld	s4,480(sp)
    80005686:	6afe                	ld	s5,472(sp)
    80005688:	6b5e                	ld	s6,464(sp)
    8000568a:	6bbe                	ld	s7,456(sp)
    8000568c:	6c1e                	ld	s8,448(sp)
    8000568e:	7cfa                	ld	s9,440(sp)
    80005690:	7d5a                	ld	s10,432(sp)
    80005692:	b305                	j	800053b2 <exec+0x8a>
    80005694:	e1243423          	sd	s2,-504(s0)
    80005698:	7dba                	ld	s11,424(sp)
    8000569a:	a035                	j	800056c6 <exec+0x39e>
    8000569c:	e1243423          	sd	s2,-504(s0)
    800056a0:	7dba                	ld	s11,424(sp)
    800056a2:	a015                	j	800056c6 <exec+0x39e>
    800056a4:	e1243423          	sd	s2,-504(s0)
    800056a8:	7dba                	ld	s11,424(sp)
    800056aa:	a831                	j	800056c6 <exec+0x39e>
    800056ac:	e1243423          	sd	s2,-504(s0)
    800056b0:	7dba                	ld	s11,424(sp)
    800056b2:	a811                	j	800056c6 <exec+0x39e>
    800056b4:	e1243423          	sd	s2,-504(s0)
    800056b8:	7dba                	ld	s11,424(sp)
    800056ba:	a031                	j	800056c6 <exec+0x39e>
  ip = 0;
    800056bc:	4a01                	li	s4,0
    800056be:	a021                	j	800056c6 <exec+0x39e>
    800056c0:	4a01                	li	s4,0
  if(pagetable)
    800056c2:	a011                	j	800056c6 <exec+0x39e>
    800056c4:	7dba                	ld	s11,424(sp)
    proc_freepagetable(pagetable, sz);
    800056c6:	e0843583          	ld	a1,-504(s0)
    800056ca:	855a                	mv	a0,s6
    800056cc:	ffffc097          	auipc	ra,0xffffc
    800056d0:	5be080e7          	jalr	1470(ra) # 80001c8a <proc_freepagetable>
  return -1;
    800056d4:	557d                	li	a0,-1
  if(ip){
    800056d6:	000a1b63          	bnez	s4,800056ec <exec+0x3c4>
    800056da:	79be                	ld	s3,488(sp)
    800056dc:	7a1e                	ld	s4,480(sp)
    800056de:	6afe                	ld	s5,472(sp)
    800056e0:	6b5e                	ld	s6,464(sp)
    800056e2:	6bbe                	ld	s7,456(sp)
    800056e4:	6c1e                	ld	s8,448(sp)
    800056e6:	7cfa                	ld	s9,440(sp)
    800056e8:	7d5a                	ld	s10,432(sp)
    800056ea:	b1e1                	j	800053b2 <exec+0x8a>
    800056ec:	79be                	ld	s3,488(sp)
    800056ee:	6afe                	ld	s5,472(sp)
    800056f0:	6b5e                	ld	s6,464(sp)
    800056f2:	6bbe                	ld	s7,456(sp)
    800056f4:	6c1e                	ld	s8,448(sp)
    800056f6:	7cfa                	ld	s9,440(sp)
    800056f8:	7d5a                	ld	s10,432(sp)
    800056fa:	b14d                	j	8000539c <exec+0x74>
    800056fc:	6b5e                	ld	s6,464(sp)
    800056fe:	b979                	j	8000539c <exec+0x74>
  sz = sz1;
    80005700:	e0843983          	ld	s3,-504(s0)
    80005704:	b591                	j	80005548 <exec+0x220>

0000000080005706 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005706:	7179                	addi	sp,sp,-48
    80005708:	f406                	sd	ra,40(sp)
    8000570a:	f022                	sd	s0,32(sp)
    8000570c:	ec26                	sd	s1,24(sp)
    8000570e:	e84a                	sd	s2,16(sp)
    80005710:	1800                	addi	s0,sp,48
    80005712:	892e                	mv	s2,a1
    80005714:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80005716:	fdc40593          	addi	a1,s0,-36
    8000571a:	ffffe097          	auipc	ra,0xffffe
    8000571e:	94c080e7          	jalr	-1716(ra) # 80003066 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005722:	fdc42703          	lw	a4,-36(s0)
    80005726:	47bd                	li	a5,15
    80005728:	02e7eb63          	bltu	a5,a4,8000575e <argfd+0x58>
    8000572c:	ffffc097          	auipc	ra,0xffffc
    80005730:	3fe080e7          	jalr	1022(ra) # 80001b2a <myproc>
    80005734:	fdc42703          	lw	a4,-36(s0)
    80005738:	01a70793          	addi	a5,a4,26
    8000573c:	078e                	slli	a5,a5,0x3
    8000573e:	953e                	add	a0,a0,a5
    80005740:	611c                	ld	a5,0(a0)
    80005742:	c385                	beqz	a5,80005762 <argfd+0x5c>
    return -1;
  if(pfd)
    80005744:	00090463          	beqz	s2,8000574c <argfd+0x46>
    *pfd = fd;
    80005748:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    8000574c:	4501                	li	a0,0
  if(pf)
    8000574e:	c091                	beqz	s1,80005752 <argfd+0x4c>
    *pf = f;
    80005750:	e09c                	sd	a5,0(s1)
}
    80005752:	70a2                	ld	ra,40(sp)
    80005754:	7402                	ld	s0,32(sp)
    80005756:	64e2                	ld	s1,24(sp)
    80005758:	6942                	ld	s2,16(sp)
    8000575a:	6145                	addi	sp,sp,48
    8000575c:	8082                	ret
    return -1;
    8000575e:	557d                	li	a0,-1
    80005760:	bfcd                	j	80005752 <argfd+0x4c>
    80005762:	557d                	li	a0,-1
    80005764:	b7fd                	j	80005752 <argfd+0x4c>

0000000080005766 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005766:	1101                	addi	sp,sp,-32
    80005768:	ec06                	sd	ra,24(sp)
    8000576a:	e822                	sd	s0,16(sp)
    8000576c:	e426                	sd	s1,8(sp)
    8000576e:	1000                	addi	s0,sp,32
    80005770:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005772:	ffffc097          	auipc	ra,0xffffc
    80005776:	3b8080e7          	jalr	952(ra) # 80001b2a <myproc>
    8000577a:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    8000577c:	0d050793          	addi	a5,a0,208
    80005780:	4501                	li	a0,0
    80005782:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005784:	6398                	ld	a4,0(a5)
    80005786:	cb19                	beqz	a4,8000579c <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005788:	2505                	addiw	a0,a0,1
    8000578a:	07a1                	addi	a5,a5,8
    8000578c:	fed51ce3          	bne	a0,a3,80005784 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005790:	557d                	li	a0,-1
}
    80005792:	60e2                	ld	ra,24(sp)
    80005794:	6442                	ld	s0,16(sp)
    80005796:	64a2                	ld	s1,8(sp)
    80005798:	6105                	addi	sp,sp,32
    8000579a:	8082                	ret
      p->ofile[fd] = f;
    8000579c:	01a50793          	addi	a5,a0,26
    800057a0:	078e                	slli	a5,a5,0x3
    800057a2:	963e                	add	a2,a2,a5
    800057a4:	e204                	sd	s1,0(a2)
      return fd;
    800057a6:	b7f5                	j	80005792 <fdalloc+0x2c>

00000000800057a8 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800057a8:	715d                	addi	sp,sp,-80
    800057aa:	e486                	sd	ra,72(sp)
    800057ac:	e0a2                	sd	s0,64(sp)
    800057ae:	fc26                	sd	s1,56(sp)
    800057b0:	f84a                	sd	s2,48(sp)
    800057b2:	f44e                	sd	s3,40(sp)
    800057b4:	ec56                	sd	s5,24(sp)
    800057b6:	e85a                	sd	s6,16(sp)
    800057b8:	0880                	addi	s0,sp,80
    800057ba:	8b2e                	mv	s6,a1
    800057bc:	89b2                	mv	s3,a2
    800057be:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800057c0:	fb040593          	addi	a1,s0,-80
    800057c4:	fffff097          	auipc	ra,0xfffff
    800057c8:	de2080e7          	jalr	-542(ra) # 800045a6 <nameiparent>
    800057cc:	84aa                	mv	s1,a0
    800057ce:	14050e63          	beqz	a0,8000592a <create+0x182>
    return 0;

  ilock(dp);
    800057d2:	ffffe097          	auipc	ra,0xffffe
    800057d6:	5e8080e7          	jalr	1512(ra) # 80003dba <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800057da:	4601                	li	a2,0
    800057dc:	fb040593          	addi	a1,s0,-80
    800057e0:	8526                	mv	a0,s1
    800057e2:	fffff097          	auipc	ra,0xfffff
    800057e6:	ae4080e7          	jalr	-1308(ra) # 800042c6 <dirlookup>
    800057ea:	8aaa                	mv	s5,a0
    800057ec:	c539                	beqz	a0,8000583a <create+0x92>
    iunlockput(dp);
    800057ee:	8526                	mv	a0,s1
    800057f0:	fffff097          	auipc	ra,0xfffff
    800057f4:	830080e7          	jalr	-2000(ra) # 80004020 <iunlockput>
    ilock(ip);
    800057f8:	8556                	mv	a0,s5
    800057fa:	ffffe097          	auipc	ra,0xffffe
    800057fe:	5c0080e7          	jalr	1472(ra) # 80003dba <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005802:	4789                	li	a5,2
    80005804:	02fb1463          	bne	s6,a5,8000582c <create+0x84>
    80005808:	044ad783          	lhu	a5,68(s5)
    8000580c:	37f9                	addiw	a5,a5,-2
    8000580e:	17c2                	slli	a5,a5,0x30
    80005810:	93c1                	srli	a5,a5,0x30
    80005812:	4705                	li	a4,1
    80005814:	00f76c63          	bltu	a4,a5,8000582c <create+0x84>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80005818:	8556                	mv	a0,s5
    8000581a:	60a6                	ld	ra,72(sp)
    8000581c:	6406                	ld	s0,64(sp)
    8000581e:	74e2                	ld	s1,56(sp)
    80005820:	7942                	ld	s2,48(sp)
    80005822:	79a2                	ld	s3,40(sp)
    80005824:	6ae2                	ld	s5,24(sp)
    80005826:	6b42                	ld	s6,16(sp)
    80005828:	6161                	addi	sp,sp,80
    8000582a:	8082                	ret
    iunlockput(ip);
    8000582c:	8556                	mv	a0,s5
    8000582e:	ffffe097          	auipc	ra,0xffffe
    80005832:	7f2080e7          	jalr	2034(ra) # 80004020 <iunlockput>
    return 0;
    80005836:	4a81                	li	s5,0
    80005838:	b7c5                	j	80005818 <create+0x70>
    8000583a:	f052                	sd	s4,32(sp)
  if((ip = ialloc(dp->dev, type)) == 0){
    8000583c:	85da                	mv	a1,s6
    8000583e:	4088                	lw	a0,0(s1)
    80005840:	ffffe097          	auipc	ra,0xffffe
    80005844:	3d6080e7          	jalr	982(ra) # 80003c16 <ialloc>
    80005848:	8a2a                	mv	s4,a0
    8000584a:	c531                	beqz	a0,80005896 <create+0xee>
  ilock(ip);
    8000584c:	ffffe097          	auipc	ra,0xffffe
    80005850:	56e080e7          	jalr	1390(ra) # 80003dba <ilock>
  ip->major = major;
    80005854:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80005858:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    8000585c:	4905                	li	s2,1
    8000585e:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80005862:	8552                	mv	a0,s4
    80005864:	ffffe097          	auipc	ra,0xffffe
    80005868:	48a080e7          	jalr	1162(ra) # 80003cee <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    8000586c:	032b0d63          	beq	s6,s2,800058a6 <create+0xfe>
  if(dirlink(dp, name, ip->inum) < 0)
    80005870:	004a2603          	lw	a2,4(s4)
    80005874:	fb040593          	addi	a1,s0,-80
    80005878:	8526                	mv	a0,s1
    8000587a:	fffff097          	auipc	ra,0xfffff
    8000587e:	c5c080e7          	jalr	-932(ra) # 800044d6 <dirlink>
    80005882:	08054163          	bltz	a0,80005904 <create+0x15c>
  iunlockput(dp);
    80005886:	8526                	mv	a0,s1
    80005888:	ffffe097          	auipc	ra,0xffffe
    8000588c:	798080e7          	jalr	1944(ra) # 80004020 <iunlockput>
  return ip;
    80005890:	8ad2                	mv	s5,s4
    80005892:	7a02                	ld	s4,32(sp)
    80005894:	b751                	j	80005818 <create+0x70>
    iunlockput(dp);
    80005896:	8526                	mv	a0,s1
    80005898:	ffffe097          	auipc	ra,0xffffe
    8000589c:	788080e7          	jalr	1928(ra) # 80004020 <iunlockput>
    return 0;
    800058a0:	8ad2                	mv	s5,s4
    800058a2:	7a02                	ld	s4,32(sp)
    800058a4:	bf95                	j	80005818 <create+0x70>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800058a6:	004a2603          	lw	a2,4(s4)
    800058aa:	00003597          	auipc	a1,0x3
    800058ae:	eb658593          	addi	a1,a1,-330 # 80008760 <etext+0x760>
    800058b2:	8552                	mv	a0,s4
    800058b4:	fffff097          	auipc	ra,0xfffff
    800058b8:	c22080e7          	jalr	-990(ra) # 800044d6 <dirlink>
    800058bc:	04054463          	bltz	a0,80005904 <create+0x15c>
    800058c0:	40d0                	lw	a2,4(s1)
    800058c2:	00003597          	auipc	a1,0x3
    800058c6:	ea658593          	addi	a1,a1,-346 # 80008768 <etext+0x768>
    800058ca:	8552                	mv	a0,s4
    800058cc:	fffff097          	auipc	ra,0xfffff
    800058d0:	c0a080e7          	jalr	-1014(ra) # 800044d6 <dirlink>
    800058d4:	02054863          	bltz	a0,80005904 <create+0x15c>
  if(dirlink(dp, name, ip->inum) < 0)
    800058d8:	004a2603          	lw	a2,4(s4)
    800058dc:	fb040593          	addi	a1,s0,-80
    800058e0:	8526                	mv	a0,s1
    800058e2:	fffff097          	auipc	ra,0xfffff
    800058e6:	bf4080e7          	jalr	-1036(ra) # 800044d6 <dirlink>
    800058ea:	00054d63          	bltz	a0,80005904 <create+0x15c>
    dp->nlink++;  // for ".."
    800058ee:	04a4d783          	lhu	a5,74(s1)
    800058f2:	2785                	addiw	a5,a5,1
    800058f4:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800058f8:	8526                	mv	a0,s1
    800058fa:	ffffe097          	auipc	ra,0xffffe
    800058fe:	3f4080e7          	jalr	1012(ra) # 80003cee <iupdate>
    80005902:	b751                	j	80005886 <create+0xde>
  ip->nlink = 0;
    80005904:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80005908:	8552                	mv	a0,s4
    8000590a:	ffffe097          	auipc	ra,0xffffe
    8000590e:	3e4080e7          	jalr	996(ra) # 80003cee <iupdate>
  iunlockput(ip);
    80005912:	8552                	mv	a0,s4
    80005914:	ffffe097          	auipc	ra,0xffffe
    80005918:	70c080e7          	jalr	1804(ra) # 80004020 <iunlockput>
  iunlockput(dp);
    8000591c:	8526                	mv	a0,s1
    8000591e:	ffffe097          	auipc	ra,0xffffe
    80005922:	702080e7          	jalr	1794(ra) # 80004020 <iunlockput>
  return 0;
    80005926:	7a02                	ld	s4,32(sp)
    80005928:	bdc5                	j	80005818 <create+0x70>
    return 0;
    8000592a:	8aaa                	mv	s5,a0
    8000592c:	b5f5                	j	80005818 <create+0x70>

000000008000592e <sys_dup>:
{
    8000592e:	7179                	addi	sp,sp,-48
    80005930:	f406                	sd	ra,40(sp)
    80005932:	f022                	sd	s0,32(sp)
    80005934:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005936:	fd840613          	addi	a2,s0,-40
    8000593a:	4581                	li	a1,0
    8000593c:	4501                	li	a0,0
    8000593e:	00000097          	auipc	ra,0x0
    80005942:	dc8080e7          	jalr	-568(ra) # 80005706 <argfd>
    return -1;
    80005946:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005948:	02054763          	bltz	a0,80005976 <sys_dup+0x48>
    8000594c:	ec26                	sd	s1,24(sp)
    8000594e:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    80005950:	fd843903          	ld	s2,-40(s0)
    80005954:	854a                	mv	a0,s2
    80005956:	00000097          	auipc	ra,0x0
    8000595a:	e10080e7          	jalr	-496(ra) # 80005766 <fdalloc>
    8000595e:	84aa                	mv	s1,a0
    return -1;
    80005960:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005962:	00054f63          	bltz	a0,80005980 <sys_dup+0x52>
  filedup(f);
    80005966:	854a                	mv	a0,s2
    80005968:	fffff097          	auipc	ra,0xfffff
    8000596c:	298080e7          	jalr	664(ra) # 80004c00 <filedup>
  return fd;
    80005970:	87a6                	mv	a5,s1
    80005972:	64e2                	ld	s1,24(sp)
    80005974:	6942                	ld	s2,16(sp)
}
    80005976:	853e                	mv	a0,a5
    80005978:	70a2                	ld	ra,40(sp)
    8000597a:	7402                	ld	s0,32(sp)
    8000597c:	6145                	addi	sp,sp,48
    8000597e:	8082                	ret
    80005980:	64e2                	ld	s1,24(sp)
    80005982:	6942                	ld	s2,16(sp)
    80005984:	bfcd                	j	80005976 <sys_dup+0x48>

0000000080005986 <sys_read>:
{
    80005986:	7179                	addi	sp,sp,-48
    80005988:	f406                	sd	ra,40(sp)
    8000598a:	f022                	sd	s0,32(sp)
    8000598c:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    8000598e:	fd840593          	addi	a1,s0,-40
    80005992:	4505                	li	a0,1
    80005994:	ffffd097          	auipc	ra,0xffffd
    80005998:	6f2080e7          	jalr	1778(ra) # 80003086 <argaddr>
  argint(2, &n);
    8000599c:	fe440593          	addi	a1,s0,-28
    800059a0:	4509                	li	a0,2
    800059a2:	ffffd097          	auipc	ra,0xffffd
    800059a6:	6c4080e7          	jalr	1732(ra) # 80003066 <argint>
  if(argfd(0, 0, &f) < 0)
    800059aa:	fe840613          	addi	a2,s0,-24
    800059ae:	4581                	li	a1,0
    800059b0:	4501                	li	a0,0
    800059b2:	00000097          	auipc	ra,0x0
    800059b6:	d54080e7          	jalr	-684(ra) # 80005706 <argfd>
    800059ba:	87aa                	mv	a5,a0
    return -1;
    800059bc:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800059be:	0007cc63          	bltz	a5,800059d6 <sys_read+0x50>
  return fileread(f, p, n);
    800059c2:	fe442603          	lw	a2,-28(s0)
    800059c6:	fd843583          	ld	a1,-40(s0)
    800059ca:	fe843503          	ld	a0,-24(s0)
    800059ce:	fffff097          	auipc	ra,0xfffff
    800059d2:	3d8080e7          	jalr	984(ra) # 80004da6 <fileread>
}
    800059d6:	70a2                	ld	ra,40(sp)
    800059d8:	7402                	ld	s0,32(sp)
    800059da:	6145                	addi	sp,sp,48
    800059dc:	8082                	ret

00000000800059de <sys_write>:
{
    800059de:	7179                	addi	sp,sp,-48
    800059e0:	f406                	sd	ra,40(sp)
    800059e2:	f022                	sd	s0,32(sp)
    800059e4:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800059e6:	fd840593          	addi	a1,s0,-40
    800059ea:	4505                	li	a0,1
    800059ec:	ffffd097          	auipc	ra,0xffffd
    800059f0:	69a080e7          	jalr	1690(ra) # 80003086 <argaddr>
  argint(2, &n);
    800059f4:	fe440593          	addi	a1,s0,-28
    800059f8:	4509                	li	a0,2
    800059fa:	ffffd097          	auipc	ra,0xffffd
    800059fe:	66c080e7          	jalr	1644(ra) # 80003066 <argint>
  if(argfd(0, 0, &f) < 0)
    80005a02:	fe840613          	addi	a2,s0,-24
    80005a06:	4581                	li	a1,0
    80005a08:	4501                	li	a0,0
    80005a0a:	00000097          	auipc	ra,0x0
    80005a0e:	cfc080e7          	jalr	-772(ra) # 80005706 <argfd>
    80005a12:	87aa                	mv	a5,a0
    return -1;
    80005a14:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005a16:	0007cc63          	bltz	a5,80005a2e <sys_write+0x50>
  return filewrite(f, p, n);
    80005a1a:	fe442603          	lw	a2,-28(s0)
    80005a1e:	fd843583          	ld	a1,-40(s0)
    80005a22:	fe843503          	ld	a0,-24(s0)
    80005a26:	fffff097          	auipc	ra,0xfffff
    80005a2a:	452080e7          	jalr	1106(ra) # 80004e78 <filewrite>
}
    80005a2e:	70a2                	ld	ra,40(sp)
    80005a30:	7402                	ld	s0,32(sp)
    80005a32:	6145                	addi	sp,sp,48
    80005a34:	8082                	ret

0000000080005a36 <sys_close>:
{
    80005a36:	1101                	addi	sp,sp,-32
    80005a38:	ec06                	sd	ra,24(sp)
    80005a3a:	e822                	sd	s0,16(sp)
    80005a3c:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005a3e:	fe040613          	addi	a2,s0,-32
    80005a42:	fec40593          	addi	a1,s0,-20
    80005a46:	4501                	li	a0,0
    80005a48:	00000097          	auipc	ra,0x0
    80005a4c:	cbe080e7          	jalr	-834(ra) # 80005706 <argfd>
    return -1;
    80005a50:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005a52:	02054463          	bltz	a0,80005a7a <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005a56:	ffffc097          	auipc	ra,0xffffc
    80005a5a:	0d4080e7          	jalr	212(ra) # 80001b2a <myproc>
    80005a5e:	fec42783          	lw	a5,-20(s0)
    80005a62:	07e9                	addi	a5,a5,26
    80005a64:	078e                	slli	a5,a5,0x3
    80005a66:	953e                	add	a0,a0,a5
    80005a68:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80005a6c:	fe043503          	ld	a0,-32(s0)
    80005a70:	fffff097          	auipc	ra,0xfffff
    80005a74:	1e2080e7          	jalr	482(ra) # 80004c52 <fileclose>
  return 0;
    80005a78:	4781                	li	a5,0
}
    80005a7a:	853e                	mv	a0,a5
    80005a7c:	60e2                	ld	ra,24(sp)
    80005a7e:	6442                	ld	s0,16(sp)
    80005a80:	6105                	addi	sp,sp,32
    80005a82:	8082                	ret

0000000080005a84 <sys_fstat>:
{
    80005a84:	1101                	addi	sp,sp,-32
    80005a86:	ec06                	sd	ra,24(sp)
    80005a88:	e822                	sd	s0,16(sp)
    80005a8a:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80005a8c:	fe040593          	addi	a1,s0,-32
    80005a90:	4505                	li	a0,1
    80005a92:	ffffd097          	auipc	ra,0xffffd
    80005a96:	5f4080e7          	jalr	1524(ra) # 80003086 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80005a9a:	fe840613          	addi	a2,s0,-24
    80005a9e:	4581                	li	a1,0
    80005aa0:	4501                	li	a0,0
    80005aa2:	00000097          	auipc	ra,0x0
    80005aa6:	c64080e7          	jalr	-924(ra) # 80005706 <argfd>
    80005aaa:	87aa                	mv	a5,a0
    return -1;
    80005aac:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005aae:	0007ca63          	bltz	a5,80005ac2 <sys_fstat+0x3e>
  return filestat(f, st);
    80005ab2:	fe043583          	ld	a1,-32(s0)
    80005ab6:	fe843503          	ld	a0,-24(s0)
    80005aba:	fffff097          	auipc	ra,0xfffff
    80005abe:	27a080e7          	jalr	634(ra) # 80004d34 <filestat>
}
    80005ac2:	60e2                	ld	ra,24(sp)
    80005ac4:	6442                	ld	s0,16(sp)
    80005ac6:	6105                	addi	sp,sp,32
    80005ac8:	8082                	ret

0000000080005aca <sys_link>:
{
    80005aca:	7169                	addi	sp,sp,-304
    80005acc:	f606                	sd	ra,296(sp)
    80005ace:	f222                	sd	s0,288(sp)
    80005ad0:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005ad2:	08000613          	li	a2,128
    80005ad6:	ed040593          	addi	a1,s0,-304
    80005ada:	4501                	li	a0,0
    80005adc:	ffffd097          	auipc	ra,0xffffd
    80005ae0:	5ca080e7          	jalr	1482(ra) # 800030a6 <argstr>
    return -1;
    80005ae4:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005ae6:	12054663          	bltz	a0,80005c12 <sys_link+0x148>
    80005aea:	08000613          	li	a2,128
    80005aee:	f5040593          	addi	a1,s0,-176
    80005af2:	4505                	li	a0,1
    80005af4:	ffffd097          	auipc	ra,0xffffd
    80005af8:	5b2080e7          	jalr	1458(ra) # 800030a6 <argstr>
    return -1;
    80005afc:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005afe:	10054a63          	bltz	a0,80005c12 <sys_link+0x148>
    80005b02:	ee26                	sd	s1,280(sp)
  begin_op();
    80005b04:	fffff097          	auipc	ra,0xfffff
    80005b08:	c84080e7          	jalr	-892(ra) # 80004788 <begin_op>
  if((ip = namei(old)) == 0){
    80005b0c:	ed040513          	addi	a0,s0,-304
    80005b10:	fffff097          	auipc	ra,0xfffff
    80005b14:	a78080e7          	jalr	-1416(ra) # 80004588 <namei>
    80005b18:	84aa                	mv	s1,a0
    80005b1a:	c949                	beqz	a0,80005bac <sys_link+0xe2>
  ilock(ip);
    80005b1c:	ffffe097          	auipc	ra,0xffffe
    80005b20:	29e080e7          	jalr	670(ra) # 80003dba <ilock>
  if(ip->type == T_DIR){
    80005b24:	04449703          	lh	a4,68(s1)
    80005b28:	4785                	li	a5,1
    80005b2a:	08f70863          	beq	a4,a5,80005bba <sys_link+0xf0>
    80005b2e:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80005b30:	04a4d783          	lhu	a5,74(s1)
    80005b34:	2785                	addiw	a5,a5,1
    80005b36:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005b3a:	8526                	mv	a0,s1
    80005b3c:	ffffe097          	auipc	ra,0xffffe
    80005b40:	1b2080e7          	jalr	434(ra) # 80003cee <iupdate>
  iunlock(ip);
    80005b44:	8526                	mv	a0,s1
    80005b46:	ffffe097          	auipc	ra,0xffffe
    80005b4a:	33a080e7          	jalr	826(ra) # 80003e80 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005b4e:	fd040593          	addi	a1,s0,-48
    80005b52:	f5040513          	addi	a0,s0,-176
    80005b56:	fffff097          	auipc	ra,0xfffff
    80005b5a:	a50080e7          	jalr	-1456(ra) # 800045a6 <nameiparent>
    80005b5e:	892a                	mv	s2,a0
    80005b60:	cd35                	beqz	a0,80005bdc <sys_link+0x112>
  ilock(dp);
    80005b62:	ffffe097          	auipc	ra,0xffffe
    80005b66:	258080e7          	jalr	600(ra) # 80003dba <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005b6a:	00092703          	lw	a4,0(s2)
    80005b6e:	409c                	lw	a5,0(s1)
    80005b70:	06f71163          	bne	a4,a5,80005bd2 <sys_link+0x108>
    80005b74:	40d0                	lw	a2,4(s1)
    80005b76:	fd040593          	addi	a1,s0,-48
    80005b7a:	854a                	mv	a0,s2
    80005b7c:	fffff097          	auipc	ra,0xfffff
    80005b80:	95a080e7          	jalr	-1702(ra) # 800044d6 <dirlink>
    80005b84:	04054763          	bltz	a0,80005bd2 <sys_link+0x108>
  iunlockput(dp);
    80005b88:	854a                	mv	a0,s2
    80005b8a:	ffffe097          	auipc	ra,0xffffe
    80005b8e:	496080e7          	jalr	1174(ra) # 80004020 <iunlockput>
  iput(ip);
    80005b92:	8526                	mv	a0,s1
    80005b94:	ffffe097          	auipc	ra,0xffffe
    80005b98:	3e4080e7          	jalr	996(ra) # 80003f78 <iput>
  end_op();
    80005b9c:	fffff097          	auipc	ra,0xfffff
    80005ba0:	c66080e7          	jalr	-922(ra) # 80004802 <end_op>
  return 0;
    80005ba4:	4781                	li	a5,0
    80005ba6:	64f2                	ld	s1,280(sp)
    80005ba8:	6952                	ld	s2,272(sp)
    80005baa:	a0a5                	j	80005c12 <sys_link+0x148>
    end_op();
    80005bac:	fffff097          	auipc	ra,0xfffff
    80005bb0:	c56080e7          	jalr	-938(ra) # 80004802 <end_op>
    return -1;
    80005bb4:	57fd                	li	a5,-1
    80005bb6:	64f2                	ld	s1,280(sp)
    80005bb8:	a8a9                	j	80005c12 <sys_link+0x148>
    iunlockput(ip);
    80005bba:	8526                	mv	a0,s1
    80005bbc:	ffffe097          	auipc	ra,0xffffe
    80005bc0:	464080e7          	jalr	1124(ra) # 80004020 <iunlockput>
    end_op();
    80005bc4:	fffff097          	auipc	ra,0xfffff
    80005bc8:	c3e080e7          	jalr	-962(ra) # 80004802 <end_op>
    return -1;
    80005bcc:	57fd                	li	a5,-1
    80005bce:	64f2                	ld	s1,280(sp)
    80005bd0:	a089                	j	80005c12 <sys_link+0x148>
    iunlockput(dp);
    80005bd2:	854a                	mv	a0,s2
    80005bd4:	ffffe097          	auipc	ra,0xffffe
    80005bd8:	44c080e7          	jalr	1100(ra) # 80004020 <iunlockput>
  ilock(ip);
    80005bdc:	8526                	mv	a0,s1
    80005bde:	ffffe097          	auipc	ra,0xffffe
    80005be2:	1dc080e7          	jalr	476(ra) # 80003dba <ilock>
  ip->nlink--;
    80005be6:	04a4d783          	lhu	a5,74(s1)
    80005bea:	37fd                	addiw	a5,a5,-1
    80005bec:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005bf0:	8526                	mv	a0,s1
    80005bf2:	ffffe097          	auipc	ra,0xffffe
    80005bf6:	0fc080e7          	jalr	252(ra) # 80003cee <iupdate>
  iunlockput(ip);
    80005bfa:	8526                	mv	a0,s1
    80005bfc:	ffffe097          	auipc	ra,0xffffe
    80005c00:	424080e7          	jalr	1060(ra) # 80004020 <iunlockput>
  end_op();
    80005c04:	fffff097          	auipc	ra,0xfffff
    80005c08:	bfe080e7          	jalr	-1026(ra) # 80004802 <end_op>
  return -1;
    80005c0c:	57fd                	li	a5,-1
    80005c0e:	64f2                	ld	s1,280(sp)
    80005c10:	6952                	ld	s2,272(sp)
}
    80005c12:	853e                	mv	a0,a5
    80005c14:	70b2                	ld	ra,296(sp)
    80005c16:	7412                	ld	s0,288(sp)
    80005c18:	6155                	addi	sp,sp,304
    80005c1a:	8082                	ret

0000000080005c1c <sys_unlink>:
{
    80005c1c:	7151                	addi	sp,sp,-240
    80005c1e:	f586                	sd	ra,232(sp)
    80005c20:	f1a2                	sd	s0,224(sp)
    80005c22:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005c24:	08000613          	li	a2,128
    80005c28:	f3040593          	addi	a1,s0,-208
    80005c2c:	4501                	li	a0,0
    80005c2e:	ffffd097          	auipc	ra,0xffffd
    80005c32:	478080e7          	jalr	1144(ra) # 800030a6 <argstr>
    80005c36:	1a054a63          	bltz	a0,80005dea <sys_unlink+0x1ce>
    80005c3a:	eda6                	sd	s1,216(sp)
  begin_op();
    80005c3c:	fffff097          	auipc	ra,0xfffff
    80005c40:	b4c080e7          	jalr	-1204(ra) # 80004788 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005c44:	fb040593          	addi	a1,s0,-80
    80005c48:	f3040513          	addi	a0,s0,-208
    80005c4c:	fffff097          	auipc	ra,0xfffff
    80005c50:	95a080e7          	jalr	-1702(ra) # 800045a6 <nameiparent>
    80005c54:	84aa                	mv	s1,a0
    80005c56:	cd71                	beqz	a0,80005d32 <sys_unlink+0x116>
  ilock(dp);
    80005c58:	ffffe097          	auipc	ra,0xffffe
    80005c5c:	162080e7          	jalr	354(ra) # 80003dba <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005c60:	00003597          	auipc	a1,0x3
    80005c64:	b0058593          	addi	a1,a1,-1280 # 80008760 <etext+0x760>
    80005c68:	fb040513          	addi	a0,s0,-80
    80005c6c:	ffffe097          	auipc	ra,0xffffe
    80005c70:	640080e7          	jalr	1600(ra) # 800042ac <namecmp>
    80005c74:	14050c63          	beqz	a0,80005dcc <sys_unlink+0x1b0>
    80005c78:	00003597          	auipc	a1,0x3
    80005c7c:	af058593          	addi	a1,a1,-1296 # 80008768 <etext+0x768>
    80005c80:	fb040513          	addi	a0,s0,-80
    80005c84:	ffffe097          	auipc	ra,0xffffe
    80005c88:	628080e7          	jalr	1576(ra) # 800042ac <namecmp>
    80005c8c:	14050063          	beqz	a0,80005dcc <sys_unlink+0x1b0>
    80005c90:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005c92:	f2c40613          	addi	a2,s0,-212
    80005c96:	fb040593          	addi	a1,s0,-80
    80005c9a:	8526                	mv	a0,s1
    80005c9c:	ffffe097          	auipc	ra,0xffffe
    80005ca0:	62a080e7          	jalr	1578(ra) # 800042c6 <dirlookup>
    80005ca4:	892a                	mv	s2,a0
    80005ca6:	12050263          	beqz	a0,80005dca <sys_unlink+0x1ae>
  ilock(ip);
    80005caa:	ffffe097          	auipc	ra,0xffffe
    80005cae:	110080e7          	jalr	272(ra) # 80003dba <ilock>
  if(ip->nlink < 1)
    80005cb2:	04a91783          	lh	a5,74(s2)
    80005cb6:	08f05563          	blez	a5,80005d40 <sys_unlink+0x124>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005cba:	04491703          	lh	a4,68(s2)
    80005cbe:	4785                	li	a5,1
    80005cc0:	08f70963          	beq	a4,a5,80005d52 <sys_unlink+0x136>
  memset(&de, 0, sizeof(de));
    80005cc4:	4641                	li	a2,16
    80005cc6:	4581                	li	a1,0
    80005cc8:	fc040513          	addi	a0,s0,-64
    80005ccc:	ffffb097          	auipc	ra,0xffffb
    80005cd0:	068080e7          	jalr	104(ra) # 80000d34 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005cd4:	4741                	li	a4,16
    80005cd6:	f2c42683          	lw	a3,-212(s0)
    80005cda:	fc040613          	addi	a2,s0,-64
    80005cde:	4581                	li	a1,0
    80005ce0:	8526                	mv	a0,s1
    80005ce2:	ffffe097          	auipc	ra,0xffffe
    80005ce6:	4a0080e7          	jalr	1184(ra) # 80004182 <writei>
    80005cea:	47c1                	li	a5,16
    80005cec:	0af51b63          	bne	a0,a5,80005da2 <sys_unlink+0x186>
  if(ip->type == T_DIR){
    80005cf0:	04491703          	lh	a4,68(s2)
    80005cf4:	4785                	li	a5,1
    80005cf6:	0af70f63          	beq	a4,a5,80005db4 <sys_unlink+0x198>
  iunlockput(dp);
    80005cfa:	8526                	mv	a0,s1
    80005cfc:	ffffe097          	auipc	ra,0xffffe
    80005d00:	324080e7          	jalr	804(ra) # 80004020 <iunlockput>
  ip->nlink--;
    80005d04:	04a95783          	lhu	a5,74(s2)
    80005d08:	37fd                	addiw	a5,a5,-1
    80005d0a:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005d0e:	854a                	mv	a0,s2
    80005d10:	ffffe097          	auipc	ra,0xffffe
    80005d14:	fde080e7          	jalr	-34(ra) # 80003cee <iupdate>
  iunlockput(ip);
    80005d18:	854a                	mv	a0,s2
    80005d1a:	ffffe097          	auipc	ra,0xffffe
    80005d1e:	306080e7          	jalr	774(ra) # 80004020 <iunlockput>
  end_op();
    80005d22:	fffff097          	auipc	ra,0xfffff
    80005d26:	ae0080e7          	jalr	-1312(ra) # 80004802 <end_op>
  return 0;
    80005d2a:	4501                	li	a0,0
    80005d2c:	64ee                	ld	s1,216(sp)
    80005d2e:	694e                	ld	s2,208(sp)
    80005d30:	a84d                	j	80005de2 <sys_unlink+0x1c6>
    end_op();
    80005d32:	fffff097          	auipc	ra,0xfffff
    80005d36:	ad0080e7          	jalr	-1328(ra) # 80004802 <end_op>
    return -1;
    80005d3a:	557d                	li	a0,-1
    80005d3c:	64ee                	ld	s1,216(sp)
    80005d3e:	a055                	j	80005de2 <sys_unlink+0x1c6>
    80005d40:	e5ce                	sd	s3,200(sp)
    panic("unlink: nlink < 1");
    80005d42:	00003517          	auipc	a0,0x3
    80005d46:	a2e50513          	addi	a0,a0,-1490 # 80008770 <etext+0x770>
    80005d4a:	ffffb097          	auipc	ra,0xffffb
    80005d4e:	816080e7          	jalr	-2026(ra) # 80000560 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005d52:	04c92703          	lw	a4,76(s2)
    80005d56:	02000793          	li	a5,32
    80005d5a:	f6e7f5e3          	bgeu	a5,a4,80005cc4 <sys_unlink+0xa8>
    80005d5e:	e5ce                	sd	s3,200(sp)
    80005d60:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005d64:	4741                	li	a4,16
    80005d66:	86ce                	mv	a3,s3
    80005d68:	f1840613          	addi	a2,s0,-232
    80005d6c:	4581                	li	a1,0
    80005d6e:	854a                	mv	a0,s2
    80005d70:	ffffe097          	auipc	ra,0xffffe
    80005d74:	302080e7          	jalr	770(ra) # 80004072 <readi>
    80005d78:	47c1                	li	a5,16
    80005d7a:	00f51c63          	bne	a0,a5,80005d92 <sys_unlink+0x176>
    if(de.inum != 0)
    80005d7e:	f1845783          	lhu	a5,-232(s0)
    80005d82:	e7b5                	bnez	a5,80005dee <sys_unlink+0x1d2>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005d84:	29c1                	addiw	s3,s3,16
    80005d86:	04c92783          	lw	a5,76(s2)
    80005d8a:	fcf9ede3          	bltu	s3,a5,80005d64 <sys_unlink+0x148>
    80005d8e:	69ae                	ld	s3,200(sp)
    80005d90:	bf15                	j	80005cc4 <sys_unlink+0xa8>
      panic("isdirempty: readi");
    80005d92:	00003517          	auipc	a0,0x3
    80005d96:	9f650513          	addi	a0,a0,-1546 # 80008788 <etext+0x788>
    80005d9a:	ffffa097          	auipc	ra,0xffffa
    80005d9e:	7c6080e7          	jalr	1990(ra) # 80000560 <panic>
    80005da2:	e5ce                	sd	s3,200(sp)
    panic("unlink: writei");
    80005da4:	00003517          	auipc	a0,0x3
    80005da8:	9fc50513          	addi	a0,a0,-1540 # 800087a0 <etext+0x7a0>
    80005dac:	ffffa097          	auipc	ra,0xffffa
    80005db0:	7b4080e7          	jalr	1972(ra) # 80000560 <panic>
    dp->nlink--;
    80005db4:	04a4d783          	lhu	a5,74(s1)
    80005db8:	37fd                	addiw	a5,a5,-1
    80005dba:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005dbe:	8526                	mv	a0,s1
    80005dc0:	ffffe097          	auipc	ra,0xffffe
    80005dc4:	f2e080e7          	jalr	-210(ra) # 80003cee <iupdate>
    80005dc8:	bf0d                	j	80005cfa <sys_unlink+0xde>
    80005dca:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    80005dcc:	8526                	mv	a0,s1
    80005dce:	ffffe097          	auipc	ra,0xffffe
    80005dd2:	252080e7          	jalr	594(ra) # 80004020 <iunlockput>
  end_op();
    80005dd6:	fffff097          	auipc	ra,0xfffff
    80005dda:	a2c080e7          	jalr	-1492(ra) # 80004802 <end_op>
  return -1;
    80005dde:	557d                	li	a0,-1
    80005de0:	64ee                	ld	s1,216(sp)
}
    80005de2:	70ae                	ld	ra,232(sp)
    80005de4:	740e                	ld	s0,224(sp)
    80005de6:	616d                	addi	sp,sp,240
    80005de8:	8082                	ret
    return -1;
    80005dea:	557d                	li	a0,-1
    80005dec:	bfdd                	j	80005de2 <sys_unlink+0x1c6>
    iunlockput(ip);
    80005dee:	854a                	mv	a0,s2
    80005df0:	ffffe097          	auipc	ra,0xffffe
    80005df4:	230080e7          	jalr	560(ra) # 80004020 <iunlockput>
    goto bad;
    80005df8:	694e                	ld	s2,208(sp)
    80005dfa:	69ae                	ld	s3,200(sp)
    80005dfc:	bfc1                	j	80005dcc <sys_unlink+0x1b0>

0000000080005dfe <sys_open>:

uint64
sys_open(void)
{
    80005dfe:	7131                	addi	sp,sp,-192
    80005e00:	fd06                	sd	ra,184(sp)
    80005e02:	f922                	sd	s0,176(sp)
    80005e04:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005e06:	f4c40593          	addi	a1,s0,-180
    80005e0a:	4505                	li	a0,1
    80005e0c:	ffffd097          	auipc	ra,0xffffd
    80005e10:	25a080e7          	jalr	602(ra) # 80003066 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005e14:	08000613          	li	a2,128
    80005e18:	f5040593          	addi	a1,s0,-176
    80005e1c:	4501                	li	a0,0
    80005e1e:	ffffd097          	auipc	ra,0xffffd
    80005e22:	288080e7          	jalr	648(ra) # 800030a6 <argstr>
    80005e26:	87aa                	mv	a5,a0
    return -1;
    80005e28:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005e2a:	0a07ce63          	bltz	a5,80005ee6 <sys_open+0xe8>
    80005e2e:	f526                	sd	s1,168(sp)

  begin_op();
    80005e30:	fffff097          	auipc	ra,0xfffff
    80005e34:	958080e7          	jalr	-1704(ra) # 80004788 <begin_op>

  if(omode & O_CREATE){
    80005e38:	f4c42783          	lw	a5,-180(s0)
    80005e3c:	2007f793          	andi	a5,a5,512
    80005e40:	cfd5                	beqz	a5,80005efc <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005e42:	4681                	li	a3,0
    80005e44:	4601                	li	a2,0
    80005e46:	4589                	li	a1,2
    80005e48:	f5040513          	addi	a0,s0,-176
    80005e4c:	00000097          	auipc	ra,0x0
    80005e50:	95c080e7          	jalr	-1700(ra) # 800057a8 <create>
    80005e54:	84aa                	mv	s1,a0
    if(ip == 0){
    80005e56:	cd41                	beqz	a0,80005eee <sys_open+0xf0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005e58:	04449703          	lh	a4,68(s1)
    80005e5c:	478d                	li	a5,3
    80005e5e:	00f71763          	bne	a4,a5,80005e6c <sys_open+0x6e>
    80005e62:	0464d703          	lhu	a4,70(s1)
    80005e66:	47a5                	li	a5,9
    80005e68:	0ee7e163          	bltu	a5,a4,80005f4a <sys_open+0x14c>
    80005e6c:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005e6e:	fffff097          	auipc	ra,0xfffff
    80005e72:	d28080e7          	jalr	-728(ra) # 80004b96 <filealloc>
    80005e76:	892a                	mv	s2,a0
    80005e78:	c97d                	beqz	a0,80005f6e <sys_open+0x170>
    80005e7a:	ed4e                	sd	s3,152(sp)
    80005e7c:	00000097          	auipc	ra,0x0
    80005e80:	8ea080e7          	jalr	-1814(ra) # 80005766 <fdalloc>
    80005e84:	89aa                	mv	s3,a0
    80005e86:	0c054e63          	bltz	a0,80005f62 <sys_open+0x164>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005e8a:	04449703          	lh	a4,68(s1)
    80005e8e:	478d                	li	a5,3
    80005e90:	0ef70c63          	beq	a4,a5,80005f88 <sys_open+0x18a>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005e94:	4789                	li	a5,2
    80005e96:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80005e9a:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80005e9e:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    80005ea2:	f4c42783          	lw	a5,-180(s0)
    80005ea6:	0017c713          	xori	a4,a5,1
    80005eaa:	8b05                	andi	a4,a4,1
    80005eac:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005eb0:	0037f713          	andi	a4,a5,3
    80005eb4:	00e03733          	snez	a4,a4
    80005eb8:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005ebc:	4007f793          	andi	a5,a5,1024
    80005ec0:	c791                	beqz	a5,80005ecc <sys_open+0xce>
    80005ec2:	04449703          	lh	a4,68(s1)
    80005ec6:	4789                	li	a5,2
    80005ec8:	0cf70763          	beq	a4,a5,80005f96 <sys_open+0x198>
    itrunc(ip);
  }

  iunlock(ip);
    80005ecc:	8526                	mv	a0,s1
    80005ece:	ffffe097          	auipc	ra,0xffffe
    80005ed2:	fb2080e7          	jalr	-78(ra) # 80003e80 <iunlock>
  end_op();
    80005ed6:	fffff097          	auipc	ra,0xfffff
    80005eda:	92c080e7          	jalr	-1748(ra) # 80004802 <end_op>

  return fd;
    80005ede:	854e                	mv	a0,s3
    80005ee0:	74aa                	ld	s1,168(sp)
    80005ee2:	790a                	ld	s2,160(sp)
    80005ee4:	69ea                	ld	s3,152(sp)
}
    80005ee6:	70ea                	ld	ra,184(sp)
    80005ee8:	744a                	ld	s0,176(sp)
    80005eea:	6129                	addi	sp,sp,192
    80005eec:	8082                	ret
      end_op();
    80005eee:	fffff097          	auipc	ra,0xfffff
    80005ef2:	914080e7          	jalr	-1772(ra) # 80004802 <end_op>
      return -1;
    80005ef6:	557d                	li	a0,-1
    80005ef8:	74aa                	ld	s1,168(sp)
    80005efa:	b7f5                	j	80005ee6 <sys_open+0xe8>
    if((ip = namei(path)) == 0){
    80005efc:	f5040513          	addi	a0,s0,-176
    80005f00:	ffffe097          	auipc	ra,0xffffe
    80005f04:	688080e7          	jalr	1672(ra) # 80004588 <namei>
    80005f08:	84aa                	mv	s1,a0
    80005f0a:	c90d                	beqz	a0,80005f3c <sys_open+0x13e>
    ilock(ip);
    80005f0c:	ffffe097          	auipc	ra,0xffffe
    80005f10:	eae080e7          	jalr	-338(ra) # 80003dba <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005f14:	04449703          	lh	a4,68(s1)
    80005f18:	4785                	li	a5,1
    80005f1a:	f2f71fe3          	bne	a4,a5,80005e58 <sys_open+0x5a>
    80005f1e:	f4c42783          	lw	a5,-180(s0)
    80005f22:	d7a9                	beqz	a5,80005e6c <sys_open+0x6e>
      iunlockput(ip);
    80005f24:	8526                	mv	a0,s1
    80005f26:	ffffe097          	auipc	ra,0xffffe
    80005f2a:	0fa080e7          	jalr	250(ra) # 80004020 <iunlockput>
      end_op();
    80005f2e:	fffff097          	auipc	ra,0xfffff
    80005f32:	8d4080e7          	jalr	-1836(ra) # 80004802 <end_op>
      return -1;
    80005f36:	557d                	li	a0,-1
    80005f38:	74aa                	ld	s1,168(sp)
    80005f3a:	b775                	j	80005ee6 <sys_open+0xe8>
      end_op();
    80005f3c:	fffff097          	auipc	ra,0xfffff
    80005f40:	8c6080e7          	jalr	-1850(ra) # 80004802 <end_op>
      return -1;
    80005f44:	557d                	li	a0,-1
    80005f46:	74aa                	ld	s1,168(sp)
    80005f48:	bf79                	j	80005ee6 <sys_open+0xe8>
    iunlockput(ip);
    80005f4a:	8526                	mv	a0,s1
    80005f4c:	ffffe097          	auipc	ra,0xffffe
    80005f50:	0d4080e7          	jalr	212(ra) # 80004020 <iunlockput>
    end_op();
    80005f54:	fffff097          	auipc	ra,0xfffff
    80005f58:	8ae080e7          	jalr	-1874(ra) # 80004802 <end_op>
    return -1;
    80005f5c:	557d                	li	a0,-1
    80005f5e:	74aa                	ld	s1,168(sp)
    80005f60:	b759                	j	80005ee6 <sys_open+0xe8>
      fileclose(f);
    80005f62:	854a                	mv	a0,s2
    80005f64:	fffff097          	auipc	ra,0xfffff
    80005f68:	cee080e7          	jalr	-786(ra) # 80004c52 <fileclose>
    80005f6c:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    80005f6e:	8526                	mv	a0,s1
    80005f70:	ffffe097          	auipc	ra,0xffffe
    80005f74:	0b0080e7          	jalr	176(ra) # 80004020 <iunlockput>
    end_op();
    80005f78:	fffff097          	auipc	ra,0xfffff
    80005f7c:	88a080e7          	jalr	-1910(ra) # 80004802 <end_op>
    return -1;
    80005f80:	557d                	li	a0,-1
    80005f82:	74aa                	ld	s1,168(sp)
    80005f84:	790a                	ld	s2,160(sp)
    80005f86:	b785                	j	80005ee6 <sys_open+0xe8>
    f->type = FD_DEVICE;
    80005f88:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    80005f8c:	04649783          	lh	a5,70(s1)
    80005f90:	02f91223          	sh	a5,36(s2)
    80005f94:	b729                	j	80005e9e <sys_open+0xa0>
    itrunc(ip);
    80005f96:	8526                	mv	a0,s1
    80005f98:	ffffe097          	auipc	ra,0xffffe
    80005f9c:	f34080e7          	jalr	-204(ra) # 80003ecc <itrunc>
    80005fa0:	b735                	j	80005ecc <sys_open+0xce>

0000000080005fa2 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005fa2:	7175                	addi	sp,sp,-144
    80005fa4:	e506                	sd	ra,136(sp)
    80005fa6:	e122                	sd	s0,128(sp)
    80005fa8:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005faa:	ffffe097          	auipc	ra,0xffffe
    80005fae:	7de080e7          	jalr	2014(ra) # 80004788 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005fb2:	08000613          	li	a2,128
    80005fb6:	f7040593          	addi	a1,s0,-144
    80005fba:	4501                	li	a0,0
    80005fbc:	ffffd097          	auipc	ra,0xffffd
    80005fc0:	0ea080e7          	jalr	234(ra) # 800030a6 <argstr>
    80005fc4:	02054963          	bltz	a0,80005ff6 <sys_mkdir+0x54>
    80005fc8:	4681                	li	a3,0
    80005fca:	4601                	li	a2,0
    80005fcc:	4585                	li	a1,1
    80005fce:	f7040513          	addi	a0,s0,-144
    80005fd2:	fffff097          	auipc	ra,0xfffff
    80005fd6:	7d6080e7          	jalr	2006(ra) # 800057a8 <create>
    80005fda:	cd11                	beqz	a0,80005ff6 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005fdc:	ffffe097          	auipc	ra,0xffffe
    80005fe0:	044080e7          	jalr	68(ra) # 80004020 <iunlockput>
  end_op();
    80005fe4:	fffff097          	auipc	ra,0xfffff
    80005fe8:	81e080e7          	jalr	-2018(ra) # 80004802 <end_op>
  return 0;
    80005fec:	4501                	li	a0,0
}
    80005fee:	60aa                	ld	ra,136(sp)
    80005ff0:	640a                	ld	s0,128(sp)
    80005ff2:	6149                	addi	sp,sp,144
    80005ff4:	8082                	ret
    end_op();
    80005ff6:	fffff097          	auipc	ra,0xfffff
    80005ffa:	80c080e7          	jalr	-2036(ra) # 80004802 <end_op>
    return -1;
    80005ffe:	557d                	li	a0,-1
    80006000:	b7fd                	j	80005fee <sys_mkdir+0x4c>

0000000080006002 <sys_mknod>:

uint64
sys_mknod(void)
{
    80006002:	7135                	addi	sp,sp,-160
    80006004:	ed06                	sd	ra,152(sp)
    80006006:	e922                	sd	s0,144(sp)
    80006008:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    8000600a:	ffffe097          	auipc	ra,0xffffe
    8000600e:	77e080e7          	jalr	1918(ra) # 80004788 <begin_op>
  argint(1, &major);
    80006012:	f6c40593          	addi	a1,s0,-148
    80006016:	4505                	li	a0,1
    80006018:	ffffd097          	auipc	ra,0xffffd
    8000601c:	04e080e7          	jalr	78(ra) # 80003066 <argint>
  argint(2, &minor);
    80006020:	f6840593          	addi	a1,s0,-152
    80006024:	4509                	li	a0,2
    80006026:	ffffd097          	auipc	ra,0xffffd
    8000602a:	040080e7          	jalr	64(ra) # 80003066 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000602e:	08000613          	li	a2,128
    80006032:	f7040593          	addi	a1,s0,-144
    80006036:	4501                	li	a0,0
    80006038:	ffffd097          	auipc	ra,0xffffd
    8000603c:	06e080e7          	jalr	110(ra) # 800030a6 <argstr>
    80006040:	02054b63          	bltz	a0,80006076 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80006044:	f6841683          	lh	a3,-152(s0)
    80006048:	f6c41603          	lh	a2,-148(s0)
    8000604c:	458d                	li	a1,3
    8000604e:	f7040513          	addi	a0,s0,-144
    80006052:	fffff097          	auipc	ra,0xfffff
    80006056:	756080e7          	jalr	1878(ra) # 800057a8 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000605a:	cd11                	beqz	a0,80006076 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000605c:	ffffe097          	auipc	ra,0xffffe
    80006060:	fc4080e7          	jalr	-60(ra) # 80004020 <iunlockput>
  end_op();
    80006064:	ffffe097          	auipc	ra,0xffffe
    80006068:	79e080e7          	jalr	1950(ra) # 80004802 <end_op>
  return 0;
    8000606c:	4501                	li	a0,0
}
    8000606e:	60ea                	ld	ra,152(sp)
    80006070:	644a                	ld	s0,144(sp)
    80006072:	610d                	addi	sp,sp,160
    80006074:	8082                	ret
    end_op();
    80006076:	ffffe097          	auipc	ra,0xffffe
    8000607a:	78c080e7          	jalr	1932(ra) # 80004802 <end_op>
    return -1;
    8000607e:	557d                	li	a0,-1
    80006080:	b7fd                	j	8000606e <sys_mknod+0x6c>

0000000080006082 <sys_chdir>:

uint64
sys_chdir(void)
{
    80006082:	7135                	addi	sp,sp,-160
    80006084:	ed06                	sd	ra,152(sp)
    80006086:	e922                	sd	s0,144(sp)
    80006088:	e14a                	sd	s2,128(sp)
    8000608a:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    8000608c:	ffffc097          	auipc	ra,0xffffc
    80006090:	a9e080e7          	jalr	-1378(ra) # 80001b2a <myproc>
    80006094:	892a                	mv	s2,a0
  
  begin_op();
    80006096:	ffffe097          	auipc	ra,0xffffe
    8000609a:	6f2080e7          	jalr	1778(ra) # 80004788 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    8000609e:	08000613          	li	a2,128
    800060a2:	f6040593          	addi	a1,s0,-160
    800060a6:	4501                	li	a0,0
    800060a8:	ffffd097          	auipc	ra,0xffffd
    800060ac:	ffe080e7          	jalr	-2(ra) # 800030a6 <argstr>
    800060b0:	04054d63          	bltz	a0,8000610a <sys_chdir+0x88>
    800060b4:	e526                	sd	s1,136(sp)
    800060b6:	f6040513          	addi	a0,s0,-160
    800060ba:	ffffe097          	auipc	ra,0xffffe
    800060be:	4ce080e7          	jalr	1230(ra) # 80004588 <namei>
    800060c2:	84aa                	mv	s1,a0
    800060c4:	c131                	beqz	a0,80006108 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    800060c6:	ffffe097          	auipc	ra,0xffffe
    800060ca:	cf4080e7          	jalr	-780(ra) # 80003dba <ilock>
  if(ip->type != T_DIR){
    800060ce:	04449703          	lh	a4,68(s1)
    800060d2:	4785                	li	a5,1
    800060d4:	04f71163          	bne	a4,a5,80006116 <sys_chdir+0x94>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    800060d8:	8526                	mv	a0,s1
    800060da:	ffffe097          	auipc	ra,0xffffe
    800060de:	da6080e7          	jalr	-602(ra) # 80003e80 <iunlock>
  iput(p->cwd);
    800060e2:	15093503          	ld	a0,336(s2)
    800060e6:	ffffe097          	auipc	ra,0xffffe
    800060ea:	e92080e7          	jalr	-366(ra) # 80003f78 <iput>
  end_op();
    800060ee:	ffffe097          	auipc	ra,0xffffe
    800060f2:	714080e7          	jalr	1812(ra) # 80004802 <end_op>
  p->cwd = ip;
    800060f6:	14993823          	sd	s1,336(s2)
  return 0;
    800060fa:	4501                	li	a0,0
    800060fc:	64aa                	ld	s1,136(sp)
}
    800060fe:	60ea                	ld	ra,152(sp)
    80006100:	644a                	ld	s0,144(sp)
    80006102:	690a                	ld	s2,128(sp)
    80006104:	610d                	addi	sp,sp,160
    80006106:	8082                	ret
    80006108:	64aa                	ld	s1,136(sp)
    end_op();
    8000610a:	ffffe097          	auipc	ra,0xffffe
    8000610e:	6f8080e7          	jalr	1784(ra) # 80004802 <end_op>
    return -1;
    80006112:	557d                	li	a0,-1
    80006114:	b7ed                	j	800060fe <sys_chdir+0x7c>
    iunlockput(ip);
    80006116:	8526                	mv	a0,s1
    80006118:	ffffe097          	auipc	ra,0xffffe
    8000611c:	f08080e7          	jalr	-248(ra) # 80004020 <iunlockput>
    end_op();
    80006120:	ffffe097          	auipc	ra,0xffffe
    80006124:	6e2080e7          	jalr	1762(ra) # 80004802 <end_op>
    return -1;
    80006128:	557d                	li	a0,-1
    8000612a:	64aa                	ld	s1,136(sp)
    8000612c:	bfc9                	j	800060fe <sys_chdir+0x7c>

000000008000612e <sys_exec>:

uint64
sys_exec(void)
{
    8000612e:	7121                	addi	sp,sp,-448
    80006130:	ff06                	sd	ra,440(sp)
    80006132:	fb22                	sd	s0,432(sp)
    80006134:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80006136:	e4840593          	addi	a1,s0,-440
    8000613a:	4505                	li	a0,1
    8000613c:	ffffd097          	auipc	ra,0xffffd
    80006140:	f4a080e7          	jalr	-182(ra) # 80003086 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80006144:	08000613          	li	a2,128
    80006148:	f5040593          	addi	a1,s0,-176
    8000614c:	4501                	li	a0,0
    8000614e:	ffffd097          	auipc	ra,0xffffd
    80006152:	f58080e7          	jalr	-168(ra) # 800030a6 <argstr>
    80006156:	87aa                	mv	a5,a0
    return -1;
    80006158:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    8000615a:	0e07c263          	bltz	a5,8000623e <sys_exec+0x110>
    8000615e:	f726                	sd	s1,424(sp)
    80006160:	f34a                	sd	s2,416(sp)
    80006162:	ef4e                	sd	s3,408(sp)
    80006164:	eb52                	sd	s4,400(sp)
  }
  memset(argv, 0, sizeof(argv));
    80006166:	10000613          	li	a2,256
    8000616a:	4581                	li	a1,0
    8000616c:	e5040513          	addi	a0,s0,-432
    80006170:	ffffb097          	auipc	ra,0xffffb
    80006174:	bc4080e7          	jalr	-1084(ra) # 80000d34 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80006178:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    8000617c:	89a6                	mv	s3,s1
    8000617e:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80006180:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80006184:	00391513          	slli	a0,s2,0x3
    80006188:	e4040593          	addi	a1,s0,-448
    8000618c:	e4843783          	ld	a5,-440(s0)
    80006190:	953e                	add	a0,a0,a5
    80006192:	ffffd097          	auipc	ra,0xffffd
    80006196:	e36080e7          	jalr	-458(ra) # 80002fc8 <fetchaddr>
    8000619a:	02054a63          	bltz	a0,800061ce <sys_exec+0xa0>
      goto bad;
    }
    if(uarg == 0){
    8000619e:	e4043783          	ld	a5,-448(s0)
    800061a2:	c7b9                	beqz	a5,800061f0 <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    800061a4:	ffffb097          	auipc	ra,0xffffb
    800061a8:	9a4080e7          	jalr	-1628(ra) # 80000b48 <kalloc>
    800061ac:	85aa                	mv	a1,a0
    800061ae:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    800061b2:	cd11                	beqz	a0,800061ce <sys_exec+0xa0>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    800061b4:	6605                	lui	a2,0x1
    800061b6:	e4043503          	ld	a0,-448(s0)
    800061ba:	ffffd097          	auipc	ra,0xffffd
    800061be:	e60080e7          	jalr	-416(ra) # 8000301a <fetchstr>
    800061c2:	00054663          	bltz	a0,800061ce <sys_exec+0xa0>
    if(i >= NELEM(argv)){
    800061c6:	0905                	addi	s2,s2,1
    800061c8:	09a1                	addi	s3,s3,8
    800061ca:	fb491de3          	bne	s2,s4,80006184 <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800061ce:	f5040913          	addi	s2,s0,-176
    800061d2:	6088                	ld	a0,0(s1)
    800061d4:	c125                	beqz	a0,80006234 <sys_exec+0x106>
    kfree(argv[i]);
    800061d6:	ffffb097          	auipc	ra,0xffffb
    800061da:	874080e7          	jalr	-1932(ra) # 80000a4a <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800061de:	04a1                	addi	s1,s1,8
    800061e0:	ff2499e3          	bne	s1,s2,800061d2 <sys_exec+0xa4>
  return -1;
    800061e4:	557d                	li	a0,-1
    800061e6:	74ba                	ld	s1,424(sp)
    800061e8:	791a                	ld	s2,416(sp)
    800061ea:	69fa                	ld	s3,408(sp)
    800061ec:	6a5a                	ld	s4,400(sp)
    800061ee:	a881                	j	8000623e <sys_exec+0x110>
      argv[i] = 0;
    800061f0:	0009079b          	sext.w	a5,s2
    800061f4:	078e                	slli	a5,a5,0x3
    800061f6:	fd078793          	addi	a5,a5,-48
    800061fa:	97a2                	add	a5,a5,s0
    800061fc:	e807b023          	sd	zero,-384(a5)
  int ret = exec(path, argv);
    80006200:	e5040593          	addi	a1,s0,-432
    80006204:	f5040513          	addi	a0,s0,-176
    80006208:	fffff097          	auipc	ra,0xfffff
    8000620c:	120080e7          	jalr	288(ra) # 80005328 <exec>
    80006210:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006212:	f5040993          	addi	s3,s0,-176
    80006216:	6088                	ld	a0,0(s1)
    80006218:	c901                	beqz	a0,80006228 <sys_exec+0xfa>
    kfree(argv[i]);
    8000621a:	ffffb097          	auipc	ra,0xffffb
    8000621e:	830080e7          	jalr	-2000(ra) # 80000a4a <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006222:	04a1                	addi	s1,s1,8
    80006224:	ff3499e3          	bne	s1,s3,80006216 <sys_exec+0xe8>
  return ret;
    80006228:	854a                	mv	a0,s2
    8000622a:	74ba                	ld	s1,424(sp)
    8000622c:	791a                	ld	s2,416(sp)
    8000622e:	69fa                	ld	s3,408(sp)
    80006230:	6a5a                	ld	s4,400(sp)
    80006232:	a031                	j	8000623e <sys_exec+0x110>
  return -1;
    80006234:	557d                	li	a0,-1
    80006236:	74ba                	ld	s1,424(sp)
    80006238:	791a                	ld	s2,416(sp)
    8000623a:	69fa                	ld	s3,408(sp)
    8000623c:	6a5a                	ld	s4,400(sp)
}
    8000623e:	70fa                	ld	ra,440(sp)
    80006240:	745a                	ld	s0,432(sp)
    80006242:	6139                	addi	sp,sp,448
    80006244:	8082                	ret

0000000080006246 <sys_pipe>:

uint64
sys_pipe(void)
{
    80006246:	7139                	addi	sp,sp,-64
    80006248:	fc06                	sd	ra,56(sp)
    8000624a:	f822                	sd	s0,48(sp)
    8000624c:	f426                	sd	s1,40(sp)
    8000624e:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80006250:	ffffc097          	auipc	ra,0xffffc
    80006254:	8da080e7          	jalr	-1830(ra) # 80001b2a <myproc>
    80006258:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    8000625a:	fd840593          	addi	a1,s0,-40
    8000625e:	4501                	li	a0,0
    80006260:	ffffd097          	auipc	ra,0xffffd
    80006264:	e26080e7          	jalr	-474(ra) # 80003086 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80006268:	fc840593          	addi	a1,s0,-56
    8000626c:	fd040513          	addi	a0,s0,-48
    80006270:	fffff097          	auipc	ra,0xfffff
    80006274:	d50080e7          	jalr	-688(ra) # 80004fc0 <pipealloc>
    return -1;
    80006278:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    8000627a:	0c054463          	bltz	a0,80006342 <sys_pipe+0xfc>
  fd0 = -1;
    8000627e:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80006282:	fd043503          	ld	a0,-48(s0)
    80006286:	fffff097          	auipc	ra,0xfffff
    8000628a:	4e0080e7          	jalr	1248(ra) # 80005766 <fdalloc>
    8000628e:	fca42223          	sw	a0,-60(s0)
    80006292:	08054b63          	bltz	a0,80006328 <sys_pipe+0xe2>
    80006296:	fc843503          	ld	a0,-56(s0)
    8000629a:	fffff097          	auipc	ra,0xfffff
    8000629e:	4cc080e7          	jalr	1228(ra) # 80005766 <fdalloc>
    800062a2:	fca42023          	sw	a0,-64(s0)
    800062a6:	06054863          	bltz	a0,80006316 <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800062aa:	4691                	li	a3,4
    800062ac:	fc440613          	addi	a2,s0,-60
    800062b0:	fd843583          	ld	a1,-40(s0)
    800062b4:	68a8                	ld	a0,80(s1)
    800062b6:	ffffb097          	auipc	ra,0xffffb
    800062ba:	42c080e7          	jalr	1068(ra) # 800016e2 <copyout>
    800062be:	02054063          	bltz	a0,800062de <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    800062c2:	4691                	li	a3,4
    800062c4:	fc040613          	addi	a2,s0,-64
    800062c8:	fd843583          	ld	a1,-40(s0)
    800062cc:	0591                	addi	a1,a1,4
    800062ce:	68a8                	ld	a0,80(s1)
    800062d0:	ffffb097          	auipc	ra,0xffffb
    800062d4:	412080e7          	jalr	1042(ra) # 800016e2 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    800062d8:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800062da:	06055463          	bgez	a0,80006342 <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    800062de:	fc442783          	lw	a5,-60(s0)
    800062e2:	07e9                	addi	a5,a5,26
    800062e4:	078e                	slli	a5,a5,0x3
    800062e6:	97a6                	add	a5,a5,s1
    800062e8:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    800062ec:	fc042783          	lw	a5,-64(s0)
    800062f0:	07e9                	addi	a5,a5,26
    800062f2:	078e                	slli	a5,a5,0x3
    800062f4:	94be                	add	s1,s1,a5
    800062f6:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    800062fa:	fd043503          	ld	a0,-48(s0)
    800062fe:	fffff097          	auipc	ra,0xfffff
    80006302:	954080e7          	jalr	-1708(ra) # 80004c52 <fileclose>
    fileclose(wf);
    80006306:	fc843503          	ld	a0,-56(s0)
    8000630a:	fffff097          	auipc	ra,0xfffff
    8000630e:	948080e7          	jalr	-1720(ra) # 80004c52 <fileclose>
    return -1;
    80006312:	57fd                	li	a5,-1
    80006314:	a03d                	j	80006342 <sys_pipe+0xfc>
    if(fd0 >= 0)
    80006316:	fc442783          	lw	a5,-60(s0)
    8000631a:	0007c763          	bltz	a5,80006328 <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    8000631e:	07e9                	addi	a5,a5,26
    80006320:	078e                	slli	a5,a5,0x3
    80006322:	97a6                	add	a5,a5,s1
    80006324:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80006328:	fd043503          	ld	a0,-48(s0)
    8000632c:	fffff097          	auipc	ra,0xfffff
    80006330:	926080e7          	jalr	-1754(ra) # 80004c52 <fileclose>
    fileclose(wf);
    80006334:	fc843503          	ld	a0,-56(s0)
    80006338:	fffff097          	auipc	ra,0xfffff
    8000633c:	91a080e7          	jalr	-1766(ra) # 80004c52 <fileclose>
    return -1;
    80006340:	57fd                	li	a5,-1
}
    80006342:	853e                	mv	a0,a5
    80006344:	70e2                	ld	ra,56(sp)
    80006346:	7442                	ld	s0,48(sp)
    80006348:	74a2                	ld	s1,40(sp)
    8000634a:	6121                	addi	sp,sp,64
    8000634c:	8082                	ret
	...

0000000080006350 <kernelvec>:
    80006350:	7111                	addi	sp,sp,-256
    80006352:	e006                	sd	ra,0(sp)
    80006354:	e40a                	sd	sp,8(sp)
    80006356:	e80e                	sd	gp,16(sp)
    80006358:	ec12                	sd	tp,24(sp)
    8000635a:	f016                	sd	t0,32(sp)
    8000635c:	f41a                	sd	t1,40(sp)
    8000635e:	f81e                	sd	t2,48(sp)
    80006360:	fc22                	sd	s0,56(sp)
    80006362:	e0a6                	sd	s1,64(sp)
    80006364:	e4aa                	sd	a0,72(sp)
    80006366:	e8ae                	sd	a1,80(sp)
    80006368:	ecb2                	sd	a2,88(sp)
    8000636a:	f0b6                	sd	a3,96(sp)
    8000636c:	f4ba                	sd	a4,104(sp)
    8000636e:	f8be                	sd	a5,112(sp)
    80006370:	fcc2                	sd	a6,120(sp)
    80006372:	e146                	sd	a7,128(sp)
    80006374:	e54a                	sd	s2,136(sp)
    80006376:	e94e                	sd	s3,144(sp)
    80006378:	ed52                	sd	s4,152(sp)
    8000637a:	f156                	sd	s5,160(sp)
    8000637c:	f55a                	sd	s6,168(sp)
    8000637e:	f95e                	sd	s7,176(sp)
    80006380:	fd62                	sd	s8,184(sp)
    80006382:	e1e6                	sd	s9,192(sp)
    80006384:	e5ea                	sd	s10,200(sp)
    80006386:	e9ee                	sd	s11,208(sp)
    80006388:	edf2                	sd	t3,216(sp)
    8000638a:	f1f6                	sd	t4,224(sp)
    8000638c:	f5fa                	sd	t5,232(sp)
    8000638e:	f9fe                	sd	t6,240(sp)
    80006390:	b05fc0ef          	jal	80002e94 <kerneltrap>
    80006394:	6082                	ld	ra,0(sp)
    80006396:	6122                	ld	sp,8(sp)
    80006398:	61c2                	ld	gp,16(sp)
    8000639a:	7282                	ld	t0,32(sp)
    8000639c:	7322                	ld	t1,40(sp)
    8000639e:	73c2                	ld	t2,48(sp)
    800063a0:	7462                	ld	s0,56(sp)
    800063a2:	6486                	ld	s1,64(sp)
    800063a4:	6526                	ld	a0,72(sp)
    800063a6:	65c6                	ld	a1,80(sp)
    800063a8:	6666                	ld	a2,88(sp)
    800063aa:	7686                	ld	a3,96(sp)
    800063ac:	7726                	ld	a4,104(sp)
    800063ae:	77c6                	ld	a5,112(sp)
    800063b0:	7866                	ld	a6,120(sp)
    800063b2:	688a                	ld	a7,128(sp)
    800063b4:	692a                	ld	s2,136(sp)
    800063b6:	69ca                	ld	s3,144(sp)
    800063b8:	6a6a                	ld	s4,152(sp)
    800063ba:	7a8a                	ld	s5,160(sp)
    800063bc:	7b2a                	ld	s6,168(sp)
    800063be:	7bca                	ld	s7,176(sp)
    800063c0:	7c6a                	ld	s8,184(sp)
    800063c2:	6c8e                	ld	s9,192(sp)
    800063c4:	6d2e                	ld	s10,200(sp)
    800063c6:	6dce                	ld	s11,208(sp)
    800063c8:	6e6e                	ld	t3,216(sp)
    800063ca:	7e8e                	ld	t4,224(sp)
    800063cc:	7f2e                	ld	t5,232(sp)
    800063ce:	7fce                	ld	t6,240(sp)
    800063d0:	6111                	addi	sp,sp,256
    800063d2:	10200073          	sret
    800063d6:	00000013          	nop
    800063da:	00000013          	nop
    800063de:	0001                	nop

00000000800063e0 <timervec>:
    800063e0:	34051573          	csrrw	a0,mscratch,a0
    800063e4:	e10c                	sd	a1,0(a0)
    800063e6:	e510                	sd	a2,8(a0)
    800063e8:	e914                	sd	a3,16(a0)
    800063ea:	6d0c                	ld	a1,24(a0)
    800063ec:	7110                	ld	a2,32(a0)
    800063ee:	6194                	ld	a3,0(a1)
    800063f0:	96b2                	add	a3,a3,a2
    800063f2:	e194                	sd	a3,0(a1)
    800063f4:	4589                	li	a1,2
    800063f6:	14459073          	csrw	sip,a1
    800063fa:	6914                	ld	a3,16(a0)
    800063fc:	6510                	ld	a2,8(a0)
    800063fe:	610c                	ld	a1,0(a0)
    80006400:	34051573          	csrrw	a0,mscratch,a0
    80006404:	30200073          	mret
	...

000000008000640a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000640a:	1141                	addi	sp,sp,-16
    8000640c:	e422                	sd	s0,8(sp)
    8000640e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006410:	0c0007b7          	lui	a5,0xc000
    80006414:	4705                	li	a4,1
    80006416:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80006418:	0c0007b7          	lui	a5,0xc000
    8000641c:	c3d8                	sw	a4,4(a5)
}
    8000641e:	6422                	ld	s0,8(sp)
    80006420:	0141                	addi	sp,sp,16
    80006422:	8082                	ret

0000000080006424 <plicinithart>:

void
plicinithart(void)
{
    80006424:	1141                	addi	sp,sp,-16
    80006426:	e406                	sd	ra,8(sp)
    80006428:	e022                	sd	s0,0(sp)
    8000642a:	0800                	addi	s0,sp,16
  int hart = cpuid();
    8000642c:	ffffb097          	auipc	ra,0xffffb
    80006430:	6d2080e7          	jalr	1746(ra) # 80001afe <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006434:	0085171b          	slliw	a4,a0,0x8
    80006438:	0c0027b7          	lui	a5,0xc002
    8000643c:	97ba                	add	a5,a5,a4
    8000643e:	40200713          	li	a4,1026
    80006442:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006446:	00d5151b          	slliw	a0,a0,0xd
    8000644a:	0c2017b7          	lui	a5,0xc201
    8000644e:	97aa                	add	a5,a5,a0
    80006450:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80006454:	60a2                	ld	ra,8(sp)
    80006456:	6402                	ld	s0,0(sp)
    80006458:	0141                	addi	sp,sp,16
    8000645a:	8082                	ret

000000008000645c <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    8000645c:	1141                	addi	sp,sp,-16
    8000645e:	e406                	sd	ra,8(sp)
    80006460:	e022                	sd	s0,0(sp)
    80006462:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006464:	ffffb097          	auipc	ra,0xffffb
    80006468:	69a080e7          	jalr	1690(ra) # 80001afe <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    8000646c:	00d5151b          	slliw	a0,a0,0xd
    80006470:	0c2017b7          	lui	a5,0xc201
    80006474:	97aa                	add	a5,a5,a0
  return irq;
}
    80006476:	43c8                	lw	a0,4(a5)
    80006478:	60a2                	ld	ra,8(sp)
    8000647a:	6402                	ld	s0,0(sp)
    8000647c:	0141                	addi	sp,sp,16
    8000647e:	8082                	ret

0000000080006480 <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80006480:	1101                	addi	sp,sp,-32
    80006482:	ec06                	sd	ra,24(sp)
    80006484:	e822                	sd	s0,16(sp)
    80006486:	e426                	sd	s1,8(sp)
    80006488:	1000                	addi	s0,sp,32
    8000648a:	84aa                	mv	s1,a0
  int hart = cpuid();
    8000648c:	ffffb097          	auipc	ra,0xffffb
    80006490:	672080e7          	jalr	1650(ra) # 80001afe <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80006494:	00d5151b          	slliw	a0,a0,0xd
    80006498:	0c2017b7          	lui	a5,0xc201
    8000649c:	97aa                	add	a5,a5,a0
    8000649e:	c3c4                	sw	s1,4(a5)
}
    800064a0:	60e2                	ld	ra,24(sp)
    800064a2:	6442                	ld	s0,16(sp)
    800064a4:	64a2                	ld	s1,8(sp)
    800064a6:	6105                	addi	sp,sp,32
    800064a8:	8082                	ret

00000000800064aa <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800064aa:	1141                	addi	sp,sp,-16
    800064ac:	e406                	sd	ra,8(sp)
    800064ae:	e022                	sd	s0,0(sp)
    800064b0:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800064b2:	479d                	li	a5,7
    800064b4:	04a7cc63          	blt	a5,a0,8000650c <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    800064b8:	00046797          	auipc	a5,0x46
    800064bc:	52878793          	addi	a5,a5,1320 # 8004c9e0 <disk>
    800064c0:	97aa                	add	a5,a5,a0
    800064c2:	0187c783          	lbu	a5,24(a5)
    800064c6:	ebb9                	bnez	a5,8000651c <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    800064c8:	00451693          	slli	a3,a0,0x4
    800064cc:	00046797          	auipc	a5,0x46
    800064d0:	51478793          	addi	a5,a5,1300 # 8004c9e0 <disk>
    800064d4:	6398                	ld	a4,0(a5)
    800064d6:	9736                	add	a4,a4,a3
    800064d8:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    800064dc:	6398                	ld	a4,0(a5)
    800064de:	9736                	add	a4,a4,a3
    800064e0:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    800064e4:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    800064e8:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    800064ec:	97aa                	add	a5,a5,a0
    800064ee:	4705                	li	a4,1
    800064f0:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    800064f4:	00046517          	auipc	a0,0x46
    800064f8:	50450513          	addi	a0,a0,1284 # 8004c9f8 <disk+0x18>
    800064fc:	ffffc097          	auipc	ra,0xffffc
    80006500:	dfc080e7          	jalr	-516(ra) # 800022f8 <wakeup>
}
    80006504:	60a2                	ld	ra,8(sp)
    80006506:	6402                	ld	s0,0(sp)
    80006508:	0141                	addi	sp,sp,16
    8000650a:	8082                	ret
    panic("free_desc 1");
    8000650c:	00002517          	auipc	a0,0x2
    80006510:	2a450513          	addi	a0,a0,676 # 800087b0 <etext+0x7b0>
    80006514:	ffffa097          	auipc	ra,0xffffa
    80006518:	04c080e7          	jalr	76(ra) # 80000560 <panic>
    panic("free_desc 2");
    8000651c:	00002517          	auipc	a0,0x2
    80006520:	2a450513          	addi	a0,a0,676 # 800087c0 <etext+0x7c0>
    80006524:	ffffa097          	auipc	ra,0xffffa
    80006528:	03c080e7          	jalr	60(ra) # 80000560 <panic>

000000008000652c <virtio_disk_init>:
{
    8000652c:	1101                	addi	sp,sp,-32
    8000652e:	ec06                	sd	ra,24(sp)
    80006530:	e822                	sd	s0,16(sp)
    80006532:	e426                	sd	s1,8(sp)
    80006534:	e04a                	sd	s2,0(sp)
    80006536:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006538:	00002597          	auipc	a1,0x2
    8000653c:	29858593          	addi	a1,a1,664 # 800087d0 <etext+0x7d0>
    80006540:	00046517          	auipc	a0,0x46
    80006544:	5c850513          	addi	a0,a0,1480 # 8004cb08 <disk+0x128>
    80006548:	ffffa097          	auipc	ra,0xffffa
    8000654c:	660080e7          	jalr	1632(ra) # 80000ba8 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006550:	100017b7          	lui	a5,0x10001
    80006554:	4398                	lw	a4,0(a5)
    80006556:	2701                	sext.w	a4,a4
    80006558:	747277b7          	lui	a5,0x74727
    8000655c:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80006560:	18f71c63          	bne	a4,a5,800066f8 <virtio_disk_init+0x1cc>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006564:	100017b7          	lui	a5,0x10001
    80006568:	0791                	addi	a5,a5,4 # 10001004 <_entry-0x6fffeffc>
    8000656a:	439c                	lw	a5,0(a5)
    8000656c:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000656e:	4709                	li	a4,2
    80006570:	18e79463          	bne	a5,a4,800066f8 <virtio_disk_init+0x1cc>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006574:	100017b7          	lui	a5,0x10001
    80006578:	07a1                	addi	a5,a5,8 # 10001008 <_entry-0x6fffeff8>
    8000657a:	439c                	lw	a5,0(a5)
    8000657c:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    8000657e:	16e79d63          	bne	a5,a4,800066f8 <virtio_disk_init+0x1cc>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80006582:	100017b7          	lui	a5,0x10001
    80006586:	47d8                	lw	a4,12(a5)
    80006588:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000658a:	554d47b7          	lui	a5,0x554d4
    8000658e:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80006592:	16f71363          	bne	a4,a5,800066f8 <virtio_disk_init+0x1cc>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006596:	100017b7          	lui	a5,0x10001
    8000659a:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000659e:	4705                	li	a4,1
    800065a0:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800065a2:	470d                	li	a4,3
    800065a4:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800065a6:	10001737          	lui	a4,0x10001
    800065aa:	4b14                	lw	a3,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800065ac:	c7ffe737          	lui	a4,0xc7ffe
    800065b0:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fb1c3f>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800065b4:	8ef9                	and	a3,a3,a4
    800065b6:	10001737          	lui	a4,0x10001
    800065ba:	d314                	sw	a3,32(a4)
  *R(VIRTIO_MMIO_STATUS) = status;
    800065bc:	472d                	li	a4,11
    800065be:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800065c0:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    800065c4:	439c                	lw	a5,0(a5)
    800065c6:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    800065ca:	8ba1                	andi	a5,a5,8
    800065cc:	12078e63          	beqz	a5,80006708 <virtio_disk_init+0x1dc>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800065d0:	100017b7          	lui	a5,0x10001
    800065d4:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    800065d8:	100017b7          	lui	a5,0x10001
    800065dc:	04478793          	addi	a5,a5,68 # 10001044 <_entry-0x6fffefbc>
    800065e0:	439c                	lw	a5,0(a5)
    800065e2:	2781                	sext.w	a5,a5
    800065e4:	12079a63          	bnez	a5,80006718 <virtio_disk_init+0x1ec>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800065e8:	100017b7          	lui	a5,0x10001
    800065ec:	03478793          	addi	a5,a5,52 # 10001034 <_entry-0x6fffefcc>
    800065f0:	439c                	lw	a5,0(a5)
    800065f2:	2781                	sext.w	a5,a5
  if(max == 0)
    800065f4:	12078a63          	beqz	a5,80006728 <virtio_disk_init+0x1fc>
  if(max < NUM)
    800065f8:	471d                	li	a4,7
    800065fa:	12f77f63          	bgeu	a4,a5,80006738 <virtio_disk_init+0x20c>
  disk.desc = kalloc();
    800065fe:	ffffa097          	auipc	ra,0xffffa
    80006602:	54a080e7          	jalr	1354(ra) # 80000b48 <kalloc>
    80006606:	00046497          	auipc	s1,0x46
    8000660a:	3da48493          	addi	s1,s1,986 # 8004c9e0 <disk>
    8000660e:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80006610:	ffffa097          	auipc	ra,0xffffa
    80006614:	538080e7          	jalr	1336(ra) # 80000b48 <kalloc>
    80006618:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000661a:	ffffa097          	auipc	ra,0xffffa
    8000661e:	52e080e7          	jalr	1326(ra) # 80000b48 <kalloc>
    80006622:	87aa                	mv	a5,a0
    80006624:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80006626:	6088                	ld	a0,0(s1)
    80006628:	12050063          	beqz	a0,80006748 <virtio_disk_init+0x21c>
    8000662c:	00046717          	auipc	a4,0x46
    80006630:	3bc73703          	ld	a4,956(a4) # 8004c9e8 <disk+0x8>
    80006634:	10070a63          	beqz	a4,80006748 <virtio_disk_init+0x21c>
    80006638:	10078863          	beqz	a5,80006748 <virtio_disk_init+0x21c>
  memset(disk.desc, 0, PGSIZE);
    8000663c:	6605                	lui	a2,0x1
    8000663e:	4581                	li	a1,0
    80006640:	ffffa097          	auipc	ra,0xffffa
    80006644:	6f4080e7          	jalr	1780(ra) # 80000d34 <memset>
  memset(disk.avail, 0, PGSIZE);
    80006648:	00046497          	auipc	s1,0x46
    8000664c:	39848493          	addi	s1,s1,920 # 8004c9e0 <disk>
    80006650:	6605                	lui	a2,0x1
    80006652:	4581                	li	a1,0
    80006654:	6488                	ld	a0,8(s1)
    80006656:	ffffa097          	auipc	ra,0xffffa
    8000665a:	6de080e7          	jalr	1758(ra) # 80000d34 <memset>
  memset(disk.used, 0, PGSIZE);
    8000665e:	6605                	lui	a2,0x1
    80006660:	4581                	li	a1,0
    80006662:	6888                	ld	a0,16(s1)
    80006664:	ffffa097          	auipc	ra,0xffffa
    80006668:	6d0080e7          	jalr	1744(ra) # 80000d34 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    8000666c:	100017b7          	lui	a5,0x10001
    80006670:	4721                	li	a4,8
    80006672:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80006674:	4098                	lw	a4,0(s1)
    80006676:	100017b7          	lui	a5,0x10001
    8000667a:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    8000667e:	40d8                	lw	a4,4(s1)
    80006680:	100017b7          	lui	a5,0x10001
    80006684:	08e7a223          	sw	a4,132(a5) # 10001084 <_entry-0x6fffef7c>
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80006688:	649c                	ld	a5,8(s1)
    8000668a:	0007869b          	sext.w	a3,a5
    8000668e:	10001737          	lui	a4,0x10001
    80006692:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80006696:	9781                	srai	a5,a5,0x20
    80006698:	10001737          	lui	a4,0x10001
    8000669c:	08f72a23          	sw	a5,148(a4) # 10001094 <_entry-0x6fffef6c>
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    800066a0:	689c                	ld	a5,16(s1)
    800066a2:	0007869b          	sext.w	a3,a5
    800066a6:	10001737          	lui	a4,0x10001
    800066aa:	0ad72023          	sw	a3,160(a4) # 100010a0 <_entry-0x6fffef60>
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    800066ae:	9781                	srai	a5,a5,0x20
    800066b0:	10001737          	lui	a4,0x10001
    800066b4:	0af72223          	sw	a5,164(a4) # 100010a4 <_entry-0x6fffef5c>
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    800066b8:	10001737          	lui	a4,0x10001
    800066bc:	4785                	li	a5,1
    800066be:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    800066c0:	00f48c23          	sb	a5,24(s1)
    800066c4:	00f48ca3          	sb	a5,25(s1)
    800066c8:	00f48d23          	sb	a5,26(s1)
    800066cc:	00f48da3          	sb	a5,27(s1)
    800066d0:	00f48e23          	sb	a5,28(s1)
    800066d4:	00f48ea3          	sb	a5,29(s1)
    800066d8:	00f48f23          	sb	a5,30(s1)
    800066dc:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    800066e0:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    800066e4:	100017b7          	lui	a5,0x10001
    800066e8:	0727a823          	sw	s2,112(a5) # 10001070 <_entry-0x6fffef90>
}
    800066ec:	60e2                	ld	ra,24(sp)
    800066ee:	6442                	ld	s0,16(sp)
    800066f0:	64a2                	ld	s1,8(sp)
    800066f2:	6902                	ld	s2,0(sp)
    800066f4:	6105                	addi	sp,sp,32
    800066f6:	8082                	ret
    panic("could not find virtio disk");
    800066f8:	00002517          	auipc	a0,0x2
    800066fc:	0e850513          	addi	a0,a0,232 # 800087e0 <etext+0x7e0>
    80006700:	ffffa097          	auipc	ra,0xffffa
    80006704:	e60080e7          	jalr	-416(ra) # 80000560 <panic>
    panic("virtio disk FEATURES_OK unset");
    80006708:	00002517          	auipc	a0,0x2
    8000670c:	0f850513          	addi	a0,a0,248 # 80008800 <etext+0x800>
    80006710:	ffffa097          	auipc	ra,0xffffa
    80006714:	e50080e7          	jalr	-432(ra) # 80000560 <panic>
    panic("virtio disk should not be ready");
    80006718:	00002517          	auipc	a0,0x2
    8000671c:	10850513          	addi	a0,a0,264 # 80008820 <etext+0x820>
    80006720:	ffffa097          	auipc	ra,0xffffa
    80006724:	e40080e7          	jalr	-448(ra) # 80000560 <panic>
    panic("virtio disk has no queue 0");
    80006728:	00002517          	auipc	a0,0x2
    8000672c:	11850513          	addi	a0,a0,280 # 80008840 <etext+0x840>
    80006730:	ffffa097          	auipc	ra,0xffffa
    80006734:	e30080e7          	jalr	-464(ra) # 80000560 <panic>
    panic("virtio disk max queue too short");
    80006738:	00002517          	auipc	a0,0x2
    8000673c:	12850513          	addi	a0,a0,296 # 80008860 <etext+0x860>
    80006740:	ffffa097          	auipc	ra,0xffffa
    80006744:	e20080e7          	jalr	-480(ra) # 80000560 <panic>
    panic("virtio disk kalloc");
    80006748:	00002517          	auipc	a0,0x2
    8000674c:	13850513          	addi	a0,a0,312 # 80008880 <etext+0x880>
    80006750:	ffffa097          	auipc	ra,0xffffa
    80006754:	e10080e7          	jalr	-496(ra) # 80000560 <panic>

0000000080006758 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006758:	7159                	addi	sp,sp,-112
    8000675a:	f486                	sd	ra,104(sp)
    8000675c:	f0a2                	sd	s0,96(sp)
    8000675e:	eca6                	sd	s1,88(sp)
    80006760:	e8ca                	sd	s2,80(sp)
    80006762:	e4ce                	sd	s3,72(sp)
    80006764:	e0d2                	sd	s4,64(sp)
    80006766:	fc56                	sd	s5,56(sp)
    80006768:	f85a                	sd	s6,48(sp)
    8000676a:	f45e                	sd	s7,40(sp)
    8000676c:	f062                	sd	s8,32(sp)
    8000676e:	ec66                	sd	s9,24(sp)
    80006770:	1880                	addi	s0,sp,112
    80006772:	8a2a                	mv	s4,a0
    80006774:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006776:	00c52c83          	lw	s9,12(a0)
    8000677a:	001c9c9b          	slliw	s9,s9,0x1
    8000677e:	1c82                	slli	s9,s9,0x20
    80006780:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80006784:	00046517          	auipc	a0,0x46
    80006788:	38450513          	addi	a0,a0,900 # 8004cb08 <disk+0x128>
    8000678c:	ffffa097          	auipc	ra,0xffffa
    80006790:	4ac080e7          	jalr	1196(ra) # 80000c38 <acquire>
  for(int i = 0; i < 3; i++){
    80006794:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006796:	44a1                	li	s1,8
      disk.free[i] = 0;
    80006798:	00046b17          	auipc	s6,0x46
    8000679c:	248b0b13          	addi	s6,s6,584 # 8004c9e0 <disk>
  for(int i = 0; i < 3; i++){
    800067a0:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800067a2:	00046c17          	auipc	s8,0x46
    800067a6:	366c0c13          	addi	s8,s8,870 # 8004cb08 <disk+0x128>
    800067aa:	a0ad                	j	80006814 <virtio_disk_rw+0xbc>
      disk.free[i] = 0;
    800067ac:	00fb0733          	add	a4,s6,a5
    800067b0:	00070c23          	sb	zero,24(a4) # 10001018 <_entry-0x6fffefe8>
    idx[i] = alloc_desc();
    800067b4:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    800067b6:	0207c563          	bltz	a5,800067e0 <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    800067ba:	2905                	addiw	s2,s2,1
    800067bc:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    800067be:	05590f63          	beq	s2,s5,8000681c <virtio_disk_rw+0xc4>
    idx[i] = alloc_desc();
    800067c2:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    800067c4:	00046717          	auipc	a4,0x46
    800067c8:	21c70713          	addi	a4,a4,540 # 8004c9e0 <disk>
    800067cc:	87ce                	mv	a5,s3
    if(disk.free[i]){
    800067ce:	01874683          	lbu	a3,24(a4)
    800067d2:	fee9                	bnez	a3,800067ac <virtio_disk_rw+0x54>
  for(int i = 0; i < NUM; i++){
    800067d4:	2785                	addiw	a5,a5,1
    800067d6:	0705                	addi	a4,a4,1
    800067d8:	fe979be3          	bne	a5,s1,800067ce <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    800067dc:	57fd                	li	a5,-1
    800067de:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    800067e0:	03205163          	blez	s2,80006802 <virtio_disk_rw+0xaa>
        free_desc(idx[j]);
    800067e4:	f9042503          	lw	a0,-112(s0)
    800067e8:	00000097          	auipc	ra,0x0
    800067ec:	cc2080e7          	jalr	-830(ra) # 800064aa <free_desc>
      for(int j = 0; j < i; j++)
    800067f0:	4785                	li	a5,1
    800067f2:	0127d863          	bge	a5,s2,80006802 <virtio_disk_rw+0xaa>
        free_desc(idx[j]);
    800067f6:	f9442503          	lw	a0,-108(s0)
    800067fa:	00000097          	auipc	ra,0x0
    800067fe:	cb0080e7          	jalr	-848(ra) # 800064aa <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006802:	85e2                	mv	a1,s8
    80006804:	00046517          	auipc	a0,0x46
    80006808:	1f450513          	addi	a0,a0,500 # 8004c9f8 <disk+0x18>
    8000680c:	ffffc097          	auipc	ra,0xffffc
    80006810:	a88080e7          	jalr	-1400(ra) # 80002294 <sleep>
  for(int i = 0; i < 3; i++){
    80006814:	f9040613          	addi	a2,s0,-112
    80006818:	894e                	mv	s2,s3
    8000681a:	b765                	j	800067c2 <virtio_disk_rw+0x6a>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000681c:	f9042503          	lw	a0,-112(s0)
    80006820:	00451693          	slli	a3,a0,0x4

  if(write)
    80006824:	00046797          	auipc	a5,0x46
    80006828:	1bc78793          	addi	a5,a5,444 # 8004c9e0 <disk>
    8000682c:	00a50713          	addi	a4,a0,10
    80006830:	0712                	slli	a4,a4,0x4
    80006832:	973e                	add	a4,a4,a5
    80006834:	01703633          	snez	a2,s7
    80006838:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    8000683a:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    8000683e:	01973823          	sd	s9,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80006842:	6398                	ld	a4,0(a5)
    80006844:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006846:	0a868613          	addi	a2,a3,168
    8000684a:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    8000684c:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    8000684e:	6390                	ld	a2,0(a5)
    80006850:	00d605b3          	add	a1,a2,a3
    80006854:	4741                	li	a4,16
    80006856:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006858:	4805                	li	a6,1
    8000685a:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    8000685e:	f9442703          	lw	a4,-108(s0)
    80006862:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80006866:	0712                	slli	a4,a4,0x4
    80006868:	963a                	add	a2,a2,a4
    8000686a:	058a0593          	addi	a1,s4,88
    8000686e:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80006870:	0007b883          	ld	a7,0(a5)
    80006874:	9746                	add	a4,a4,a7
    80006876:	40000613          	li	a2,1024
    8000687a:	c710                	sw	a2,8(a4)
  if(write)
    8000687c:	001bb613          	seqz	a2,s7
    80006880:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80006884:	00166613          	ori	a2,a2,1
    80006888:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    8000688c:	f9842583          	lw	a1,-104(s0)
    80006890:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006894:	00250613          	addi	a2,a0,2
    80006898:	0612                	slli	a2,a2,0x4
    8000689a:	963e                	add	a2,a2,a5
    8000689c:	577d                	li	a4,-1
    8000689e:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800068a2:	0592                	slli	a1,a1,0x4
    800068a4:	98ae                	add	a7,a7,a1
    800068a6:	03068713          	addi	a4,a3,48
    800068aa:	973e                	add	a4,a4,a5
    800068ac:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    800068b0:	6398                	ld	a4,0(a5)
    800068b2:	972e                	add	a4,a4,a1
    800068b4:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800068b8:	4689                	li	a3,2
    800068ba:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    800068be:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800068c2:	010a2223          	sw	a6,4(s4)
  disk.info[idx[0]].b = b;
    800068c6:	01463423          	sd	s4,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800068ca:	6794                	ld	a3,8(a5)
    800068cc:	0026d703          	lhu	a4,2(a3)
    800068d0:	8b1d                	andi	a4,a4,7
    800068d2:	0706                	slli	a4,a4,0x1
    800068d4:	96ba                	add	a3,a3,a4
    800068d6:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    800068da:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    800068de:	6798                	ld	a4,8(a5)
    800068e0:	00275783          	lhu	a5,2(a4)
    800068e4:	2785                	addiw	a5,a5,1
    800068e6:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    800068ea:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800068ee:	100017b7          	lui	a5,0x10001
    800068f2:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800068f6:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    800068fa:	00046917          	auipc	s2,0x46
    800068fe:	20e90913          	addi	s2,s2,526 # 8004cb08 <disk+0x128>
  while(b->disk == 1) {
    80006902:	4485                	li	s1,1
    80006904:	01079c63          	bne	a5,a6,8000691c <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    80006908:	85ca                	mv	a1,s2
    8000690a:	8552                	mv	a0,s4
    8000690c:	ffffc097          	auipc	ra,0xffffc
    80006910:	988080e7          	jalr	-1656(ra) # 80002294 <sleep>
  while(b->disk == 1) {
    80006914:	004a2783          	lw	a5,4(s4)
    80006918:	fe9788e3          	beq	a5,s1,80006908 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    8000691c:	f9042903          	lw	s2,-112(s0)
    80006920:	00290713          	addi	a4,s2,2
    80006924:	0712                	slli	a4,a4,0x4
    80006926:	00046797          	auipc	a5,0x46
    8000692a:	0ba78793          	addi	a5,a5,186 # 8004c9e0 <disk>
    8000692e:	97ba                	add	a5,a5,a4
    80006930:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80006934:	00046997          	auipc	s3,0x46
    80006938:	0ac98993          	addi	s3,s3,172 # 8004c9e0 <disk>
    8000693c:	00491713          	slli	a4,s2,0x4
    80006940:	0009b783          	ld	a5,0(s3)
    80006944:	97ba                	add	a5,a5,a4
    80006946:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    8000694a:	854a                	mv	a0,s2
    8000694c:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80006950:	00000097          	auipc	ra,0x0
    80006954:	b5a080e7          	jalr	-1190(ra) # 800064aa <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80006958:	8885                	andi	s1,s1,1
    8000695a:	f0ed                	bnez	s1,8000693c <virtio_disk_rw+0x1e4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000695c:	00046517          	auipc	a0,0x46
    80006960:	1ac50513          	addi	a0,a0,428 # 8004cb08 <disk+0x128>
    80006964:	ffffa097          	auipc	ra,0xffffa
    80006968:	388080e7          	jalr	904(ra) # 80000cec <release>
}
    8000696c:	70a6                	ld	ra,104(sp)
    8000696e:	7406                	ld	s0,96(sp)
    80006970:	64e6                	ld	s1,88(sp)
    80006972:	6946                	ld	s2,80(sp)
    80006974:	69a6                	ld	s3,72(sp)
    80006976:	6a06                	ld	s4,64(sp)
    80006978:	7ae2                	ld	s5,56(sp)
    8000697a:	7b42                	ld	s6,48(sp)
    8000697c:	7ba2                	ld	s7,40(sp)
    8000697e:	7c02                	ld	s8,32(sp)
    80006980:	6ce2                	ld	s9,24(sp)
    80006982:	6165                	addi	sp,sp,112
    80006984:	8082                	ret

0000000080006986 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006986:	1101                	addi	sp,sp,-32
    80006988:	ec06                	sd	ra,24(sp)
    8000698a:	e822                	sd	s0,16(sp)
    8000698c:	e426                	sd	s1,8(sp)
    8000698e:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006990:	00046497          	auipc	s1,0x46
    80006994:	05048493          	addi	s1,s1,80 # 8004c9e0 <disk>
    80006998:	00046517          	auipc	a0,0x46
    8000699c:	17050513          	addi	a0,a0,368 # 8004cb08 <disk+0x128>
    800069a0:	ffffa097          	auipc	ra,0xffffa
    800069a4:	298080e7          	jalr	664(ra) # 80000c38 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800069a8:	100017b7          	lui	a5,0x10001
    800069ac:	53b8                	lw	a4,96(a5)
    800069ae:	8b0d                	andi	a4,a4,3
    800069b0:	100017b7          	lui	a5,0x10001
    800069b4:	d3f8                	sw	a4,100(a5)

  __sync_synchronize();
    800069b6:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800069ba:	689c                	ld	a5,16(s1)
    800069bc:	0204d703          	lhu	a4,32(s1)
    800069c0:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    800069c4:	04f70863          	beq	a4,a5,80006a14 <virtio_disk_intr+0x8e>
    __sync_synchronize();
    800069c8:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800069cc:	6898                	ld	a4,16(s1)
    800069ce:	0204d783          	lhu	a5,32(s1)
    800069d2:	8b9d                	andi	a5,a5,7
    800069d4:	078e                	slli	a5,a5,0x3
    800069d6:	97ba                	add	a5,a5,a4
    800069d8:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800069da:	00278713          	addi	a4,a5,2
    800069de:	0712                	slli	a4,a4,0x4
    800069e0:	9726                	add	a4,a4,s1
    800069e2:	01074703          	lbu	a4,16(a4)
    800069e6:	e721                	bnez	a4,80006a2e <virtio_disk_intr+0xa8>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    800069e8:	0789                	addi	a5,a5,2
    800069ea:	0792                	slli	a5,a5,0x4
    800069ec:	97a6                	add	a5,a5,s1
    800069ee:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    800069f0:	00052223          	sw	zero,4(a0)
    wakeup(b);
    800069f4:	ffffc097          	auipc	ra,0xffffc
    800069f8:	904080e7          	jalr	-1788(ra) # 800022f8 <wakeup>

    disk.used_idx += 1;
    800069fc:	0204d783          	lhu	a5,32(s1)
    80006a00:	2785                	addiw	a5,a5,1
    80006a02:	17c2                	slli	a5,a5,0x30
    80006a04:	93c1                	srli	a5,a5,0x30
    80006a06:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006a0a:	6898                	ld	a4,16(s1)
    80006a0c:	00275703          	lhu	a4,2(a4)
    80006a10:	faf71ce3          	bne	a4,a5,800069c8 <virtio_disk_intr+0x42>
  }

  release(&disk.vdisk_lock);
    80006a14:	00046517          	auipc	a0,0x46
    80006a18:	0f450513          	addi	a0,a0,244 # 8004cb08 <disk+0x128>
    80006a1c:	ffffa097          	auipc	ra,0xffffa
    80006a20:	2d0080e7          	jalr	720(ra) # 80000cec <release>
}
    80006a24:	60e2                	ld	ra,24(sp)
    80006a26:	6442                	ld	s0,16(sp)
    80006a28:	64a2                	ld	s1,8(sp)
    80006a2a:	6105                	addi	sp,sp,32
    80006a2c:	8082                	ret
      panic("virtio_disk_intr status");
    80006a2e:	00002517          	auipc	a0,0x2
    80006a32:	e6a50513          	addi	a0,a0,-406 # 80008898 <etext+0x898>
    80006a36:	ffffa097          	auipc	ra,0xffffa
    80006a3a:	b2a080e7          	jalr	-1238(ra) # 80000560 <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051073          	csrw	sscratch,a0
    80007004:	02000537          	lui	a0,0x2000
    80007008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000700a:	0536                	slli	a0,a0,0xd
    8000700c:	02153423          	sd	ra,40(a0)
    80007010:	02253823          	sd	sp,48(a0)
    80007014:	02353c23          	sd	gp,56(a0)
    80007018:	04453023          	sd	tp,64(a0)
    8000701c:	04553423          	sd	t0,72(a0)
    80007020:	04653823          	sd	t1,80(a0)
    80007024:	04753c23          	sd	t2,88(a0)
    80007028:	f120                	sd	s0,96(a0)
    8000702a:	f524                	sd	s1,104(a0)
    8000702c:	fd2c                	sd	a1,120(a0)
    8000702e:	e150                	sd	a2,128(a0)
    80007030:	e554                	sd	a3,136(a0)
    80007032:	e958                	sd	a4,144(a0)
    80007034:	ed5c                	sd	a5,152(a0)
    80007036:	0b053023          	sd	a6,160(a0)
    8000703a:	0b153423          	sd	a7,168(a0)
    8000703e:	0b253823          	sd	s2,176(a0)
    80007042:	0b353c23          	sd	s3,184(a0)
    80007046:	0d453023          	sd	s4,192(a0)
    8000704a:	0d553423          	sd	s5,200(a0)
    8000704e:	0d653823          	sd	s6,208(a0)
    80007052:	0d753c23          	sd	s7,216(a0)
    80007056:	0f853023          	sd	s8,224(a0)
    8000705a:	0f953423          	sd	s9,232(a0)
    8000705e:	0fa53823          	sd	s10,240(a0)
    80007062:	0fb53c23          	sd	s11,248(a0)
    80007066:	11c53023          	sd	t3,256(a0)
    8000706a:	11d53423          	sd	t4,264(a0)
    8000706e:	11e53823          	sd	t5,272(a0)
    80007072:	11f53c23          	sd	t6,280(a0)
    80007076:	140022f3          	csrr	t0,sscratch
    8000707a:	06553823          	sd	t0,112(a0)
    8000707e:	00853103          	ld	sp,8(a0)
    80007082:	02053203          	ld	tp,32(a0)
    80007086:	01053283          	ld	t0,16(a0)
    8000708a:	00053303          	ld	t1,0(a0)
    8000708e:	12000073          	sfence.vma
    80007092:	18031073          	csrw	satp,t1
    80007096:	12000073          	sfence.vma
    8000709a:	8282                	jr	t0

000000008000709c <userret>:
    8000709c:	12000073          	sfence.vma
    800070a0:	18051073          	csrw	satp,a0
    800070a4:	12000073          	sfence.vma
    800070a8:	02000537          	lui	a0,0x2000
    800070ac:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800070ae:	0536                	slli	a0,a0,0xd
    800070b0:	02853083          	ld	ra,40(a0)
    800070b4:	03053103          	ld	sp,48(a0)
    800070b8:	03853183          	ld	gp,56(a0)
    800070bc:	04053203          	ld	tp,64(a0)
    800070c0:	04853283          	ld	t0,72(a0)
    800070c4:	05053303          	ld	t1,80(a0)
    800070c8:	05853383          	ld	t2,88(a0)
    800070cc:	7120                	ld	s0,96(a0)
    800070ce:	7524                	ld	s1,104(a0)
    800070d0:	7d2c                	ld	a1,120(a0)
    800070d2:	6150                	ld	a2,128(a0)
    800070d4:	6554                	ld	a3,136(a0)
    800070d6:	6958                	ld	a4,144(a0)
    800070d8:	6d5c                	ld	a5,152(a0)
    800070da:	0a053803          	ld	a6,160(a0)
    800070de:	0a853883          	ld	a7,168(a0)
    800070e2:	0b053903          	ld	s2,176(a0)
    800070e6:	0b853983          	ld	s3,184(a0)
    800070ea:	0c053a03          	ld	s4,192(a0)
    800070ee:	0c853a83          	ld	s5,200(a0)
    800070f2:	0d053b03          	ld	s6,208(a0)
    800070f6:	0d853b83          	ld	s7,216(a0)
    800070fa:	0e053c03          	ld	s8,224(a0)
    800070fe:	0e853c83          	ld	s9,232(a0)
    80007102:	0f053d03          	ld	s10,240(a0)
    80007106:	0f853d83          	ld	s11,248(a0)
    8000710a:	10053e03          	ld	t3,256(a0)
    8000710e:	10853e83          	ld	t4,264(a0)
    80007112:	11053f03          	ld	t5,272(a0)
    80007116:	11853f83          	ld	t6,280(a0)
    8000711a:	7928                	ld	a0,112(a0)
    8000711c:	10200073          	sret
	...
