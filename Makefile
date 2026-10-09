# Makefile for FitnessScript (.fit)

CC = gcc
LEX = flex
YACC = bison
CFLAGS = -Wall -g

TARGET = fitness

all: $(TARGET)

$(TARGET): lex.yy.c fitness.tab.c
	$(CC) $(CFLAGS) lex.yy.c fitness.tab.c -o $(TARGET)

fitness.tab.c fitness.tab.h: fitness.y
	$(YACC) -d fitness.y

lex.yy.c: fitness.l fitness.tab.h
	$(LEX) fitness.l

run: $(TARGET)
	./$(TARGET) sample.fit

run-error: $(TARGET)
	./$(TARGET) error_sample.fit

clean:
	rm -f lex.yy.c fitness.tab.c fitness.tab.h $(TARGET) $(TARGET).exe

.PHONY: all run run-error clean
