.class public identifiers_case_sensitive
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

  invokestatic identifiers_case_sensitive/main()I
  pop
  return

.end method

.method public static printint(I)V
.limit locals 101
.limit stack 101
	iconst_100
	iload 0
	iadd
	invokestatic Runtime/printInt(I)V

.end method

.method public static printdouble()V
.limit locals 101
.limit stack 101
	dconst_99.0
	iload 0
	iadd
	invokestatic Runtime/printDouble(D)V

.end method

.method public static readint()I
.limit locals 101
.limit stack 101
	iconst_0
	ireturn

.end method

.method public static readdouble()
.limit locals 101
.limit stack 101
	dconst_1.0
	ireturn

.end method

.method public static main()I
.limit locals 101
.limit stack 101
	istore 0
	istore 1
	iload 0
	pop
	iload 1
	pop
	iconst_0
	ireturn

.end method

