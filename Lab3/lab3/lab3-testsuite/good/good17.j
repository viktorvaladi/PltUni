.class public good17
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

  invokestatic good17/main()I
  pop
  return

.end method

.method public static main()I
.limit locals 101
.limit stack 101
	ldc 6
	istore 0
	iload 0
	pop
	iload 0
	ldc 7
	iadd
	istore 1
	iload 1
	pop
	iload 1
	invokestatic Runtime/printInt(I)V
	iconst_4
	istore 2
	iload 2
	pop
	iload 2
	invokestatic Runtime/printInt(I)V
	iload 2
	istore 0
	iload 0
	pop
	iload 0
	invokestatic Runtime/printInt(I)V
	iload 0
	invokestatic Runtime/printInt(I)V
	iload 1
	invokestatic Runtime/printInt(I)V
	iconst_0
	ireturn
.end method
