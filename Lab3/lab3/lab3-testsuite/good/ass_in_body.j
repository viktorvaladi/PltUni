.class public ass_in_body
.super java/lang/Object

.method public <init>()V
  .limit locals 1

  aload_0
  invokespecial java/lang/Object/<init>()V
  return

.end method

.method public static main([Ljava/lang/String;)V
  .limit locals 1
  .limit stack  1

  invokestatic ass_in_body/main()I
  pop
  return

.end method

.method public static f(I)I
.limit locals 101
.limit stack 101
	ldc 7
	istore 0
	iload 0
	pop
	iload 0
	ireturn
nop
.end method
.method public static main()I
.limit locals 101
.limit stack 101
	iconst_5
	invokestatic ass_in_body/f(I)I
	invokestatic Runtime/printInt(I)V
	iconst_0
	ireturn
nop
.end method
